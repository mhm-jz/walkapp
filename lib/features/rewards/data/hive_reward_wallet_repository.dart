import 'package:hive_ce/hive_ce.dart';

import '../domain/reward_transaction.dart';
import 'reward_wallet_repository.dart';

final class HiveRewardWalletRepository implements RewardWalletRepository {
  HiveRewardWalletRepository._(this._box);

  static const boxName = 'reward_wallet_box';
  static const _transactionsKey = 'transactions';
  final Box<dynamic> _box;

  static Future<HiveRewardWalletRepository> open() async =>
      HiveRewardWalletRepository._(await Hive.openBox<dynamic>(boxName));

  @override
  Future<List<RewardTransaction>> loadTransactions() async {
    final raw = _box.get(_transactionsKey);
    if (raw is! List) return const <RewardTransaction>[];
    return raw
        .whereType<Map>()
        .map(RewardTransaction.fromMap)
        .whereType<RewardTransaction>()
        .toList(growable: false);
  }

  @override
  Future<bool> appendTransaction(RewardTransaction transaction) async {
    final transactions = (await loadTransactions()).toList();
    if (transactions.any(
      (item) => item.idempotencyKey == transaction.idempotencyKey,
    )) {
      return false;
    }
    transactions.add(transaction);
    await _box.put(
      _transactionsKey,
      transactions.map((item) => item.toMap()).toList(growable: false),
    );
    await _box.flush();
    return true;
  }
}
