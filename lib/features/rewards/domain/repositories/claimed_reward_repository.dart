import '../claimed_reward.dart';

abstract interface class ClaimedRewardRepository {
  Future<List<ClaimedReward>> loadClaimedRewards();

  Future<bool> addClaimedReward(
    ClaimedReward reward, {
    required String idempotencyKey,
  });

  Future<void> updateClaimedReward(ClaimedReward reward);

  Future<void> removeClaimedReward(String id);
}
