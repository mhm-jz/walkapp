import '../../campaigns/domain/campaign_enrollment.dart';
import '../../campaigns/domain/campaign_enrollment_status.dart';
import '../../history/application/daily_step_history_controller.dart';
import '../../history/domain/daily_step_record.dart';

final class HealthAchievement {
  const HealthAchievement({
    required this.title,
    required this.description,
    required this.category,
    required this.isUnlocked,
    this.unlockedAt,
  });

  final String title;
  final String description;
  final String category;
  final bool isUnlocked;
  final DateTime? unlockedAt;
}

abstract final class HealthAchievementEvaluator {
  static List<HealthAchievement> evaluate({
    required List<DailyStepRecord> records,
    required List<CampaignEnrollment> enrollments,
  }) {
    final sorted = records.toList()..sort((a, b) => a.date.compareTo(b.date));
    final firstThousand = _first(
      sorted,
      (record) => record.confirmedSteps >= 1000,
    );
    final firstGoal = _first(sorted, (record) => record.goalReached);
    final active = sorted
        .where((record) => record.confirmedSteps > 0)
        .toList(growable: false);
    final threeActive = active.length >= 3 ? active[2] : null;
    final consistentAt = _firstThreeGoalStreak(sorted);
    final explorerAt = _firstSevenDayTotal(sorted, 50000);
    CampaignEnrollment? campaignCompletion;
    for (final enrollment in enrollments) {
      if (enrollment.status == CampaignEnrollmentStatus.completed) {
        campaignCompletion = enrollment;
        break;
      }
    }
    return <HealthAchievement>[
      _achievement(
        'First Steps',
        'Record at least 1,000 confirmed steps in one day.',
        'Health',
        firstThousand,
      ),
      _achievement(
        'Goal Getter',
        'Reach the recorded daily goal for the first time.',
        'Health',
        firstGoal,
      ),
      _achievement(
        'Three Active Days',
        'Record confirmed steps on three separate dates.',
        'Health',
        threeActive,
      ),
      _achievement(
        'Consistent Walker',
        'Reach the daily goal on three consecutive dates.',
        'Health',
        consistentAt,
      ),
      _achievement(
        'Weekly Explorer',
        'Record 50,000 confirmed steps across seven consecutive days.',
        'Health',
        explorerAt,
      ),
      HealthAchievement(
        title: 'Campaign Finisher',
        description: 'Complete one walking campaign.',
        category: 'Campaign',
        isUnlocked: campaignCompletion != null,
        unlockedAt: campaignCompletion?.completedAt,
      ),
    ];
  }

  static HealthAchievement _achievement(
    String title,
    String description,
    String category,
    DailyStepRecord? record,
  ) => HealthAchievement(
    title: title,
    description: description,
    category: category,
    isUnlocked: record != null,
    unlockedAt: record == null
        ? null
        : DailyStepHistoryController.parseDate(record.date),
  );

  static DailyStepRecord? _first(
    List<DailyStepRecord> records,
    bool Function(DailyStepRecord) predicate,
  ) {
    for (final record in records) {
      if (predicate(record)) return record;
    }
    return null;
  }

  static DailyStepRecord? _firstThreeGoalStreak(List<DailyStepRecord> records) {
    var streak = 0;
    DateTime? previous;
    for (final record in records) {
      final date = DailyStepHistoryController.parseDate(record.date);
      if (previous == null || date.difference(previous).inDays != 1) {
        streak = 0;
      }
      streak = record.goalReached ? streak + 1 : 0;
      if (streak >= 3) return record;
      previous = date;
    }
    return null;
  }

  static DailyStepRecord? _firstSevenDayTotal(
    List<DailyStepRecord> records,
    int target,
  ) {
    final byDate = <String, DailyStepRecord>{
      for (final record in records) record.date: record,
    };
    for (final endRecord in records) {
      final end = DailyStepHistoryController.parseDate(endRecord.date);
      var total = 0;
      for (var offset = 0; offset < 7; offset++) {
        total +=
            byDate[DailyStepHistoryController.dateKey(
                  end.subtract(Duration(days: offset)),
                )]
                ?.confirmedSteps ??
            0;
      }
      if (total >= target) return endRecord;
    }
    return null;
  }
}
