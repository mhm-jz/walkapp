import '../domain/daily_step_record.dart';
import '../domain/repositories/daily_step_history_repository.dart';

final class InMemoryDailyStepHistoryRepository
    implements DailyStepHistoryRepository {
  final Map<String, DailyStepRecord> _records = <String, DailyStepRecord>{};

  @override
  Future<DailyStepRecord?> getRecord(String date) async => _records[date];

  @override
  Future<List<DailyStepRecord>> getRecordsBetween(
    String startDate,
    String endDate,
  ) async => _records.values
      .where((record) => record.date.compareTo(startDate) >= 0)
      .where((record) => record.date.compareTo(endDate) <= 0)
      .toList(growable: false);

  @override
  Future<List<DailyStepRecord>> getNonFinalizedRecords() async => _records
      .values
      .where((record) => !record.isFinalized)
      .toList(growable: false);

  @override
  Future<void> upsert(DailyStepRecord record) async {
    _records[record.date] = record;
  }

  @override
  Future<int> getLifetimeConfirmedSteps() async {
    var total = 0;
    for (final record in _records.values) {
      total += record.confirmedSteps;
    }
    return total;
  }
}
