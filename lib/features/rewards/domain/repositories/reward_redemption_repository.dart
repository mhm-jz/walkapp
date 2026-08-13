import '../reward_redemption_operation.dart';

abstract interface class RewardRedemptionRepository {
  Future<List<RewardRedemptionOperation>> loadOperations();

  Future<void> saveOperation(RewardRedemptionOperation operation);
}
