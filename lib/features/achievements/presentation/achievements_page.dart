import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../step_counter/presentation/step_counter_controller.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({required this.controller, super.key});

  static const _milestones = <int>[1000, 5000, 10000, 20000];

  final StepCounterController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Achievements'),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final confirmedSteps = controller.snapshot.confirmedSteps;
            int? nextMilestone;
            for (final milestone in _milestones) {
              if (confirmedSteps < milestone) {
                nextMilestone = milestone;
                break;
              }
            }
            final progress = nextMilestone == null
                ? 1.0
                : (confirmedSteps / nextMilestone).clamp(0.0, 1.0);

            return CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Today’s achievements',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Milestones use today’s confirmed steps only.',
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
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: AppSpacing.sm,
                                    runSpacing: AppSpacing.sm,
                                    children: <Widget>[
                                      Text(
                                        nextMilestone == null
                                            ? 'All daily milestones achieved'
                                            : 'Next: $nextMilestone steps',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      AppStatusChip(
                                        label: '$confirmedSteps confirmed',
                                        status: AppStatus.success,
                                        icon: Icons.check_circle_outline,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Semantics(
                                    label: 'Progress toward next milestone',
                                    value:
                                        '${(progress * 100).round()} percent',
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(end: progress),
                                      duration: AppDurations.medium,
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, child) =>
                                          LinearProgressIndicator(
                                            value: value,
                                            minHeight: AppSpacing.sm,
                                            borderRadius: BorderRadius.circular(
                                              AppRadii.pill,
                                            ),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            for (final milestone in _milestones) ...<Widget>[
                              _MilestoneCard(
                                steps: milestone,
                                achieved: confirmedSteps >= milestone,
                              ),
                              if (milestone != _milestones.last)
                                const SizedBox(height: AppSpacing.md),
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
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.steps, required this.achieved});

  final int steps;
  final bool achieved;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = achieved ? context.appTheme.success : scheme.onSurfaceVariant;
    return AppCard(
      color: achieved ? scheme.primaryContainer.withValues(alpha: 0.35) : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stack =
              constraints.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3;
          final details = Row(
            children: <Widget>[
              Container(
                width: AppSizes.minTouchTarget,
                height: AppSizes.minTouchTarget,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  achieved ? Icons.emoji_events : Icons.lock_outline,
                  color: color,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '$steps steps',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      achieved
                          ? 'Reached with confirmed steps today'
                          : 'Keep walking to unlock this today',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final status = AppStatusChip(
            label: achieved ? 'Achieved' : 'Locked',
            status: achieved ? AppStatus.success : AppStatus.neutral,
          );
          if (stack) {
            return Column(
              children: <Widget>[
                details,
                const SizedBox(height: AppSpacing.md),
                Align(alignment: Alignment.centerLeft, child: status),
              ],
            );
          }
          return Row(
            children: <Widget>[
              Expanded(child: details),
              const SizedBox(width: AppSpacing.sm),
              status,
            ],
          );
        },
      ),
    );
  }
}
