import 'dart:async';

import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer/pedometer.dart';

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

      _store = StepLocalStore(directoryPath: directoryPath);
      final previousSnapshot = await _store!.readSnapshot(
        reason: 'serviceStart',
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
      _error = 'Service initialization failed: $error';
      _isTracking = false;
      _stopReason = 'initialization_error';

      await _persistFinalSnapshot();
      await FlutterForegroundTask.stopService();
    }
  }

  void _subscribeToPedometer() {
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
    logStepDiagnostic(
      '[STEP_ACTIVITY_SUBSCRIBE] timestamp=${DateTime.now().toIso8601String()} '
      'alreadySubscribed=${_activitySubscription != null}',
    );
    _activitySubscription = FlutterActivityRecognition.instance.activityStream
        .listen(
          _onActivityChanged,
          onError: _onActivityError,
          cancelOnError: false,
        );
  }

  void _onStepCount(StepCount event) {
    final session = _session;
    final now = DateTime.now();
    final previousRawSteps = session?.lastRawSteps;
    final delta = previousRawSteps == null
        ? null
        : event.steps - previousRawSteps;

    if (!_isTracking || _isStopping || session == null) {
      logStepDiagnostic(
        '[STEP_SENSOR] raw=${event.steps} '
        'previous=${previousRawSteps ?? 'none'} delta=${delta ?? 'none'} '
        'timestamp=${now.toIso8601String()} result=ignoredNotTracking',
      );
      return;
    }

    _completeExpiredWindowIfNeeded(now);

    final update = session.recordRawReading(
      cumulativeRawSteps: event.steps,
      timestamp: now,
    );
    logStepDiagnostic(
      '[STEP_SENSOR] raw=${event.steps} '
      'previous=${previousRawSteps ?? 'none'} delta=${delta ?? 'none'} '
      'timestamp=${now.toIso8601String()} '
      'result=${_sensorResult(update.status, delta)}',
    );

    switch (update.status) {
      case RawStepStatus.baselineEstablished:
        _publish(reason: 'sensorBaseline');
        return;
      case RawStepStatus.ignored:
        return;
      case RawStepStatus.provisionalAdded:
        final appliedEvidence = update.appliedActivityEvidence;
        if (appliedEvidence != null) {
          logStepDiagnostic(
            '[STEP_ACTIVITY_APPLIED] '
            'type=${appliedEvidence.activity.storageName} '
            'confidence=${appliedEvidence.confidence.storageName} '
            'ageMs=${appliedEvidence.age.inMilliseconds} '
            'bucket=${appliedEvidence.bucketIndex} '
            'steps=${appliedEvidence.bucketCandidateSteps}',
          );
        } else if (update.staleActivityEvidenceAge != null) {
          logStepDiagnostic(
            '[STEP_ACTIVITY_STALE] '
            'type=${session.latestActivity?.storageName ?? 'UNKNOWN'} '
            'confidence='
            '${session.latestActivityConfidence?.storageName ?? 'LOW'} '
            'ageMs=${update.staleActivityEvidenceAge!.inMilliseconds} '
            'bucket=${update.bucketIndex ?? 'none'}',
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
    final activity = event.type.toTrackingActivity();
    final confidence = event.confidence.toTrackingConfidence();
    if (!_isTracking || _isStopping || session == null) {
      logStepDiagnostic(
        '[STEP_ACTIVITY] type=${activity.storageName} '
        'confidence=${confidence.storageName} '
        'timestamp=${now.toIso8601String()} windowActive=false '
        'bucket=none result=ignoredNotTracking',
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
    for (var index = 0; index < buckets.length; index++) {
      final bucket = buckets[index];
      final valid = validationPolicy.isValidBucket(
        observedWalkingOrRunning: bucket.observedWalkingOrRunning,
        observedVehicleOrBicycle: bucket.observedVehicleOrBicycle,
        bestWalkingConfidence: bucket.bestWalkingConfidence,
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
    logStepDiagnostic(
      '[STEP_SENSOR_ERROR] timestamp=${DateTime.now().toIso8601String()} '
      'error=$error stack=${_singleLineStack(stackTrace)}',
    );
    _error = 'Pedometer error: $error';
    unawaited(_stopTracking(reason: 'pedometer_error'));
  }

  void _onActivityError(Object error, StackTrace stackTrace) {
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
      'payload': snapshot.toMap(),
    });
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
        .then<void>((_) => store.writeSnapshot(snapshot, reason: reason))
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
        _cancelValidationTimer('reset');
        _session?.reset();
        _error = null;
        _stopReason = null;
        _publish(reason: 'reset', persist: true);
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
    if (_activitySubscription != null) {
      logStepDiagnostic(
        '[STEP_ACTIVITY_CANCEL] timestamp=${DateTime.now().toIso8601String()}',
      );
    }
    await _activitySubscription?.cancel();
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
    _cancelValidationTimer('destroy');
    _cancelNotificationTimer();
    _session?.stop();
    _stopReason ??= isTimeout ? 'service_timeout' : 'service_destroyed';

    await _cancelSubscriptions();
    await _persistFinalSnapshot();
    await _store?.close();
    _store = null;
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
