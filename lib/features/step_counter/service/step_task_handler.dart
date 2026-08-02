import 'dart:async';

import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer/pedometer.dart';
import '../../../core/diagnostics/step_diagnostic_event.dart';
import '../../../core/diagnostics/step_diagnostic_logger.dart';

import '../data/step_local_store.dart';
import '../data/step_snapshot.dart';
import '../domain/step_validation_policy.dart';
import '../domain/step_validation_session.dart';
import '../domain/tracking_activity.dart';
import '../step_diagnostics.dart';
import 'final_snapshot_persistence.dart';

final class StepTaskHandler extends TaskHandler {
  StepTaskHandler({this.validationPolicy = const StepValidationPolicy()}) {
    logStepDiagnostic(
      '[STEP_SERVICE_CREATE] timestamp=${DateTime.now().toIso8601String()} '
      'tracking=false subscriptions=false windowActive=false',
    );
  }

  final StepValidationPolicy validationPolicy;

  static const Duration _notificationThrottleDuration = Duration(
    milliseconds: 750,
  );

  StepLocalStore? _store;
  StepValidationSession? _session;
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<Activity>? _activitySubscription;
  Timer? _validationTimer;
  Timer? _notificationTimer;

  Future<void> _writeChain = Future<void>.value();
  final FinalSnapshotPersistence _finalPersistence = FinalSnapshotPersistence();

  bool _isTracking = false;
  bool _isStopping = false;
  TrackingActivity _activity = TrackingActivity.unknown;
  TrackingConfidence _confidence = TrackingConfidence.low;
  DateTime? _startedAt;
  String? _error;
  String? _stopReason;
  String? _lastNotificationText;
  String? _pendingNotificationText;
  DateTime? _lastNotificationUpdateAt;
  StepDiagnosticLogger? _diagnostics;
  int _windowId = 0;
  int _samplingCallbackSequence = 0;
  int? _latestEvidenceElapsedMs;
  int? _latestEvidenceWindowId;
  int? _latestEvidenceBucketIndex;
  final Map<int, List<Map<String, Object?>>> _bucketSamplingHistory = {};
  int? _windowStartedElapsedMs;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    logStepDiagnostic(
      '[STEP_SERVICE_START] timestamp=${timestamp.toIso8601String()} '
      'tracking=$_isTracking '
      'subscriptions=${_stepSubscription != null || _activitySubscription != null} '
      'windowActive=${_session?.hasActiveWindow ?? false}',
    );
    try {
      final directoryPath = await FlutterForegroundTask.getData<String>(
        key: StepLocalStore.taskHivePathKey,
      );

      if (directoryPath == null || directoryPath.isEmpty) {
        throw StateError('Hive path was not provided to the service.');
      }
      final diagnosticId = await FlutterForegroundTask.getData<String>(
        key: StepLocalStore.taskDiagnosticSessionIdKey,
      );
      if (diagnosticId != null) {
        final diagnosticStartElapsedMs =
            await FlutterForegroundTask.getData<int>(
              key: StepLocalStore.taskDiagnosticSessionStartElapsedMsKey,
            );
        _diagnostics = await StepDiagnosticLogger.create(
          supportPath: directoryPath,
          source: 'background',
          sessionId: diagnosticId,
          sessionStartedElapsedRealtimeMs: diagnosticStartElapsedMs,
        );
      }
      _diagnostics?.record(
        StepDiagnosticEventType.serviceStart,
        payload: {'starter': starter.name},
      );

      _store = StepLocalStore(directoryPath: directoryPath);
      final previousSnapshot = await _store!.readSnapshot(
        reason: 'serviceStart',
      );
      _diagnostics?.record(
        StepDiagnosticEventType.hiveRead,
        payload: _snapshotPayload(previousSnapshot, 'serviceStart'),
      );

      // Only confirmed durable state is recovered. Baseline, buckets, and
      // provisional steps always start empty.
      _session = StepValidationSession(
        confirmedSteps: previousSnapshot.confirmedSteps,
        policy: validationPolicy,
      );
      _isTracking = true;
      _isStopping = false;
      _activity = TrackingActivity.unknown;
      _confidence = TrackingConfidence.low;
      _startedAt = timestamp;
      _error = null;
      _stopReason = null;

      _subscribeToActivity();
      _subscribeToPedometer();
      _publish(reason: 'serviceStarted', persist: true);
    } catch (error) {
      _diagnostics?.record(
        StepDiagnosticEventType.serviceError,
        payload: {'errorType': error.runtimeType.toString()},
        flush: true,
      );
      _error = 'Service initialization failed: $error';
      _isTracking = false;
      _stopReason = 'initialization_error';

      await _persistFinalSnapshot();
      await FlutterForegroundTask.stopService();
    }
  }

  void _subscribeToPedometer() {
    _diagnostics?.record(StepDiagnosticEventType.pedometerSubscribe);
    logStepDiagnostic(
      '[STEP_SENSOR_SUBSCRIBE] timestamp=${DateTime.now().toIso8601String()} '
      'alreadySubscribed=${_stepSubscription != null}',
    );
    _stepSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
      cancelOnError: false,
    );
  }

  void _subscribeToActivity() {
    _diagnostics?.record(StepDiagnosticEventType.samplingSubscribeRequest);
    logStepDiagnostic(
      '[STEP_ACTIVITY_SUBSCRIBE] timestamp=${DateTime.now().toIso8601String()} '
      'alreadySubscribed=${_activitySubscription != null}',
    );
    _activitySubscription = FlutterActivityRecognition.instance.activityStream
        .listen(
          _onActivityChanged,
          onError: _onActivityError,
          onDone: () => _diagnostics?.record(
            StepDiagnosticEventType.samplingStreamDone,
            flush: true,
          ),
          cancelOnError: false,
        );
    _diagnostics?.record(StepDiagnosticEventType.samplingSubscribeSuccess);
  }

  void _onStepCount(StepCount event) {
    final session = _session;
    final now = DateTime.now();
    final previousRawSteps = session?.lastRawSteps;
    final delta = previousRawSteps == null
        ? null
        : event.steps - previousRawSteps;
    final callbackElapsedMs = _diagnostics?.nowElapsedMs;
    final provisionalBefore = session?.provisionalSteps ?? 0;

    if (!_isTracking || _isStopping || session == null) {
      logStepDiagnostic(
        '[STEP_SENSOR] raw=${event.steps} '
        'previous=${previousRawSteps ?? 'none'} delta=${delta ?? 'none'} '
        'timestamp=${now.toIso8601String()} result=ignoredNotTracking',
      );
      _diagnostics?.record(
        StepDiagnosticEventType.pedometerCallback,
        payload: {
          'pedometerCallbackReceivedElapsedRealtimeMs': callbackElapsedMs,
          'pedometerCallbackReceivedWallClockUtc': now
              .toUtc()
              .toIso8601String(),
          'sensorEventElapsedRealtimeMs': null,
          'sensorEventTimestampAvailable': false,
          'sensorCumulativeValue': event.steps,
          'previousSensorCumulativeValue': previousRawSteps,
          'calculatedDelta': delta,
          'rawDeltaAccepted': false,
          'rawDeltaRejectionReason': 'OUT_OF_ACTIVE_SESSION',
          'provisionalBefore': provisionalBefore,
          'provisionalAfter': provisionalBefore,
        },
      );
      return;
    }

    _completeExpiredWindowIfNeeded(now);

    final update = session.recordRawReading(
      cumulativeRawSteps: event.steps,
      timestamp: now,
    );
    final rejectionReason = switch (update.status) {
      RawStepStatus.baselineEstablished => 'BASELINE_ONLY',
      RawStepStatus.provisionalAdded => null,
      RawStepStatus.ignored when delta != null && delta <= 0 =>
        'NON_POSITIVE_DELTA',
      RawStepStatus.ignored
          when delta != null && delta > validationPolicy.maxRawDeltaPerEvent =>
        'DELTA_OVER_LIMIT',
      RawStepStatus.ignored => 'UNKNOWN',
    };
    _diagnostics?.record(
      StepDiagnosticEventType.pedometerCallback,
      windowId: session.hasActiveWindow ? _windowId : null,
      bucketIndex: update.bucketIndex,
      payload: {
        'pedometerCallbackReceivedElapsedRealtimeMs': callbackElapsedMs,
        'pedometerCallbackReceivedWallClockUtc': now.toUtc().toIso8601String(),
        'sensorEventElapsedRealtimeMs': null,
        'sensorEventTimestampAvailable': false,
        'sensorCumulativeValue': event.steps,
        'previousSensorCumulativeValue': previousRawSteps,
        'calculatedDelta': delta,
        'currentWindowId': session.hasActiveWindow ? _windowId : null,
        'currentBucketIndex': update.bucketIndex,
        'rawDeltaAccepted': update.status == RawStepStatus.provisionalAdded,
        'rawDeltaRejectionReason': rejectionReason,
        'provisionalBefore': provisionalBefore,
        'provisionalAfter': session.provisionalSteps,
      },
    );
    logStepDiagnostic(
      '[STEP_SENSOR] raw=${event.steps} '
      'previous=${previousRawSteps ?? 'none'} delta=${delta ?? 'none'} '
      'timestamp=${now.toIso8601String()} '
      'result=${_sensorResult(update.status, delta)}',
    );

    switch (update.status) {
      case RawStepStatus.baselineEstablished:
        _diagnostics?.record(
          StepDiagnosticEventType.pedometerBaseline,
          payload: {'sensorCumulativeValue': event.steps},
        );
        _publish(reason: 'sensorBaseline');
        return;
      case RawStepStatus.ignored:
        _diagnostics?.record(
          StepDiagnosticEventType.rawDeltaRejected,
          payload: {'delta': delta, 'reason': rejectionReason},
        );
        return;
      case RawStepStatus.provisionalAdded:
        if (update.startedWindow) {
          _windowId++;
          _windowStartedElapsedMs = callbackElapsedMs;
          _bucketSamplingHistory.clear();
          final start = callbackElapsedMs;
          _diagnostics?.record(
            StepDiagnosticEventType.windowOpen,
            windowId: _windowId,
            payload: {
              'windowOpenedElapsedRealtimeMs': start,
              'windowStartElapsedRealtimeMs': start,
              'windowEndElapsedRealtimeMs': start == null
                  ? null
                  : start + validationPolicy.windowDuration.inMilliseconds,
            },
          );
        }
        _diagnostics?.record(
          StepDiagnosticEventType.rawDeltaAccepted,
          windowId: _windowId,
          bucketIndex: update.bucketIndex,
          payload: {'delta': update.delta},
        );
        _diagnostics?.record(
          StepDiagnosticEventType.candidateCreated,
          windowId: _windowId,
          bucketIndex: update.bucketIndex,
          payload: {
            'delta': update.delta,
            'candidateObservedElapsedRealtimeMs': callbackElapsedMs,
            'candidateAssignedElapsedRealtimeMs': callbackElapsedMs,
            'candidateTimeSource': 'PEDOMETER_CALLBACK_RECEIVE_TIME',
          },
        );
        _diagnostics?.record(
          StepDiagnosticEventType.bucketAssignment,
          windowId: _windowId,
          bucketIndex: update.bucketIndex,
          payload: {
            'delta': update.delta,
            'candidateObservedElapsedRealtimeMs': callbackElapsedMs,
            'candidateAssignedElapsedRealtimeMs': callbackElapsedMs,
          },
        );
        final appliedActivity = update.appliedActivityEvidence;

        if (appliedActivity != null) {
          logStepDiagnostic(
            '[STEP_ACTIVITY_APPLIED] '
            'type=${appliedActivity.activity.storageName} '
            'confidence=${appliedActivity.confidence.storageName} '
            'stateAgeMs=${appliedActivity.age.inMilliseconds} '
            'bucket=${appliedActivity.bucketIndex} '
            'steps=${appliedActivity.bucketCandidateSteps}',
          );
        }
        if (update.startedWindow) {
          _startValidationTimer();
        }
        // Provisional and displayed values reach UI and notification now.
        _publish(reason: 'stepDelta');
    }
  }

  void _onActivityChanged(Activity event) {
    final session = _session;
    final now = DateTime.now();
    final receivedMs = _diagnostics?.nowElapsedMs;
    final callbackId =
        'sampling-callback-${receivedMs ?? 0}-${(++_samplingCallbackSequence).toString().padLeft(5, '0')}';
    final processingStartedMs = _diagnostics?.nowElapsedMs;
    final previousActivity = _activity;
    final previousConfidence = _confidence;
    final previousEvidenceMs = _latestEvidenceElapsedMs;
    final activity = event.type.toTrackingActivity();
    final confidence = event.confidence.toTrackingConfidence();
    _diagnostics?.record(
      StepDiagnosticEventType.samplingCallbackEnter,
      payload: {
        'samplingCallbackId': callbackId,
        'samplingCallbackReceivedElapsedRealtimeMs': receivedMs,
        'samplingCallbackReceivedWallClockUtc': now.toUtc().toIso8601String(),
        'samplingCallbackProcessingStartedElapsedRealtimeMs':
            processingStartedMs,
        'activityEventElapsedRealtimeMs': null,
        'activityEventTimestampAvailable': false,
      },
    );
    if (!_isTracking || _isStopping || session == null) {
      logStepDiagnostic(
        '[STEP_ACTIVITY] type=${activity.storageName} '
        'confidence=${confidence.storageName} '
        'timestamp=${now.toIso8601String()} windowActive=false '
        'bucket=none result=ignoredNotTracking',
      );
      final completed = _diagnostics?.nowElapsedMs;
      _diagnostics?.record(
        StepDiagnosticEventType.samplingActivityIgnored,
        payload: {
          'samplingCallbackId': callbackId,
          'ignoredReason': 'OUTSIDE_ACTIVE_SESSION',
          'samplingCallbackProcessingCompletedElapsedRealtimeMs': completed,
          'samplingCallbackProcessingDurationMs': _duration(
            processingStartedMs,
            completed,
          ),
        },
      );
      return;
    }

    _completeExpiredWindowIfNeeded(now);

    _activity = activity;
    _confidence = confidence;
    final appliedToBucket = session.recordActivity(
      activity: _activity,
      confidence: _confidence,
      timestamp: now,
    );
    final bucketIndex = session.bucketIndexAt(now);
    _latestEvidenceElapsedMs = receivedMs;
    _latestEvidenceWindowId = session.hasActiveWindow ? _windowId : null;
    _latestEvidenceBucketIndex = bucketIndex;
    if (bucketIndex != null) {
      (_bucketSamplingHistory[bucketIndex] ??= []).add({
        'elapsedMs': receivedMs,
        'activity': activity.storageName,
        'confidence': confidence.storageName,
      });
    }
    _diagnostics?.record(
      StepDiagnosticEventType.samplingActivityParsed,
      windowId: session.hasActiveWindow ? _windowId : null,
      bucketIndex: bucketIndex,
      payload: {
        'samplingCallbackId': callbackId,
        'rawActivityType': event.type.toString(),
        'mappedActivityType': activity.storageName,
        'rawConfidence': event.confidence.toString(),
        'mappedConfidence': confidence.storageName,
        'callbackReceivedElapsedRealtimeMs': receivedMs,
        'previousActivityType': previousActivity.storageName,
        'previousConfidence': previousConfidence.storageName,
        'previousEvidenceReceivedElapsedRealtimeMs': previousEvidenceMs,
        'becameCurrentEvidence': true,
        'ignoredReason': null,
        'currentWindowId': session.hasActiveWindow ? _windowId : null,
        'currentBucketIndex': bucketIndex,
      },
    );
    _diagnostics?.record(
      StepDiagnosticEventType.samplingEvidenceUpdated,
      payload: {
        'samplingCallbackId': callbackId,
        'previousActivityType': previousActivity.storageName,
        'previousConfidence': previousConfidence.storageName,
        'previousEvidenceReceivedElapsedRealtimeMs': previousEvidenceMs,
        'newActivityType': activity.storageName,
        'newConfidence': confidence.storageName,
        'newEvidenceReceivedElapsedRealtimeMs': receivedMs,
        'evidenceChanged':
            previousActivity != activity || previousConfidence != confidence,
        'changeReason': 'SAMPLING_CALLBACK_APPLIED',
      },
    );
    final completedMs = _diagnostics?.nowElapsedMs;
    _diagnostics?.record(
      appliedToBucket
          ? StepDiagnosticEventType.samplingActivityApplied
          : StepDiagnosticEventType.samplingActivityIgnored,
      windowId: session.hasActiveWindow ? _windowId : null,
      bucketIndex: bucketIndex,
      payload: {
        'samplingCallbackId': callbackId,
        'becameCurrentEvidence': true,
        'appliedToBucket': appliedToBucket,
        'ignoredReason': appliedToBucket ? null : 'NO_ACTIVE_BUCKET',
        'samplingCallbackReceivedElapsedRealtimeMs': receivedMs,
        'samplingCallbackProcessingStartedElapsedRealtimeMs':
            processingStartedMs,
        'samplingCallbackProcessingCompletedElapsedRealtimeMs': completedMs,
        'samplingCallbackProcessingDurationMs': _duration(
          processingStartedMs,
          completedMs,
        ),
        'timingInvariantPassed': _ordered(
          receivedMs,
          processingStartedMs,
          completedMs,
        ),
        'timingInvariantFailures':
            _ordered(receivedMs, processingStartedMs, completedMs)
            ? <String>[]
            : <String>[
                'samplingCallbackReceived<=processingStarted<=processingCompleted',
              ],
      },
    );
    logStepDiagnostic(
      '[STEP_ACTIVITY] type=${_activity.storageName} '
      'confidence=${_confidence.storageName} '
      'timestamp=${now.toIso8601String()} '
      'windowActive=${session.hasActiveWindow} '
      'bucket=${bucketIndex ?? 'none'} '
      'applied=$appliedToBucket',
    );

    _publish(reason: 'activityUpdate');
  }

  void _startValidationTimer() {
    _cancelValidationTimer('replace');
    final now = DateTime.now();
    logStepDiagnostic(
      '[STEP_TIMER_START] timestamp=${now.toIso8601String()} '
      'windowStart=${_session?.windowStartedAt?.toIso8601String()} '
      'provisional=${_session?.provisionalSteps ?? 0} '
      'windowActive=${_session?.hasActiveWindow ?? false}',
    );
    _validationTimer = Timer(
      validationPolicy.windowDuration,
      _onValidationTimerCompleted,
    );
  }

  void _onValidationTimerCompleted() {
    _validationTimer = null;
    logStepDiagnostic(
      '[STEP_TIMER_COMPLETE] timestamp=${DateTime.now().toIso8601String()} '
      'windowStart=${_session?.windowStartedAt?.toIso8601String()} '
      'provisional=${_session?.provisionalSteps ?? 0} '
      'windowActive=${_session?.hasActiveWindow ?? false}',
    );
    if (!_isTracking || _isStopping) return;

    _completeValidationWindow();
  }

  void _completeExpiredWindowIfNeeded(DateTime timestamp) {
    final session = _session;
    if (session != null && session.isWindowExpired(timestamp)) {
      _cancelValidationTimer('window_expired_event');
      _completeValidationWindow();
    }
  }

  void _completeValidationWindow() {
    final session = _session;
    if (session == null || !session.hasActiveWindow) return;

    final buckets = session.buckets;
    final validationStartedMs = _diagnostics?.nowElapsedMs;
    final confirmedBefore = session.confirmedSteps;
    final provisionalBefore = session.provisionalSteps;
    for (var index = 0; index < buckets.length; index++) {
      final bucket = buckets[index];
      final valid = validationPolicy.isValidBucket(
        observedWalkingOrRunning: bucket.observedWalkingOrRunning,
        observedVehicleOrBicycle: bucket.observedVehicleOrBicycle,
        bestWalkingConfidence: bucket.bestWalkingConfidence,
      );
      final history = _bucketSamplingHistory[index] ?? const [];
      final activityCounts = <String, int>{};
      final confidenceCounts = <String, int>{};
      for (final callback in history) {
        final activity = callback['activity'].toString();
        final confidence = callback['confidence'].toString();
        activityCounts[activity] = (activityCounts[activity] ?? 0) + 1;
        confidenceCounts[confidence] = (confidenceCounts[confidence] ?? 0) + 1;
      }
      final evidenceAge =
          validationStartedMs == null || _latestEvidenceElapsedMs == null
          ? null
          : validationStartedMs - _latestEvidenceElapsedMs!;
      final reason = valid
          ? 'ACCEPTED_WALKING_CONFIDENCE'
          : bucket.observedVehicleOrBicycle
          ? 'REJECTED_IN_VEHICLE_OR_ON_BICYCLE'
          : !bucket.observedWalkingOrRunning
          ? 'REJECTED_NO_ACTIVITY_EVIDENCE'
          : 'REJECTED_LOW_CONFIDENCE';
      _diagnostics?.record(
        StepDiagnosticEventType.bucketValidation,
        windowId: _windowId,
        bucketIndex: index,
        payload: {
          'bucketStartElapsedRealtimeMs': _windowStartedElapsedMs == null
              ? null
              : _windowStartedElapsedMs! +
                    index * validationPolicy.bucketDuration.inMilliseconds,
          'bucketEndElapsedRealtimeMs': _windowStartedElapsedMs == null
              ? null
              : _windowStartedElapsedMs! +
                    (index + 1) *
                        validationPolicy.bucketDuration.inMilliseconds,
          'validationStartedElapsedRealtimeMs': validationStartedMs,
          'candidateSteps': bucket.candidateSteps,
          'acceptedSteps': valid ? bucket.candidateSteps : 0,
          'rejectedSteps': valid ? 0 : bucket.candidateSteps,
          'validationReason': reason,
          'activityEvidenceType': _activity.storageName,
          'activityEvidenceConfidence': _confidence.storageName,
          'evidenceReceivedElapsedRealtimeMs': _latestEvidenceElapsedMs,
          'evidenceAgeAtValidationStartMs': evidenceAge,
          'evidenceWindowIdAtReceive': _latestEvidenceWindowId,
          'evidenceBucketIndexAtReceive': _latestEvidenceBucketIndex,
          'evidenceUsed': true,
          'evidenceIgnored': false,
          'walkingObserved': bucket.observedWalkingOrRunning,
          'runningObserved': bucket.observedWalkingOrRunning,
          'vehicleObserved': bucket.observedVehicleOrBicycle,
          'bicycleObserved': bucket.observedVehicleOrBicycle,
          'stillObserved': activityCounts['STILL'] != null,
          'bestWalkingConfidence': bucket.bestWalkingConfidence.storageName,
          'bestRunningConfidence': bucket.bestWalkingConfidence.storageName,
          'minimumAcceptedConfidence': 'MEDIUM',
          'configuredEvidenceStaleThresholdMs': null,
          'evidenceConsideredStaleByCurrentImplementation': false,
          'samplingCallbackCount': history.length,
          'activityCountsByType': activityCounts,
          'confidenceCounts': confidenceCounts,
          'firstSamplingCallbackElapsedRealtimeMs': history.isEmpty
              ? null
              : history.first['elapsedMs'],
          'lastSamplingCallbackElapsedRealtimeMs': history.isEmpty
              ? null
              : history.last['elapsedMs'],
        },
      );
      logStepDiagnostic(
        '[STEP_BUCKET_VALIDATION] bucket=$index '
        'steps=${bucket.candidateSteps} '
        'walking=${bucket.observedWalkingOrRunning} '
        'confidence=${bucket.bestWalkingConfidence.storageName} '
        'vehicle=${bucket.observedVehicleOrBicycle} valid=$valid',
      );
    }

    final result = session.completeWindow();
    final validationCompletedMs = _diagnostics?.nowElapsedMs;
    _diagnostics?.record(
      StepDiagnosticEventType.windowValidation,
      windowId: _windowId,
      payload: {
        'windowStartElapsedRealtimeMs': _windowStartedElapsedMs,
        'windowEndElapsedRealtimeMs': _windowStartedElapsedMs == null
            ? null
            : _windowStartedElapsedMs! +
                  validationPolicy.windowDuration.inMilliseconds,
        'validationStartedElapsedRealtimeMs': validationStartedMs,
        'validationCompletedElapsedRealtimeMs': validationCompletedMs,
        'validationDurationMs': _duration(
          validationStartedMs,
          validationCompletedMs,
        ),
        'candidateStepTotal': result.confirmedStepsAdded + result.stepsRejected,
        'acceptedStepTotal': result.confirmedStepsAdded,
        'rejectedStepTotal': result.stepsRejected,
        'confirmedBefore': confirmedBefore,
        'confirmedAfter': session.confirmedSteps,
        'provisionalBefore': provisionalBefore,
        'provisionalFinal': session.provisionalSteps,
        'timingInvariantPassed': _ordered(
          validationStartedMs,
          validationStartedMs,
          validationCompletedMs,
        ),
        'timingInvariantFailures':
            _ordered(
              validationStartedMs,
              validationStartedMs,
              validationCompletedMs,
            )
            ? <String>[]
            : <String>['validationStarted<=validationCompleted'],
      },
      flush: true,
    );
    _windowStartedElapsedMs = null;
    logStepDiagnostic(
      '[STEP_VALIDATION] accepted=${result.confirmedStepsAdded} '
      'rejected=${result.stepsRejected} '
      'confirmedTotal=${session.confirmedSteps} '
      'provisionalTotal=${session.provisionalSteps} '
      'displayedTotal=${session.displayedSteps}',
    );
    _publish(reason: 'validationComplete', persist: true);
  }

  void _onStepCountError(Object error, StackTrace stackTrace) {
    _diagnostics?.record(
      StepDiagnosticEventType.pedometerError,
      payload: {'errorType': error.runtimeType.toString()},
      flush: true,
    );
    logStepDiagnostic(
      '[STEP_SENSOR_ERROR] timestamp=${DateTime.now().toIso8601String()} '
      'error=$error stack=${_singleLineStack(stackTrace)}',
    );
    _error = 'Pedometer error: $error';
    unawaited(_stopTracking(reason: 'pedometer_error'));
  }

  void _onActivityError(Object error, StackTrace stackTrace) {
    _diagnostics?.record(
      StepDiagnosticEventType.samplingStreamError,
      payload: {'errorType': error.runtimeType.toString()},
      flush: true,
    );
    logStepDiagnostic(
      '[STEP_ACTIVITY_ERROR] timestamp=${DateTime.now().toIso8601String()} '
      'error=$error stack=${_singleLineStack(stackTrace)}',
    );
    _error = 'Activity Recognition error: $error';
    unawaited(_stopTracking(reason: 'activity_recognition_error'));
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Intentionally unused. Validation is driven by sensor/activity events and
    // a one-shot Timer that exists only while provisional steps exist.
  }

  StepSnapshot _buildSnapshot() {
    final session = _session;
    return StepSnapshot(
      confirmedSteps: session?.confirmedSteps ?? 0,
      provisionalSteps: session?.provisionalSteps ?? 0,
      isTracking: _isTracking,
      sensorReady: session?.sensorReady ?? false,
      activity: _activity,
      confidence: _confidence,
      startedAt: _startedAt,
      updatedAt: DateTime.now(),
      error: _error,
      stopReason: _stopReason,
    );
  }

  void _publish({required String reason, bool persist = false}) {
    final snapshot = _buildSnapshot();
    _diagnostics?.record(
      StepDiagnosticEventType.snapshotCreated,
      payload: _snapshotPayload(snapshot, reason),
    );
    _sendToMain(snapshot, reason: reason);
    _updateNotificationIfChanged(snapshot);

    if (persist) {
      _enqueueSnapshotWrite(snapshot, reason: reason);
    }
  }

  void _sendToMain(StepSnapshot snapshot, {required String reason}) {
    logStepDiagnostic(
      '[STEP_SERVICE_SEND] reason=$reason '
      'confirmed=${snapshot.confirmedSteps} '
      'provisional=${snapshot.provisionalSteps} '
      'displayed=${snapshot.displayedSteps} '
      'tracking=${snapshot.isTracking}',
    );
    FlutterForegroundTask.sendDataToMain(<String, dynamic>{
      'type': 'step_snapshot',
      'diagnosticSessionId': _diagnostics?.sessionId,
      'payload': snapshot.toMap(),
    });
    _diagnostics?.record(
      StepDiagnosticEventType.snapshotSent,
      payload: _snapshotPayload(snapshot, reason),
    );
  }

  String _notificationText(StepSnapshot snapshot) {
    if (snapshot.error != null) return 'خطا در شمارش قدم';
    if (!snapshot.sensorReady) return 'در انتظار اولین داده سنسور...';

    final validating = snapshot.provisionalSteps > 0
        ? ' | ${snapshot.provisionalSteps} در حال بررسی'
        : '';
    return '${snapshot.displayedSteps} قدم$validating | ${_activityLabel()}';
  }

  void _updateNotificationIfChanged(StepSnapshot snapshot) {
    final notificationText = _notificationText(snapshot);
    if (notificationText == _lastNotificationText &&
        _pendingNotificationText == null) {
      return;
    }

    _pendingNotificationText = notificationText;
    final now = DateTime.now();
    final lastUpdatedAt = _lastNotificationUpdateAt;
    if (lastUpdatedAt == null ||
        now.difference(lastUpdatedAt) >= _notificationThrottleDuration) {
      _flushPendingNotification();
      return;
    }

    if (_notificationTimer != null) return;

    final remaining =
        _notificationThrottleDuration - now.difference(lastUpdatedAt);
    _notificationTimer = Timer(remaining, _flushPendingNotification);
  }

  void _flushPendingNotification() {
    _notificationTimer = null;
    final notificationText = _pendingNotificationText;
    if (notificationText == null || notificationText == _lastNotificationText) {
      _pendingNotificationText = null;
      return;
    }

    _lastNotificationText = notificationText;
    _pendingNotificationText = null;
    _lastNotificationUpdateAt = DateTime.now();
    unawaited(
      FlutterForegroundTask.updateService(
        notificationTitle: 'قدم‌شمار فعال است',
        notificationText: notificationText,
      ),
    );
  }

  void _cancelNotificationTimer() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
    _pendingNotificationText = null;
  }

  void _cancelValidationTimer(String reason) {
    if (_validationTimer == null) return;

    _validationTimer!.cancel();
    _validationTimer = null;
    logStepDiagnostic(
      '[STEP_TIMER_CANCEL] timestamp=${DateTime.now().toIso8601String()} '
      'windowStart=${_session?.windowStartedAt?.toIso8601String()} '
      'provisional=${_session?.provisionalSteps ?? 0} '
      'reason=$reason windowActive=${_session?.hasActiveWindow ?? false}',
    );
  }

  String _activityLabel() {
    return switch (_activity) {
      TrackingActivity.walking => 'در حال پیاده‌روی',
      TrackingActivity.running => 'در حال دویدن',
      TrackingActivity.inVehicle => 'داخل خودرو',
      TrackingActivity.onBicycle => 'دوچرخه',
      TrackingActivity.still => 'بدون حرکت',
      TrackingActivity.unknown => 'نامشخص',
    };
  }

  void _enqueueSnapshotWrite(StepSnapshot snapshot, {required String reason}) {
    final store = _store;
    if (store == null) return;

    _writeChain = _writeChain
        .then<void>((_) async {
          await store.writeSnapshot(snapshot, reason: reason);
          _diagnostics?.record(
            StepDiagnosticEventType.hiveWrite,
            payload: _snapshotPayload(snapshot, reason),
          );
        })
        .catchError((Object error, StackTrace stackTrace) {
          _error = 'Hive write error: $error';
        });
  }

  @override
  void onReceiveData(Object data) {
    if (data is! Map) return;

    switch (data['command']?.toString()) {
      case 'get_snapshot':
        _publish(reason: 'uiSnapshotRequest');
        break;
      case 'reset_steps':
        _diagnostics?.record(StepDiagnosticEventType.resetRequested);
        _cancelValidationTimer('reset');
        _session?.reset();
        _error = null;
        _stopReason = null;
        _publish(reason: 'reset', persist: true);
        _diagnostics?.record(StepDiagnosticEventType.resetCompleted);
        break;
      case 'stop_tracking':
        unawaited(_stopTracking(reason: data['reason']?.toString() ?? 'user'));
        break;
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'stop_tracking') {
      unawaited(_stopTracking(reason: 'notification_button'));
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
  }

  @override
  void onNotificationDismissed() {}

  Future<void> _stopTracking({required String reason}) async {
    if (_isStopping) return;

    logStepDiagnostic(
      '[STEP_SERVICE_STOP_REQUEST] timestamp=${DateTime.now().toIso8601String()} '
      'reason=$reason tracking=$_isTracking '
      'subscriptions=${_stepSubscription != null || _activitySubscription != null} '
      'windowActive=${_session?.hasActiveWindow ?? false}',
    );

    _isStopping = true;
    _diagnostics?.record(
      StepDiagnosticEventType.serviceStop,
      payload: {'reason': reason},
      flush: true,
    );
    _isTracking = false;
    _stopReason = reason;
    _cancelValidationTimer('stop:$reason');
    _cancelNotificationTimer();
    _session?.stop();

    await _cancelSubscriptions();
    await _persistFinalSnapshot();
    await FlutterForegroundTask.stopService();
  }

  Future<void> _persistFinalSnapshot() {
    return _finalPersistence.run(() async {
      final snapshot = _buildSnapshot();
      _sendToMain(snapshot, reason: 'serviceStopped');

      await _writeChain;
      final store = _store;
      if (store != null) {
        await store.writeSnapshot(
          snapshot,
          flush: true,
          reason: 'serviceStopped',
        );
      }
    });
  }

  Future<void> _cancelSubscriptions() async {
    if (_stepSubscription != null) {
      logStepDiagnostic(
        '[STEP_SENSOR_CANCEL] timestamp=${DateTime.now().toIso8601String()}',
      );
    }
    await _stepSubscription?.cancel();
    _diagnostics?.record(StepDiagnosticEventType.pedometerUnsubscribe);
    if (_activitySubscription != null) {
      logStepDiagnostic(
        '[STEP_ACTIVITY_CANCEL] timestamp=${DateTime.now().toIso8601String()}',
      );
    }
    _diagnostics?.record(StepDiagnosticEventType.samplingUnsubscribeRequest);
    try {
      await _activitySubscription?.cancel();
      _diagnostics?.record(
        StepDiagnosticEventType.samplingUnsubscribeCompleted,
      );
    } catch (error) {
      _diagnostics?.record(
        StepDiagnosticEventType.samplingUnsubscribeFailure,
        payload: {'errorType': error.runtimeType.toString()},
        flush: true,
      );
    }
    _stepSubscription = null;
    _activitySubscription = null;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    logStepDiagnostic(
      '[STEP_SERVICE_DESTROY] timestamp=${timestamp.toIso8601String()} '
      'tracking=$_isTracking '
      'subscriptions=${_stepSubscription != null || _activitySubscription != null} '
      'windowActive=${_session?.hasActiveWindow ?? false} timeout=$isTimeout',
    );
    _isTracking = false;
    _diagnostics?.record(
      StepDiagnosticEventType.serviceDestroy,
      payload: {'isTimeout': isTimeout},
      flush: true,
    );
    _cancelValidationTimer('destroy');
    _cancelNotificationTimer();
    _session?.stop();
    _stopReason ??= isTimeout ? 'service_timeout' : 'service_destroyed';

    await _cancelSubscriptions();
    await _persistFinalSnapshot();
    await _store?.close();
    _store = null;
    await _diagnostics?.close(finalize: true, incomplete: isTimeout);
    _diagnostics = null;
  }

  String _sensorResult(RawStepStatus status, int? delta) {
    if (status != RawStepStatus.ignored) return status.name;
    if (delta == 0) return 'ignoredZeroDelta';
    if (delta != null && delta < 0) return 'ignoredNegativeDelta';
    if (delta != null && delta > validationPolicy.maxRawDeltaPerEvent) {
      return 'ignoredLargeDelta';
    }
    return 'ignoredInvalidDelta';
  }

  String _singleLineStack(StackTrace stackTrace) {
    return stackTrace.toString().replaceAll('\n', ' | ');
  }

  int? _duration(int? start, int? end) =>
      start == null || end == null ? null : end - start;
  bool _ordered(int? first, int? second, int? third) =>
      first == null ||
      second == null ||
      third == null ||
      (first <= second && second <= third);
  Map<String, Object?> _snapshotPayload(StepSnapshot snapshot, String reason) =>
      {
        'reason': reason,
        'confirmedSteps': snapshot.confirmedSteps,
        'provisionalSteps': snapshot.provisionalSteps,
        'displayedSteps': snapshot.displayedSteps,
        'activityType': snapshot.activity.storageName,
        'confidence': snapshot.confidence.storageName,
        'isTracking': snapshot.isTracking,
      };
}

extension on ActivityType {
  TrackingActivity toTrackingActivity() {
    return switch (this) {
      ActivityType.WALKING => TrackingActivity.walking,
      ActivityType.RUNNING => TrackingActivity.running,
      ActivityType.IN_VEHICLE => TrackingActivity.inVehicle,
      ActivityType.ON_BICYCLE => TrackingActivity.onBicycle,
      ActivityType.STILL => TrackingActivity.still,
      ActivityType.UNKNOWN => TrackingActivity.unknown,
    };
  }
}

extension on ActivityConfidence {
  TrackingConfidence toTrackingConfidence() {
    return switch (this) {
      ActivityConfidence.HIGH => TrackingConfidence.high,
      ActivityConfidence.MEDIUM => TrackingConfidence.medium,
      ActivityConfidence.LOW => TrackingConfidence.low,
    };
  }
}
