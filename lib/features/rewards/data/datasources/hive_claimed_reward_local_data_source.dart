import 'package:hive_ce/hive_ce.dart';

import '../../domain/claimed_reward.dart';
import 'claimed_reward_local_data_source.dart';

final class HiveClaimedRewardLocalDataSource
    implements ClaimedRewardLocalDataSource {
  HiveClaimedRewardLocalDataSource._(this._box);

  static const boxName = 'claimed_rewards_box';
  static const _claimsKey = 'claims';
  static const _idempotencyKeysKey = 'idempotency_keys';
  final Box<dynamic> _box;

  static Future<HiveClaimedRewardLocalDataSource> open() async =>
      HiveClaimedRewardLocalDataSource._(await Hive.openBox<dynamic>(boxName));

  @override
  Future<List<ClaimedReward>> loadClaimedRewards() async {
    final raw = _box.get(_claimsKey);
    if (raw is! List) return const <ClaimedReward>[];
    return raw
        .whereType<Map>()
        .map(ClaimedReward.fromMap)
        .whereType<ClaimedReward>()
        .toList(growable: false);
  }

  @override
  Future<bool> addClaimedReward(
    ClaimedReward reward, {
    required String idempotencyKey,
  }) async {
    final keys =
        (_box.get(_idempotencyKeysKey) as List?)
            ?.map((item) => item.toString())
            .toSet() ??
        <String>{};
    if (keys.contains(idempotencyKey)) return false;
    final claims = (await loadClaimedRewards()).toList()..add(reward);
    keys.add(idempotencyKey);
    await _box.putAll(<String, Object>{
      _claimsKey: claims.map((item) => item.toMap()).toList(growable: false),
      _idempotencyKeysKey: keys.toList(growable: false),
    });
    await _box.flush();
    return true;
  }

  @override
  Future<void> updateClaimedReward(ClaimedReward reward) async {
    final claims = (await loadClaimedRewards()).toList();
    final index = claims.indexWhere((item) => item.id == reward.id);
    if (index < 0) return;
    claims[index] = reward;
    await _box.put(
      _claimsKey,
      claims.map((item) => item.toMap()).toList(growable: false),
    );
    await _box.flush();
  }

  @override
  Future<void> removeClaimedReward(String id) async {
    final claims = (await loadClaimedRewards()).toList()
      ..removeWhere((item) => item.id == id);
    await _box.put(
      _claimsKey,
      claims.map((item) => item.toMap()).toList(growable: false),
    );
    await _box.flush();
  }
}
