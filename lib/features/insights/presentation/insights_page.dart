import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../campaigns/presentation/campaign_formatters.dart';
import '../../history/application/daily_step_history_controller.dart';
import '../../history/domain/daily_step_record.dart';
import '../../step_counter/domain/tracking_activity.dart';
import '../../step_counter/presentation/step_counter_controller.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({
    required this.controller,
    required this.settingsController,
    required this.historyController,
    super.key,
  });

  final StepCounterController controller;
  final AppSettingsController settingsController;
  final DailyStepHistoryController historyController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          controller,
          settingsController,
          historyController,
        ]),
        builder: (context, child) {
          final now = DateTime.now();
          final monday = DateUtils.dateOnly(
            now.subtract(Duration(days: now.weekday - 1)),
          );
          final previousMonday = monday.subtract(const Duration(days: 7));
          final current = _between(monday, monday.add(const Duration(days: 6)));
          final previous = _between(
            previousMonday,
            monday.subtract(const Duration(days: 1)),
          );
          final total = historyController.totalFor(current);
          final previousTotal = historyController.totalFor(previous);
          final best = historyController.bestDay(
            historyController.recentRecords,
          );
          final snapshot = controller.snapshot;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: <Widget>[
              Text(
                'Insights',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Real trends from confirmed steps recorded on this device.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.appTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _MetricCard(
                title: 'This week',
                values: <String>[
                  '${formatCampaignNumber(total)} confirmed steps',
                  '${formatCampaignNumber(total ~/ 7)} daily average',
                  '${historyController.activeDaysFor(current)} active days',
                  '${historyController.goalDaysFor(current)} goal days',
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (previous.isNotEmpty && previousTotal > 0)
                _Comparison(current: total, previous: previousTotal)
              else
                const _MetricCard(
                  title: 'More weekly comparisons are coming',
                  values: <String>[
                    'Keep tracking your walks to build a meaningful trend.',
                  ],
                ),
              const SizedBox(height: AppSpacing.md),
              _MetricCard(
                title: 'Consistency',
                values: <String>[
                  '${historyController.currentGoalStreak()} current goal-day streak',
                  '${historyController.longestGoalStreak()} longest local streak',
                  '${historyController.goalDaysFor(historyController.recordsForDays(30)) * 100 ~/ 30}% goal completion over 30 days',
                ],
              ),
              if (best != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                _MetricCard(
                  title: 'Best day',
                  values: <String>[
                    '${_date(best.date)} — ${formatCampaignNumber(best.confirmedSteps)} confirmed steps',
                    best.goalReached
                        ? 'Recorded goal reached'
                        : 'Recorded goal not reached',
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              _MetricCard(
                title: 'Today',
                values: <String>[
                  '${formatCampaignNumber(snapshot.displayedSteps)} live displayed steps',
                  '${formatCampaignNumber(snapshot.confirmedSteps)} confirmed',
                  '${formatCampaignNumber(snapshot.provisionalSteps)} validating',
                  'Daily goal: ${formatCampaignNumber(settingsController.dailyGoal)}',
                  'Current activity: ${_activity(snapshot.activity)}',
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Live displayed steps may include activity still being validated. '
                'Historical totals use confirmed steps only.',
              ),
            ],
          );
        },
      ),
    );
  }

  List<DailyStepRecord> _between(DateTime start, DateTime end) =>
      historyController.recentRecords
          .where((record) {
            final date = DailyStepHistoryController.parseDate(record.date);
            return !date.isBefore(start) && !date.isAfter(end);
          })
          .toList(growable: false);

  String _activity(TrackingActivity activity) => switch (activity) {
    TrackingActivity.walking => 'Walking',
    TrackingActivity.running => 'Running',
    TrackingActivity.inVehicle => 'In vehicle',
    TrackingActivity.onBicycle => 'Cycling',
    TrackingActivity.still => 'Still',
    TrackingActivity.unknown => 'Detecting activity',
  };

  String _date(String value) {
    final date = DailyStepHistoryController.parseDate(value);
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({required this.current, required this.previous});
  final int current;
  final int previous;

  @override
  Widget build(BuildContext context) {
    final difference = ((current - previous).abs() / previous * 100).round();
    final more = current >= previous;
    return AppCard(
      child: Row(
        children: <Widget>[
          AppStatusChip(
            label: more ? '$difference% more' : '$difference% fewer',
            status: more ? AppStatus.success : AppStatus.neutral,
            icon: more ? Icons.trending_up : Icons.trending_down,
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(child: Text('Compared with last week')),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.values});
  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final value in values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(value),
          ),
      ],
    ),
  );
}
