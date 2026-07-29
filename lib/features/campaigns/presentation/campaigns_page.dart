import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';

class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
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
                Text(
                  'Campaigns',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Walk toward goals and unlock offers from participating brands.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const AppCard(
                  child: Column(
                    children: <Widget>[
                      _CampaignInformationRow(
                        icon: Icons.flag_outlined,
                        text: 'Campaigns have a clear walking target.',
                      ),
                      Divider(height: AppSpacing.xl),
                      _CampaignInformationRow(
                        icon: Icons.touch_app_outlined,
                        text: 'You choose whether to join.',
                      ),
                      Divider(height: AppSpacing.xl),
                      _CampaignInformationRow(
                        icon: Icons.directions_walk_outlined,
                        text: 'Progress starts after joining.',
                      ),
                      Divider(height: AppSpacing.xl),
                      _CampaignInformationRow(
                        icon: Icons.fact_check_outlined,
                        text: 'Reward conditions are shown before joining.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppCard(
                  child: AppEmptyState(
                    title: 'No campaigns available yet',
                    message:
                        'New walking campaigns from participating brands will appear here.',
                    icon: Icons.campaign_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CampaignInformationRow extends StatelessWidget {
  const _CampaignInformationRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(text)),
      ],
    );
  }
}
