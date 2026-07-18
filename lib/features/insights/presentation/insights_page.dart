import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../step_counter/domain/tracking_activity.dart';
import '../../step_counter/presentation/step_counter_controller.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({
    required this.controller,
    required this.settingsController,
    super.key,
  });

  final StepCounterController controller;
  final AppSettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          controller,
          settingsController,
        ]),
        builder: (context, child) {
          final snapshot = controller.snapshot;
          final goal = settingsController.dailyGoal;
          final rawProgress = snapshot.displayedSteps / goal;
          final visualProgress = rawProgress.clamp(0.0, 1.0);
          final percentage = math.max((rawProgress * 100).round(), 0);

          return CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
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
                          Text(
                            'Insights',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'A clear view of today’s real activity data.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: context.appTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        'Daily goal progress',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    ),
                                    AppStatusChip(
                                      label: '$percentage%',
                                      status: AppStatus.success,
                                      icon: Icons.trending_up,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Semantics(
                                  label: 'Daily goal completion',
                                  value: '$percentage percent',
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(end: visualProgress),
                                    duration: AppDurations.medium,
                                    curve: Curves.easeOutCubic,
                                    builder: (context, progress, child) =>
                                        LinearProgressIndicator(
                                          value: progress,
                                          minHeight: AppSpacing.sm,
                                          borderRadius: BorderRadius.circular(
                                            AppRadii.pill,
                                          ),
                                        ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  '${snapshot.displayedSteps} of $goal steps',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: context.appTheme.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _TodayMetrics(
                            displayed: snapshot.displayedSteps,
                            confirmed: snapshot.confirmedSteps,
                            validating: snapshot.provisionalSteps,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppCard(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: AppSizes.minTouchTarget,
                                  height: AppSizes.minTouchTarget,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.md,
                                    ),
                                  ),
                                  child: Icon(
                                    _activityIcon(snapshot.activity),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Current activity',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: context
                                                  .appTheme
                                                  .textSecondary,
                                            ),
                                      ),
                                      Text(
                                        _activityLabel(snapshot.activity),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const AppCard(
                            child: AppEmptyState(
                              title: 'More insights are coming',
                              message:
                                  'Keep tracking your walks. Weekly trends and progress comparisons will appear when historical tracking is available.',
                              icon: Icons.insights_outlined,
                            ),
                          ),
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

  String _activityLabel(TrackingActivity value) => switch (value) {
    TrackingActivity.walking => 'Walking',
    TrackingActivity.running => 'Running',
    TrackingActivity.still => 'Still',
    TrackingActivity.inVehicle => 'In vehicle',
    TrackingActivity.onBicycle => 'Cycling',
    TrackingActivity.unknown => 'Detecting activity',
  };

  IconData _activityIcon(TrackingActivity value) => switch (value) {
    TrackingActivity.walking => Icons.directions_walk,
    TrackingActivity.running => Icons.directions_run,
    TrackingActivity.still => Icons.pause_circle_outline,
    TrackingActivity.inVehicle => Icons.directions_car,
    TrackingActivity.onBicycle => Icons.directions_bike,
    TrackingActivity.unknown => Icons.help_outline,
  };
}

class _TodayMetrics extends StatelessWidget {
  const _TodayMetrics({
    required this.displayed,
    required this.confirmed,
    required this.validating,
  });

  final int displayed;
  final int confirmed;
  final int validating;

  @override
  Widget build(BuildContext context) {
    final metrics = <({String label, int value, IconData icon})>[
      (label: 'Today', value: displayed, icon: Icons.directions_walk_outlined),
      (label: 'Confirmed', value: confirmed, icon: Icons.check_circle_outline),
      (label: 'Validating', value: validating, icon: Icons.schedule),
    ];
    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow =
              constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3;
          final columns = narrow ? 2 : 3;
          final width =
              (constraints.maxWidth - AppSpacing.sm * (columns - 1)) / columns;
          return Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.lg,
            children: <Widget>[
              for (final metric in metrics)
                SizedBox(
                  width: width,
                  child: Column(
                    children: <Widget>[
                      Icon(
                        metric.icon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FittedBox(
                        child: Text(
                          '${metric.value}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        metric.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.appTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
