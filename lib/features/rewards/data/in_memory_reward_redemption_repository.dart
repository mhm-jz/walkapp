import '../domain/repositories/reward_redemption_repository.dart';
import '../domain/reward_redemption_operation.dart';

final class InMemoryRewardRedemptionRepository
    implements RewardRedemptionRepository {
  final Map<String, RewardRedemptionOperation> _operations =
      <String, RewardRedemptionOperation>{};

  @override
  Future<List<RewardRedemptionOperation>> loadOperations() async =>
      List<RewardRedemptionOperation>.unmodifiable(_operations.values);

  @override
  Future<void> saveOperation(RewardRedemptionOperation operation) async {
    _operations[operation.id] = operation;
  }
}
