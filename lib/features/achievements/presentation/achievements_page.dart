import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('Achievements')),
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: <Widget>[
                Text(
                  'Your achievements',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$unlocked of ${achievements.length} unlocked from real local activity.',
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
                  achievement.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(achievement.description),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    AppStatusChip(
                      label: achievement.category,
                      status: achievement.category == 'Campaign'
                          ? AppStatus.info
                          : AppStatus.neutral,
                    ),
                    AppStatusChip(
                      label: achievement.isUnlocked ? 'Unlocked' : 'Locked',
                      status: achievement.isUnlocked
                          ? AppStatus.success
                          : AppStatus.neutral,
                    ),
                  ],
                ),
                if (achievement.unlockedAt != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Unlocked ${achievement.unlockedAt!.month}/'
                    '${achievement.unlockedAt!.day}/'
                    '${achievement.unlockedAt!.year}',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
