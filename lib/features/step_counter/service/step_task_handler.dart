import 'dart:async';

import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer/pedometer.dart';

import '../data/step_local_store.dart';
import '../data/step_snapshot.dart';
import '../domain/step_validation_policy.dart';
import '../domain/step_validation_session.dart';
import '../domain/tracking_activity.dart';
import 'final_snapshot_persistence.dart';

final class StepTaskHandler extends TaskHandler {
  StepTaskHandler({this.validationPolicy = const StepValidationPolicy()});

  final StepValidationPolicy validationPolicy;

  StepLocalStore? _store;
  StepValidationSession? _session;
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<Activity>? _activitySubscription;
  Timer? _validationTimer;

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

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    try {
      final directoryPath = await FlutterForegroundTask.getData<String>(
        key: StepLocalStore.taskHivePathKey,
      );

      if (directoryPath == null || directoryPath.isEmpty) {
        throw StateError('Hive path was not provided to the service.');
      }

      _store = StepLocalStore(directoryPath: directoryPath);
      final previousSnapshot = await _store!.readSnapshot();

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
      _publish(persist: true);
    } catch (error) {
      _error = 'Service initialization failed: $error';
      _isTracking = false;
      _stopReason = 'initialization_error';

      await _persistFinalSnapshot();
      await FlutterForegroundTask.stopService();
    }
  }

  void _subscribeToPedometer() {
    _stepSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
      cancelOnError: false,
    );
  }

  void _subscribeToActivity() {
    _activitySubscription = FlutterActivityRecognition.instance.activityStream
        .listen(
          _onActivityChanged,
          onError: _onActivityError,
          cancelOnError: false,
        );
  }

  void _onStepCount(StepCount event) {
    if (!_isTracking || _isStopping) return;

    final session = _session;
    if (session == null) return;

    final now = DateTime.now();
    _completeExpiredWindowIfNeeded(now);

    final update = session.recordRawReading(
      cumulativeRawSteps: event.steps,
      timestamp: now,
    );

    switch (update.status) {
      case RawStepStatus.baselineEstablished:
        _publish();
        return;
      case RawStepStatus.ignored:
        return;
      case RawStepStatus.provisionalAdded:
        if (update.startedWindow) {
          _startValidationTimer();
        }
        // Provisional and displayed values reach UI and notification now.
        _publish();
    }
  }

  void _onActivityChanged(Activity event) {
    if (!_isTracking || _isStopping) return;

    final session = _session;
    if (session == null) return;

    final now = DateTime.now();
    _completeExpiredWindowIfNeeded(now);

    _activity = event.type.toTrackingActivity();
    _confidence = event.confidence.toTrackingConfidence();
    session.recordActivity(
      activity: _activity,
      confidence: _confidence,
      timestamp: now,
    );

    _publish();
  }

  void _startValidationTimer() {
    _validationTimer?.cancel();
    _validationTimer = Timer(
      validationPolicy.windowDuration,
      _onValidationTimerCompleted,
    );
  }

  void _onValidationTimerCompleted() {
    _validationTimer = null;
    if (!_isTracking || _isStopping) return;

    _completeValidationWindow();
  }

  void _completeExpiredWindowIfNeeded(DateTime timestamp) {
    final session = _session;
    if (session != null && session.isWindowExpired(timestamp)) {
      _validationTimer?.cancel();
      _validationTimer = null;
      _completeValidationWindow();
    }
  }

  void _completeValidationWindow() {
    final session = _session;
    if (session == null || !session.hasActiveWindow) return;

    session.completeWindow();
    _publish(persist: true);
  }

  void _onStepCountError(Object error) {
    _error = 'Pedometer error: $error';
    unawaited(_stopTracking(reason: 'pedometer_error'));
  }

  void _onActivityError(Object error) {
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

  void _publish({bool persist = false}) {
    final snapshot = _buildSnapshot();
    _sendToMain(snapshot);
    _updateNotificationIfChanged(snapshot);

    if (persist) {
      _enqueueSnapshotWrite(snapshot);
    }
  }

  void _sendToMain(StepSnapshot snapshot) {
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
    if (notificationText == _lastNotificationText) return;

    _lastNotificationText = notificationText;
    unawaited(
      FlutterForegroundTask.updateService(
        notificationTitle: 'قدم‌شمار فعال است',
        notificationText: notificationText,
      ),
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

  void _enqueueSnapshotWrite(StepSnapshot snapshot) {
    final store = _store;
    if (store == null) return;

    _writeChain = _writeChain
        .then<void>((_) => store.writeSnapshot(snapshot))
        .catchError((Object error, StackTrace stackTrace) {
          _error = 'Hive write error: $error';
        });
  }

  @override
  void onReceiveData(Object data) {
    if (data is! Map) return;

    switch (data['command']?.toString()) {
      case 'get_snapshot':
        _publish();
        break;
      case 'reset_steps':
        _validationTimer?.cancel();
        _validationTimer = null;
        _session?.reset();
        _error = null;
        _stopReason = null;
        _publish(persist: true);
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

    _isStopping = true;
    _isTracking = false;
    _stopReason = reason;
    _validationTimer?.cancel();
    _validationTimer = null;
    _session?.stop();

    await _cancelSubscriptions();
    await _persistFinalSnapshot();
    await FlutterForegroundTask.stopService();
  }

  Future<void> _persistFinalSnapshot() {
    return _finalPersistence.run(() async {
      final snapshot = _buildSnapshot();
      _sendToMain(snapshot);

      await _writeChain;
      final store = _store;
      if (store != null) {
        await store.writeSnapshot(snapshot, flush: true);
      }
    });
  }

  Future<void> _cancelSubscriptions() async {
    await _stepSubscription?.cancel();
    await _activitySubscription?.cancel();
    _stepSubscription = null;
    _activitySubscription = null;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _isTracking = false;
    _validationTimer?.cancel();
    _validationTimer = null;
    _session?.stop();
    _stopReason ??= isTimeout ? 'service_timeout' : 'service_destroyed';

    await _cancelSubscriptions();
    await _persistFinalSnapshot();
    await _store?.close();
    _store = null;
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
