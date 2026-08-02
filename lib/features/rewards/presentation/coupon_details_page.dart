import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:walkingapp/l10n/app_localizations_extension.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../application/rewards_controller.dart';
import '../domain/claimed_reward.dart';
import '../domain/claimed_reward_source_type.dart';
import '../domain/coupon_status.dart';
import 'reward_formatters.dart';

class CouponDetailsPage extends StatelessWidget {
  const CouponDetailsPage({
    required this.claimedRewardId,
    required this.controller,
    super.key,
  });

  final String claimedRewardId;
  final RewardsController controller;

  Future<void> _copy(BuildContext context, ClaimedReward reward) async {
    await Clipboard.setData(ClipboardData(text: reward.couponCode));
    if (context.mounted) {
      AppSnackbar.show(context, context.l10n.prototypeCouponCopied);
    }
  }

  Future<void> _markUsed(BuildContext context, ClaimedReward reward) async {
    final confirmed = await AppDialog.show<bool>(
      context,
      title: context.l10n.markCouponUsedQuestion,
      content: Text(context.l10n.couponUseLocalExplanation),
      actions: <Widget>[
        AppButton(
          label: context.l10n.cancel,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: context.l10n.markAsUsed,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirmed != true || !context.mounted) return;
    final updated = await controller.markClaimedRewardUsed(reward);
    if (context.mounted) {
      AppSnackbar.show(
        context,
        updated
            ? context.l10n.couponMarkedUsed
            : context.l10n.couponUpdateError,
        isError: !updated,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.couponDetails)),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final reward = controller.claimedRewardById(claimedRewardId);
          if (reward == null) {
            return Center(
              child: AppErrorView(message: context.l10n.savedRewardUnavailable),
            );
          }
          final status = reward.statusAt(DateTime.now());
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
                      reward.rewardTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Column(
                        children: <Widget>[
                          AppStatusChip(
                            label: context.l10n.prototypeCoupon,
                            status: AppStatus.info,
                            icon: Icons.science_outlined,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SelectableText(
                            reward.couponCode,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(letterSpacing: 1.4),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: context.l10n.copyCode,
                            icon: Icons.copy,
                            onPressed: status == CouponStatus.available
                                ? () => _copy(context, reward)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _Fact(
                            label: context.l10n.status,
                            value: couponStatusLabel(context.l10n, status),
                          ),
                          _Fact(
                            label: context.l10n.claimed,
                            value: rewardDate(context.l10n, reward.claimedAt),
                          ),
                          _Fact(
                            label: context.l10n.expiration,
                            value: rewardDate(context.l10n, reward.expiresAt),
                          ),
                          _Fact(
                            label: context.l10n.whereToUse,
                            value: reward.usageChannel,
                          ),
                          _Fact(
                            label: context.l10n.minimumPurchase,
                            value: reward.minimumPurchaseDescription,
                          ),
                          _Fact(
                            label: context.l10n.source,
                            value:
                                reward.sourceType ==
                                    ClaimedRewardSourceType.campaign
                                ? context.l10n.campaignRewardSource
                                : context.l10n.pointsRedemptionSource,
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
                            context.l10n.terms,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          for (final term in reward.terms)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: Text(
                                '• ${localizedRewardTerm(context.l10n, term)}',
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppCard(child: Text(context.l10n.couponCodeDisclaimer)),
                    if (kDebugMode &&
                        status == CouponStatus.available) ...<Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: AppStatusChip(
                          label: context.l10n.debugSimulation,
                          status: AppStatus.warning,
                          icon: Icons.developer_mode,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: context.l10n.markAsUsed,
                        variant: AppButtonVariant.outlined,
                        expanded: true,
                        onPressed: controller.isSaving
                            ? null
                            : () => _markUsed(context, reward),
                      ),
                    ],
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

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(value),
      ],
    ),
  );
}
