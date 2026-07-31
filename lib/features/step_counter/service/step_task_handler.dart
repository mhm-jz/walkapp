import 'dart:async';
import 'dart:convert';

import 'package:activity_transition_bridge/activity_transition_bridge.dart';
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
  Timer? _validationTimer;
  Timer? _graceTimer;
  Timer? _notificationTimer;

  Future<void> _writeChain = Future<void>.value();
  final FinalSnapshotPersistence _finalPersistence = FinalSnapshotPersistence();
  final Set<String> _deliveredTransitionIds = <String>{};

  bool _isTracking = false;
  bool _isStopping = false;
  bool _isDrainingTransitions = false;
  bool _finalizeAfterCurrentDrain = false;
  TrackingActivity _activity = TrackingActivity.unknown;
  DateTime? _startedAt;
  String? _error;
  String? _stopReason;
  String? _lastNotificationText;
  String? _pendingNotificationText;
  DateTime? _lastNotificationUpdateAt;
  String? _transitionSessionId;
  int? _elapsedRealtimeAnchorNanos;
  int? _transitionEvidenceFloorNanos;
  Stopwatch? _monotonicClock;
  StepDiagnosticLogger? _diagnostics;
  int _windowId = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    logStepDiagnostic(
      '[STEP_SERVICE_START] timestamp=${timestamp.toIso8601String()} '
      'tracking=$_isTracking subscriptions=${_stepSubscription != null} '
      'windowActive=${_session?.hasActiveWindow ?? false}',
    );
    try {
      final directoryPath = await FlutterForegroundTask.getData<String>(
        key: StepLocalStore.taskHivePathKey,
      );
      if (directoryPath == null || directoryPath.isEmpty) {
        throw StateError('Hive path was not provided to the service.');
      }

      final diagnosticSessionId = await FlutterForegroundTask.getData<String>(
        key: StepLocalStore.taskDiagnosticSessionIdKey,
      );
      if (diagnosticSessionId != null && diagnosticSessionId.isNotEmpty) {
        final savedDiagnosticStartElapsedMs =
            await FlutterForegroundTask.getData<int>(
              key: StepLocalStore.taskDiagnosticSessionStartElapsedMsKey,
            );
        final diagnosticRecordingAnchorNanos =
            await ActivityTransitionBridge.elapsedRealtimeNanos();
        _diagnostics = await StepDiagnosticLogger.create(
          applicationSupportPath: directoryPath,
          source: 'background',
          sessionId: diagnosticSessionId,
          sessionStartElapsedRealtimeMs:
              savedDiagnosticStartElapsedMs ??
              (diagnosticRecordingAnchorNanos == null
                  ? null
                  : diagnosticRecordingAnchorNanos ~/ 1000000),
          recordingClockAnchorElapsedRealtimeMs:
              diagnosticRecordingAnchorNanos == null
              ? null
              : diagnosticRecordingAnchorNanos ~/ 1000000,
        );
      }
      _diagnostics?.record(
        StepDiagnosticEventType.serviceStart,
        payload: <String, Object?>{'starter': starter.name},
      );

      _store = StepLocalStore(directoryPath: directoryPath);
      final previousSnapshot = await _store!.readSnapshot(
        reason: 'serviceStart',
      );
      _diagnostics?.record(
        StepDiagnosticEventType.hiveRead,
        payload: _snapshotPayload(previousSnapshot, reason: 'serviceStart'),
      );
      _session = StepValidationSession(
        confirmedSteps: previousSnapshot.confirmedSteps,
        policy: validationPolicy,
      );
      _isTracking = true;
      _isStopping = false;
      _activity = TrackingActivity.unknown;
      _startedAt = timestamp;
      _error = null;
      _stopReason = null;

      await _registerTransitions(timestamp);
      _subscribeToPedometer();
      _publish(reason: 'serviceStarted', persist: true);
      unawaited(_drainTransitions());
    } catch (error, stackTrace) {
      _diagnostics?.record(
        StepDiagnosticEventType.serviceError,
        payload: <String, Object?>{'failureType': error.runtimeType.toString()},
        flush: true,
      );
      logStepDiagnostic(
        '[STEP_TRANSITION_REGISTER] activity=ALL transition=ENTER_EXIT '
        'eventElapsedMs=none receivedElapsedMs=none deliveryDelayMs=none '
        'sessionId=${_transitionSessionId ?? 'none'} result=error '
        'error=$error stack=${_singleLineStack(stackTrace)}',
      );
      _error = 'Transition-based activity detection could not start.';
      _isTracking = false;
      _stopReason = 'initialization_error';
      await _unregisterTransitionsBestEffort();
      await _persistFinalSnapshot();
      await FlutterForegroundTask.stopService();
    }
  }

  Future<void> _registerTransitions(DateTime timestamp) async {
    final sessionId =
        '${timestamp.microsecondsSinceEpoch}-${identityHashCode(this)}';
    _transitionSessionId = sessionId;
    _deliveredTransitionIds.clear();
    _diagnostics?.record(
      StepDiagnosticEventType.transitionRegisterRequest,
      payload: <String, Object?>{
        'transitionSessionId': sessionId,
        'activities': <String>[
          'WALKING',
          'RUNNING',
          'STILL',
          'ON_BICYCLE',
          'IN_VEHICLE',
        ],
        'transitions': <String>['ENTER', 'EXIT'],
      },
    );
    final registration = await ActivityTransitionBridge.register(
      sessionId: sessionId,
      diagnosticSessionId: _diagnostics?.sessionId,
      diagnosticDirectoryPath: _diagnostics?.store.directory.path,
    );
    if (registration.sessionId != sessionId) {
      throw StateError('Transition registration session mismatch.');
    }
    _elapsedRealtimeAnchorNanos = registration.sessionStartElapsedRealtimeNanos;
    _transitionEvidenceFloorNanos =
        registration.sessionStartElapsedRealtimeNanos;
    _monotonicClock = Stopwatch()..start();
    final elapsedMs = registration.sessionStartElapsedRealtimeNanos ~/ 1000000;
    _diagnostics?.attachMonotonicSessionClock(elapsedMs);
    _diagnostics?.record(
      StepDiagnosticEventType.transitionRegisterSuccess,
      elapsedRealtimeMs: elapsedMs,
      payload: <String, Object?>{
        'transitionSessionId': sessionId,
        'sessionStartElapsedRealtimeNanos':
            registration.sessionStartElapsedRealtimeNanos,
      },
      flush: true,
    );
    logStepDiagnostic(
      '[STEP_TRANSITION_REGISTER] activity=ALL transition=ENTER_EXIT '
      'eventElapsedMs=$elapsedMs receivedElapsedMs=$elapsedMs '
      'deliveryDelayMs=0 sessionId=$sessionId result=registered',
    );
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

  void _onStepCount(StepCount event) {
    final session = _session;
    final now = DateTime.now();
    final elapsedNanos = _currentElapsedRealtimeNanos;
    final previousRawSteps = session?.lastRawSteps;
    final delta = previousRawSteps == null
        ? null
        : event.steps - previousRawSteps;

    if (!_isTracking ||
        _isStopping ||
        session == null ||
        elapsedNanos == null) {
      logStepDiagnostic(
        '[STEP_SENSOR] raw=${event.steps} '
        'previous=${previousRawSteps ?? 'none'} delta=${delta ?? 'none'} '
        'timestamp=${now.toIso8601String()} eventElapsedMs=none '
        'result=ignoredNotTracking',
      );
      _diagnostics?.record(
        StepDiagnosticEventType.pedometerCallback,
        payload: <String, Object?>{
          'sensorCumulativeValue': event.steps,
          'previousSensorCumulativeValue': previousRawSteps,
          'calculatedDelta': delta,
          'pedometerCallbackReceivedElapsedRealtimeMs': null,
          'pedometerCallbackReceivedWallClockUtc': now
              .toUtc()
              .toIso8601String(),
          'sensorEventElapsedRealtimeMs': null,
          'sensorEventTimestampAvailable': false,
          'accepted': false,
          'rejectionReason': 'OUT_OF_ACTIVE_SESSION',
        },
      );
      _diagnostics?.record(
        StepDiagnosticEventType.rawDeltaRejected,
        payload: <String, Object?>{
          'delta': delta,
          'reason': 'OUT_OF_ACTIVE_SESSION',
        },
      );
      return;
    }

    _closeExpiredWindowIfNeeded(elapsedNanos);
    final update = session.recordRawReading(
      cumulativeRawSteps: event.steps,
      elapsedRealtimeNanos: elapsedNanos,
    );
    final elapsedMs = elapsedNanos ~/ 1000000;
    final reason = switch (update.status) {
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
      elapsedRealtimeMs: elapsedMs,
      windowId: session.hasActiveWindow ? _windowId : null,
      bucketIndex: update.bucketIndex,
      payload: <String, Object?>{
        'sensorCumulativeValue': event.steps,
        'previousSensorCumulativeValue': previousRawSteps,
        'calculatedDelta': delta,
        'pedometerCallbackReceivedElapsedRealtimeMs': elapsedMs,
        'pedometerCallbackReceivedWallClockUtc': now.toUtc().toIso8601String(),
        'sensorEventElapsedRealtimeMs': null,
        'sensorEventTimestampAvailable': false,
        'accepted': update.status == RawStepStatus.provisionalAdded,
        'rejectionReason': reason,
        'provisionalTotalAfterCallback': session.provisionalSteps,
      },
    );
    logStepDiagnostic(
      '[STEP_SENSOR] raw=${event.steps} '
      'previous=${previousRawSteps ?? 'none'} delta=${delta ?? 'none'} '
      'timestamp=${now.toIso8601String()} '
      'eventElapsedMs=${elapsedNanos ~/ 1000000} '
      'bucket=${update.bucketIndex ?? 'none'} '
      'result=${_sensorResult(update.status, delta)}',
    );

    switch (update.status) {
      case RawStepStatus.baselineEstablished:
        _diagnostics?.record(
          StepDiagnosticEventType.pedometerBaseline,
          elapsedRealtimeMs: elapsedMs,
          payload: <String, Object?>{'sensorCumulativeValue': event.steps},
        );
        _publish(reason: 'sensorBaseline');
        return;
      case RawStepStatus.ignored:
        _diagnostics?.record(
          StepDiagnosticEventType.rawDeltaRejected,
          elapsedRealtimeMs: elapsedMs,
          payload: <String, Object?>{'delta': delta, 'reason': reason},
        );
        return;
      case RawStepStatus.provisionalAdded:
        if (update.startedWindow) {
          _windowId++;
          _diagnostics?.record(
            StepDiagnosticEventType.windowOpen,
            elapsedRealtimeMs: elapsedMs,
            windowId: _windowId,
            payload: <String, Object?>{
              'windowOpenedElapsedRealtimeMs': elapsedMs,
              'windowStartElapsedRealtimeMs':
                  session.activeWindowStartElapsedRealtimeNanos! ~/ 1000000,
              'windowEndElapsedRealtimeMs':
                  session.activeWindowEndElapsedRealtimeNanos! ~/ 1000000,
            },
          );
        }
        _diagnostics?.record(
          StepDiagnosticEventType.rawDeltaAccepted,
          elapsedRealtimeMs: elapsedMs,
          windowId: _windowId,
          bucketIndex: update.bucketIndex,
          payload: <String, Object?>{'delta': update.delta},
        );
        _diagnostics?.record(
          StepDiagnosticEventType.candidateSampleCreated,
          elapsedRealtimeMs: elapsedMs,
          windowId: _windowId,
          bucketIndex: update.bucketIndex,
          payload: <String, Object?>{
            'delta': update.delta,
            'candidateObservedElapsedRealtimeMs': elapsedMs,
            'candidateAssignedElapsedRealtimeMs': elapsedMs,
            'candidateTimeSource': 'PEDOMETER_CALLBACK_RECEIVE_TIME',
          },
        );
        _diagnostics?.record(
          StepDiagnosticEventType.bucketAssignment,
          elapsedRealtimeMs: elapsedMs,
          windowId: _windowId,
          bucketIndex: update.bucketIndex,
          payload: <String, Object?>{
            'delta': update.delta,
            'bucketStartElapsedRealtimeMs':
                session.activeWindowStartElapsedRealtimeNanos! ~/ 1000000 +
                update.bucketIndex! *
                    validationPolicy.bucketDuration.inMilliseconds,
            'bucketEndElapsedRealtimeMs':
                session.activeWindowStartElapsedRealtimeNanos! ~/ 1000000 +
                (update.bucketIndex! + 1) *
                    validationPolicy.bucketDuration.inMilliseconds,
            'candidateObservedElapsedRealtimeMs': elapsedMs,
            'candidateAssignedElapsedRealtimeMs': elapsedMs,
            'candidateTimeSource': 'PEDOMETER_CALLBACK_RECEIVE_TIME',
          },
        );
        if (update.startedWindow) {
          _startValidationTimer();
        }
        _publish(reason: 'stepDelta');
    }
  }

  void _startValidationTimer() {
    _cancelValidationTimer('replace');
    final session = _session;
    logStepDiagnostic(
      '[STEP_TIMER_START] timestamp=${DateTime.now().toIso8601String()} '
      'windowStartElapsedMs='
      '${_toElapsedMs(session?.activeWindowStartElapsedRealtimeNanos)} '
      'windowEndElapsedMs='
      '${_toElapsedMs(session?.activeWindowEndElapsedRealtimeNanos)} '
      'provisional=${session?.provisionalSteps ?? 0} '
      'windowActive=${session?.hasActiveWindow ?? false}',
    );
    _validationTimer = Timer(
      validationPolicy.windowDuration,
      _onValidationTimerCompleted,
    );
  }

  void _onValidationTimerCompleted() {
    _validationTimer = null;
    if (!_isTracking || _isStopping) return;
    _closeActiveWindow();
  }

  void _closeExpiredWindowIfNeeded(int elapsedRealtimeNanos) {
    final session = _session;
    if (session != null &&
        session.isActiveWindowExpired(elapsedRealtimeNanos)) {
      _cancelValidationTimer('window_expired_event');
      _closeActiveWindow();
    }
  }

  void _closeActiveWindow() {
    final session = _session;
    if (session == null || !session.hasActiveWindow) return;
    session.closeActiveWindow();
    _diagnostics?.record(
      StepDiagnosticEventType.windowClose,
      elapsedRealtimeMs:
          session.pendingWindowEndElapsedRealtimeNanos! ~/ 1000000,
      windowId: _windowId,
      payload: <String, Object?>{
        'windowStartElapsedRealtimeMs':
            session.pendingWindowStartElapsedRealtimeNanos! ~/ 1000000,
        'windowEndElapsedRealtimeMs':
            session.pendingWindowEndElapsedRealtimeNanos! ~/ 1000000,
        'provisionalSteps': session.provisionalSteps,
      },
    );
    logStepDiagnostic(
      '[STEP_TIMER_COMPLETE] timestamp=${DateTime.now().toIso8601String()} '
      'windowStartElapsedMs='
      '${_toElapsedMs(session.pendingWindowStartElapsedRealtimeNanos)} '
      'windowEndElapsedMs='
      '${_toElapsedMs(session.pendingWindowEndElapsedRealtimeNanos)} '
      'provisional=${session.provisionalSteps} windowActive=false',
    );
    _startGraceTimer();
  }

  void _startGraceTimer() {
    _cancelGraceTimer();
    final session = _session;
    final sessionId = _transitionSessionId;
    logStepDiagnostic(
      '[STEP_TRANSITION_GRACE_START] activity=ALL transition=NONE '
      'eventElapsedMs='
      '${_toElapsedMs(session?.pendingWindowEndElapsedRealtimeNanos)} '
      'receivedElapsedMs=${_toElapsedMs(_currentElapsedRealtimeNanos)} '
      'deliveryDelayMs=0 sessionId=${sessionId ?? 'none'} '
      'graceMs=${validationPolicy.transitionLateEventGracePeriod.inMilliseconds}',
    );
    final graceStartedMs = _toNullableElapsedMs(_currentElapsedRealtimeNanos);
    _diagnostics?.record(
      StepDiagnosticEventType.graceStart,
      elapsedRealtimeMs: _toNullableElapsedMs(_currentElapsedRealtimeNanos),
      windowId: _windowId,
      payload: <String, Object?>{
        'graceStartedElapsedRealtimeMs': graceStartedMs,
        'graceExpectedEndElapsedRealtimeMs': graceStartedMs == null
            ? null
            : graceStartedMs +
                  validationPolicy
                      .transitionLateEventGracePeriod
                      .inMilliseconds,
        'windowEndElapsedRealtimeMs': _toNullableElapsedMs(
          session?.pendingWindowEndElapsedRealtimeNanos,
        ),
      },
      flush: true,
    );
    _graceTimer = Timer(
      validationPolicy.transitionLateEventGracePeriod,
      _onGraceExpired,
    );
  }

  void _onGraceExpired() {
    _graceTimer = null;
    final sessionId = _transitionSessionId;
    logStepDiagnostic(
      '[STEP_TRANSITION_GRACE_EXPIRED] activity=ALL transition=NONE '
      'eventElapsedMs='
      '${_toElapsedMs(_session?.pendingWindowEndElapsedRealtimeNanos)} '
      'receivedElapsedMs=${_toElapsedMs(_currentElapsedRealtimeNanos)} '
      'deliveryDelayMs=0 sessionId=${sessionId ?? 'none'}',
    );
    _diagnostics?.record(
      StepDiagnosticEventType.graceExpired,
      elapsedRealtimeMs: _toNullableElapsedMs(_currentElapsedRealtimeNanos),
      windowId: _windowId,
      payload: <String, Object?>{
        'graceExpiredElapsedRealtimeMs': _toNullableElapsedMs(
          _currentElapsedRealtimeNanos,
        ),
        'windowEndElapsedRealtimeMs': _toNullableElapsedMs(
          _session?.pendingWindowEndElapsedRealtimeNanos,
        ),
        ..._timingInvariantPayload(<(String, int?, int?)>[
          (
            'windowEndElapsedRealtimeMs<=graceExpiredElapsedRealtimeMs',
            _toNullableElapsedMs(
              _session?.pendingWindowEndElapsedRealtimeNanos,
            ),
            _toNullableElapsedMs(_currentElapsedRealtimeNanos),
          ),
        ]),
      },
      flush: true,
    );
    if (!_isTracking || _isStopping) return;
    unawaited(_drainTransitions(finalizePendingAfterDrain: true));
  }

  Future<void> _drainTransitions({
    bool finalizePendingAfterDrain = false,
  }) async {
    final sessionId = _transitionSessionId;
    final session = _session;
    if (_isDrainingTransitions ||
        !_isTracking ||
        _isStopping ||
        sessionId == null ||
        session == null) {
      if (_isDrainingTransitions && finalizePendingAfterDrain) {
        _finalizeAfterCurrentDrain = true;
      } else if (finalizePendingAfterDrain && !_isDrainingTransitions) {
        _finalizePendingWindow();
      }
      return;
    }

    _isDrainingTransitions = true;
    try {
      await _drainNativeReceiverDiagnostics();
      final events = await ActivityTransitionBridge.peek(sessionId: sessionId);
      final acknowledged = <String>[];
      for (final nativeEvent in events) {
        final dartDequeuedElapsedMs = _toNullableElapsedMs(
          _currentElapsedRealtimeNanos,
        );
        final nativeReceiveElapsedMs =
            nativeEvent.receivedElapsedRealtimeNanos ~/ 1000000;
        _diagnostics?.record(
          StepDiagnosticEventType.transitionEventReceived,
          elapsedRealtimeMs: nativeReceiveElapsedMs,
          payload: <String, Object?>{
            'activity': nativeEvent.activityType,
            'transition': nativeEvent.transitionType,
            ..._transitionTimingPayload(
              nativeEvent,
              dartDequeuedElapsedMs: dartDequeuedElapsedMs,
            ),
            'transitionSessionId': nativeEvent.sessionId,
            'deduplicationKey': nativeEvent.id,
            'queueResult': 'peeked',
          },
        );
        if (_transitionSessionId != sessionId ||
            nativeEvent.sessionId != sessionId ||
            !_isTracking ||
            _isStopping) {
          continue;
        }
        final evidence = _toEvidence(nativeEvent);
        if (evidence == null) {
          _diagnostics?.record(
            StepDiagnosticEventType.transitionEventFiltered,
            elapsedRealtimeMs: nativeReceiveElapsedMs,
            payload: <String, Object?>{
              'deduplicationKey': nativeEvent.id,
              'reason': 'UNSUPPORTED_ACTIVITY_OR_TRANSITION',
            },
          );
          acknowledged.add(nativeEvent.id);
          continue;
        }
        final evidenceFloor = _transitionEvidenceFloorNanos;
        if (evidenceFloor != null &&
            evidence.eventElapsedRealtimeNanos < evidenceFloor) {
          final delayMs =
              (evidence.receivedElapsedRealtimeNanos -
                  evidence.eventElapsedRealtimeNanos) ~/
              1000000;
          logStepDiagnostic(
            '[STEP_TRANSITION_DUPLICATE] '
            'activity=${evidence.activity.storageName} '
            'transition=${evidence.transition.storageName} '
            'eventElapsedMs='
            '${evidence.eventElapsedRealtimeNanos ~/ 1000000} '
            'receivedElapsedMs='
            '${evidence.receivedElapsedRealtimeNanos ~/ 1000000} '
            'deliveryDelayMs=$delayMs sessionId=$sessionId '
            'reason=beforeSessionEvidenceFloor',
          );
          acknowledged.add(nativeEvent.id);
          continue;
        }
        final added =
            _deliveredTransitionIds.add(evidence.id) &&
            session.recordTransition(evidence);
        final dartProcessedElapsedMs = _toNullableElapsedMs(
          _currentElapsedRealtimeNanos,
        );
        final delayMs =
            (evidence.receivedElapsedRealtimeNanos -
                evidence.eventElapsedRealtimeNanos) ~/
            1000000;
        logStepDiagnostic(
          '[STEP_TRANSITION_${added ? 'DELIVER' : 'DUPLICATE'}] '
          'activity=${evidence.activity.storageName} '
          'transition=${evidence.transition.storageName} '
          'eventElapsedMs='
          '${evidence.eventElapsedRealtimeNanos ~/ 1000000} '
          'receivedElapsedMs='
          '${evidence.receivedElapsedRealtimeNanos ~/ 1000000} '
          'deliveryDelayMs=$delayMs sessionId=$sessionId',
        );
        if (added) {
          _diagnostics?.record(
            StepDiagnosticEventType.transitionEventDelivered,
            elapsedRealtimeMs: _toNullableElapsedMs(
              _currentElapsedRealtimeNanos,
            ),
            payload: <String, Object?>{
              'activity': evidence.activity.storageName,
              'transition': evidence.transition.storageName,
              ..._transitionTimingPayload(
                nativeEvent,
                dartDequeuedElapsedMs: dartDequeuedElapsedMs,
                dartProcessedElapsedMs: dartProcessedElapsedMs,
              ),
              'transitionSessionId': sessionId,
              'deduplicationKey': evidence.id,
              'queueResult': 'recorded',
            },
          );
          _diagnostics?.record(
            evidence.transition == ActivityTransitionType.enter
                ? StepDiagnosticEventType.transitionIntervalOpened
                : StepDiagnosticEventType.transitionIntervalClosed,
            elapsedRealtimeMs: evidence.eventElapsedRealtimeNanos ~/ 1000000,
            payload: <String, Object?>{
              'activity': evidence.activity.storageName,
              'transition': evidence.transition.storageName,
              'deduplicationKey': evidence.id,
              'affectedWindow': _windowId,
              if (evidence.transition == ActivityTransitionType.enter) ...{
                'intervalOpenedByEventElapsedRealtimeMs':
                    evidence.eventElapsedRealtimeNanos ~/ 1000000,
                'intervalOpenProcessedElapsedRealtimeMs':
                    dartProcessedElapsedMs,
              } else ...{
                'intervalClosedByEventElapsedRealtimeMs':
                    evidence.eventElapsedRealtimeNanos ~/ 1000000,
                'intervalCloseProcessedElapsedRealtimeMs':
                    dartProcessedElapsedMs,
              },
            },
          );
          _activity = session.activityAt(evidence.receivedElapsedRealtimeNanos);
          logStepDiagnostic(
            '[STEP_TRANSITION_INTERVAL] '
            'activity=${evidence.activity.storageName} '
            'transition=${evidence.transition.storageName} '
            'eventElapsedMs='
            '${evidence.eventElapsedRealtimeNanos ~/ 1000000} '
            'receivedElapsedMs='
            '${evidence.receivedElapsedRealtimeNanos ~/ 1000000} '
            'deliveryDelayMs=$delayMs sessionId=$sessionId '
            'displayActivity=${_activity.storageName}',
          );
          _publish(reason: 'transitionUpdate');
        }
        acknowledged.add(nativeEvent.id);
      }
      if (acknowledged.isNotEmpty && _transitionSessionId == sessionId) {
        await ActivityTransitionBridge.acknowledge(
          sessionId: sessionId,
          eventIds: acknowledged,
        );
      }
    } catch (error, stackTrace) {
      logStepDiagnostic(
        '[STEP_TRANSITION_DELIVER] activity=UNKNOWN transition=UNKNOWN '
        'eventElapsedMs=none receivedElapsedMs=none deliveryDelayMs=none '
        'sessionId=$sessionId result=error error=$error '
        'stack=${_singleLineStack(stackTrace)}',
      );
    } finally {
      _isDrainingTransitions = false;
      final shouldFinalize =
          finalizePendingAfterDrain || _finalizeAfterCurrentDrain;
      _finalizeAfterCurrentDrain = false;
      if (shouldFinalize &&
          _transitionSessionId == sessionId &&
          _isTracking &&
          !_isStopping) {
        _finalizePendingWindow();
      }
    }
  }

  Future<void> _drainNativeReceiverDiagnostics() async {
    final logger = _diagnostics;
    if (logger == null) return;
    final lines = await ActivityTransitionBridge.peekReceiverDiagnostics(
      diagnosticSessionId: logger.sessionId,
    );
    if (lines.isEmpty) return;
    final persistedIds = <String>[];
    for (final line in lines) {
      try {
        final decoded = jsonDecode(line);
        if (decoded is! Map) continue;
        final event = decoded.map<String, Object?>(
          (key, value) => MapEntry(key.toString(), value),
        );
        final diagnosticId = event['diagnosticId']?.toString();
        if (diagnosticId == null) continue;
        if (logger.hasImportedDiagnosticId(diagnosticId) ||
            logger.importPersistedEvent(event)) {
          persistedIds.add(diagnosticId);
        }
      } catch (_) {
        // A malformed diagnostic record must not affect Transition delivery.
      }
    }
    await logger.flush();
    if (persistedIds.isNotEmpty) {
      await ActivityTransitionBridge.acknowledgeReceiverDiagnostics(
        diagnosticSessionId: logger.sessionId,
        diagnosticIds: persistedIds,
      );
    }
  }

  ActivityTransitionEvidence? _toEvidence(NativeActivityTransitionEvent event) {
    final activity = TrackingActivity.fromStorage(event.activityType);
    if (activity == TrackingActivity.unknown) return null;
    final transition = switch (event.transitionType) {
      'ENTER' => ActivityTransitionType.enter,
      'EXIT' => ActivityTransitionType.exit,
      _ => null,
    };
    if (transition == null) return null;
    return ActivityTransitionEvidence(
      id: event.id,
      sessionId: event.sessionId,
      activity: activity,
      transition: transition,
      eventElapsedRealtimeNanos: event.eventElapsedRealtimeNanos,
      receivedElapsedRealtimeNanos: event.receivedElapsedRealtimeNanos,
    );
  }

  void _finalizePendingWindow() {
    final session = _session;
    if (session == null) return;
    final validationStartedElapsedMs = _toNullableElapsedMs(
      _currentElapsedRealtimeNanos,
    );
    final confirmedBefore = session.confirmedSteps;
    final provisionalBefore = session.provisionalSteps;
    final result = session.finalizePendingWindow();
    final validationCompletedElapsedMs = _toNullableElapsedMs(
      _currentElapsedRealtimeNanos,
    );
    if (result == null) return;
    final sessionId = _transitionSessionId ?? 'none';

    for (final bucket in result.buckets) {
      final bucketStartElapsedMs =
          result.windowStartElapsedRealtimeNanos ~/ 1000000 +
          bucket.bucketIndex * validationPolicy.bucketDuration.inMilliseconds;
      final bucketEndElapsedMs =
          bucketStartElapsedMs + validationPolicy.bucketDuration.inMilliseconds;
      _diagnostics?.record(
        StepDiagnosticEventType.bucketValidation,
        elapsedRealtimeMs: result.windowEndElapsedRealtimeNanos ~/ 1000000,
        windowId: _windowId,
        bucketIndex: bucket.bucketIndex,
        payload: <String, Object?>{
          'bucketStartElapsedRealtimeMs': bucketStartElapsedMs,
          'bucketEndElapsedRealtimeMs': bucketEndElapsedMs,
          'validationStartedElapsedRealtimeMs': validationStartedElapsedMs,
          'validationCompletedElapsedRealtimeMs': validationCompletedElapsedMs,
          'validationDurationMs': _durationOrNull(
            validationStartedElapsedMs,
            validationCompletedElapsedMs,
          ),
          'candidateSteps': bucket.candidateSteps,
          'acceptedSteps': bucket.acceptedSteps,
          'rejectedSteps': bucket.rejectedSteps,
          'validationReason': bucket.acceptedSteps > 0
              ? 'ACCEPTED_WALKING_OR_RUNNING_INTERVAL'
              : (bucket.disqualifyingIntervals.isNotEmpty
                    ? 'REJECTED_VEHICLE_OR_BICYCLE'
                    : 'REJECTED_NO_QUALIFYING_INTERVAL'),
          'activityEvidenceUsed': <String, Object?>{
            'qualifyingIntervals': _intervalPayload(bucket.qualifyingIntervals),
            'disqualifyingIntervals': _intervalPayload(
              bucket.disqualifyingIntervals,
            ),
          },
          'activityEvidenceIgnored': const <Object?>[],
        },
      );
      logStepDiagnostic(
        '[STEP_TRANSITION_WINDOW_VALIDATION] '
        'windowStartElapsedMs='
        '${result.windowStartElapsedRealtimeNanos ~/ 1000000} '
        'windowEndElapsedMs='
        '${result.windowEndElapsedRealtimeNanos ~/ 1000000} '
        'bucket=${bucket.bucketIndex} '
        'candidateSteps=${bucket.candidateSteps} '
        'acceptedSteps=${bucket.acceptedSteps} '
        'rejectedSteps=${bucket.rejectedSteps} '
        'walkingRunningIntervalOverlap='
        '${_intervalLog(bucket.qualifyingIntervals)} '
        'vehicleBicycleIntervalOverlap='
        '${_intervalLog(bucket.disqualifyingIntervals)} '
        'sessionId=$sessionId',
      );
      logStepDiagnostic(
        '[STEP_BUCKET_VALIDATION] bucket=${bucket.bucketIndex} '
        'steps=${bucket.candidateSteps} '
        'accepted=${bucket.acceptedSteps} '
        'rejected=${bucket.rejectedSteps} '
        'transitionOnly=true',
      );
    }
    _diagnostics?.record(
      StepDiagnosticEventType.windowValidation,
      elapsedRealtimeMs: result.windowEndElapsedRealtimeNanos ~/ 1000000,
      windowId: _windowId,
      payload: <String, Object?>{
        'windowStartElapsedRealtimeMs':
            result.windowStartElapsedRealtimeNanos ~/ 1000000,
        'windowEndElapsedRealtimeMs':
            result.windowEndElapsedRealtimeNanos ~/ 1000000,
        'validationStartedElapsedRealtimeMs': validationStartedElapsedMs,
        'validationCompletedElapsedRealtimeMs': validationCompletedElapsedMs,
        'validationDurationMs': _durationOrNull(
          validationStartedElapsedMs,
          validationCompletedElapsedMs,
        ),
        ..._timingInvariantPayload(<(String, int?, int?)>[
          (
            'windowStartElapsedRealtimeMs<=windowEndElapsedRealtimeMs',
            result.windowStartElapsedRealtimeNanos ~/ 1000000,
            result.windowEndElapsedRealtimeNanos ~/ 1000000,
          ),
          (
            'validationStartedElapsedRealtimeMs<=validationCompletedElapsedRealtimeMs',
            validationStartedElapsedMs,
            validationCompletedElapsedMs,
          ),
        ]),
        'candidateSteps': result.confirmedStepsAdded + result.stepsRejected,
        'acceptedSteps': result.confirmedStepsAdded,
        'rejectedSteps': result.stepsRejected,
        'confirmedTotalBeforeValidation': confirmedBefore,
        'confirmedTotalAfterValidation': session.confirmedSteps,
        'provisionalTotalBeforeValidation': provisionalBefore,
        'provisionalTotalAfterValidation': session.provisionalSteps,
      },
      flush: true,
    );
    logStepDiagnostic(
      '[STEP_VALIDATION] accepted=${result.confirmedStepsAdded} '
      'rejected=${result.stepsRejected} '
      'confirmedTotal=${session.confirmedSteps} '
      'provisionalTotal=${session.provisionalSteps} '
      'displayedTotal=${session.displayedSteps}',
    );
    _publish(reason: 'validationComplete', persist: true);
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    unawaited(_drainTransitions());
  }

  void _onStepCountError(Object error, StackTrace stackTrace) {
    _diagnostics?.record(
      StepDiagnosticEventType.pedometerError,
      payload: <String, Object?>{'failureType': error.runtimeType.toString()},
      flush: true,
    );
    logStepDiagnostic(
      '[STEP_SENSOR_ERROR] timestamp=${DateTime.now().toIso8601String()} '
      'error=$error stack=${_singleLineStack(stackTrace)}',
    );
    _error = 'Pedometer error: $error';
    unawaited(_stopTracking(reason: 'pedometer_error'));
  }

  StepSnapshot _buildSnapshot() {
    final session = _session;
    return StepSnapshot(
      confirmedSteps: session?.confirmedSteps ?? 0,
      provisionalSteps: session?.provisionalSteps ?? 0,
      isTracking: _isTracking,
      sensorReady: session?.sensorReady ?? false,
      activity: _activity,
      // Retained only for transport compatibility. Transition validation and
      // presentation do not use or display this value.
      confidence: TrackingConfidence.low,
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
      elapsedRealtimeMs: _toNullableElapsedMs(_currentElapsedRealtimeNanos),
      payload: _snapshotPayload(snapshot, reason: reason),
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
      elapsedRealtimeMs: _toNullableElapsedMs(_currentElapsedRealtimeNanos),
      payload: _snapshotPayload(snapshot, reason: reason),
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
      'windowStartElapsedMs='
      '${_toElapsedMs(_session?.activeWindowStartElapsedRealtimeNanos)} '
      'provisional=${_session?.provisionalSteps ?? 0} reason=$reason '
      'windowActive=${_session?.hasActiveWindow ?? false}',
    );
  }

  void _cancelGraceTimer() {
    _graceTimer?.cancel();
    _graceTimer = null;
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
            payload: _snapshotPayload(snapshot, reason: reason),
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
        _cancelGraceTimer();
        _session?.reset();
        _activity = TrackingActivity.unknown;
        _deliveredTransitionIds.clear();
        _transitionEvidenceFloorNanos = _currentElapsedRealtimeNanos;
        final sessionId = _transitionSessionId;
        if (sessionId != null) {
          unawaited(ActivityTransitionBridge.clear(sessionId: sessionId));
        }
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
      'subscriptions=${_stepSubscription != null} '
      'windowActive=${_session?.hasActiveWindow ?? false}',
    );
    _isStopping = true;
    _diagnostics?.record(
      StepDiagnosticEventType.serviceStop,
      payload: <String, Object?>{'reason': reason},
      flush: true,
    );
    _isTracking = false;
    _stopReason = reason;
    _cancelValidationTimer('stop:$reason');
    _cancelGraceTimer();
    _cancelNotificationTimer();
    _session?.stop();
    await _cancelPedometerSubscription();
    await _unregisterTransitionsBestEffort();
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
        _diagnostics?.record(
          StepDiagnosticEventType.hiveWrite,
          payload: _snapshotPayload(snapshot, reason: 'serviceStopped'),
          flush: true,
        );
      }
    });
  }

  Future<void> _cancelPedometerSubscription() async {
    if (_stepSubscription != null) {
      logStepDiagnostic(
        '[STEP_SENSOR_CANCEL] timestamp=${DateTime.now().toIso8601String()}',
      );
    }
    await _stepSubscription?.cancel();
    _stepSubscription = null;
    _diagnostics?.record(StepDiagnosticEventType.pedometerUnsubscribe);
  }

  Future<void> _unregisterTransitionsBestEffort() async {
    final sessionId = _transitionSessionId;
    _transitionSessionId = null;
    _monotonicClock?.stop();
    _monotonicClock = null;
    _elapsedRealtimeAnchorNanos = null;
    _transitionEvidenceFloorNanos = null;
    if (sessionId == null) return;
    try {
      await ActivityTransitionBridge.unregister(sessionId: sessionId);
      _diagnostics?.record(
        StepDiagnosticEventType.transitionUnregister,
        payload: <String, Object?>{
          'transitionSessionId': sessionId,
          'result': 'unregistered',
        },
      );
      logStepDiagnostic(
        '[STEP_TRANSITION_UNREGISTER] activity=ALL transition=ENTER_EXIT '
        'eventElapsedMs=none receivedElapsedMs=none deliveryDelayMs=0 '
        'sessionId=$sessionId result=unregistered',
      );
    } catch (error, stackTrace) {
      logStepDiagnostic(
        '[STEP_TRANSITION_UNREGISTER] activity=ALL transition=ENTER_EXIT '
        'eventElapsedMs=none receivedElapsedMs=none deliveryDelayMs=none '
        'sessionId=$sessionId result=error error=$error '
        'stack=${_singleLineStack(stackTrace)}',
      );
    }
    _deliveredTransitionIds.clear();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    logStepDiagnostic(
      '[STEP_SERVICE_DESTROY] timestamp=${timestamp.toIso8601String()} '
      'tracking=$_isTracking subscriptions=${_stepSubscription != null} '
      'windowActive=${_session?.hasActiveWindow ?? false} timeout=$isTimeout',
    );
    _isTracking = false;
    _diagnostics?.record(
      StepDiagnosticEventType.serviceDestroy,
      payload: <String, Object?>{'isTimeout': isTimeout},
      flush: true,
    );
    _isStopping = true;
    _cancelValidationTimer('destroy');
    _cancelGraceTimer();
    _cancelNotificationTimer();
    _session?.stop();
    _stopReason ??= isTimeout ? 'service_timeout' : 'service_destroyed';
    await _cancelPedometerSubscription();
    await _unregisterTransitionsBestEffort();
    await _persistFinalSnapshot();
    await _store?.close();
    _store = null;
    await _diagnostics?.close(finalize: true, incomplete: isTimeout);
    _diagnostics = null;
  }

  int? get _currentElapsedRealtimeNanos {
    final anchor = _elapsedRealtimeAnchorNanos;
    final clock = _monotonicClock;
    if (anchor == null || clock == null) return null;
    return anchor + clock.elapsedMicroseconds * 1000;
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

  String _intervalLog(List<ActivityInterval> intervals) {
    if (intervals.isEmpty) return 'none';
    return intervals
        .map(
          (interval) =>
              '${interval.activity.storageName}:'
              '${interval.startElapsedRealtimeNanos ~/ 1000000}-'
              '${interval.endElapsedRealtimeNanos ~/ 1000000}',
        )
        .join(',');
  }

  String _toElapsedMs(int? elapsedNanos) {
    return elapsedNanos == null ? 'none' : '${elapsedNanos ~/ 1000000}';
  }

  int? _toNullableElapsedMs(int? elapsedNanos) =>
      elapsedNanos == null ? null : elapsedNanos ~/ 1000000;

  Map<String, Object?> _snapshotPayload(
    StepSnapshot snapshot, {
    required String reason,
  }) => <String, Object?>{
    'reason': reason,
    'confirmedSteps': snapshot.confirmedSteps,
    'provisionalSteps': snapshot.provisionalSteps,
    'displayedSteps': snapshot.displayedSteps,
    'isTracking': snapshot.isTracking,
    'activity': snapshot.activity.storageName,
  };

  List<Map<String, Object?>> _intervalPayload(
    List<ActivityInterval> intervals,
  ) => intervals
      .map(
        (interval) => <String, Object?>{
          'activity': interval.activity.storageName,
          'startElapsedRealtimeMs':
              interval.startElapsedRealtimeNanos ~/ 1000000,
          'endElapsedRealtimeMs': interval.endElapsedRealtimeNanos ~/ 1000000,
        },
      )
      .toList(growable: false);

  Map<String, Object?> _transitionTimingPayload(
    NativeActivityTransitionEvent event, {
    required int? dartDequeuedElapsedMs,
    int? dartProcessedElapsedMs,
  }) {
    final eventMs = event.eventElapsedRealtimeNanos ~/ 1000000;
    final receiverMs = event.receiverEnteredElapsedRealtimeNanos ~/ 1000000;
    final parsedMs = _toNullableElapsedMs(
      event.transitionResultParsedElapsedRealtimeNanos,
    );
    final queuedMs = _toNullableElapsedMs(
      event.transitionQueuedElapsedRealtimeNanos,
    );
    return <String, Object?>{
      'transitionEventElapsedRealtimeNanos': event.eventElapsedRealtimeNanos,
      'transitionEventElapsedRealtimeMs': eventMs,
      'receiverEnteredElapsedRealtimeMs': receiverMs,
      'transitionResultParsedElapsedRealtimeMs': parsedMs,
      'transitionQueuedElapsedRealtimeMs': queuedMs,
      'dartDequeuedElapsedRealtimeMs': dartDequeuedElapsedMs,
      'dartProcessedElapsedRealtimeMs': dartProcessedElapsedMs,
      'transitionDeliveryDelayMs': receiverMs - eventMs,
      'receiverParsingDelayMs': _durationOrNull(receiverMs, parsedMs),
      'nativeQueueDelayMs': _durationOrNull(parsedMs, queuedMs),
      'nativeToDartDelayMs': _durationOrNull(queuedMs, dartDequeuedElapsedMs),
      'dartProcessingDelayMs': _durationOrNull(
        dartDequeuedElapsedMs,
        dartProcessedElapsedMs,
      ),
      'totalEventToDartProcessingDelayMs': _durationOrNull(
        eventMs,
        dartProcessedElapsedMs,
      ),
      'eventSessionOffsetMs':
          _diagnostics?.sessionStartElapsedRealtimeMs == null
          ? null
          : eventMs - _diagnostics!.sessionStartElapsedRealtimeMs!,
      ..._timingInvariantPayload(<(String, int?, int?)>[
        (
          'transitionEventElapsedRealtimeMs<=receiverEnteredElapsedRealtimeMs',
          eventMs,
          receiverMs,
        ),
        (
          'receiverEnteredElapsedRealtimeMs<=transitionResultParsedElapsedRealtimeMs',
          receiverMs,
          parsedMs,
        ),
        (
          'transitionResultParsedElapsedRealtimeMs<=transitionQueuedElapsedRealtimeMs',
          parsedMs,
          queuedMs,
        ),
        (
          'transitionQueuedElapsedRealtimeMs<=dartDequeuedElapsedRealtimeMs',
          queuedMs,
          dartDequeuedElapsedMs,
        ),
        (
          'dartDequeuedElapsedRealtimeMs<=dartProcessedElapsedRealtimeMs',
          dartDequeuedElapsedMs,
          dartProcessedElapsedMs,
        ),
      ]),
    };
  }

  int? _durationOrNull(int? startMs, int? endMs) =>
      startMs == null || endMs == null ? null : endMs - startMs;

  Map<String, Object?> _timingInvariantPayload(
    List<(String, int?, int?)> checks,
  ) {
    final failures = <String>[];
    for (final (name, start, end) in checks) {
      if (start != null && end != null && start > end) failures.add(name);
    }
    return <String, Object?>{
      'timingInvariantPassed': failures.isEmpty,
      'timingInvariantFailures': failures,
    };
  }

  String _singleLineStack(StackTrace stackTrace) {
    return stackTrace.toString().replaceAll('\n', ' | ');
  }
}
