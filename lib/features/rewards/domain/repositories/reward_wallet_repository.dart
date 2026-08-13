import '../reward_transaction.dart';

abstract interface class RewardWalletRepository {
  Future<List<RewardTransaction>> loadTransactions();

  Future<bool> appendTransaction(RewardTransaction transaction);
}
