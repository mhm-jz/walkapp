import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart';

import 'step_snapshot.dart';
import '../domain/step_snapshot_store.dart';
import '../step_diagnostics.dart';

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
  Future<StepSnapshot> readSnapshot({String reason = 'unspecified'}) async {
    try {
      final box = await _openBox();
      final rawValue = box.get(snapshotKey);
      final snapshot = rawValue is Map
          ? StepSnapshot.fromPersistedMap(
              rawValue.map<String, dynamic>(
                (key, value) => MapEntry(key.toString(), value),
              ),
            )
          : StepSnapshot.initial();
      logStepDiagnostic(
        '[STEP_HIVE_READ] confirmed=${snapshot.confirmedSteps} '
        'tracking=${snapshot.isTracking} '
        'timestamp=${DateTime.now().toIso8601String()} reason=$reason',
      );
      return snapshot;
    } catch (error, stackTrace) {
      logStepDiagnostic(
        '[STEP_HIVE_ERROR] operation=read '
        'timestamp=${DateTime.now().toIso8601String()} reason=$reason '
        'error=$error stack=${_singleLineStack(stackTrace)}',
      );
      rethrow;
    }
  }

  @override
  Future<void> writeSnapshot(
    StepSnapshot snapshot, {
    bool flush = false,
    String reason = 'unspecified',
  }) async {
    try {
      final box = await _openBox();
      await box.put(snapshotKey, snapshot.toPersistedMap());
      if (flush) {
        await box.flush();
      }
      logStepDiagnostic(
        '[STEP_HIVE_WRITE] confirmed=${snapshot.confirmedSteps} '
        'tracking=${snapshot.isTracking} '
        'timestamp=${DateTime.now().toIso8601String()} '
        'reason=$reason flush=$flush',
      );
    } catch (error, stackTrace) {
      logStepDiagnostic(
        '[STEP_HIVE_ERROR] operation=write confirmed=${snapshot.confirmedSteps} '
        'timestamp=${DateTime.now().toIso8601String()} reason=$reason '
        'error=$error stack=${_singleLineStack(stackTrace)}',
      );
      rethrow;
    }
  }

  @override
  Future<StepSnapshot> resetSnapshot() async {
    final resetValue = StepSnapshot.initial();

    await writeSnapshot(resetValue, flush: true, reason: 'reset');
    return resetValue;
  }

  @override
  Future<void> close() async {
    final currentBox = _box;

    if (currentBox != null && currentBox.isOpen) {
      try {
        await currentBox.close();
      } catch (error, stackTrace) {
        logStepDiagnostic(
          '[STEP_HIVE_ERROR] operation=close '
          'timestamp=${DateTime.now().toIso8601String()} '
          'error=$error stack=${_singleLineStack(stackTrace)}',
        );
        rethrow;
      }
    }

    _box = null;
  }
}

String _singleLineStack(StackTrace stackTrace) {
  return stackTrace.toString().replaceAll('\n', ' | ');
}

final class AppStepSnapshotStoreFactory implements StepSnapshotStoreFactory {
  const AppStepSnapshotStoreFactory();

  @override
  Future<StepSnapshotStore> create() => StepLocalStore.createForApp();
}
