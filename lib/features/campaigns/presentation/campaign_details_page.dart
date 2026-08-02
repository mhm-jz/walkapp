import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../../l10n/app_localizations_extension.dart';
import '../application/campaign_enrollment_controller.dart';
import '../domain/campaign.dart';
import '../domain/campaign_enrollment.dart';
import '../domain/campaign_enrollment_status.dart';
import '../domain/campaign_reward_type.dart';
import '../domain/campaign_status.dart';
import '../domain/campaign_type.dart';
import '../../rewards/application/rewards_controller.dart';
import '../../rewards/presentation/coupon_details_page.dart';
import '../../rewards/presentation/wallet_activity_page.dart';
import 'campaign_formatters.dart';
import 'active_campaign_page.dart';
import 'widgets/campaign_shared_widgets.dart';

class CampaignDetailsPage extends StatelessWidget {
  const CampaignDetailsPage({
    required this.campaign,
    required this.enrollmentController,
    required this.settingsController,
    required this.rewardsController,
    super.key,
  });

  final Campaign campaign;
  final CampaignEnrollmentController enrollmentController;
  final AppSettingsController settingsController;
  final RewardsController rewardsController;

  void _openActiveCampaign(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ActiveCampaignPage(
          controller: enrollmentController,
          rewardsController: rewardsController,
        ),
      ),
    );
  }

  Future<void> _showActiveConflict(BuildContext context) async {
    final viewActive = await AppDialog.show<bool>(
      context,
      title: context.l10n.activeCampaignExists,
      content: Text(context.l10n.completeOrLeaveCampaign),
      actions: <Widget>[
        AppButton(
          label: context.l10n.keepCurrentCampaign,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: context.l10n.viewActiveCampaign,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (viewActive == true && context.mounted) _openActiveCampaign(context);
  }

  Future<void> _confirmJoin(BuildContext context) async {
    if (enrollmentController.activeEnrollment != null) {
      await _showActiveConflict(context);
      return;
    }
    final capturedGoal = settingsController.dailyGoal;
    final requirement = campaign.type == CampaignType.stepTarget
        ? context.l10n.confirmedCampaignStepsRequirement(
            formatCampaignNumber(campaign.targetSteps ?? 0),
          )
        : context.l10n.separateGoalDaysRequirement(
            campaign.requiredGoalDays ?? 0,
            formatCampaignNumber(capturedGoal),
          );
    final confirmed = await AppDialog.show<bool>(
      context,
      title: context.l10n.joinCampaignQuestion(campaign.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(context.l10n.requirementValue(requirement)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.endsOn(campaignDate(context.l10n, campaign.endAt)),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.rewardPreviewValue(campaign.reward.discountLabel),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(context.l10n.joinProgressExplanation),
            const SizedBox(height: AppSpacing.sm),
            Text(context.l10n.oneActiveCampaign),
            if (campaign.type == CampaignType.dailyGoalConsistency) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.capturedGoalExplanation(
                  formatCampaignNumber(capturedGoal),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              campaign.reward.type == CampaignRewardType.points
                  ? context.l10n.leavingCampaignPointsOutcome(
                      campaign.reward.pointsAmount ?? 0,
                    )
                  : context.l10n.leavingCampaignRewardOutcome,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        AppButton(
          label: context.l10n.cancel,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: context.l10n.joinCampaign,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirmed != true || !context.mounted) return;
    final result = await enrollmentController.join(
      campaign,
      currentDailyGoal: capturedGoal,
    );
    if (!context.mounted) return;
    switch (result) {
      case CampaignJoinResult.joined:
        AppSnackbar.show(
          context,
          'به چالش پیوستید. پیشرفت از صفر آغاز می‌شود.',
        );
        _openActiveCampaign(context);
      case CampaignJoinResult.activeConflict:
        await _showActiveConflict(context);
      case CampaignJoinResult.unavailable:
        AppSnackbar.show(
          context,
          context.l10n.campaignNoLongerAvailable,
          isError: true,
        );
      case CampaignJoinResult.alreadyCompleted:
        AppSnackbar.show(context, context.l10n.campaignAlreadyCompleted);
      case CampaignJoinResult.persistenceFailed:
        AppSnackbar.show(
          context,
          enrollmentController.userMessage ?? context.l10n.campaignJoinError,
          isError: true,
        );
    }
  }

  Future<void> _handleCompletedReward(
    BuildContext context,
    CampaignEnrollment enrollment,
  ) async {
    if (campaign.reward.type == CampaignRewardType.points) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) =>
              WalletActivityPage(controller: rewardsController),
        ),
      );
      return;
    }
    var claim = rewardsController.claimedRewardForCampaign(campaign.id);
    if (claim == null) {
      final result = await rewardsController.claimCampaignReward(enrollment);
      if (!context.mounted) return;
      if (result != RewardActionResult.success &&
          result != RewardActionResult.alreadyClaimed) {
        AppSnackbar.show(
          context,
          rewardsController.userMessage ?? context.l10n.rewardClaimError,
          isError: true,
        );
        return;
      }
      claim = rewardsController.claimedRewardForCampaign(campaign.id);
    }
    if (claim != null && context.mounted) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => CouponDetailsPage(
            claimedRewardId: claim!.id,
            controller: rewardsController,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = campaign.statusAt(now);

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        enrollmentController,
        rewardsController,
      ]),
      builder: (context, child) {
        final enrollment = enrollmentController.enrollmentFor(campaign.id);
        final isThisActive =
            enrollment?.status == CampaignEnrollmentStatus.active;
        final completed =
            enrollment?.status == CampaignEnrollmentStatus.completed;
        final expiredEnrollment =
            enrollment?.status == CampaignEnrollmentStatus.expired;
        final anotherActive =
            enrollmentController.activeEnrollment != null && !isThisActive;
        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.campaignDetails)),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.contentMaxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _CampaignIdentity(campaign: campaign, status: status),
                      const SizedBox(height: AppSpacing.xl),
                      _CampaignSummary(campaign: campaign),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionHeading(title: context.l10n.howItWorks),
                      const SizedBox(height: AppSpacing.sm),
                      AppCard(
                        child: Column(
                          children: <Widget>[
                            _NumberedStep(
                              number: 1,
                              text: context.l10n.joinCampaignStep,
                            ),
                            const Divider(height: AppSpacing.xl),
                            _NumberedStep(
                              number: 2,
                              text: context.l10n.walkCampaignPeriodStep,
                            ),
                            const Divider(height: AppSpacing.xl),
                            _NumberedStep(
                              number: 3,
                              text: context.l10n.unlockRewardStep,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionHeading(title: context.l10n.goalRules),
                      const SizedBox(height: AppSpacing.sm),
                      AppCard(child: _GoalRules(campaign: campaign)),
                      const SizedBox(height: AppSpacing.xl),
                      _SectionHeading(title: context.l10n.rewardTerms),
                      const SizedBox(height: AppSpacing.sm),
                      CampaignRewardPreview(reward: campaign.reward),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(child: _RewardTerms(campaign: campaign)),
                      const SizedBox(height: AppSpacing.xl),
                      const AppCard(child: _BehaviorExplanation()),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(
                        label: _actionLabel(
                          context,
                          status,
                          isThisActive: isThisActive,
                          completed: completed,
                          expiredEnrollment: expiredEnrollment,
                        ),
                        icon:
                            status == CampaignStatus.available ||
                                status == CampaignStatus.endingSoon
                            ? Icons.add_circle_outline
                            : Icons.lock_clock_outlined,
                        expanded: true,
                        onPressed: isThisActive
                            ? () => _openActiveCampaign(context)
                            : completed && enrollment != null
                            ? () => _handleCompletedReward(context, enrollment)
                            : expiredEnrollment
                            ? null
                            : status == CampaignStatus.available ||
                                  status == CampaignStatus.endingSoon
                            ? () => anotherActive
                                  ? _showActiveConflict(context)
                                  : _confirmJoin(context)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _actionLabel(
    BuildContext context,
    CampaignStatus status, {
    required bool isThisActive,
    required bool completed,
    required bool expiredEnrollment,
  }) {
    if (isThisActive) return context.l10n.viewProgress;
    if (completed) {
      if (campaign.reward.type == CampaignRewardType.points) {
        return context.l10n.rewards;
      }
      return rewardsController.claimedRewardForCampaign(campaign.id) == null
          ? context.l10n.claimReward
          : context.l10n.viewClaimedReward;
    }
    if (expiredEnrollment) return context.l10n.campaignFinished;
    return switch (status) {
      CampaignStatus.available ||
      CampaignStatus.endingSoon => context.l10n.joinCampaign,
      CampaignStatus.upcoming => context.l10n.startsOn(
        campaignDate(context.l10n, campaign.startAt),
      ),
      CampaignStatus.expired => context.l10n.campaignFinished,
    };
  }
}

class _CampaignIdentity extends StatelessWidget {
  const _CampaignIdentity({required this.campaign, required this.status});

  final Campaign campaign;
  final CampaignStatus status;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            CampaignBrandMark(
              initials: campaign.brand.initials,
              inactive: status == CampaignStatus.expired,
            ),
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
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            CampaignStatusChip(status: status),
            Chip(
              label: Text(
                campaignCategoryLabel(context.l10n, campaign.category),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          campaign.fullDescription,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${campaignDate(context.l10n, campaign.startAt)} – '
          '${campaignDate(context.l10n, campaign.endAt)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.appTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CampaignSummary extends StatelessWidget {
  const _CampaignSummary({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final goalLabel = campaign.type == CampaignType.stepTarget
        ? context.l10n.targetSteps
        : context.l10n.requiredGoalDays;
    final goalValue = campaign.type == CampaignType.stepTarget
        ? '${campaign.targetSteps}'
        : context.l10n.daysValue(campaign.requiredGoalDays ?? 0);
    final items = <({IconData icon, String label, String value})>[
      (icon: Icons.flag_outlined, label: goalLabel, value: goalValue),
      (
        icon: Icons.calendar_month_outlined,
        label: context.l10n.campaignDuration,
        value: context.l10n.daysValue(campaign.durationDays),
      ),
      (
        icon: Icons.redeem_outlined,
        label: context.l10n.reward,
        value: campaign.reward.discountLabel,
      ),
    ];

    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 560;
          final itemWidth = wide
              ? (constraints.maxWidth - AppSpacing.xl * 2) / 3
              : constraints.maxWidth;
          return Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.lg,
            children: <Widget>[
              for (final item in items)
                SizedBox(
                  width: itemWidth,
                  child: CampaignSummaryItem(
                    icon: item.icon,
                    label: item.label,
                    value: item.value,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _GoalRules extends StatelessWidget {
  const _GoalRules({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final rules = campaign.type == CampaignType.stepTarget
        ? <String>[
            context.l10n.requiredVerifiedSteps(campaign.targetSteps ?? 0),
            context.l10n.walkBetweenDates(
              campaignDate(context.l10n, campaign.startAt),
              campaignDate(context.l10n, campaign.endAt),
            ),
            'پیشرفت پس از عضویت آغاز می‌شود.',
            context.l10n.eligibleActivityOnly,
          ]
        : <String>[
            context.l10n.requiredSeparateGoalDays(
              campaign.requiredGoalDays ?? 0,
            ),
            context.l10n.personalDailyGoalUsed,
            context.l10n.campaignDayCountsOnce,
            'پیشرفت پس از عضویت آغاز می‌شود.',
          ];
    return _BulletList(items: rules);
  }
}

class _RewardTerms extends StatelessWidget {
  const _RewardTerms({required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final reward = campaign.reward;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _TermRow(label: context.l10n.reward, value: reward.discountLabel),
        const Divider(height: AppSpacing.xl),
        _TermRow(
          label: context.l10n.minimumPurchase,
          value: reward.minimumPurchaseDescription,
        ),
        const Divider(height: AppSpacing.xl),
        _TermRow(label: context.l10n.whereToUse, value: reward.usageChannel),
        const Divider(height: AppSpacing.xl),
        _TermRow(
          label: context.l10n.expiration,
          value: reward.expirationDescription,
        ),
        const Divider(height: AppSpacing.xl),
        _TermRow(
          label: context.l10n.availability,
          value: reward.inventoryLabel,
        ),
        const Divider(height: AppSpacing.xl),
        Text(
          context.l10n.importantRestrictions,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        _BulletList(items: campaign.terms),
      ],
    );
  }
}

class _TermRow extends StatelessWidget {
  const _TermRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.appTheme.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class _BehaviorExplanation extends StatelessWidget {
  const _BehaviorExplanation();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.monitor_heart_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(context.l10n.healthStepsContinueExplanation)),
      ],
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          child: Text('$number'),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < items.length; index++) ...<Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.sm),
                child: Icon(Icons.circle, size: 6),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(items[index])),
            ],
          ),
          if (index != items.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}
