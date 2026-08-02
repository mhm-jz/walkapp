import 'package:flutter/material.dart';
import 'package:walkingapp/l10n/app_localizations_extension.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../campaigns/presentation/campaign_formatters.dart';
import '../../history/application/daily_step_history_controller.dart';
import '../../history/domain/daily_step_record.dart';
import '../../step_counter/presentation/step_counter_controller.dart';
import '../../step_counter/presentation/tracking_activity_localization.dart';
import '../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
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
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: <Widget>[
              Text(
                l10n.insights,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.insightsDescription,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.appTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _MetricCard(
                title: l10n.thisWeek,
                values: <String>[
                  l10n.confirmedStepCount(formatCampaignNumber(total)),
                  l10n.dailyAverage(formatCampaignNumber(total ~/ 7)),
                  l10n.activeDayCount(historyController.activeDaysFor(current)),
                  l10n.goalDayCount(historyController.goalDaysFor(current)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (previous.isNotEmpty && previousTotal > 0)
                _Comparison(current: total, previous: previousTotal)
              else
                _MetricCard(
                  title: l10n.moreWeeklyComparisons,
                  values: <String>[l10n.keepTrackingForTrend],
                ),
              const SizedBox(height: AppSpacing.md),
              _MetricCard(
                title: l10n.consistency,
                values: <String>[
                  l10n.currentGoalDayStreak(
                    historyController.currentGoalStreak(),
                  ),
                  l10n.longestLocalStreak(
                    historyController.longestGoalStreak(),
                  ),
                  l10n.goalCompletionThirtyDays(
                    historyController.goalDaysFor(
                          historyController.recordsForDays(30),
                        ) *
                        100 ~/
                        30,
                  ),
                ],
              ),
              if (best != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                _MetricCard(
                  title: l10n.bestDay,
                  values: <String>[
                    l10n.datedConfirmedSteps(
                      _date(best.date),
                      formatCampaignNumber(best.confirmedSteps),
                    ),
                    best.goalReached
                        ? l10n.recordedGoalReached
                        : l10n.recordedGoalNotReached,
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              _MetricCard(
                title: l10n.todaySteps,
                values: <String>[
                  l10n.liveDisplayedSteps(
                    formatCampaignNumber(snapshot.displayedSteps),
                  ),
                  l10n.confirmedValue(
                    formatCampaignNumber(snapshot.confirmedSteps),
                  ),
                  l10n.validatingValue(
                    formatCampaignNumber(snapshot.provisionalSteps),
                  ),
                  l10n.dailyGoalFormatted(
                    formatCampaignNumber(settingsController.dailyGoal),
                  ),
                  l10n.currentActivityValue(
                    snapshot.activity.localizedLabel(l10n),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.liveStepsExplanation),
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
            label: more
                ? context.l10n.percentageMore(difference)
                : context.l10n.percentageFewer(difference),
            status: more ? AppStatus.success : AppStatus.neutral,
            icon: more ? Icons.trending_up : Icons.trending_down,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(context.l10n.comparedWithLastWeek)),
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
