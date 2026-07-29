import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../application/rewards_controller.dart';
import '../domain/claimed_reward.dart';
import '../domain/claimed_reward_source_type.dart';
import '../domain/coupon_status.dart';
import 'coupon_details_page.dart';
import 'reward_formatters.dart';

class MyRewardsPage extends StatelessWidget {
  const MyRewardsPage({required this.controller, super.key});
  final RewardsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Rewards')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final claims = controller.claimedRewards;
          if (claims.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: AppEmptyState(
                  title: 'No claimed rewards yet',
                  message:
                      'Complete eligible campaigns or redeem a reward with points.',
                  icon: Icons.card_giftcard_outlined,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              for (final status in CouponStatus.values) ...<Widget>[
                Text(
                  couponStatusLabel(status),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (claims
                    .where((item) => item.statusAt(DateTime.now()) == status)
                    .isEmpty)
                  Text('No ${couponStatusLabel(status).toLowerCase()} rewards.')
                else
                  for (final claim in claims.where(
                    (item) => item.statusAt(DateTime.now()) == status,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _ClaimCard(claim: claim, controller: controller),
                    ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ClaimCard extends StatelessWidget {
  const _ClaimCard({required this.claim, required this.controller});
  final ClaimedReward claim;
  final RewardsController controller;

  @override
  Widget build(BuildContext context) {
    final status = claim.statusAt(DateTime.now());
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(claim.brandName, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            claim.rewardTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: AppStatusChip(
              label: couponStatusLabel(status),
              status: status == CouponStatus.available
                  ? AppStatus.success
                  : AppStatus.neutral,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            claim.sourceType == ClaimedRewardSourceType.campaign
                ? 'Campaign reward'
                : 'Points redemption',
          ),
          Text('Claimed ${rewardDate(claim.claimedAt)}'),
          Text('Expires ${rewardDate(claim.expiresAt)}'),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: 'View coupon',
              variant: AppButtonVariant.outlined,
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) => CouponDetailsPage(
                    claimedRewardId: claim.id,
                    controller: controller,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
