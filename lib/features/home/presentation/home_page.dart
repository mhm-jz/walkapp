import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../campaigns/application/campaign_enrollment_controller.dart';
import '../../campaigns/domain/campaign.dart';
import '../../campaigns/domain/campaign_enrollment.dart';
import '../../campaigns/domain/campaign_enrollment_status.dart';
import '../../campaigns/domain/campaign_reward_type.dart';
import '../../campaigns/domain/campaign_status.dart';
import '../../campaigns/domain/campaign_type.dart';
import '../../campaigns/presentation/active_campaign_page.dart';
import '../../campaigns/presentation/campaign_details_page.dart';
import '../../campaigns/presentation/campaign_formatters.dart';
import '../../rewards/application/rewards_controller.dart';
import '../../rewards/domain/claimed_reward.dart';
import '../../rewards/domain/coupon_status.dart';
import '../../rewards/presentation/coupon_details_page.dart';
import '../../step_counter/data/step_snapshot.dart';
import '../../step_counter/domain/tracking_activity.dart';
import '../../step_counter/presentation/step_counter_controller.dart';
import '../../step_counter/presentation/widgets/daily_goal_sheet.dart';
import '../../notifications/application/notification_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.stepController,
    required this.settingsController,
    required this.campaignController,
    required this.rewardsController,
    required this.onOpenAccount,
    required this.onOpenCampaigns,
    required this.onOpenRewards,
    required this.notificationController,
    required this.onOpenNotifications,
    super.key,
  });

  final StepCounterController stepController;
  final AppSettingsController settingsController;
  final CampaignEnrollmentController campaignController;
  final RewardsController rewardsController;
  final VoidCallback onOpenAccount;
  final VoidCallback onOpenCampaigns;
  final VoidCallback onOpenRewards;
  final NotificationController notificationController;
  final VoidCallback onOpenNotifications;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _showGoalEditor() async {
    final goal = await DailyGoalSheet.show(
      context,
      currentGoal: widget.settingsController.dailyGoal,
    );
    if (goal == null || !mounted) return;
    await widget.settingsController.setDailyGoal(goal);
    if (mounted) AppSnackbar.show(context, 'Daily goal updated');
  }

  Future<void> _toggleTracking() async {
    final wasTracking = widget.stepController.snapshot.isTracking;
    if (wasTracking) {
      await widget.stepController.stop();
    } else {
      await widget.stepController.start();
    }
    if (!mounted) return;
    final error = widget.stepController.uiError;
    AppSnackbar.show(
      context,
      error == null
          ? wasTracking
                ? 'Step tracking stopped'
                : 'Step tracking started'
          : 'Tracking could not be updated. Please try again.',
      isError: error != null,
    );
  }

  void _openActiveCampaign() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ActiveCampaignPage(
          controller: widget.campaignController,
          rewardsController: widget.rewardsController,
        ),
      ),
    );
  }

  void _openCampaign(Campaign campaign) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => CampaignDetailsPage(
          campaign: campaign,
          enrollmentController: widget.campaignController,
          settingsController: widget.settingsController,
          rewardsController: widget.rewardsController,
        ),
      ),
    );
  }

  Future<void> _claimReward(
    ({Campaign campaign, CampaignEnrollment enrollment}) item,
  ) async {
    final result = await widget.rewardsController.claimCampaignReward(
      item.enrollment,
    );
    if (!mounted) return;
    final claim = widget.rewardsController.claimedRewardForCampaign(
      item.campaign.id,
    );
    if ((result == RewardActionResult.success ||
            result == RewardActionResult.alreadyClaimed) &&
        claim != null) {
      AppSnackbar.show(context, 'Campaign reward claimed');
      _openCoupon(claim);
      return;
    }
    AppSnackbar.show(
      context,
      widget.rewardsController.userMessage ??
          'The reward could not be claimed.',
      isError: true,
    );
  }

  void _openCoupon(ClaimedReward reward) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => CouponDetailsPage(
          claimedRewardId: reward.id,
          controller: widget.rewardsController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: widget.stepController.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      constraints: const BoxConstraints(
                        maxWidth: AppSizes.contentMaxWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          AnimatedBuilder(
                            animation: Listenable.merge(<Listenable>[
                              widget.settingsController,
                              widget.notificationController,
                            ]),
                            builder: (context, child) => _HomeHeader(
                              profileName:
                                  widget.settingsController.profileName,
                              onOpenAccount: widget.onOpenAccount,
                              unreadCount:
                                  widget.notificationController.unreadCount,
                              onOpenNotifications: widget.onOpenNotifications,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AnimatedBuilder(
                            animation: Listenable.merge(<Listenable>[
                              widget.stepController,
                              widget.settingsController,
                            ]),
                            builder: (context, child) {
                              final snapshot = widget.stepController.snapshot;
                              final goal = widget.settingsController.dailyGoal;
                              return Column(
                                children: <Widget>[
                                  _TodayProgressCard(
                                    steps: snapshot.displayedSteps,
                                    goal: goal,
                                    onEditGoal: _showGoalEditor,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  _HealthStats(
                                    confirmed: snapshot.confirmedSteps,
                                    validating: snapshot.provisionalSteps,
                                    remaining: math.max(
                                      goal - snapshot.displayedSteps,
                                      0,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AnimatedBuilder(
                            animation: Listenable.merge(<Listenable>[
                              widget.campaignController,
                              widget.rewardsController,
                              widget.settingsController,
                            ]),
                            builder: (context, child) => _CampaignOverview(
                              campaignController: widget.campaignController,
                              rewardsController: widget.rewardsController,
                              rewardInterests:
                                  widget.settingsController.rewardInterests,
                              onContinue: _openActiveCampaign,
                              onExplore: widget.onOpenCampaigns,
                              onViewCampaign: _openCampaign,
                              onOpenRewards: widget.onOpenRewards,
                              onClaimReward: _claimReward,
                              onOpenCoupon: _openCoupon,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AnimatedBuilder(
                            animation: widget.rewardsController,
                            builder: (context, child) => _RewardsSummary(
                              controller: widget.rewardsController,
                              onOpenRewards: widget.onOpenRewards,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AnimatedBuilder(
                            animation: widget.stepController,
                            builder: (context, child) {
                              final snapshot = widget.stepController.snapshot;
                              final shownError =
                                  widget.stepController.uiError ??
                                  snapshot.error;
                              return Column(
                                children: <Widget>[
                                  _TrackingStatusCard(snapshot: snapshot),
                                  if (shownError != null) ...<Widget>[
                                    const SizedBox(height: AppSpacing.md),
                                    AppErrorView(
                                      message: _friendlyError(shownError),
                                      onRetry: widget.stepController.refresh,
                                      compact: true,
                                    ),
                                  ],
                                  const SizedBox(height: AppSpacing.lg),
                                  AppButton(
                                    label: _trackingActionLabel(
                                      snapshot,
                                      widget.stepController.isBusy,
                                    ),
                                    icon: snapshot.isTracking
                                        ? Icons.stop_circle_outlined
                                        : Icons.directions_walk,
                                    expanded: true,
                                    isLoading: widget.stepController.isBusy,
                                    onPressed: widget.stepController.isBusy
                                        ? null
                                        : _toggleTracking,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _friendlyError(String error) {
    final lower = error.toLowerCase();
    if (lower.contains('permission')) {
      return 'Activity permission is required to count steps.';
    }
    if (lower.contains('sensor') || lower.contains('pedometer')) {
      return 'The step sensor is unavailable on this device.';
    }
    return 'Tracking could not be updated. Pull down or try again.';
  }

  String _trackingActionLabel(StepSnapshot snapshot, bool busy) {
    if (!busy) return snapshot.isTracking ? 'Stop Tracking' : 'Start Walking';
    return snapshot.isTracking ? 'Stopping…' : 'Starting…';
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.profileName,
    required this.onOpenAccount,
    required this.unreadCount,
    required this.onOpenNotifications,
  });

  final String profileName;
  final VoidCallback onOpenAccount;
  final int unreadCount;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final name = profileName.trim().split(RegExp(r'\s+')).firstOrNull ?? '';
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 18
        ? 'Good afternoon'
        : 'Good evening';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name.isEmpty ? greeting : '$greeting, $name',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _fullDate(now),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.appTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Semantics(
          label: unreadCount == 0
              ? 'Notifications, none unread'
              : 'Notifications, $unreadCount unread',
          button: true,
          child: Badge(
            isLabelVisible: unreadCount > 0,
            label: AnimatedSwitcher(
              duration: AppDurations.fast,
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                key: ValueKey(unreadCount),
              ),
            ),
            child: AppIconButton(
              icon: Icons.notifications_outlined,
              tooltip: 'Open notifications',
              onPressed: onOpenNotifications,
            ),
          ),
        ),
        AppIconButton(
          icon: Icons.account_circle_outlined,
          tooltip: 'Open account menu',
          onPressed: onOpenAccount,
        ),
      ],
    );
  }

  String _fullDate(DateTime value) {
    const weekdays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[value.weekday - 1]}, '
        '${months[value.month - 1]} ${value.day}';
  }
}

class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard({
    required this.steps,
    required this.goal,
    required this.onEditGoal,
  });

  final int steps;
  final int goal;
  final VoidCallback onEditGoal;

  @override
  Widget build(BuildContext context) {
    final rawProgress = goal <= 0 ? 0.0 : steps / goal;
    final progress = rawProgress.clamp(0.0, 1.0);
    final percentage = (rawProgress * 100).round();
    final remaining = math.max(goal - steps, 0);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label:
          'Today’s health progress, $steps of $goal steps, $percentage percent, $remaining remaining',
      child: AppCard(
        color: scheme.primaryContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Today’s health progress',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                AppIconButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit daily goal',
                  onPressed: onEditGoal,
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: AppDurations.medium,
              child: Text(
                '${formatCampaignNumber(steps)} steps',
                key: ValueKey<int>(steps),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$percentage% of ${formatCampaignNumber(goal)}  •  '
              '${formatCampaignNumber(remaining)} remaining',
            ),
            const SizedBox(height: AppSpacing.md),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: progress),
              duration: AppDurations.slow,
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => LinearProgressIndicator(
                value: value,
                minHeight: 12,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                color: scheme.primary,
                backgroundColor: scheme.primary.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthStats extends StatelessWidget {
  const _HealthStats({
    required this.confirmed,
    required this.validating,
    required this.remaining,
  });

  final int confirmed;
  final int validating;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final items = <({String label, int value, IconData icon, Color color})>[
      (
        label: 'Confirmed',
        value: confirmed,
        icon: Icons.verified_outlined,
        color: context.appTheme.success,
      ),
      (
        label: 'Validating',
        value: validating,
        icon: Icons.hourglass_top,
        color: context.appTheme.warning,
      ),
      (
        label: 'Remaining',
        value: remaining,
        icon: Icons.flag_outlined,
        color: Theme.of(context).colorScheme.secondary,
      ),
    ];
    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow =
              constraints.maxWidth < 310 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.3;
          final width = narrow
              ? (constraints.maxWidth - AppSpacing.sm) / 2
              : (constraints.maxWidth - AppSpacing.sm * 2) / 3;
          return Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.md,
            children: <Widget>[
              for (final item in items)
                Semantics(
                  label: '${item.label}, ${item.value} steps',
                  child: SizedBox(
                    width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(item.icon, size: 20, color: item.color),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          formatCampaignNumber(item.value),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(item.label),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CampaignOverview extends StatelessWidget {
  const _CampaignOverview({
    required this.campaignController,
    required this.rewardsController,
    required this.rewardInterests,
    required this.onContinue,
    required this.onExplore,
    required this.onViewCampaign,
    required this.onOpenRewards,
    required this.onClaimReward,
    required this.onOpenCoupon,
  });

  final CampaignEnrollmentController campaignController;
  final RewardsController rewardsController;
  final List<String> rewardInterests;
  final VoidCallback onContinue;
  final VoidCallback onExplore;
  final ValueChanged<Campaign> onViewCampaign;
  final VoidCallback onOpenRewards;
  final ValueChanged<({Campaign campaign, CampaignEnrollment enrollment})>
  onClaimReward;
  final ValueChanged<ClaimedReward> onOpenCoupon;

  @override
  Widget build(BuildContext context) {
    if (campaignController.viewState == CampaignEnrollmentViewState.loading) {
      return const AppCard(
        child: Row(
          children: <Widget>[
            SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: AppSpacing.md),
            Text('Loading campaign progress…'),
          ],
        ),
      );
    }
    if (campaignController.viewState == CampaignEnrollmentViewState.error) {
      return AppErrorView(
        message:
            campaignController.userMessage ??
            'Campaign progress is temporarily unavailable.',
        onRetry: campaignController.initialize,
        compact: true,
      );
    }
    final active = campaignController.activeEnrollment;
    if (active != null) {
      final campaign = campaignController.campaignFor(active);
      if (campaign != null) {
        return _ActiveCampaignCard(
          campaign: campaign,
          enrollment: active,
          controller: campaignController,
          onContinue: onContinue,
          onExplore: onExplore,
        );
      }
    }

    final recent = campaignController.recentEnrollment;
    final recentCampaign = recent == null
        ? null
        : campaignController.campaignFor(recent);
    final featured = _featuredCampaign();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (recent != null &&
            recentCampaign != null &&
            recent.status == CampaignEnrollmentStatus.completed) ...<Widget>[
          _CompletedCampaignCard(
            campaign: recentCampaign,
            enrollment: recent,
            rewardsController: rewardsController,
            onOpenRewards: onOpenRewards,
            onClaimReward: () =>
                onClaimReward((campaign: recentCampaign, enrollment: recent)),
            onOpenCoupon: onOpenCoupon,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (featured != null)
          _FeaturedCampaignCard(
            campaign: featured,
            onView: () => onViewCampaign(featured),
          )
        else if (recent == null)
          _CampaignDiscoveryPrompt(onExplore: onExplore),
      ],
    );
  }

  Campaign? _featuredCampaign() {
    final now = DateTime.now();
    final eligible = campaignController.campaigns
        .where((campaign) {
          final status = campaign.statusAt(now);
          final enrollment = campaignController.enrollmentFor(campaign.id);
          return (status == CampaignStatus.available ||
                  status == CampaignStatus.endingSoon) &&
              enrollment?.status != CampaignEnrollmentStatus.completed;
        })
        .toList(growable: false);
    final hasPreference =
        rewardInterests.isNotEmpty &&
        !rewardInterests.contains('No preference');
    if (hasPreference) {
      for (final campaign in eligible) {
        if (campaign.isFeatured &&
            rewardInterests.contains(
              campaignCategoryLabel(campaign.category),
            )) {
          return campaign;
        }
      }
    }
    for (final campaign in eligible) {
      if (campaign.isFeatured) return campaign;
    }
    if (hasPreference) {
      for (final campaign in eligible) {
        if (rewardInterests.contains(
          campaignCategoryLabel(campaign.category),
        )) {
          return campaign;
        }
      }
    }
    return eligible.firstOrNull;
  }
}

class _ActiveCampaignCard extends StatelessWidget {
  const _ActiveCampaignCard({
    required this.campaign,
    required this.enrollment,
    required this.controller,
    required this.onContinue,
    required this.onExplore,
  });

  final Campaign campaign;
  final CampaignEnrollment enrollment;
  final CampaignEnrollmentController controller;
  final VoidCallback onContinue;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final progress = controller.progressFor(campaign, enrollment);
    final stepTarget = campaign.type == CampaignType.stepTarget;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Active campaign',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            campaign.brand.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.appTheme.textSecondary,
            ),
          ),
          Text(campaign.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            label: 'Campaign progress ${(progress * 100).round()} percent',
            child: LinearProgressIndicator(value: progress, minHeight: 9),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            stepTarget
                ? '${formatCampaignNumber(enrollment.totalEligibleSteps)} / '
                      '${formatCampaignNumber(campaign.targetSteps ?? 0)} campaign steps'
                : '${controller.completedGoalDays(enrollment)} of '
                      '${campaign.requiredGoalDays} goal days completed',
          ),
          if (!stepTarget)
            Text(
              '${formatCampaignNumber(controller.eligibleStepsToday(enrollment))} / '
              '${formatCampaignNumber(enrollment.goalAtEnrollment ?? 0)} eligible steps today',
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(campaignTiming(campaign, DateTime.now())),
          Text('Reward: ${campaign.reward.discountLabel}'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: <Widget>[
              AppButton(label: 'Continue Campaign', onPressed: onContinue),
              AppButton(
                label: 'Explore more',
                variant: AppButtonVariant.text,
                onPressed: onExplore,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletedCampaignCard extends StatelessWidget {
  const _CompletedCampaignCard({
    required this.campaign,
    required this.enrollment,
    required this.rewardsController,
    required this.onOpenRewards,
    required this.onClaimReward,
    required this.onOpenCoupon,
  });

  final Campaign campaign;
  final CampaignEnrollment enrollment;
  final RewardsController rewardsController;
  final VoidCallback onOpenRewards;
  final VoidCallback onClaimReward;
  final ValueChanged<ClaimedReward> onOpenCoupon;

  @override
  Widget build(BuildContext context) {
    final points = campaign.reward.type == CampaignRewardType.points;
    final claim = rewardsController.claimedRewardForCampaign(campaign.id);
    return AppCard(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const AppStatusChip(
            label: 'Campaign completed',
            status: AppStatus.success,
            icon: Icons.verified_outlined,
          ),
          if (!points && claim == null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text('Reward ready', style: Theme.of(context).textTheme.labelLarge),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(campaign.title, style: Theme.of(context).textTheme.titleLarge),
          Text(
            points
                ? '${campaign.reward.pointsAmount ?? 0} points earned'
                : claim == null
                ? '${campaign.reward.title} is ready to claim'
                : '${campaign.reward.title} unlocked',
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: points
                  ? 'View Rewards'
                  : claim == null
                  ? 'Claim Reward'
                  : 'View Reward',
              isLoading: rewardsController.isSaving,
              onPressed: points
                  ? onOpenRewards
                  : claim == null
                  ? onClaimReward
                  : () => onOpenCoupon(claim),
            ),
          ),
          if (!points && rewardsController.directRewardsReady.length > 1)
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                label: 'View all',
                variant: AppButtonVariant.text,
                onPressed: onOpenRewards,
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedCampaignCard extends StatelessWidget {
  const _FeaturedCampaignCard({required this.campaign, required this.onView});
  final Campaign campaign;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Featured challenge',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Text(campaign.brand.name),
        Text(campaign.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(campaignGoalSummary(campaign)),
        Text('Reward: ${campaign.reward.discountLabel}'),
        Text(campaignTiming(campaign, DateTime.now())),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton(
            label: 'View Campaign',
            variant: AppButtonVariant.outlined,
            onPressed: onView,
          ),
        ),
      ],
    ),
  );
}

class _CampaignDiscoveryPrompt extends StatelessWidget {
  const _CampaignDiscoveryPrompt({required this.onExplore});
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Icon(Icons.campaign_outlined),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Ready for a walking challenge?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Explore campaigns and unlock rewards from participating brands.',
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: AppButton(
                  label: 'Explore Campaigns',
                  variant: AppButtonVariant.text,
                  onPressed: onExplore,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RewardsSummary extends StatelessWidget {
  const _RewardsSummary({
    required this.controller,
    required this.onOpenRewards,
  });
  final RewardsController controller;
  final VoidCallback onOpenRewards;

  @override
  Widget build(BuildContext context) {
    if (controller.viewState == RewardsViewState.loading) {
      return const AppCard(child: Text('Loading rewards…'));
    }
    if (controller.viewState == RewardsViewState.error) {
      return AppErrorView(
        message:
            controller.userMessage ?? 'Rewards are temporarily unavailable.',
        onRetry: controller.initialize,
        compact: true,
      );
    }
    final ready = controller.directRewardsReady.length;
    final availableCoupons = controller.claimedRewards
        .where(
          (reward) => reward.statusAt(DateTime.now()) == CouponStatus.available,
        )
        .length;
    final hasActivity =
        controller.transactions.isNotEmpty || ready > 0 || availableCoupons > 0;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.redeem_outlined),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Rewards', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                if (hasActivity) ...<Widget>[
                  Text('${controller.wallet.balance} points available'),
                  if (ready > 0)
                    Text(
                      '$ready reward${ready == 1 ? '' : 's'} ready to claim',
                    ),
                  if (availableCoupons > 0)
                    Text(
                      '$availableCoupons available coupon${availableCoupons == 1 ? '' : 's'}',
                    ),
                ] else
                  const Text(
                    'Complete eligible campaigns to start earning rewards.',
                  ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppButton(
                    label: 'Open Rewards',
                    variant: AppButtonVariant.text,
                    onPressed: onOpenRewards,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStatusCard extends StatelessWidget {
  const _TrackingStatusCard({required this.snapshot});
  final StepSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final label = !snapshot.isTracking
        ? 'Tracking paused'
        : !snapshot.sensorReady
        ? 'Preparing sensor'
        : _activityLabel(snapshot.activity);
    final validation = snapshot.provisionalSteps > 0
        ? 'Validating recent steps'
        : 'Up to date';
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            snapshot.isTracking ? Icons.sensors : Icons.sensors_off_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  snapshot.isTracking ? 'Tracking active' : 'Tracking paused',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(label),
                Text(
                  snapshot.sensorReady
                      ? 'Step sensor ready'
                      : snapshot.isTracking
                      ? 'Step sensor preparing'
                      : 'Step sensor inactive',
                ),
                if (snapshot.isTracking) Text(validation),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _activityLabel(TrackingActivity activity) => switch (activity) {
    TrackingActivity.walking => 'Walking',
    TrackingActivity.running => 'Running',
    TrackingActivity.onBicycle => 'Cycling',
    TrackingActivity.inVehicle => 'In vehicle',
    TrackingActivity.still => 'Detecting activity',
    TrackingActivity.unknown => 'Detecting activity',
  };
}
