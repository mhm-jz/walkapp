import 'reward_transaction_type.dart';

final class RewardTransaction {
  const RewardTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.reason,
    required this.createdAt,
    required this.idempotencyKey,
    this.sourceCampaignId,
    this.sourceRewardId,
  });

  final String id;
  final RewardTransactionType type;
  final int amount;
  final String reason;
  final DateTime createdAt;
  final String? sourceCampaignId;
  final String? sourceRewardId;
  final String idempotencyKey;

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'type': type.name,
    'amount': amount,
    'reason': reason,
    'createdAt': createdAt.toIso8601String(),
    'sourceCampaignId': sourceCampaignId,
    'sourceRewardId': sourceRewardId,
    'idempotencyKey': idempotencyKey,
  };

  static RewardTransaction? fromMap(Map<dynamic, dynamic> map) {
    final typeName = map['type']?.toString();
    final type = typeName == RewardTransactionType.credit.name
        ? RewardTransactionType.credit
        : typeName == RewardTransactionType.debit.name
        ? RewardTransactionType.debit
        : null;
    final createdAt = DateTime.tryParse(map['createdAt']?.toString() ?? '');
    final amount = map['amount'] is int
        ? map['amount'] as int
        : int.tryParse(map['amount']?.toString() ?? '');
    if (type == null ||
        createdAt == null ||
        amount == null ||
        amount <= 0 ||
        map['id'] == null ||
        map['idempotencyKey'] == null) {
      return null;
    }
    return RewardTransaction(
      id: map['id'].toString(),
      type: type,
      amount: amount,
      reason: map['reason']?.toString() ?? 'Reward activity',
      createdAt: createdAt,
      sourceCampaignId: map['sourceCampaignId']?.toString(),
      sourceRewardId: map['sourceRewardId']?.toString(),
      idempotencyKey: map['idempotencyKey'].toString(),
    );
  }
}
