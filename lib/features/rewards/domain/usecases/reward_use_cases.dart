import '../claimed_reward.dart';
import '../reward.dart';
import '../reward_transaction.dart';
import '../repositories/claimed_reward_repository.dart';
import '../repositories/reward_catalog_repository.dart';
import '../repositories/reward_wallet_repository.dart';

final class RewardUseCases {
  const RewardUseCases(this._catalog, this._wallet, this._claims);
  final RewardCatalogRepository _catalog;
  final RewardWalletRepository _wallet;
  final ClaimedRewardRepository _claims;
  Future<List<Reward>> getRewards() => _catalog.getRewards();
  Future<List<RewardTransaction>> loadTransactions() =>
      _wallet.loadTransactions();
  Future<bool> appendTransaction(RewardTransaction value) =>
      _wallet.appendTransaction(value);
  Future<List<ClaimedReward>> loadClaimedRewards() =>
      _claims.loadClaimedRewards();
  Future<bool> addClaimedReward(
    ClaimedReward value, {
    required String idempotencyKey,
  }) => _claims.addClaimedReward(value, idempotencyKey: idempotencyKey);
  Future<void> updateClaimedReward(ClaimedReward value) =>
      _claims.updateClaimedReward(value);
}
