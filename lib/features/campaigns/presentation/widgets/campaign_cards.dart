import 'package:flutter/material.dart';

import '../../../../core/design_system/components/app_button.dart';
import '../../../../core/design_system/components/app_card.dart';
import '../../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../../core/design_system/tokens/app_tokens.dart';
import '../../domain/campaign.dart';
import '../../domain/campaign_status.dart';
import '../campaign_formatters.dart';
import 'campaign_shared_widgets.dart';

class FeaturedCampaignCard extends StatelessWidget {
  const FeaturedCampaignCard({
    required this.campaign,
    required this.onView,
    super.key,
  });

  final Campaign campaign;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return AppCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CampaignBrandMark(initials: campaign.brand.initials),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      campaign.brand.name,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      campaign.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: CampaignStatusChip(status: campaign.statusAt(now)),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            campaign.reward.discountLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.md,
            children: <Widget>[
              _InlineFact(
                icon: Icons.flag_outlined,
                value: campaignGoalSummary(campaign),
              ),
              _InlineFact(
                icon: Icons.schedule,
                value: campaignTiming(campaign, now),
              ),
              _InlineFact(
                icon: Icons.category_outlined,
                value: campaignTypeLabel(campaign.type),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: 'View Campaign',
              icon: Icons.arrow_forward,
              onPressed: onView,
            ),
          ),
        ],
      ),
    );
  }
}

class CampaignCard extends StatelessWidget {
  const CampaignCard({required this.campaign, required this.onView, super.key});

  final Campaign campaign;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = campaign.statusAt(now);
    final expired = status == CampaignStatus.expired;
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      color: expired ? scheme.surfaceContainerHighest : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CampaignBrandMark(
                initials: campaign.brand.initials,
                inactive: expired,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      campaign.brand.name,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: expired ? context.appTheme.textSecondary : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      campaign.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: CampaignStatusChip(status: status),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            campaign.shortDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.appTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            campaign.reward.discountLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: expired ? context.appTheme.textSecondary : scheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _InlineFact(
                icon: Icons.flag_outlined,
                value: campaignGoalSummary(campaign),
              ),
              _InlineFact(
                icon: Icons.schedule,
                value: campaignTiming(campaign, now),
              ),
              _InlineFact(
                icon: Icons.category_outlined,
                value: campaignTypeLabel(campaign.type),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: 'View details',
              icon: Icons.arrow_forward,
              variant: AppButtonVariant.outlined,
              onPressed: onView,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineFact extends StatelessWidget {
  const _InlineFact({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Flexible(child: Text(value)),
        ],
      ),
    );
  }
}
