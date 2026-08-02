import 'package:flutter/material.dart';
import 'package:walkingapp/l10n/app_localizations_extension.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../campaigns/application/campaign_enrollment_controller.dart';
import '../../history/application/daily_step_history_controller.dart';
import '../../step_counter/presentation/step_counter_controller.dart';
import '../domain/health_achievement.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({
    required this.controller,
    required this.historyController,
    required this.campaignController,
    super.key,
  });

  final StepCounterController controller;
  final DailyStepHistoryController historyController;
  final CampaignEnrollmentController campaignController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.achievements)),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[
            controller,
            historyController,
            campaignController,
          ]),
          builder: (context, child) {
            final achievements = HealthAchievementEvaluator.evaluate(
              records: historyController.recentRecords,
              enrollments: campaignController.enrollments,
            );
            final unlocked = achievements
                .where((item) => item.isUnlocked)
                .length;
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: <Widget>[
                Text(
                  context.l10n.yourAchievements,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.achievementProgress(
                    unlocked,
                    achievements.length,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final achievement in achievements)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _AchievementCard(achievement: achievement),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});
  final HealthAchievement achievement;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: achievement.isUnlocked
          ? Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.4)
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            achievement.isUnlocked ? Icons.emoji_events : Icons.lock_outline,
            color: achievement.isUnlocked
                ? context.appTheme.success
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  _title(context, achievement.type),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(_description(context, achievement.type)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    AppStatusChip(
                      label:
                          achievement.category ==
                              HealthAchievementCategory.campaign
                          ? context.l10n.campaignCategory
                          : context.l10n.healthCategory,
                      status:
                          achievement.category ==
                              HealthAchievementCategory.campaign
                          ? AppStatus.info
                          : AppStatus.neutral,
                    ),
                    AppStatusChip(
                      label: achievement.isUnlocked
                          ? context.l10n.unlocked
                          : context.l10n.locked,
                      status: achievement.isUnlocked
                          ? AppStatus.success
                          : AppStatus.neutral,
                    ),
                  ],
                ),
                if (achievement.unlockedAt != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.unlockedOn(
                      '${achievement.unlockedAt!.month}/'
                      '${achievement.unlockedAt!.day}/'
                      '${achievement.unlockedAt!.year}',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _title(BuildContext context, HealthAchievementType type) =>
      switch (type) {
        HealthAchievementType.firstSteps => context.l10n.firstStepsAchievement,
        HealthAchievementType.goalGetter => context.l10n.goalGetterAchievement,
        HealthAchievementType.threeActiveDays =>
          context.l10n.threeActiveDaysAchievement,
        HealthAchievementType.consistentWalker =>
          context.l10n.consistentWalkerAchievement,
        HealthAchievementType.weeklyExplorer =>
          context.l10n.weeklyExplorerAchievement,
        HealthAchievementType.campaignFinisher =>
          context.l10n.campaignFinisherAchievement,
      };

  String _description(BuildContext context, HealthAchievementType type) =>
      switch (type) {
        HealthAchievementType.firstSteps =>
          context.l10n.firstStepsAchievementDescription,
        HealthAchievementType.goalGetter =>
          context.l10n.goalGetterAchievementDescription,
        HealthAchievementType.threeActiveDays =>
          context.l10n.threeActiveDaysAchievementDescription,
        HealthAchievementType.consistentWalker =>
          context.l10n.consistentWalkerAchievementDescription,
        HealthAchievementType.weeklyExplorer =>
          context.l10n.weeklyExplorerAchievementDescription,
        HealthAchievementType.campaignFinisher =>
          context.l10n.campaignFinisherAchievementDescription,
      };
}
