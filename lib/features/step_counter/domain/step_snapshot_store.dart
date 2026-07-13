import '../data/step_snapshot.dart';

abstract interface class StepSnapshotStore {
  Future<StepSnapshot> readSnapshot({String reason = 'unspecified'});

  Future<void> writeSnapshot(
    StepSnapshot snapshot, {
    bool flush = false,
    String reason = 'unspecified',
  });

  Future<StepSnapshot> resetSnapshot();

  Future<void> close();
}

abstract interface class StepSnapshotStoreFactory {
  Future<StepSnapshotStore> create();
}
