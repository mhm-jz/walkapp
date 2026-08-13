import 'package:hive_ce/hive_ce.dart';

import '../../domain/reward_redemption_operation.dart';
import 'reward_redemption_local_data_source.dart';

final class HiveRewardRedemptionLocalDataSource
    implements RewardRedemptionLocalDataSource {
  HiveRewardRedemptionLocalDataSource._(this._box);

  static const boxName = 'reward_redemption_journal_box';
  static const _operationsKey = 'operations';
  final Box<dynamic> _box;

  static Future<HiveRewardRedemptionLocalDataSource> open() async =>
      HiveRewardRedemptionLocalDataSource._(
        await Hive.openBox<dynamic>(boxName),
      );

  @override
  Future<List<RewardRedemptionOperation>> loadOperations() async {
    final raw = _box.get(_operationsKey);
    if (raw is! List) return const <RewardRedemptionOperation>[];
    return raw
        .whereType<Map>()
        .map(RewardRedemptionOperation.fromMap)
        .whereType<RewardRedemptionOperation>()
        .toList(growable: false);
  }

  @override
  Future<void> saveOperation(RewardRedemptionOperation operation) async {
    final operations = (await loadOperations()).toList();
    final index = operations.indexWhere((item) => item.id == operation.id);
    if (index < 0) {
      operations.add(operation);
    } else {
      operations[index] = operation;
    }
    await _box.put(
      _operationsKey,
      operations.map((item) => item.toMap()).toList(growable: false),
    );
    await _box.flush();
  }
}
