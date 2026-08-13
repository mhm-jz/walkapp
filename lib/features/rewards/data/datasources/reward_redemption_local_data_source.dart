import '../../domain/reward_redemption_operation.dart';

abstract interface class RewardRedemptionLocalDataSource {
  Future<List<RewardRedemptionOperation>> loadOperations();
  Future<void> saveOperation(RewardRedemptionOperation operation);
}
