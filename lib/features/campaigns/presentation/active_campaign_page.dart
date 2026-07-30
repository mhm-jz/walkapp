import 'package:flutter/material.dart';
import 'package:walkingapp/l10n/app_localizations_extension.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../application/campaign_enrollment_controller.dart';
import '../domain/campaign.dart';
import '../domain/campaign_enrollment.dart';
import '../domain/campaign_enrollment_status.dart';
import '../domain/campaign_type.dart';
import '../domain/campaign_reward_type.dart';
import '../../rewards/application/rewards_controller.dart';
import '../../rewards/presentation/coupon_details_page.dart';
import '../../rewards/presentation/wallet_activity_page.dart';
import 'campaign_formatters.dart';
import 'widgets/campaign_shared_widgets.dart';

class ActiveCampaignPage extends StatefulWidget {
  const ActiveCampaignPage({
    required this.controller,
    required this.rewardsController,
    super.key,
  });

  final CampaignEnrollmentController controller;
  final RewardsController rewardsController;

  @override
  State<ActiveCampaignPage> createState() => _ActiveCampaignPageState();
}

class _ActiveCampaignPageState extends State<ActiveCampaignPage> {
  bool _completionScheduled = false;

  Future<void> _showCompletion(Campaign campaign) async {
    await AppDialog.show<void>(
      context,
      title: context.l10n.campaignCompleted,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.elasticOut,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Icon(
              Icons.celebration_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            campaign.reward.type == CampaignRewardType.points
                ? '${context.l10n.earnedRewardPoints(campaign.reward.pointsAmount ?? 0)} ${context.l10n.pointsAddedToRewards}'
                : context.l10n.unlockedReward(campaign.reward.discountLabel),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: <Widget>[
        AppButton(
          label: context.l10n.done,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
    await widget.controller.acknowledgeCompletion();
  }

  Future<void> _confirmLeave() async {
    final shouldLeave = await AppDialog.show<bool>(
      context,
      title: context.l10n.leaveCampaignQuestion,
      content: Text(context.l10n.campaignLeaveDescription),
      actions: <Widget>[
        AppButton(
          label: context.l10n.continueCampaign,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: context.l10n.leaveCampaign,
          variant: AppButtonVariant.destructive,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (shouldLeave != true || !mounted) return;
    final left = await widget.controller.leaveActiveCampaign();
    if (!mounted) return;
    if (left) {
      AppSnackbar.show(context, context.l10n.campaignLeftHealthContinues);
      Navigator.of(context).pop();
    } else {
      AppSnackbar.show(
        context,
        widget.controller.userMessage ?? context.l10n.campaignLeaveError,
        isError: true,
      );
    }
  }

  Future<void> _startTracking() async {
    await widget.controller.stepController.start();
    if (!mounted) return;
    final error = widget.controller.stepController.uiError;
    AppSnackbar.show(
      context,
      error == null
          ? context.l10n.stepTrackingStarted
          : context.l10n.trackingStartError,
      isError: error != null,
    );
  }

  Future<void> _claimReward(CampaignEnrollment enrollment) async {
    final result = await widget.rewardsController.claimCampaignReward(
      enrollment,
    );
    if (!mounted) return;
    final claim = widget.rewardsController.claimedRewardForCampaign(
      enrollment.campaignId,
    );
    if ((result == RewardActionResult.success ||
            result == RewardActionResult.alreadyClaimed) &&
        claim != null) {
      AppSnackbar.show(context, context.l10n.campaignRewardClaimed);
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => CouponDetailsPage(
            claimedRewardId: claim.id,
            controller: widget.rewardsController,
          ),
        ),
      );
      return;
    }
    AppSnackbar.show(
      context,
      widget.rewardsController.userMessage ?? context.l10n.rewardClaimError,
      isError: true,
    );
  }

  void _viewCampaignReward(CampaignEnrollment enrollment) {
    final claim = widget.rewardsController.claimedRewardForCampaign(
      enrollment.campaignId,
    );
    if (claim == null) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => CouponDetailsPage(
          claimedRewardId: claim.id,
          controller: widget.rewardsController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.activeCampaign)),
      body: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          widget.controller,
          widget.controller.stepController,
          widget.rewardsController,
        ]),
        builder: (context, child) {
          final enrollment = widget.controller.recentEnrollment;
          if (widget.controller.viewState ==
              CampaignEnrollmentViewState.loading) {
            return Center(
              child: AppLoadingIndicator(label: context.l10n.loadingCampaign),
            );
          }
          if (widget.controller.viewState ==
              CampaignEnrollmentViewState.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppErrorView(
                  message:
                      widget.controller.userMessage ??
                      'عضویت در چالش بارگیری نشد.',
                  onRetry: widget.controller.initialize,
                ),
              ),
            );
          }
          if (enrollment == null) {
            return Center(
              child: AppEmptyState(
                title: context.l10n.noCampaignToShow,
                message: context.l10n.returnToCampaigns,
                icon: Icons.campaign_outlined,
              ),
            );
          }
          final campaign = widget.controller.campaignFor(enrollment);
          if (campaign == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppErrorView(
                  message: context.l10n.savedCampaignUnavailable,
                ),
              ),
            );
          }
          if (enrollment.status == CampaignEnrollmentStatus.completed &&
              !enrollment.completionAcknowledged &&
              !_completionScheduled) {
            _completionScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _showCompletion(campaign);
            });
          }
          return _CampaignBody(
            campaign: campaign,
            enrollment: enrollment,
            controller: widget.controller,
            rewardsController: widget.rewardsController,
            onStartTracking: _startTracking,
            onLeave: _confirmLeave,
            onClaimReward: () => _claimReward(enrollment),
            onViewReward: () => _viewCampaignReward(enrollment),
            onViewWallet: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (context) =>
                    WalletActivityPage(controller: widget.rewardsController),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CampaignBody extends StatelessWidget {
  const _CampaignBody({
    required this.campaign,
    required this.enrollment,
    required this.controller,
    required this.rewardsController,
    required this.onStartTracking,
    required this.onLeave,
    required this.onClaimReward,
    required this.onViewReward,
    required this.onViewWallet,
  });

  final Campaign campaign;
  final CampaignEnrollment enrollment;
  final CampaignEnrollmentController controller;
  final RewardsController rewardsController;
  final VoidCallback onStartTracking;
  final VoidCallback onLeave;
  final VoidCallback onClaimReward;
  final VoidCallback onViewReward;
  final VoidCallback onViewWallet;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _Header(campaign: campaign, enrollment: enrollment),
              const SizedBox(height: AppSpacing.xl),
              _ProgressCard(
                campaign: campaign,
                enrollment: enrollment,
                controller: controller,
              ),
              if (enrollment.status ==
                  CampaignEnrollmentStatus.completed) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                _CompletionRewardCard(
                  campaign: campaign,
                  enrollment: enrollment,
                  rewardsController: rewardsController,
                  onClaimReward: onClaimReward,
                  onViewReward: onViewReward,
                  onViewWallet: onViewWallet,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              _TrackingCard(
                isTracking: controller.stepController.snapshot.isTracking,
                onStart: onStartTracking,
              ),
              const SizedBox(height: AppSpacing.lg),
              _RulesCard(campaign: campaign, enrollment: enrollment),
              if (enrollment.status == CampaignEnrollmentStatus.active) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: context.l10n.leaveCampaign,
                  icon: Icons.exit_to_app,
                  variant: AppButtonVariant.destructive,
                  expanded: true,
                  onPressed: onLeave,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletionRewardCard extends StatelessWidget {
  const _CompletionRewardCard({
    required this.campaign,
    required this.enrollment,
    required this.rewardsController,
    required this.onClaimReward,
    required this.onViewReward,
    required this.onViewWallet,
  });

  final Campaign campaign;
  final CampaignEnrollment enrollment;
  final RewardsController rewardsController;
  final VoidCallback onClaimReward;
  final VoidCallback onViewReward;
  final VoidCallback onViewWallet;

  @override
  Widget build(BuildContext context) {
    final points = campaign.reward.type == CampaignRewardType.points;
    final pointsAdded = rewardsController.campaignPointsAdded(enrollment);
    final claim = rewardsController.claimedRewardForCampaign(campaign.id);
    return AppCard(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            points
                ? context.l10n.pointsEarned(campaign.reward.pointsAmount ?? 0)
                : campaign.reward.discountLabel,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            points
                ? pointsAdded
                      ? context.l10n.pointsAddedToRewards
                      : context.l10n.pointsBeingAdded
                : claim == null
                ? context.l10n.completedRewardReady
                : context.l10n.couponAvailableInRewards,
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppButton(
              label: points
                  ? context.l10n.rewards
                  : claim == null
                  ? context.l10n.claimReward
                  : context.l10n.viewClaimedReward,
              isLoading: rewardsController.isSaving,
              onPressed: points
                  ? onViewWallet
                  : claim == null
                  ? onClaimReward
                  : onViewReward,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.campaign, required this.enrollment});

  final Campaign campaign;
  final CampaignEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            CampaignBrandMark(initials: campaign.brand.initials),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                campaign.brand.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(campaign.title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppStatusChip(
            label: _enrollmentStatusLabel(context, enrollment.status),
            status: switch (enrollment.status) {
              CampaignEnrollmentStatus.active => AppStatus.info,
              CampaignEnrollmentStatus.completed => AppStatus.success,
              CampaignEnrollmentStatus.expired => AppStatus.neutral,
              CampaignEnrollmentStatus.left => AppStatus.neutral,
            },
            icon: switch (enrollment.status) {
              CampaignEnrollmentStatus.active => Icons.directions_walk,
              CampaignEnrollmentStatus.completed => Icons.verified_outlined,
              CampaignEnrollmentStatus.expired => Icons.event_busy_outlined,
              CampaignEnrollmentStatus.left => Icons.exit_to_app,
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          context.l10n.joinedAndEnds(
            campaignDate(context.l10n, enrollment.joinedAt),
            campaignDate(context.l10n, campaign.endAt),
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.appTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          enrollment.status == CampaignEnrollmentStatus.expired
              ? 'چالش پایان یافته'
              : enrollment.status == CampaignEnrollmentStatus.completed
              ? context.l10n.requirementCompleted
              : campaignTiming(context.l10n, campaign, DateTime.now()),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.campaign,
    required this.enrollment,
    required this.controller,
  });

  final Campaign campaign;
  final CampaignEnrollment enrollment;
  final CampaignEnrollmentController controller;

  @override
  Widget build(BuildContext context) {
    final progress = controller.progressFor(campaign, enrollment);
    final percent = (progress * 100).round();
    final isStepTarget = campaign.type == CampaignType.stepTarget;
    final completedDays = controller.completedGoalDays(enrollment);
    final requiredDays = campaign.requiredGoalDays ?? 0;
    final today = controller.eligibleStepsToday(enrollment);
    final capturedGoal = enrollment.goalAtEnrollment ?? 0;
    return Semantics(
      label: isStepTarget
          ? context.l10n.stepProgressSemantics(
              percent,
              enrollment.totalEligibleSteps,
              campaign.targetSteps ?? 0,
            )
          : context.l10n.goalProgressSemantics(completedDays, requiredDays),
      child: AppCard(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              enrollment.status == CampaignEnrollmentStatus.completed
                  ? context.l10n.campaignCompletedStatus
                  : enrollment.status == CampaignEnrollmentStatus.expired
                  ? context.l10n.finalCampaignProgress
                  : context.l10n.campaignProgress,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            LinearProgressIndicator(value: progress, minHeight: 12),
            const SizedBox(height: AppSpacing.md),
            if (isStepTarget) ...<Widget>[
              Text(
                context.l10n.campaignStepProgress(
                  formatCampaignNumber(enrollment.totalEligibleSteps),
                  formatCampaignNumber(campaign.targetSteps ?? 0),
                ),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.stepsRemainingPercent(
                  formatCampaignNumber(
                    ((campaign.targetSteps ?? 0) -
                            enrollment.totalEligibleSteps)
                        .clamp(0, 1 << 31),
                  ),
                  percent,
                ),
              ),
            ] else ...<Widget>[
              Text(
                context.l10n.goalDaysCompleted(completedDays, requiredDays),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.eligibleStepsToday(
                  formatCampaignNumber(today),
                  formatCampaignNumber(capturedGoal),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.requiredDaysRemaining(
                  (requiredDays - completedDays).clamp(0, requiredDays),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.capturedDailyGoal(
                  formatCampaignNumber(capturedGoal),
                ),
              ),
            ],
            if (enrollment.status ==
                CampaignEnrollmentStatus.completed) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(
                campaign.reward.type == CampaignRewardType.points
                    ? context.l10n.earnedRewardPoints(
                        campaign.reward.pointsAmount ?? 0,
                      )
                    : context.l10n.unlockedReward(
                        campaign.reward.discountLabel,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard({required this.isTracking, required this.onStart});

  final bool isTracking;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            isTracking ? Icons.sensors : Icons.sensors_off_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  isTracking
                      ? context.l10n.trackingActiveStatus
                      : context.l10n.trackingStoppedStatus,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isTracking
                      ? context.l10n.trackingCampaignAutoUpdate
                      : context.l10n.trackingCampaignRequirement,
                ),
                if (!isTracking) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AppButton(
                      label: context.l10n.startTracking,
                      icon: Icons.play_arrow,
                      onPressed: onStart,
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
}

class _RulesCard extends StatelessWidget {
  const _RulesCard({required this.campaign, required this.enrollment});

  final Campaign campaign;
  final CampaignEnrollment enrollment;

  @override
  Widget build(BuildContext context) {
    final rules = <String>[
      context.l10n.confirmedAfterEnrollmentOnly,
      context.l10n.healthProgressIndependent,
      if (campaign.type == CampaignType.dailyGoalConsistency)
        context.l10n.capturedGoalPreserved(
          formatCampaignNumber(enrollment.goalAtEnrollment ?? 0),
        ),
      context.l10n.deadlineValue(campaignDate(context.l10n, campaign.endAt)),
      context.l10n.rewardPreviewSentence(campaign.reward.discountLabel),
      context.l10n.offlinePrototypeState,
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            context.l10n.campaignRules,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < rules.length; index++) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.check_circle_outline, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(rules[index])),
              ],
            ),
            if (index != rules.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

String _enrollmentStatusLabel(
  BuildContext context,
  CampaignEnrollmentStatus status,
) => switch (status) {
  CampaignEnrollmentStatus.active => context.l10n.activeStatus,
  CampaignEnrollmentStatus.completed => context.l10n.completed,
  CampaignEnrollmentStatus.expired => context.l10n.campaignFinished,
  CampaignEnrollmentStatus.left => context.l10n.leftStatus,
};
