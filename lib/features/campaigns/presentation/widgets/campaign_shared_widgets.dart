import 'package:flutter/material.dart';

import '../../../../core/design_system/components/app_card.dart';
import '../../../../core/design_system/components/app_status_chip.dart';
import '../../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../../core/design_system/tokens/app_tokens.dart';
import '../../domain/campaign_reward.dart';
import '../../domain/campaign_status.dart';
import '../campaign_formatters.dart';

class CampaignStatusChip extends StatelessWidget {
  const CampaignStatusChip({required this.status, super.key});

  final CampaignStatus status;

  @override
  Widget build(BuildContext context) {
    return AppStatusChip(
      label: campaignStatusLabel(status),
      status: switch (status) {
        CampaignStatus.available => AppStatus.success,
        CampaignStatus.endingSoon => AppStatus.warning,
        CampaignStatus.upcoming => AppStatus.info,
        CampaignStatus.expired => AppStatus.neutral,
      },
      icon: switch (status) {
        CampaignStatus.available => Icons.check_circle_outline,
        CampaignStatus.endingSoon => Icons.schedule,
        CampaignStatus.upcoming => Icons.event_outlined,
        CampaignStatus.expired => Icons.event_busy_outlined,
      },
    );
  }
}

class CampaignBrandMark extends StatelessWidget {
  const CampaignBrandMark({
    required this.initials,
    this.inactive = false,
    super.key,
  });

  final String initials;
  final bool inactive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: AppSizes.minTouchTarget,
      height: AppSizes.minTouchTarget,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: inactive
            ? scheme.surfaceContainerHighest
            : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: inactive ? scheme.onSurfaceVariant : scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class CampaignSummaryItem extends StatelessWidget {
  const CampaignSummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.appTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ],
    );
  }
}

class CampaignRewardPreview extends StatelessWidget {
  const CampaignRewardPreview({required this.reward, super.key});

  final CampaignReward reward;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.redeem_outlined,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  reward.discountLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  reward.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
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
