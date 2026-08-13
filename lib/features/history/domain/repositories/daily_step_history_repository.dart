import '../daily_step_record.dart';

abstract interface class DailyStepHistoryRepository {
  Future<DailyStepRecord?> getRecord(String date);

  Future<List<DailyStepRecord>> getRecordsBetween(
    String startDate,
    String endDate,
  );

  Future<List<DailyStepRecord>> getNonFinalizedRecords();

  Future<void> upsert(DailyStepRecord record);

  Future<int> getLifetimeConfirmedSteps();
}
