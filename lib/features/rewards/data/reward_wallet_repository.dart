import '../domain/reward_transaction.dart';

abstract interface class RewardWalletRepository {
  Future<List<RewardTransaction>> loadTransactions();

  Future<bool> appendTransaction(RewardTransaction transaction);
}

final class InMemoryRewardWalletRepository implements RewardWalletRepository {
  final List<RewardTransaction> _items = <RewardTransaction>[];

  @override
  Future<List<RewardTransaction>> loadTransactions() async =>
      List<RewardTransaction>.unmodifiable(_items);

  @override
  Future<bool> appendTransaction(RewardTransaction transaction) async {
    if (_items.any(
      (item) => item.idempotencyKey == transaction.idempotencyKey,
    )) {
      return false;
    }
    _items.add(transaction);
    return true;
  }
}
