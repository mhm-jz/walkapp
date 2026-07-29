import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

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
                  'Rewards',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Your points, unlocked offers, and coupon codes will live here.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const AppCard(
                  child: Column(
                    children: <Widget>[
                      _RewardInformationRow(
                        icon: Icons.verified_outlined,
                        text: 'Eligible verified activity may earn points.',
                      ),
                      Divider(height: AppSpacing.xl),
                      _RewardInformationRow(
                        icon: Icons.campaign_outlined,
                        text: 'Some campaigns unlock rewards directly.',
                      ),
                      Divider(height: AppSpacing.xl),
                      _RewardInformationRow(
                        icon: Icons.event_available_outlined,
                        text:
                            'Reward conditions and expiration dates will be visible.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppCard(
                  child: AppEmptyState(
                    title: 'No rewards yet',
                    message:
                        'Complete eligible walking goals and campaigns to unlock rewards.',
                    icon: Icons.redeem_outlined,
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

class _RewardInformationRow extends StatelessWidget {
  const _RewardInformationRow({required this.icon, required this.text});

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
