import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
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
      title: 'Redeem ${reward.title}?',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Points required: ${reward.requiredPoints}'),
            Text('Current balance: $balance'),
            Text(
              'Balance after redemption: ${balance - reward.requiredPoints}',
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Important terms: ${reward.terms.join(' ')}'),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'The resulting coupon is generated locally for MVP demonstration '
              'and cannot be validated by a real merchant.',
            ),
          ],
        ),
      ),
      actions: <Widget>[
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: 'Redeem Reward',
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
          ? 'Your point balance is no longer high enough.'
          : controller.userMessage ?? 'The reward could not be redeemed.',
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward Details')),
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
                            '${reward.requiredPoints} points',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text('Current balance: $balance points'),
                          Text(
                            status == RewardStatus.available
                                ? 'After redemption: $after points'
                                : '${(reward.requiredPoints - balance).clamp(0, reward.requiredPoints)} more points needed',
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
                            'Minimum purchase: ${reward.minimumPurchaseDescription}',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Where to use: ${rewardChannelLabel(reward.usageChannel)}',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(reward.expirationDescription),
                          const SizedBox(height: AppSpacing.sm),
                          Text(reward.inventoryLabel),
                          const Divider(height: AppSpacing.xl),
                          Text(
                            'Terms',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          for (final term in reward.terms) Text('• $term'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.science_outlined),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Local prototype: points and coupons have no cash '
                              'value and cannot be validated by a merchant.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: switch (status) {
                        RewardStatus.available =>
                          'Redeem for ${reward.requiredPoints} points',
                        RewardStatus.insufficientPoints =>
                          '${reward.requiredPoints - balance} more points needed',
                        RewardStatus.claimed => 'View Reward',
                        RewardStatus.expired => 'Reward expired',
                        RewardStatus.unavailable => 'Currently unavailable',
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
