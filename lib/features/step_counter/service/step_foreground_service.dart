import 'dart:io';

import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:path_provider/path_provider.dart';

import '../data/step_local_store.dart';
import '../domain/step_tracking_service.dart';
import 'step_task_handler.dart';

@pragma('vm:entry-point')
void startStepTrackingCallback() {
  FlutterForegroundTask.setTaskHandler(StepTaskHandler());
}

final class StepForegroundService
    implements StepTrackingService, ActivityAccessRequester {
  StepForegroundService();

  bool _initialized = false;

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
  }

  @override
  Future<void> stop() async {
    if (!await isRunning()) return;

    FlutterForegroundTask.sendDataToTask(<String, dynamic>{
      'command': 'stop_tracking',
      'reason': 'user',
    });

    // Give TaskHandler time to persist the final snapshot and stop itself.
    for (var attempt = 0; attempt < 20; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      if (!await isRunning()) {
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
