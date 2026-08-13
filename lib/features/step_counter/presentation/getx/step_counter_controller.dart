import 'package:get/get.dart';

import '../../../../core/presentation/reactive_controller.dart';
import '../../../../core/diagnostics/step_diagnostic_event.dart';
import '../../domain/step_snapshot_store.dart';
import '../../domain/step_snapshot.dart';
import '../../domain/step_tracking_service.dart';
import '../../step_diagnostics.dart';

/// Coordinates step-tracking use cases and exposes immutable view state.
final class StepCounterController extends ReactiveController {
  StepCounterController({
    required this.trackingService,
    required this.storeFactory,
  });

  final StepTrackingService trackingService;
  final StepSnapshotStoreFactory storeFactory;

  final Rx<StepSnapshot> _snapshot = StepSnapshot.initial().obs;
  final RxBool _isBusy = false.obs;
  final RxnString _uiError = RxnString();
  bool _callbackAttached = false;
  bool _disposed = false;

  StepSnapshot get snapshot => _snapshot.value;
  bool get isBusy => _isBusy.value;
  String? get uiError => _uiError.value;

  Future<void> initialize() async {
    trackingService.initialize();
    _attachTaskCallback();

    await reload();
  }

  Future<void> reload() async {
    _setBusy(true);
    _uiError.value = null;

    try {
      final serviceRunning = await trackingService.isRunning();

      if (serviceRunning) {
        _snapshot.value = _snapshot.value.copyWith(
          isTracking: true,
          stopReason: null,
          updatedAt: DateTime.now(),
        );

        trackingService.requestSnapshot();
      } else {
        await _loadSnapshotFromHiveWhileServiceIsStopped();
      }
    } catch (error) {
      _uiError.value = error.toString();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> start() async {
    if (_isBusy.value || _snapshot.value.isTracking) return;

    _setBusy(true);
    _uiError.value = null;

    try {
      final recorder = trackingService;
      if (recorder is StepDiagnosticRecorder) {
        await (recorder as StepDiagnosticRecorder).prepareDiagnosticSession({
          'confirmedStepsBeforeStart': _snapshot.value.confirmedSteps,
          'provisionalStepsBeforeStart': _snapshot.value.provisionalSteps,
          'displayedStepsBeforeStart': _snapshot.value.displayedSteps,
          'persistedConfirmedValue': _snapshot.value.confirmedSteps,
          'persistedTrackingState': _snapshot.value.isTracking,
          'serviceRunningState': await trackingService.isRunning(),
          'pedometerSubscriptionActive': false,
          'samplingSubscriptionActive': false,
          'currentActivityType': _snapshot.value.activity.storageName,
          'currentConfidence': _snapshot.value.confidence.storageName,
          'currentEvidenceReceivedElapsedRealtimeMs': null,
        });
      }
      await trackingService.start();

      _snapshot.value = _snapshot.value.copyWith(
        isTracking: true,
        sensorReady: false,
        provisionalSteps: 0,
        startedAt: DateTime.now(),
        error: null,
        stopReason: null,
        updatedAt: DateTime.now(),
      );

      trackingService.requestSnapshot();
    } catch (error) {
      _uiError.value = error.toString();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> stop() async {
    if (_isBusy.value || !_snapshot.value.isTracking) return;

    _setBusy(true);
    _uiError.value = null;

    try {
      await trackingService.stop();

      // The service has now closed its Hive box, so UI can safely read it.
      await _loadSnapshotFromHiveWhileServiceIsStopped();
    } catch (error) {
      _uiError.value = error.toString();
    } finally {
      _setBusy(false);
    }
  }

  Future<ActivityAccessStatus> requestActivityAccess() {
    final requester = trackingService;
    if (requester is! ActivityAccessRequester) {
      return Future<ActivityAccessStatus>.value(
        ActivityAccessStatus.unsupported,
      );
    }
    return (requester as ActivityAccessRequester).requestActivityAccess();
  }

  Future<void> reset() async {
    if (_isBusy.value) return;

    _setBusy(true);
    _uiError.value = null;

    try {
      if (await trackingService.isRunning()) {
        trackingService.requestReset();
      } else {
        final store = await storeFactory.create();

        try {
          _snapshot.value = await store.resetSnapshot();
        } finally {
          await store.close();
        }
      }
    } catch (error) {
      _uiError.value = error.toString();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _loadSnapshotFromHiveWhileServiceIsStopped() async {
    final store = await storeFactory.create();

    try {
      final persistedSnapshot = await store.readSnapshot(
        reason: 'serviceStopped',
      );

      // Force Stop may prevent TaskHandler.onDestroy from running.
      // Therefore isRunningService, not Hive's old flag, is the source of truth.
      _snapshot.value = persistedSnapshot.copyWith(
        isTracking: false,
        provisionalSteps: 0,
        sensorReady: false,
        updatedAt: DateTime.now(),
      );

      if (persistedSnapshot.isTracking) {
        await store.writeSnapshot(
          _snapshot.value,
          flush: true,
          reason: 'stoppedStateCorrection',
        );
      }
    } finally {
      await store.close();
    }
  }

  void _attachTaskCallback() {
    if (_callbackAttached) return;

    trackingService.addDataCallback(_onReceiveTaskData);

    _callbackAttached = true;
  }

  void _onReceiveTaskData(Object data) {
    logStepDiagnostic(
      '[STEP_UI_RAW_DATA] type=${data.runtimeType} payload=$data',
    );
    if (_disposed || data is! Map) return;

    if (data['type']?.toString() != 'step_snapshot') {
      return;
    }

    final payload = data['payload'];
    if (payload is! Map) return;

    _snapshot.value = StepSnapshot.fromMap(
      payload.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );
    _record(StepDiagnosticEventType.snapshotReceived);

    logStepDiagnostic(
      '[STEP_UI_RECEIVE] confirmedSteps=${_snapshot.value.confirmedSteps} '
      'provisionalSteps=${_snapshot.value.provisionalSteps} '
      'displayedSteps=${_snapshot.value.displayedSteps}',
    );

    _uiError.value = null;
    refreshState();
    _record(StepDiagnosticEventType.uiUpdated);
    logStepDiagnostic(
      '[STEP_UI_NOTIFY] confirmed=${_snapshot.value.confirmedSteps} '
      'provisional=${_snapshot.value.provisionalSteps} '
      'displayed=${_snapshot.value.displayedSteps} '
      'tracking=${_snapshot.value.isTracking}',
    );
  }

  void _setBusy(bool value) {
    _isBusy.value = value;

    if (!_disposed) {
      refreshState();
    }
  }

  void _record(String type) {
    final recorder = trackingService;
    if (recorder is StepDiagnosticRecorder) {
      (recorder as StepDiagnosticRecorder).recordDiagnostic(
        type,
        payload: {
          'confirmedSteps': _snapshot.value.confirmedSteps,
          'provisionalSteps': _snapshot.value.provisionalSteps,
          'displayedSteps': _snapshot.value.displayedSteps,
          'activityType': _snapshot.value.activity.storageName,
          'confidence': _snapshot.value.confidence.storageName,
          'isTracking': _snapshot.value.isTracking,
        },
      );
    }
  }

  @override
  void dispose() {
    _disposed = true;

    if (_callbackAttached) {
      trackingService.removeDataCallback(_onReceiveTaskData);
    }

    super.dispose();
  }
}
