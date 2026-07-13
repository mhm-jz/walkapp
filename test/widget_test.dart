import 'package:flutter_test/flutter_test.dart';
import 'package:walkingapp/features/step_counter/data/step_snapshot.dart';
import 'package:walkingapp/features/step_counter/domain/step_snapshot_store.dart';
import 'package:walkingapp/features/step_counter/domain/step_tracking_service.dart';
import 'package:walkingapp/features/step_counter/presentation/step_counter_controller.dart';
import 'package:walkingapp/main.dart';

void main() {
  testWidgets('shows the persisted step count', (tester) async {
    final store = _MemoryStepSnapshotStore(
      StepSnapshot.initial().copyWith(confirmedSteps: 42),
    );
    final controller = StepCounterController(
      trackingService: _FakeStepTrackingService(),
      storeFactory: _MemoryStoreFactory(store),
    );

    await tester.pumpWidget(WalkingApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('42'), findsOneWidget);
    expect(find.text('سرویس متوقف است'), findsOneWidget);
  });

  testWidgets('shows displayed and provisional values from running service', (
    tester,
  ) async {
    final service = _FakeStepTrackingService(running: true);
    final controller = StepCounterController(
      trackingService: service,
      storeFactory: _MemoryStoreFactory(
        _MemoryStepSnapshotStore(StepSnapshot.initial()),
      ),
    );
    await tester.pumpWidget(WalkingApp(controller: controller));
    await tester.pumpAndSettle();

    service.emit(
      StepSnapshot.initial()
          .copyWith(
            confirmedSteps: 100,
            provisionalSteps: 20,
            isTracking: true,
            sensorReady: true,
          )
          .toMap(),
    );
    await tester.pump();

    expect(find.text('120'), findsOneWidget);
    expect(find.text('20 قدم در انتظار بررسی فعالیت'), findsOneWidget);
  });
}

final class _FakeStepTrackingService implements StepTrackingService {
  _FakeStepTrackingService({this.running = false});

  final bool running;
  StepTaskDataCallback? _callback;

  @override
  void addDataCallback(StepTaskDataCallback callback) {
    _callback = callback;
  }

  void emit(Map<String, dynamic> snapshot) {
    _callback?.call(<String, dynamic>{
      'type': 'step_snapshot',
      'payload': snapshot,
    });
  }

  @override
  void initialize() {}

  @override
  Future<bool> isRunning() async => running;

  @override
  void removeDataCallback(StepTaskDataCallback callback) {
    if (_callback == callback) _callback = null;
  }

  @override
  void requestReset() {}

  @override
  void requestSnapshot() {}

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}

final class _MemoryStoreFactory implements StepSnapshotStoreFactory {
  const _MemoryStoreFactory(this.store);

  final StepSnapshotStore store;

  @override
  Future<StepSnapshotStore> create() async => store;
}

final class _MemoryStepSnapshotStore implements StepSnapshotStore {
  _MemoryStepSnapshotStore(this.snapshot);

  StepSnapshot snapshot;

  @override
  Future<void> close() async {}

  @override
  Future<StepSnapshot> readSnapshot() async => snapshot;

  @override
  Future<StepSnapshot> resetSnapshot() async {
    snapshot = StepSnapshot.initial();
    return snapshot;
  }

  @override
  Future<void> writeSnapshot(StepSnapshot value, {bool flush = false}) async {
    snapshot = value;
  }
}
