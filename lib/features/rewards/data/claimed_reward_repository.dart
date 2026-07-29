import '../domain/claimed_reward.dart';

abstract interface class ClaimedRewardRepository {
  Future<List<ClaimedReward>> loadClaimedRewards();

  Future<bool> addClaimedReward(
    ClaimedReward reward, {
    required String idempotencyKey,
  });

  Future<void> updateClaimedReward(ClaimedReward reward);
}

final class InMemoryClaimedRewardRepository implements ClaimedRewardRepository {
  final List<ClaimedReward> _items = <ClaimedReward>[];
  final Set<String> _keys = <String>{};

  @override
  Future<List<ClaimedReward>> loadClaimedRewards() async =>
      List<ClaimedReward>.unmodifiable(_items);

  @override
  Future<bool> addClaimedReward(
    ClaimedReward reward, {
    required String idempotencyKey,
  }) async {
    if (!_keys.add(idempotencyKey)) return false;
    _items.add(reward);
    return true;
  }

  @override
  Future<void> updateClaimedReward(ClaimedReward reward) async {
    final index = _items.indexWhere((item) => item.id == reward.id);
    if (index >= 0) _items[index] = reward;
  }
}
