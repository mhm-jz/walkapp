import 'package:flutter/material.dart';
import 'package:walkingapp/l10n/app_localizations_extension.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import 'step_counter_controller.dart';
import 'widgets/daily_goal_sheet.dart';
import 'widgets/step_dashboard_widgets.dart';

class StepCounterPage extends StatefulWidget {
  const StepCounterPage({
    required this.controller,
    required this.settingsController,
    this.embedded = false,
    this.onOpenAccount,
    super.key,
  });

  final StepCounterController controller;
  final AppSettingsController settingsController;
  final bool embedded;
  final VoidCallback? onOpenAccount;

  @override
  State<StepCounterPage> createState() => _StepCounterPageState();
}

class _StepCounterPageState extends State<StepCounterPage> {
  late final StepCounterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.initialize();
  }

  Future<void> _startTracking() async {
    await _controller.start();
    if (!mounted || _controller.uiError != null) return;
    AppSnackbar.show(context, context.l10n.stepTrackingStarted);
  }

  Future<void> _stopTracking() async {
    await _controller.stop();
    if (!mounted || _controller.uiError != null) return;
    AppSnackbar.show(context, context.l10n.stepTrackingStopped);
  }

  Future<void> _showGoalEditor() async {
    final newGoal = await DailyGoalSheet.show(
      context,
      currentGoal: widget.settingsController.dailyGoal,
    );
    if (newGoal == null || !mounted) return;
    await widget.settingsController.setDailyGoal(newGoal);
    if (mounted) AppSnackbar.show(context, context.l10n.dailyGoalUpdated);
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      bottom: !widget.embedded,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          _controller,
          widget.settingsController,
        ]),
        builder: (context, child) {
          final snapshot = _controller.snapshot;
          final shownError = _controller.uiError ?? snapshot.error;
          final goal = widget.settingsController.dailyGoal;
          final stopReasonMessage = _stopReasonMessage(snapshot.stopReason);

          return RefreshIndicator(
            onRefresh: _controller.refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                          children: <Widget>[
                            StepDashboardHeader(
                              isTracking: snapshot.isTracking,
                              themeMode: widget.settingsController.themeMode,
                              onThemeChanged:
                                  widget.settingsController.setThemeMode,
                              profileName:
                                  widget.settingsController.profileName,
                              onOpenAccount: widget.onOpenAccount,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            StepProgressCard(
                              steps: snapshot.displayedSteps,
                              goal: goal,
                              onEditGoal: _showGoalEditor,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            StepStatsSection(
                              confirmedSteps: snapshot.confirmedSteps,
                              validatingSteps: snapshot.provisionalSteps,
                              displayedSteps: snapshot.displayedSteps,
                              goal: goal,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            ActivitySummaryCard(
                              activity: snapshot.activity,
                              confidence: snapshot.confidence,
                              sensorReady: snapshot.sensorReady,
                              isTracking: snapshot.isTracking,
                              provisionalSteps: snapshot.provisionalSteps,
                            ),
                            if (shownError != null) ...<Widget>[
                              const SizedBox(height: AppSpacing.lg),
                              AppErrorView(
                                message: _friendlyError(shownError),
                                onRetry: _controller.refresh,
                                compact: true,
                              ),
                            ],
                            if (stopReasonMessage != null) ...<Widget>[
                              const SizedBox(height: AppSpacing.lg),
                              _StopReasonCard(message: stopReasonMessage),
                            ],
                            const SizedBox(height: AppSpacing.xl),
                            TrackingActionArea(
                              isTracking: snapshot.isTracking,
                              isLoading: _controller.isBusy,
                              onStart: _startTracking,
                              onStop: _stopTracking,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    return WithForegroundTask(
      child: widget.embedded ? content : Scaffold(body: content),
    );
  }

  String _friendlyError(String error) {
    final lower = error.toLowerCase();
    if (lower.contains('permission')) {
      return context.l10n.activityPermissionRequired;
    }
    if (lower.contains('sensor') || lower.contains('pedometer')) {
      return context.l10n.stepSensorUnavailable;
    }
    return context.l10n.trackingRefreshError;
  }

  String? _stopReasonMessage(String? reason) {
    if (reason == null) return null;
    final normalized = reason
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '_')
        .replaceAll(RegExp('^_+|_+\$'), '');
    return switch (normalized) {
      'user' || 'notification_button' =>
        'هر زمان آماده پیاده‌روی بودید، ردیابی را آغاز کنید.',
      'service_timeout' =>
        'ردیابی پس‌زمینه متوقف شده است. هر زمان آماده بودید دوباره آغاز کنید.',
      _ => null,
    };
  }
}

class _StopReasonCard extends StatelessWidget {
  const _StopReasonCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'ردیابی متوقف است',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
