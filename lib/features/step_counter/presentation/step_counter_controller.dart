import 'package:flutter/foundation.dart';
import '../data/step_snapshot.dart';
import '../domain/step_snapshot_store.dart';
import '../domain/step_tracking_service.dart';

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

  Future<void> reset() async {
    if (_isBusy) return;

    _setBusy(true);
    _uiError = null;

    try {
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
    } catch (error) {
      _uiError = error.toString();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _loadSnapshotFromHiveWhileServiceIsStopped() async {
    final store = await storeFactory.create();

    try {
      final persistedSnapshot = await store.readSnapshot();

      // Force Stop may prevent TaskHandler.onDestroy from running.
      // Therefore isRunningService, not Hive's old flag, is the source of truth.
      _snapshot = persistedSnapshot.copyWith(
        isTracking: false,
        provisionalSteps: 0,
        sensorReady: false,
        updatedAt: DateTime.now(),
      );

      if (persistedSnapshot.isTracking) {
        await store.writeSnapshot(_snapshot, flush: true);
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
    if (_disposed || data is! Map) return;

    if (data['type']?.toString() != 'step_snapshot') {
      return;
    }

    final payload = data['payload'];
    if (payload is! Map) return;

    _snapshot = StepSnapshot.fromMap(
      payload.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      ),
    );

    _uiError = null;
    notifyListeners();
  }

  void _setBusy(bool value) {
    _isBusy = value;

    if (!_disposed) {
      notifyListeners();
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
