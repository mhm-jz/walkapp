import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design_system/components/app_button.dart';
import '../../../../core/design_system/components/app_card.dart';
import '../../../../core/design_system/components/app_status_chip.dart';
import '../../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../../core/design_system/tokens/app_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/tracking_activity.dart';
import '../tracking_activity_localization.dart';
import '../../../../l10n/app_localizations_extension.dart';

class StepDashboardHeader extends StatelessWidget {
  const StepDashboardHeader({
    required this.isTracking,
    required this.themeMode,
    required this.onThemeChanged,
    required this.profileName,
    this.onOpenAccount,
    super.key,
  });

  final bool isTracking;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final String profileName;
  final VoidCallback? onOpenAccount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                context.l10n.todaySteps,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                isTracking ? context.l10n.keepGoing : context.l10n.readyToMove,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.appTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppStatusChip(
                label: isTracking
                    ? context.l10n.trackingActive
                    : context.l10n.trackingStopped,
                status: isTracking ? AppStatus.success : AppStatus.neutral,
                icon: isTracking ? Icons.sensors : Icons.pause_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        PopupMenuButton<ThemeMode>(
          tooltip: context.l10n.chooseTheme,
          icon: Icon(_themeIcon(themeMode)),
          onSelected: onThemeChanged,
          itemBuilder: (context) => <PopupMenuEntry<ThemeMode>>[
            PopupMenuItem(
              value: ThemeMode.system,
              child: ListTile(
                leading: Icon(Icons.brightness_auto),
                title: Text(context.l10n.systemTheme),
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.light,
              child: ListTile(
                leading: Icon(Icons.light_mode_outlined),
                title: Text(context.l10n.lightTheme),
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.dark,
              child: ListTile(
                leading: Icon(Icons.dark_mode_outlined),
                title: Text(context.l10n.darkTheme),
              ),
            ),
          ],
        ),
        if (onOpenAccount != null)
          IconButton(
            tooltip: context.l10n.openAccountMenu,
            onPressed: onOpenAccount,
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: _profileInitials(profileName).isEmpty
                  ? const Icon(Icons.person_outline, size: 19)
                  : Text(
                      _profileInitials(profileName),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  IconData _themeIcon(ThemeMode mode) => switch (mode) {
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
    ThemeMode.system => Icons.brightness_auto,
  };

  String _profileInitials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class StepProgressCard extends StatelessWidget {
  const StepProgressCard({
    required this.steps,
    required this.goal,
    required this.onEditGoal,
    super.key,
  });

  final int steps;
  final int goal;
  final VoidCallback onEditGoal;

  @override
  Widget build(BuildContext context) {
    final rawProgress = goal == 0 ? 0.0 : steps / goal;
    final visualProgress = rawProgress.clamp(0.0, 1.0);
    final percentage = (rawProgress * 100).round();
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.l10n.todayProgress,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.dailyGoalWithSteps(goal),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppIconButton(
                onPressed: onEditGoal,
                tooltip: context.l10n.editDailyGoal,
                icon: Icons.edit_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: visualProgress),
            duration: AppDurations.slow,
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, child) => Semantics(
              label: context.l10n.dailyStepProgress,
              value: context.l10n.dailyStepProgressValue(
                steps,
                goal,
                percentage,
              ),
              child: SizedBox.square(
                dimension: AppSizes.progressDiameter - AppSpacing.lg,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CircularProgressIndicator(
                      value: animatedProgress,
                      color: scheme.primary,
                      backgroundColor: scheme.primary.withValues(alpha: 0.12),
                      strokeWidth: AppSizes.progressStroke,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.directions_walk_rounded,
                              color: scheme.primary,
                              size: 28,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            AnimatedSwitcher(
                              duration: AppDurations.medium,
                              child: FittedBox(
                                key: ValueKey<int>(steps),
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '$steps',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                            Text(
                              'قدم',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: context.appTheme.textSecondary,
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
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              AppStatusChip(
                label: context.l10n.percentageComplete(percentage),
                status: AppStatus.success,
                icon: Icons.trending_up_rounded,
              ),
              AppStatusChip(
                label: context.l10n.goalNumber(goal),
                status: AppStatus.neutral,
                icon: Icons.flag_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StepStatsSection extends StatelessWidget {
  const StepStatsSection({
    required this.confirmedSteps,
    required this.validatingSteps,
    required this.displayedSteps,
    required this.goal,
    super.key,
  });

  final int confirmedSteps;
  final int validatingSteps;
  final int displayedSteps;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final remainingSteps = math.max(goal - displayedSteps, 0);
    final items = <_StatData>[
      _StatData(
        label: context.l10n.confirmedSteps,
        value: confirmedSteps,
        icon: Icons.check_circle_outline,
        color: context.appTheme.success,
      ),
      _StatData(
        label: context.l10n.validating,
        value: validatingSteps,
        icon: Icons.schedule,
        color: context.appTheme.warning,
      ),
      _StatData(
        label: context.l10n.remaining,
        value: remainingSteps,
        icon: Icons.track_changes,
        color: Theme.of(context).colorScheme.secondary,
      ),
    ];

    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wrap =
              constraints.maxWidth < 270 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3;
          final columns = wrap ? 2 : 3;
          final itemWidth =
              (constraints.maxWidth - (AppSpacing.sm * (columns - 1))) /
              columns;
          return Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.md,
            children: <Widget>[
              for (final item in items)
                SizedBox(
                  width: itemWidth,
                  child: _StatItem(data: item),
                ),
            ],
          );
        },
      ),
    );
  }
}

class ActivitySummaryCard extends StatelessWidget {
  const ActivitySummaryCard({
    required this.activity,
    required this.sensorReady,
    required this.isTracking,
    required this.provisionalSteps,
    super.key,
  });

  final TrackingActivity activity;
  final bool sensorReady;
  final bool isTracking;
  final int provisionalSteps;

  @override
  Widget build(BuildContext context) {
    final presentation = _activityPresentation(context, activity);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.currentActivity,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Container(
                width: AppSizes.minTouchTarget,
                height: AppSizes.minTouchTarget,
                decoration: BoxDecoration(
                  color: presentation.color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Icon(
                  presentation.icon,
                  color: presentation.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      presentation.label,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.transitionBasedDetection,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              AppStatusChip(
                label: sensorReady
                    ? context.l10n.sensorsReady
                    : isTracking
                    ? context.l10n.sensorsPreparing
                    : context.l10n.sensorsInactive,
                status: sensorReady ? AppStatus.success : AppStatus.neutral,
                icon: Icons.sensors,
              ),
              AppStatusChip(
                label: isTracking
                    ? context.l10n.trackingActiveCompact
                    : context.l10n.trackingStoppedCompact,
                status: isTracking ? AppStatus.success : AppStatus.neutral,
                icon: isTracking
                    ? Icons.location_searching
                    : Icons.location_disabled,
              ),
              AppStatusChip(
                label: provisionalSteps > 0
                    ? context.l10n.validationValidating
                    : context.l10n.validationIdle,
                status: provisionalSteps > 0
                    ? AppStatus.warning
                    : AppStatus.neutral,
                icon: Icons.fact_check_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  _ActivityPresentation _activityPresentation(
    BuildContext context,
    TrackingActivity value,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final label = value.localizedLabel(AppLocalizations.of(context));
    return switch (value) {
      TrackingActivity.walking => _ActivityPresentation(
        label: label,
        icon: Icons.directions_walk,
        color: context.appTheme.success,
      ),
      TrackingActivity.running => _ActivityPresentation(
        label: label,
        icon: Icons.directions_run,
        color: scheme.secondary,
      ),
      TrackingActivity.still => _ActivityPresentation(
        label: label,
        icon: Icons.pause_circle_outline,
        color: scheme.onSurfaceVariant,
      ),
      TrackingActivity.inVehicle => _ActivityPresentation(
        label: label,
        icon: Icons.directions_car,
        color: context.appTheme.warning,
      ),
      TrackingActivity.onBicycle => _ActivityPresentation(
        label: label,
        icon: Icons.directions_bike,
        color: scheme.secondary,
      ),
      TrackingActivity.unknown => _ActivityPresentation(
        label: label,
        icon: Icons.help_outline,
        color: scheme.onSurfaceVariant,
      ),
    };
  }
}

class TrackingActionArea extends StatelessWidget {
  const TrackingActionArea({
    required this.isTracking,
    required this.isLoading,
    required this.onStart,
    required this.onStop,
    super.key,
  });

  final bool isTracking;
  final bool isLoading;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: isTracking ? context.l10n.stopTracking : context.l10n.startWalking,
      icon: isTracking ? Icons.stop_rounded : Icons.directions_walk_rounded,
      variant: isTracking
          ? AppButtonVariant.destructive
          : AppButtonVariant.primary,
      isLoading: isLoading,
      expanded: true,
      onPressed: isLoading
          ? null
          : isTracking
          ? onStop
          : onStart,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Icon(data.icon, color: data.color, size: 21),
        ),
        const SizedBox(height: AppSpacing.sm),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${data.value}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Text(
          data.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.appTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatData {
  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
}

class _ActivityPresentation {
  const _ActivityPresentation({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
