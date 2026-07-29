import 'reward_transaction.dart';
import 'reward_transaction_type.dart';

final class RewardWallet {
  RewardWallet(List<RewardTransaction> transactions)
    : transactions = List<RewardTransaction>.unmodifiable(transactions);

  final List<RewardTransaction> transactions;

  int get totalEarned => transactions
      .where((item) => item.type == RewardTransactionType.credit)
      .fold(0, (total, item) => total + item.amount);

  int get totalSpent => transactions
      .where((item) => item.type == RewardTransactionType.debit)
      .fold(0, (total, item) => total + item.amount);

  int get balance => totalEarned - totalSpent;
}
