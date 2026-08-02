import 'dart:io';

import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
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
  @override
  String? get diagnosticSessionId => _diagnostics?.sessionId;

  @override
  Future<void> prepareDiagnosticSession(Map<String, Object?> startState) async {
    final directory = await getApplicationSupportDirectory();
    _diagnostics = await StepDiagnosticLogger.create(
      supportPath: directory.path,
      source: 'main',
      createSession: true,
    );
    _diagnostics?.record(
      StepDiagnosticEventType.sessionCreated,
      payload: startState,
    );
    _diagnostics?.record(
      StepDiagnosticEventType.trackingStartRequested,
      payload: startState,
    );
  }

  @override
  void recordDiagnostic(
    String type, {
    Map<String, Object?> payload = const {},
  }) => _diagnostics?.record(type, payload: payload);

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
        eventAction: ForegroundTaskEventAction.nothing(),
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
    final diagnosticId = _diagnostics?.sessionId;
    if (diagnosticId != null) {
      await FlutterForegroundTask.saveData(
        key: StepLocalStore.taskDiagnosticSessionIdKey,
        value: diagnosticId,
      );
      await FlutterForegroundTask.saveData(
        key: StepLocalStore.taskDiagnosticSessionStartElapsedMsKey,
        value: _diagnostics!.sessionStartedElapsedRealtimeMs,
      );
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
    var permission = await FlutterActivityRecognition.instance
        .checkPermission();
    if (permission == ActivityPermission.DENIED) {
      permission = await FlutterActivityRecognition.instance
          .requestPermission();
    }
    return switch (permission) {
      ActivityPermission.GRANTED => ActivityAccessStatus.granted,
      ActivityPermission.PERMANENTLY_DENIED =>
        ActivityAccessStatus.permanentlyDenied,
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
      payload: {
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

    if (notificationPermission != NotificationPermission.granted) {
      throw StateError('Notification permission was not granted.');
    }
  }
}
