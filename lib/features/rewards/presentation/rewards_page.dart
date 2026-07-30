import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../../l10n/app_localizations_extension.dart';
import '../../campaigns/domain/campaign.dart';
import '../../campaigns/domain/campaign_enrollment.dart';
import '../application/rewards_controller.dart';
import '../domain/reward.dart';
import '../domain/reward_status.dart';
import 'coupon_details_page.dart';
import 'my_rewards_page.dart';
import 'reward_details_page.dart';
import 'reward_formatters.dart';
import 'wallet_activity_page.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({
    required this.controller,
    this.settingsController,
    super.key,
  });
  final RewardsController controller;
  final AppSettingsController? settingsController;

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  String _filter = 'all';

  List<Reward> _filteredRewards() {
    final balance = widget.controller.wallet.balance;
    final interests = widget.settingsController?.rewardInterests ?? const [];
    final ordered = widget.controller.catalog.indexed.toList()
      ..sort((a, b) {
        if (interests.isEmpty || interests.contains('بدون ترجیح')) {
          return a.$1.compareTo(b.$1);
        }
        final aMatches = interests.contains(a.$2.category);
        final bMatches = interests.contains(b.$2.category);
        if (aMatches == bMatches) return a.$1.compareTo(b.$1);
        return aMatches ? -1 : 1;
      });
    return ordered
        .map((item) => item.$2)
        .where((reward) {
          if (_filter == 'all') return true;
          if (_filter == 'affordable') {
            return reward.isAvailable && reward.requiredPoints <= balance;
          }
          return reward.category == _filter;
        })
        .toList(growable: false);
  }

  void _open(Widget page) {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (context) => page));
  }

  Future<void> _claimCampaignReward(
    ({Campaign campaign, CampaignEnrollment enrollment}) item,
  ) async {
    final result = await widget.controller.claimCampaignReward(item.enrollment);
    if (!mounted) return;
    final claim = widget.controller.claimedRewardForCampaign(item.campaign.id);
    if ((result == RewardActionResult.success ||
            result == RewardActionResult.alreadyClaimed) &&
        claim != null) {
      AppSnackbar.show(context, context.l10n.campaignRewardClaimed);
      _open(
        CouponDetailsPage(
          claimedRewardId: claim.id,
          controller: widget.controller,
        ),
      );
      return;
    }
    AppSnackbar.show(
      context,
      widget.controller.userMessage ?? context.l10n.rewardClaimError,
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          if (widget.controller.viewState == RewardsViewState.loading) {
            return Center(
              child: AppLoadingIndicator(label: context.l10n.loadingRewards),
            );
          }
          if (widget.controller.viewState == RewardsViewState.error) {
            return AppErrorView(
              message:
                  widget.controller.userMessage ??
                  context.l10n.rewardsLoadError,
              onRetry: widget.controller.initialize,
            );
          }
          final rewards = _filteredRewards();
          Reward? featured;
          for (final reward in widget.controller.catalog) {
            if (reward.isFeatured && reward.isAvailable) {
              featured = reward;
              break;
            }
          }
          return CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg,
                  AppSpacing.xl,
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
                          Text(
                            context.l10n.rewards,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            context.l10n.rewardsDescription,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: context.appTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: AppStatusChip(
                              label: context.l10n.localRewardsPrototype,
                              status: AppStatus.neutral,
                              icon: Icons.science_outlined,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _WalletCard(
                            controller: widget.controller,
                            onWallet: () => _open(
                              WalletActivityPage(controller: widget.controller),
                            ),
                            onMyRewards: () => _open(
                              MyRewardsPage(controller: widget.controller),
                            ),
                          ),
                          if (widget.controller.userMessage != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            AppErrorView(
                              message: widget.controller.userMessage!,
                              compact: true,
                            ),
                          ],
                          if (widget
                              .controller
                              .directRewardsReady
                              .isNotEmpty) ...<Widget>[
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              context.l10n.readyToClaim,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            for (final item
                                in widget.controller.directRewardsReady)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: AppCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        item.campaign.brand.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelLarge,
                                      ),
                                      Text(
                                        item.campaign.title,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(item.campaign.reward.discountLabel),
                                      const SizedBox(height: AppSpacing.md),
                                      Align(
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: AppButton(
                                          label: context.l10n.claimReward,
                                          isLoading: widget.controller.isSaving,
                                          onPressed: () =>
                                              _claimCampaignReward(item),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                          if (featured != null) ...<Widget>[
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              context.l10n.featuredReward,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _FeaturedReward(
                              reward: featured,
                              controller: widget.controller,
                              onView: () => _open(
                                RewardDetailsPage(
                                  reward: featured!,
                                  controller: widget.controller,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          _Filters(
                            selected: _filter,
                            onSelected: (value) =>
                                setState(() => _filter = value),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            context.l10n.rewardCatalog,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (rewards.isEmpty)
                            AppCard(
                              child: AppEmptyState(
                                title: context.l10n.noMatchingRewards,
                                message: context.l10n.rewardFilterHint,
                                icon: Icons.filter_alt_off_outlined,
                              ),
                            )
                          else
                            for (final reward in rewards)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: _RewardCard(
                                  reward: reward,
                                  controller: widget.controller,
                                  onView: () => _open(
                                    RewardDetailsPage(
                                      reward: reward,
                                      controller: widget.controller,
                                    ),
                                  ),
                                ),
                              ),
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
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.controller,
    required this.onWallet,
    required this.onMyRewards,
  });
  final RewardsController controller;
  final VoidCallback onWallet;
  final VoidCallback onMyRewards;

  @override
  Widget build(BuildContext context) {
    final wallet = controller.wallet;
    return AppCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            context.l10n.availablePoints,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            '${wallet.balance}',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.walletTotals(wallet.totalEarned, wallet.totalSpent),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              AppButton(
                label: context.l10n.viewWalletActivity,
                icon: Icons.receipt_long_outlined,
                onPressed: onWallet,
              ),
              AppButton(
                label: context.l10n.myRewards,
                icon: Icons.card_giftcard,
                variant: AppButtonVariant.outlined,
                onPressed: onMyRewards,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturedReward extends StatelessWidget {
  const _FeaturedReward({
    required this.reward,
    required this.controller,
    required this.onView,
  });
  final Reward reward;
  final RewardsController controller;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final status = controller.statusFor(reward);
    final needed = reward.requiredPoints - controller.wallet.balance;
    final (label, supportingMessage, chipStatus) = switch (status) {
      RewardStatus.available => (
        context.l10n.availableStatus,
        context.l10n.enoughPointsMessage,
        AppStatus.success,
      ),
      RewardStatus.insufficientPoints => (
        context.l10n.insufficientPointsStatus,
        context.l10n.morePointsNeeded(needed.clamp(0, reward.requiredPoints)),
        AppStatus.warning,
      ),
      RewardStatus.claimed => (
        context.l10n.claimedStatus,
        context.l10n.limitedRewardClaimed,
        AppStatus.neutral,
      ),
      RewardStatus.unavailable => (
        context.l10n.unavailableStatus,
        context.l10n.rewardCurrentlyUnavailable,
        AppStatus.neutral,
      ),
      RewardStatus.expired => (
        context.l10n.expiredStatus,
        context.l10n.rewardExpiredMessage,
        AppStatus.neutral,
      ),
    };
    return AppCard(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(reward.brandName, style: Theme.of(context).textTheme.labelLarge),
          Text(reward.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(reward.discountLabel),
          Text(context.l10n.pointsRequired(reward.requiredPoints)),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppStatusChip(label: label, status: chipStatus),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(supportingMessage),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppButton(label: context.l10n.viewReward, onPressed: onView),
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.selected, required this.onSelected});
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final values = <(String, String)>[
      ('all', context.l10n.allFilter),
      ('Clothing', context.l10n.clothingCategory),
      ('Sports', context.l10n.sportsCategory),
      ('Food', context.l10n.foodCategory),
      ('Wellness', context.l10n.wellnessCategory),
      ('affordable', context.l10n.affordableFilter),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final value in values) ...<Widget>[
            FilterChip(
              label: Text(value.$2),
              selected: selected == value.$1,
              onSelected: (_) => onSelected(value.$1),
            ),
            if (value != values.last) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.controller,
    required this.onView,
  });
  final Reward reward;
  final RewardsController controller;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final status = controller.statusFor(reward);
    final needed = reward.requiredPoints - controller.wallet.balance;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(child: Text(reward.brandInitials)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      reward.brandName,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      reward.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(reward.discountLabel),
          Text(context.l10n.pointsRequired(reward.requiredPoints)),
          Text(rewardChannelLabel(context.l10n, reward.usageChannel)),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppStatusChip(
              label: switch (status) {
                RewardStatus.available => context.l10n.availableStatus,
                RewardStatus.insufficientPoints =>
                  context.l10n.morePointsNeeded(needed),
                RewardStatus.claimed => context.l10n.claimedStatus,
                RewardStatus.expired => context.l10n.expiredStatus,
                RewardStatus.unavailable => context.l10n.unavailableStatus,
              },
              status: status == RewardStatus.available
                  ? AppStatus.success
                  : status == RewardStatus.insufficientPoints
                  ? AppStatus.warning
                  : AppStatus.neutral,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppButton(
              label: context.l10n.viewDetails,
              variant: AppButtonVariant.outlined,
              onPressed: onView,
            ),
          ),
        ],
      ),
    );
  }
}
