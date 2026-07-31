import 'dart:io';

import 'package:activity_transition_bridge/activity_transition_bridge.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/diagnostics/step_diagnostic_event.dart';
import '../../../core/diagnostics/step_diagnostic_logger.dart';
import '../data/step_local_store.dart';
import '../domain/step_tracking_service.dart';
import 'step_task_handler.dart';

@pragma('vm:entry-point')
void startStepTrackingCallback() {
  FlutterForegroundTask.setTaskHandler(StepTaskHandler());
}

final class StepForegroundService
    implements
        StepTrackingService,
        ActivityAccessRequester,
        StepDiagnosticRecorder {
  StepForegroundService();

  bool _initialized = false;
  StepDiagnosticLogger? _diagnostics;
  String? _diagnosticSessionId;

  @override
  String? get diagnosticSessionId => _diagnosticSessionId;

  @override
  Future<void> prepareDiagnosticSession(
    Map<String, Object?> startSnapshot,
  ) async {
    final directory = await getApplicationSupportDirectory();
    final sessionStartElapsedRealtimeNanos =
        await ActivityTransitionBridge.elapsedRealtimeNanos();
    final logger = await StepDiagnosticLogger.create(
      applicationSupportPath: directory.path,
      source: 'main',
      createDescriptor: true,
      sessionStartElapsedRealtimeMs: sessionStartElapsedRealtimeNanos == null
          ? null
          : sessionStartElapsedRealtimeNanos ~/ 1000000,
    );
    _diagnostics = logger;
    _diagnosticSessionId = logger?.sessionId;
    logger?.record(
      StepDiagnosticEventType.sessionCreated,
      payload: startSnapshot,
      flush: true,
    );
    logger?.record(
      StepDiagnosticEventType.trackingStartRequested,
      payload: startSnapshot,
    );
  }

  @override
  void recordDiagnosticEvent(
    String eventType, {
    Map<String, Object?> payload = const <String, Object?>{},
  }) {
    _diagnostics?.record(eventType, payload: payload);
  }

  @override
  void initialize() {
    if (_initialized) return;

    FlutterForegroundTask.initCommunicationPort();

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'step_tracking_channel',
        channelName: 'Step tracking',
        channelDescription:
            'Shown while step tracking is active in the background.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,

        // If Android kills the service, do not restart it automatically.
        allowAutoRestart: false,

        // Removing the UI from Recent Apps must not stop the service.
        stopWithTask: false,
      ),
    );

    _initialized = true;
  }

  @override
  Future<bool> isRunning() {
    return FlutterForegroundTask.isRunningService;
  }

  @override
  Future<void> start() async {
    initialize();

    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'This MVP foreground step tracker is implemented for Android.',
      );
    }

    if (await isRunning()) {
      requestSnapshot();
      return;
    }

    await _ensurePermissions();

    final directory = await getApplicationSupportDirectory();

    final pathSaved = await FlutterForegroundTask.saveData(
      key: StepLocalStore.taskHivePathKey,
      value: directory.path,
    );

    if (!pathSaved) {
      throw StateError('Could not save the Hive path for the service.');
    }

    final diagnosticSessionId = _diagnosticSessionId;
    if (diagnosticSessionId != null) {
      await FlutterForegroundTask.saveData(
        key: StepLocalStore.taskDiagnosticSessionIdKey,
        value: diagnosticSessionId,
      );
      final sessionStartElapsedMs = _diagnostics?.sessionStartElapsedRealtimeMs;
      if (sessionStartElapsedMs != null) {
        await FlutterForegroundTask.saveData(
          key: StepLocalStore.taskDiagnosticSessionStartElapsedMsKey,
          value: sessionStartElapsedMs,
        );
      }
    }

    final result = await FlutterForegroundTask.startService(
      serviceId: 1001,
      serviceTypes: const <ForegroundServiceTypes>[
        ForegroundServiceTypes.health,
      ],
      notificationTitle: 'قدم‌شمار فعال است',
      notificationText: 'در حال آماده‌سازی سنسورها...',
      notificationButtons: const <NotificationButton>[
        NotificationButton(id: 'stop_tracking', text: 'توقف'),
      ],
      notificationInitialRoute: '/',
      callback: startStepTrackingCallback,
    );

    if (result is ServiceRequestFailure) {
      _diagnostics?.record(
        StepDiagnosticEventType.serviceError,
        payload: const <String, Object?>{
          'failureType': 'ServiceRequestFailure',
        },
        flush: true,
      );
      throw StateError('Foreground service could not start: ${result.error}');
    }
    _diagnostics?.record(StepDiagnosticEventType.trackingStarted, flush: true);
  }

  @override
  Future<void> stop() async {
    if (!await isRunning()) return;

    _diagnostics?.record(StepDiagnosticEventType.trackingStopRequested);
    FlutterForegroundTask.sendDataToTask(<String, dynamic>{
      'command': 'stop_tracking',
      'reason': 'user',
    });

    // Give TaskHandler time to persist the final snapshot and stop itself.
    for (var attempt = 0; attempt < 20; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      if (!await isRunning()) {
        _diagnostics?.record(StepDiagnosticEventType.trackingStopped);
        await _diagnostics?.close();
        _diagnostics = null;
        return;
      }
    }

    // Fallback if communication with TaskHandler failed.
    final result = await FlutterForegroundTask.stopService();

    if (result is ServiceRequestFailure) {
      throw StateError('Foreground service could not stop: ${result.error}');
    }
  }

  @override
  Future<ActivityAccessStatus> requestActivityAccess() async {
    if (!Platform.isAndroid) return ActivityAccessStatus.unsupported;
    final permission =
        await ActivityTransitionBridge.requestActivityRecognitionPermission();
    return switch (permission) {
      'granted' => ActivityAccessStatus.granted,
      'permanentlyDenied' => ActivityAccessStatus.permanentlyDenied,
      _ => ActivityAccessStatus.denied,
    };
  }

  @override
  void requestSnapshot() {
    FlutterForegroundTask.sendDataToTask(<String, dynamic>{
      'command': 'get_snapshot',
    });
  }

  @override
  void requestReset() {
    FlutterForegroundTask.sendDataToTask(<String, dynamic>{
      'command': 'reset_steps',
    });
  }

  @override
  void addDataCallback(StepTaskDataCallback callback) {
    FlutterForegroundTask.addTaskDataCallback(callback);
  }

  @override
  void removeDataCallback(StepTaskDataCallback callback) {
    FlutterForegroundTask.removeTaskDataCallback(callback);
  }

  Future<void> _ensurePermissions() async {
    final activityPermission = await requestActivityAccess();
    _diagnostics?.record(
      StepDiagnosticEventType.permissionState,
      payload: <String, Object?>{
        'permission': 'ACTIVITY_RECOGNITION',
        'state': activityPermission.name,
      },
    );
    if (activityPermission == ActivityAccessStatus.permanentlyDenied) {
      throw StateError(
        'Activity Recognition permission is permanently denied.',
      );
    }
    if (activityPermission != ActivityAccessStatus.granted) {
      throw StateError('Activity Recognition permission was not granted.');
    }

    var notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();

    if (notificationPermission != NotificationPermission.granted) {
      notificationPermission =
          await FlutterForegroundTask.requestNotificationPermission();
    }
    _diagnostics?.record(
      StepDiagnosticEventType.permissionState,
      payload: <String, Object?>{
        'permission': 'POST_NOTIFICATIONS',
        'state': notificationPermission.name,
      },
    );

    if (notificationPermission != NotificationPermission.granted) {
      throw StateError('Notification permission was not granted.');
    }
  }
}
