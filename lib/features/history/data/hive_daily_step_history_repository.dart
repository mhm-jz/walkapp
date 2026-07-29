import 'package:hive_ce/hive_ce.dart';

import '../domain/daily_step_record.dart';
import 'daily_step_history_repository.dart';

final class HiveDailyStepHistoryRepository
    implements DailyStepHistoryRepository {
  HiveDailyStepHistoryRepository._(this._box);

  static const boxName = 'daily_step_history_box';
  final Box<dynamic> _box;

  static Future<HiveDailyStepHistoryRepository> open() async =>
      HiveDailyStepHistoryRepository._(await Hive.openBox<dynamic>(boxName));

  @override
  Future<DailyStepRecord?> getRecord(String date) async {
    final raw = _box.get(date);
    return raw is Map ? DailyStepRecord.fromMap(raw) : null;
  }

  @override
  Future<List<DailyStepRecord>> getRecordsBetween(
    String startDate,
    String endDate,
  ) async {
    final records = <DailyStepRecord>[];
    for (final key in _box.keys) {
      final date = key.toString();
      if (date.compareTo(startDate) < 0 || date.compareTo(endDate) > 0) {
        continue;
      }
      final record = await getRecord(date);
      if (record != null) records.add(record);
    }
    records.sort((a, b) => a.date.compareTo(b.date));
    return records;
  }

  @override
  Future<List<DailyStepRecord>> getNonFinalizedRecords() async {
    final records = <DailyStepRecord>[];
    for (final key in _box.keys) {
      final record = await getRecord(key.toString());
      if (record != null && !record.isFinalized) records.add(record);
    }
    return records;
  }

  @override
  Future<void> upsert(DailyStepRecord record) async {
    await _box.put(record.date, record.toMap());
    await _box.flush();
  }

  @override
  Future<int> getLifetimeConfirmedSteps() async {
    var total = 0;
    for (final key in _box.keys) {
      total += (await getRecord(key.toString()))?.confirmedSteps ?? 0;
    }
    return total;
  }
}
