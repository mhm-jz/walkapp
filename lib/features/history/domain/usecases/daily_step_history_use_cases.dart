import '../daily_step_record.dart';
import '../repositories/daily_step_history_repository.dart';

final class DailyStepHistoryUseCases {
  const DailyStepHistoryUseCases(this._repository);
  final DailyStepHistoryRepository _repository;
  Future<DailyStepRecord?> getRecord(String date) =>
      _repository.getRecord(date);
  Future<List<DailyStepRecord>> getRecordsBetween(String start, String end) =>
      _repository.getRecordsBetween(start, end);
  Future<List<DailyStepRecord>> getNonFinalizedRecords() =>
      _repository.getNonFinalizedRecords();
  Future<void> upsert(DailyStepRecord value) => _repository.upsert(value);
  Future<int> getLifetimeConfirmedSteps() =>
      _repository.getLifetimeConfirmedSteps();
}
