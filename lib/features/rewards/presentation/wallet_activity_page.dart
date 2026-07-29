import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../application/rewards_controller.dart';
import '../domain/reward_transaction_type.dart';
import 'reward_formatters.dart';

class WalletActivityPage extends StatelessWidget {
  const WalletActivityPage({required this.controller, super.key});
  final RewardsController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.transactions.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Activity')),
      body: items.isEmpty
          ? const Center(
              child: AppEmptyState(
                title: 'No point activity yet',
                message:
                    'Point credits and reward redemptions will appear here.',
                icon: Icons.receipt_long_outlined,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: items.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final item = items[index];
                final credit = item.type == RewardTransactionType.credit;
                return AppCard(
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        child: Icon(credit ? Icons.add : Icons.remove),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.reason,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(rewardDate(item.createdAt)),
                          ],
                        ),
                      ),
                      Text(
                        '${credit ? '+' : '-'}${item.amount}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
