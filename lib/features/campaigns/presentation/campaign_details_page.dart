import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../domain/campaign.dart';
import '../domain/campaign_status.dart';
import '../domain/campaign_type.dart';
import 'campaign_formatters.dart';
import 'widgets/campaign_shared_widgets.dart';

class CampaignDetailsPage extends StatelessWidget {
  const CampaignDetailsPage({required this.campaign, super.key});

  final Campaign campaign;

  Future<void> _showEnrollmentPreview(BuildContext context) {
    return AppDialog.show<void>(
      context,
      title: 'Joining is coming next',
      content: const Text(
        'Campaign joining will be enabled in the next MVP phase.\n\n'
        'No campaign has been joined and no progress has been started.',
      ),
      actions: <Widget>[
        AppButton(
          label: 'Got it',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = campaign.statusAt(now);

    return Scaffold(
      appBar: AppBar(title: const Text('Campaign details')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
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
                  const _SectionHeading(title: 'How it works'),
                  const SizedBox(height: AppSpacing.sm),
                  const AppCard(
                    child: Column(
                      children: <Widget>[
                        _NumberedStep(number: 1, text: 'Join the campaign'),
                        Divider(height: AppSpacing.xl),
                        _NumberedStep(
                          number: 2,
                          text: 'Walk during the campaign period',
                        ),
                        Divider(height: AppSpacing.xl),
                        _NumberedStep(
                          number: 3,
                          text: 'Complete the goal and unlock the reward',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionHeading(title: 'Goal rules'),
                  const SizedBox(height: AppSpacing.sm),
                  AppCard(child: _GoalRules(campaign: campaign)),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionHeading(title: 'Reward terms'),
                  const SizedBox(height: AppSpacing.sm),
                  CampaignRewardPreview(reward: campaign.reward),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(child: _RewardTerms(campaign: campaign)),
                  const SizedBox(height: AppSpacing.xl),
                  const AppCard(child: _BehaviorExplanation()),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: _actionLabel(status),
                    icon:
                        status == CampaignStatus.available ||
                            status == CampaignStatus.endingSoon
                        ? Icons.add_circle_outline
                        : Icons.lock_clock_outlined,
                    expanded: true,
                    onPressed:
                        status == CampaignStatus.available ||
                            status == CampaignStatus.endingSoon
                        ? () => _showEnrollmentPreview(context)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _actionLabel(CampaignStatus status) => switch (status) {
    CampaignStatus.available || CampaignStatus.endingSoon => 'Join Campaign',
    CampaignStatus.upcoming => 'Starts on ${campaignDate(campaign.startAt)}',
    CampaignStatus.expired => 'Campaign ended',
  };
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
            Chip(label: Text(campaignCategoryLabel(campaign.category))),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          campaign.fullDescription,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '${campaignDate(campaign.startAt)} – '
          '${campaignDate(campaign.endAt)}',
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
        ? 'Target steps'
        : 'Required goal days';
    final goalValue = campaign.type == CampaignType.stepTarget
        ? '${campaign.targetSteps}'
        : '${campaign.requiredGoalDays} days';
    final items = <({IconData icon, String label, String value})>[
      (icon: Icons.flag_outlined, label: goalLabel, value: goalValue),
      (
        icon: Icons.calendar_month_outlined,
        label: 'Campaign duration',
        value: '${campaign.durationDays} days',
      ),
      (
        icon: Icons.redeem_outlined,
        label: 'Reward',
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
            '${campaign.targetSteps} eligible verified steps are required.',
            'Walk between ${campaignDate(campaign.startAt)} and '
                '${campaignDate(campaign.endAt)}.',
            'Progress begins after joining.',
            'Only eligible verified activity counts.',
          ]
        : <String>[
            '${campaign.requiredGoalDays} separate goal days are required.',
            'Your personal daily goal is used.',
            'Each campaign day can count at most once.',
            'Progress begins after joining.',
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
        _TermRow(label: 'Reward', value: reward.discountLabel),
        const Divider(height: AppSpacing.xl),
        _TermRow(
          label: 'Minimum purchase',
          value: reward.minimumPurchaseDescription,
        ),
        const Divider(height: AppSpacing.xl),
        _TermRow(label: 'Where to use', value: reward.usageChannel),
        const Divider(height: AppSpacing.xl),
        _TermRow(label: 'Expiration', value: reward.expirationDescription),
        const Divider(height: AppSpacing.xl),
        _TermRow(label: 'Availability', value: reward.inventoryLabel),
        const Divider(height: AppSpacing.xl),
        Text(
          'Important restrictions',
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
        const Expanded(
          child: Text(
            'Your health steps continue to be tracked normally.\n\n'
            'Campaign progress is calculated separately after you join.',
          ),
        ),
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
