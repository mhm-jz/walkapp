import '../reward.dart';

abstract interface class RewardCatalogRepository {
  Future<List<Reward>> getRewards();
}
