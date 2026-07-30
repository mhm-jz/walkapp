import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../l10n/app_localizations_extension.dart';
import '../application/rewards_controller.dart';
import '../domain/reward.dart';
import '../domain/reward_status.dart';
import 'coupon_details_page.dart';
import 'reward_formatters.dart';

class RewardDetailsPage extends StatelessWidget {
  const RewardDetailsPage({
    required this.reward,
    required this.controller,
    super.key,
  });

  final Reward reward;
  final RewardsController controller;

  Future<void> _redeem(BuildContext context) async {
    final balance = controller.wallet.balance;
    final confirmed = await AppDialog.show<bool>(
      context,
      title: context.l10n.redeemRewardQuestion(reward.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(context.l10n.pointsRequired(reward.requiredPoints)),
            Text(context.l10n.currentBalance(balance)),
            Text(
              context.l10n.balanceAfterRedemption(
                balance - reward.requiredPoints,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(context.l10n.importantTerms(reward.terms.join(' '))),
            const SizedBox(height: AppSpacing.md),
            Text(context.l10n.localCouponDisclaimer),
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
          label: context.l10n.claimReward,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirmed != true || !context.mounted) return;
    final result = await controller.redeemReward(reward);
    if (!context.mounted) return;
    if (result == RewardActionResult.success ||
        result == RewardActionResult.alreadyClaimed) {
      final claim = controller.claimedRewardForReward(reward.id);
      if (claim != null) {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => CouponDetailsPage(
              claimedRewardId: claim.id,
              controller: controller,
            ),
          ),
        );
      }
      return;
    }
    AppSnackbar.show(
      context,
      result == RewardActionResult.insufficientPoints
          ? context.l10n.insufficientBalanceMessage
          : controller.userMessage ?? context.l10n.rewardRedeemError,
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.rewardDetails)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final status = controller.statusFor(reward);
          final balance = controller.wallet.balance;
          final existing = controller.claimedRewardForReward(reward.id);
          final after = balance - reward.requiredPoints;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.contentMaxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      reward.brandName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      reward.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(reward.fullDescription),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            context.l10n.pointsValue(reward.requiredPoints),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(context.l10n.currentBalancePoints(balance)),
                          Text(
                            status == RewardStatus.available
                                ? context.l10n.afterRedemptionPoints(after)
                                : context.l10n.morePointsNeeded(
                                    (reward.requiredPoints - balance).clamp(
                                      0,
                                      reward.requiredPoints,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            reward.discountLabel,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Divider(height: AppSpacing.xl),
                          Text(
                            context.l10n.minimumPurchaseValue(
                              reward.minimumPurchaseDescription,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            context.l10n.whereToUseValue(
                              rewardChannelLabel(
                                context.l10n,
                                reward.usageChannel,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(reward.expirationDescription),
                          const SizedBox(height: AppSpacing.sm),
                          Text(reward.inventoryLabel),
                          const Divider(height: AppSpacing.xl),
                          Text(
                            context.l10n.terms,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          for (final term in reward.terms)
                            Text(
                              '• ${localizedRewardTerm(context.l10n, term)}',
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.science_outlined),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(context.l10n.localRewardDisclaimer),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: switch (status) {
                        RewardStatus.available => context.l10n.redeemForPoints(
                          reward.requiredPoints,
                        ),
                        RewardStatus.insufficientPoints =>
                          context.l10n.morePointsNeeded(
                            reward.requiredPoints - balance,
                          ),
                        RewardStatus.claimed => context.l10n.viewClaimedReward,
                        RewardStatus.expired => context.l10n.expiredStatus,
                        RewardStatus.unavailable =>
                          context.l10n.unavailableStatus,
                      },
                      icon: status == RewardStatus.claimed
                          ? Icons.open_in_new
                          : Icons.redeem,
                      expanded: true,
                      isLoading: controller.isSaving,
                      onPressed: status == RewardStatus.available
                          ? () => _redeem(context)
                          : status == RewardStatus.claimed && existing != null
                          ? () => Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (context) => CouponDetailsPage(
                                  claimedRewardId: existing.id,
                                  controller: controller,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
