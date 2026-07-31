import 'package:flutter/foundation.dart';
import '../../../core/diagnostics/step_diagnostic_event.dart';
import '../data/step_snapshot.dart';
import '../domain/step_snapshot_store.dart';
import '../domain/step_tracking_service.dart';
import '../step_diagnostics.dart';

final class StepCounterController extends ChangeNotifier {
  StepCounterController({
    required this.trackingService,
    required this.storeFactory,
  });

  final StepTrackingService trackingService;
  final StepSnapshotStoreFactory storeFactory;

  StepSnapshot _snapshot = StepSnapshot.initial();
  bool _isBusy = false;
  String? _uiError;
  bool _callbackAttached = false;
  bool _disposed = false;

  StepSnapshot get snapshot => _snapshot;
  bool get isBusy => _isBusy;
  String? get uiError => _uiError;

  Future<void> initialize() async {
    trackingService.initialize();
    _attachTaskCallback();

    await refresh();
  }

  Future<void> refresh() async {
    _setBusy(true);
    _uiError = null;

    try {
      final serviceRunning = await trackingService.isRunning();

      if (serviceRunning) {
        _snapshot = _snapshot.copyWith(
          isTracking: true,
          stopReason: null,
          updatedAt: DateTime.now(),
        );

        trackingService.requestSnapshot();
      } else {
        await _loadSnapshotFromHiveWhileServiceIsStopped();
      }
    } catch (error) {
      _uiError = error.toString();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> start() async {
    if (_isBusy || _snapshot.isTracking) return;

    _setBusy(true);
    _uiError = null;

    try {
      final diagnostics = trackingService;
      if (diagnostics is StepDiagnosticRecorder) {
        await (diagnostics as StepDiagnosticRecorder)
            .prepareDiagnosticSession(<String, Object?>{
              'confirmedStepsBeforeStart': _snapshot.confirmedSteps,
              'provisionalStepsBeforeStart': _snapshot.provisionalSteps,
              'displayedStepsBeforeStart': _snapshot.displayedSteps,
              'persistedConfirmedValue': _snapshot.confirmedSteps,
              'persistedTrackingState': _snapshot.isTracking,
              'pedometerBaselineValue': null,
              'serviceRunningState': await trackingService.isRunning(),
              'currentValidationState': _snapshot.provisionalSteps > 0
                  ? 'validating'
                  : 'idle',
            });
      }
      await trackingService.start();

      _snapshot = _snapshot.copyWith(
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
      _uiError = error.toString();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> stop() async {
    if (_isBusy || !_snapshot.isTracking) return;

    _setBusy(true);
    _uiError = null;

    try {
      await trackingService.stop();

      // The service has now closed its Hive box, so UI can safely read it.
      await _loadSnapshotFromHiveWhileServiceIsStopped();
    } catch (error) {
      _uiError = error.toString();
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
    if (_isBusy) return;

    _setBusy(true);
    _uiError = null;

    try {
      _recordDiagnostic(StepDiagnosticEventType.resetRequested);
      if (await trackingService.isRunning()) {
        trackingService.requestReset();
      } else {
        final store = await storeFactory.create();

        try {
          _snapshot = await store.resetSnapshot();
        } finally {
          await store.close();
        }
      }
      _recordDiagnostic(StepDiagnosticEventType.resetCompleted);
    } catch (error) {
      _uiError = error.toString();
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
      _snapshot = persistedSnapshot.copyWith(
        isTracking: false,
        provisionalSteps: 0,
        sensorReady: false,
        updatedAt: DateTime.now(),
      );

      if (persistedSnapshot.isTracking) {
        await store.writeSnapshot(
          _snapshot,
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
    final receivedDiagnosticSessionId = data['diagnosticSessionId']?.toString();

    _snapshot = StepSnapshot.fromMap(
      payload.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );
    _recordDiagnostic(
      StepDiagnosticEventType.snapshotReceived,
      payload: _snapshotDiagnosticPayload(),
      expectedSessionId: receivedDiagnosticSessionId,
    );

    logStepDiagnostic(
      '[STEP_UI_RECEIVE] confirmedSteps=${_snapshot.confirmedSteps} '
      'provisionalSteps=${_snapshot.provisionalSteps} '
      'displayedSteps=${_snapshot.displayedSteps}',
    );

    _uiError = null;
    notifyListeners();
    _recordDiagnostic(
      StepDiagnosticEventType.uiStateUpdated,
      payload: _snapshotDiagnosticPayload(),
      expectedSessionId: receivedDiagnosticSessionId,
    );
    logStepDiagnostic(
      '[STEP_UI_NOTIFY] confirmed=${_snapshot.confirmedSteps} '
      'provisional=${_snapshot.provisionalSteps} '
      'displayed=${_snapshot.displayedSteps} tracking=${_snapshot.isTracking}',
    );
  }

  void _setBusy(bool value) {
    _isBusy = value;

    if (!_disposed) {
      notifyListeners();
    }
  }

  void _recordDiagnostic(
    String eventType, {
    Map<String, Object?> payload = const <String, Object?>{},
    String? expectedSessionId,
  }) {
    final service = trackingService;
    if (service is StepDiagnosticRecorder) {
      final recorder = service as StepDiagnosticRecorder;
      if (expectedSessionId != null &&
          expectedSessionId != recorder.diagnosticSessionId) {
        return;
      }
      recorder.recordDiagnosticEvent(eventType, payload: payload);
    }
  }

  Map<String, Object?> _snapshotDiagnosticPayload() => <String, Object?>{
    'confirmedSteps': _snapshot.confirmedSteps,
    'provisionalSteps': _snapshot.provisionalSteps,
    'displayedSteps': _snapshot.displayedSteps,
    'isTracking': _snapshot.isTracking,
    'activity': _snapshot.activity.storageName,
  };

  @override
  void dispose() {
    _disposed = true;

    if (_callbackAttached) {
      trackingService.removeDataCallback(_onReceiveTaskData);
    }

    super.dispose();
  }
}
