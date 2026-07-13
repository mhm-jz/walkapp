import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart';

import 'step_snapshot.dart';
import '../domain/step_snapshot_store.dart';

final class StepLocalStore implements StepSnapshotStore {
  StepLocalStore({required this.directoryPath});

  static const String boxName = 'step_counter_box';
  static const String snapshotKey = 'step_snapshot';

  /// Shared keys used by flutter_foreground_task.
  static const String taskHivePathKey = 'step_hive_path';

  final String directoryPath;

  Box<dynamic>? _box;
  bool _hiveInitialized = false;

  static Future<StepLocalStore> createForApp() async {
    final directory = await getApplicationSupportDirectory();

    return StepLocalStore(directoryPath: directory.path);
  }

  Future<Box<dynamic>> _openBox() async {
    if (!_hiveInitialized) {
      Hive.init(directoryPath);
      _hiveInitialized = true;
    }

    final currentBox = _box;
    if (currentBox != null && currentBox.isOpen) {
      return currentBox;
    }

    final openedBox = await Hive.openBox<dynamic>(boxName);
    _box = openedBox;
    return openedBox;
  }

  @override
  Future<StepSnapshot> readSnapshot() async {
    final box = await _openBox();
    final rawValue = box.get(snapshotKey);

    if (rawValue is Map) {
      return StepSnapshot.fromPersistedMap(
        rawValue.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
    }

    return StepSnapshot.initial();
  }

  @override
  Future<void> writeSnapshot(
    StepSnapshot snapshot, {
    bool flush = false,
  }) async {
    final box = await _openBox();

    await box.put(snapshotKey, snapshot.toPersistedMap());

    if (flush) {
      await box.flush();
    }
  }

  @override
  Future<StepSnapshot> resetSnapshot() async {
    final resetValue = StepSnapshot.initial();

    await writeSnapshot(resetValue, flush: true);
    return resetValue;
  }

  @override
  Future<void> close() async {
    final currentBox = _box;

    if (currentBox != null && currentBox.isOpen) {
      await currentBox.close();
    }

    _box = null;
  }
}

final class AppStepSnapshotStoreFactory implements StepSnapshotStoreFactory {
  const AppStepSnapshotStoreFactory();

  @override
  Future<StepSnapshotStore> create() => StepLocalStore.createForApp();
}
