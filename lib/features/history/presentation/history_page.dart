import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../l10n/app_localizations_extension.dart';
import '../../campaigns/presentation/campaign_formatters.dart';
import '../application/daily_step_history_controller.dart';
import '../domain/daily_step_record.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    required this.controller,
    this.showHeading = true,
    super.key,
  });
  final DailyStepHistoryController controller;
  final bool showHeading;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _days = 7;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          final records = widget.controller.recordsForDays(_days);
          final range = _calendarRange(_days, records);
          final hasConfirmed = records.any(
            (record) => record.confirmedSteps > 0,
          );
          return CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSizes.contentMaxWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (widget.showHeading) ...<Widget>[
                            Text(
                              context.l10n.history,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                          ],
                          Text(
                            context.l10n.historyDescription,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: context.appTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(context.l10n.historyValidationExplanation),
                          const SizedBox(height: AppSpacing.lg),
                          SegmentedButton<int>(
                            segments: <ButtonSegment<int>>[
                              ButtonSegment<int>(
                                value: 7,
                                label: Text(context.l10n.sevenDays),
                              ),
                              ButtonSegment<int>(
                                value: 30,
                                label: Text(context.l10n.thirtyDays),
                              ),
                            ],
                            selected: <int>{_days},
                            onSelectionChanged: (selection) =>
                                setState(() => _days = selection.first),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (widget.controller.viewState ==
                              DailyHistoryViewState.loading)
                            Center(
                              child: AppLoadingIndicator(
                                label: context.l10n.loadingWalkingHistory,
                              ),
                            )
                          else if (widget.controller.viewState ==
                              DailyHistoryViewState.error)
                            AppErrorView(
                              message:
                                  widget.controller.userMessage ??
                                  context.l10n.walkingHistoryUnavailable,
                              onRetry: widget.controller.retry,
                            )
                          else if (!hasConfirmed)
                            AppCard(
                              child: AppEmptyState(
                                title: context.l10n.noConfirmedHistory,
                                message:
                                    context.l10n.noConfirmedHistoryDescription,
                                icon: Icons.calendar_month_outlined,
                              ),
                            )
                          else ...<Widget>[
                            _Summary(
                              total: widget.controller.totalFor(records),
                              average:
                                  widget.controller.totalFor(records) ~/ _days,
                              goalDays: widget.controller.goalDaysFor(records),
                              activeDays: widget.controller.activeDaysFor(
                                records,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _StepChart(days: range),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              context.l10n.dailyConfirmedSteps,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            for (final item in range.reversed)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: _DayCard(
                                  date: item.date,
                                  record: item.record,
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<({DateTime date, DailyStepRecord? record})> _calendarRange(
    int days,
    List<DailyStepRecord> records,
  ) {
    final byDate = <String, DailyStepRecord>{
      for (final record in records) record.date: record,
    };
    final today = DailyStepHistoryController.dateOnly(DateTime.now());
    return List.generate(days, (index) {
      final date = today.subtract(Duration(days: days - index - 1));
      return (
        date: date,
        record: byDate[DailyStepHistoryController.dateKey(date)],
      );
    });
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.total,
    required this.average,
    required this.goalDays,
    required this.activeDays,
  });
  final int total;
  final int average;
  final int goalDays;
  final int activeDays;

  @override
  Widget build(BuildContext context) {
    final values = <(String, String)>[
      (context.l10n.totalConfirmed, formatCampaignNumber(total)),
      (context.l10n.dailyAverageLabel, formatCampaignNumber(average)),
      (context.l10n.goalDays, '$goalDays'),
      (context.l10n.activeDays, '$activeDays'),
    ];
    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.lg,
          children: <Widget>[
            for (final value in values)
              SizedBox(
                width: (constraints.maxWidth - AppSpacing.md) / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      value.$2,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(value.$1),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepChart extends StatelessWidget {
  const _StepChart({required this.days});
  final List<({DateTime date, DailyStepRecord? record})> days;

  @override
  Widget build(BuildContext context) {
    final maximum = days.fold<int>(
      1,
      (value, item) => math.max(value, item.record?.confirmedSteps ?? 0),
    );
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final chartHeight = (190 + ((textScale - 1) * 56)).clamp(190.0, 270.0);
    final total = days.fold<int>(
      0,
      (value, item) => value + (item.record?.confirmedSteps ?? 0),
    );
    return AppCard(
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: context.l10n.confirmedStepsChartSemantics(
          days.length,
          formatCampaignNumber(total),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (final item in days)
                  Semantics(
                    label: context.l10n.dayConfirmedStepsSemantics(
                      _friendlyDate(context.l10n.localeName, item.date),
                      item.record?.confirmedSteps ?? 0,
                    ),
                    child: Container(
                      width: days.length == 7 ? 48 : 34,
                      decoration: DateUtils.isSameDay(item.date, DateTime.now())
                          ? BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: .45),
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            formatCampaignNumber(
                              item.record?.confirmedSteps ?? 0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            width: 18,
                            height:
                                110 *
                                ((item.record?.confirmedSteps ?? 0) / maximum),
                            constraints: const BoxConstraints(minHeight: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary
                                  .withValues(
                                    alpha:
                                        DateUtils.isSameDay(
                                          item.date,
                                          DateTime.now(),
                                        )
                                        ? 1
                                        : .72,
                                  ),
                              borderRadius: BorderRadius.circular(AppRadii.md),
                              border: item.record == null
                                  ? Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            DateUtils.isSameDay(item.date, DateTime.now())
                                ? context.l10n.today
                                : '${item.date.day}',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight:
                                      DateUtils.isSameDay(
                                        item.date,
                                        DateTime.now(),
                                      )
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.date, required this.record});
  final DateTime date;
  final DailyStepRecord? record;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.isSameDay(date, DateTime.now());
    final steps = record?.confirmedSteps ?? 0;
    final goal = record?.goalSnapshot;
    final percentage = goal == null || goal == 0
        ? 0
        : (steps / goal * 100).round();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  today
                      ? context.l10n.today
                      : _friendlyDate(context.l10n.localeName, date),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              AppStatusChip(
                label: today
                    ? context.l10n.today
                    : record == null
                    ? context.l10n.noRecord
                    : record!.goalReached
                    ? context.l10n.goalReached
                    : context.l10n.completedDay,
                status: record?.goalReached == true
                    ? AppStatus.success
                    : AppStatus.neutral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.confirmedStepCount(formatCampaignNumber(steps)),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (goal != null) ...<Widget>[
            Text(context.l10n.goalValue(formatCampaignNumber(goal))),
            Text(context.l10n.percentageValue(percentage)),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: (steps / goal).clamp(0, 1),
              minHeight: 7,
            ),
          ] else
            Text(context.l10n.noRecordForDate),
        ],
      ),
    );
  }
}

String _friendlyDate(String localeName, DateTime value) =>
    DateFormat('EEEE، d MMMM', localeName).format(value);
