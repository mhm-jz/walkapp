import 'dart:async';

import 'package:activity_transition_bridge/activity_transition_bridge.dart';
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

      _store = StepLocalStore(directoryPath: directoryPath);
      final previousSnapshot = await _store!.readSnapshot(
        reason: 'serviceStart',
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
    final registration = await ActivityTransitionBridge.register(
      sessionId: sessionId,
    );
    if (registration.sessionId != sessionId) {
      throw StateError('Transition registration session mismatch.');
    }
    _elapsedRealtimeAnchorNanos = registration.sessionStartElapsedRealtimeNanos;
    _transitionEvidenceFloorNanos =
        registration.sessionStartElapsedRealtimeNanos;
    _monotonicClock = Stopwatch()..start();
    final elapsedMs = registration.sessionStartElapsedRealtimeNanos ~/ 1000000;
    logStepDiagnostic(
      '[STEP_TRANSITION_REGISTER] activity=ALL transition=ENTER_EXIT '
      'eventElapsedMs=$elapsedMs receivedElapsedMs=$elapsedMs '
      'deliveryDelayMs=0 sessionId=$sessionId result=registered',
    );
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
      return;
    }

    _closeExpiredWindowIfNeeded(elapsedNanos);
    final update = session.recordRawReading(
      cumulativeRawSteps: event.steps,
      elapsedRealtimeNanos: elapsedNanos,
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
        _publish(reason: 'sensorBaseline');
        return;
      case RawStepStatus.ignored:
        return;
      case RawStepStatus.provisionalAdded:
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
      final events = await ActivityTransitionBridge.peek(sessionId: sessionId);
      final acknowledged = <String>[];
      for (final nativeEvent in events) {
        if (_transitionSessionId != sessionId ||
            nativeEvent.sessionId != sessionId ||
            !_isTracking ||
            _isStopping) {
          continue;
        }
        final evidence = _toEvidence(nativeEvent);
        if (evidence == null) {
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
    final result = session?.finalizePendingWindow();
    if (session == null || result == null) return;
    final sessionId = _transitionSessionId ?? 'none';

    for (final bucket in result.buckets) {
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

  String _singleLineStack(StackTrace stackTrace) {
    return stackTrace.toString().replaceAll('\n', ' | ');
  }
}
