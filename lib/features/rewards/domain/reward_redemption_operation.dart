import 'claimed_reward.dart';
import 'reward_transaction.dart';

enum RewardRedemptionOperationState { prepared, completed, compensated }

final class RewardRedemptionOperation {
  const RewardRedemptionOperation({
    required this.id,
    required this.debit,
    required this.claim,
    required this.claimIdempotencyKey,
    required this.compensationIdempotencyKey,
    required this.createdAt,
    required this.state,
    this.lastErrorDescription,
  });

  final String id;
  final RewardTransaction debit;
  final ClaimedReward claim;
  final String claimIdempotencyKey;
  final String compensationIdempotencyKey;
  final DateTime createdAt;
  final RewardRedemptionOperationState state;
  final String? lastErrorDescription;

  RewardRedemptionOperation copyWith({
    RewardRedemptionOperationState? state,
    String? lastErrorDescription,
  }) => RewardRedemptionOperation(
    id: id,
    debit: debit,
    claim: claim,
    claimIdempotencyKey: claimIdempotencyKey,
    compensationIdempotencyKey: compensationIdempotencyKey,
    createdAt: createdAt,
    state: state ?? this.state,
    lastErrorDescription: lastErrorDescription,
  );

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'debit': debit.toMap(),
    'claim': claim.toMap(),
    'claimIdempotencyKey': claimIdempotencyKey,
    'compensationIdempotencyKey': compensationIdempotencyKey,
    'createdAt': createdAt.toIso8601String(),
    'state': state.name,
    'lastErrorDescription': lastErrorDescription,
  };

  static RewardRedemptionOperation? fromMap(Map<dynamic, dynamic> map) {
    final debitMap = map['debit'];
    final claimMap = map['claim'];
    final debit = debitMap is Map ? RewardTransaction.fromMap(debitMap) : null;
    final claim = claimMap is Map ? ClaimedReward.fromMap(claimMap) : null;
    final createdAt = DateTime.tryParse(map['createdAt']?.toString() ?? '');
    final id = map['id']?.toString();
    final claimKey = map['claimIdempotencyKey']?.toString();
    final compensationKey = map['compensationIdempotencyKey']?.toString();
    if (id == null ||
        debit == null ||
        claim == null ||
        createdAt == null ||
        claimKey == null ||
        compensationKey == null) {
      return null;
    }
    return RewardRedemptionOperation(
      id: id,
      debit: debit,
      claim: claim,
      claimIdempotencyKey: claimKey,
      compensationIdempotencyKey: compensationKey,
      createdAt: createdAt,
      state: switch (map['state']?.toString()) {
        'completed' => RewardRedemptionOperationState.completed,
        'compensated' => RewardRedemptionOperationState.compensated,
        _ => RewardRedemptionOperationState.prepared,
      },
      lastErrorDescription: map['lastErrorDescription']?.toString(),
    );
  }
}
