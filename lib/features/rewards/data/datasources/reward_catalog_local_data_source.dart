import '../../domain/reward.dart';

abstract interface class RewardCatalogLocalDataSource {
  Future<List<Reward>> getRewards();
}
