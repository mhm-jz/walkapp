import '../../domain/reward_transaction.dart';

abstract interface class RewardWalletLocalDataSource {
  Future<List<RewardTransaction>> loadTransactions();
  Future<bool> appendTransaction(RewardTransaction transaction);
}
