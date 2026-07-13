import '../data/step_snapshot.dart';

abstract interface class StepSnapshotStore {
  Future<StepSnapshot> readSnapshot();

  Future<void> writeSnapshot(StepSnapshot snapshot, {bool flush = false});

  Future<StepSnapshot> resetSnapshot();

  Future<void> close();
}

abstract interface class StepSnapshotStoreFactory {
  Future<StepSnapshotStore> create();
}
