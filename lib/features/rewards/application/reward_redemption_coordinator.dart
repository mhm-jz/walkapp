import '../data/claimed_reward_repository.dart';
import '../data/reward_redemption_repository.dart';
import '../data/reward_wallet_repository.dart';
import '../domain/reward_redemption_operation.dart';
import '../domain/reward_transaction.dart';
import '../domain/reward_transaction_type.dart';

enum RewardRedemptionOutcome { success, compensated, incomplete }

final class RewardRedemptionCoordinator {
  RewardRedemptionCoordinator(
    this._walletRepository,
    this._claimedRewardRepository,
    this._redemptionRepository,
  );

  final RewardWalletRepository _walletRepository;
  final ClaimedRewardRepository _claimedRewardRepository;
  final RewardRedemptionRepository _redemptionRepository;

  Future<RewardRedemptionOutcome> redeem(
    RewardRedemptionOperation operation,
  ) async {
    await _redemptionRepository.saveOperation(operation);
    try {
      await _walletRepository.appendTransaction(operation.debit);
    } catch (error) {
      await _recordError(operation, error);
      return RewardRedemptionOutcome.incomplete;
    }
    return _finishDebitedOperation(operation);
  }

  Future<void> reconcileIncompleteOperations() async {
    final operations = await _redemptionRepository.loadOperations();
    for (final operation in operations) {
      if (operation.state != RewardRedemptionOperationState.prepared) continue;
      await _reconcile(operation);
    }
  }

  Future<void> _reconcile(RewardRedemptionOperation operation) async {
    final transactions = await _walletRepository.loadTransactions();
    final claims = await _claimedRewardRepository.loadClaimedRewards();
    final debitExists = transactions.any(
      (item) => item.idempotencyKey == operation.debit.idempotencyKey,
    );
    final compensationExists = transactions.any(
      (item) => item.idempotencyKey == operation.compensationIdempotencyKey,
    );
    final claimExists = claims.any((item) => item.id == operation.claim.id);

    if (debitExists && claimExists) {
      await _mark(operation, RewardRedemptionOperationState.completed);
      return;
    }
    if (compensationExists) {
      if (claimExists) {
        await _claimedRewardRepository.removeClaimedReward(operation.claim.id);
      }
      await _mark(operation, RewardRedemptionOperationState.compensated);
      return;
    }
    if (debitExists) {
      await _finishDebitedOperation(operation);
      return;
    }
    if (claimExists) {
      await _recoverClaimWithoutDebit(operation);
      return;
    }
    await _mark(operation, RewardRedemptionOperationState.compensated);
  }

  Future<RewardRedemptionOutcome> _finishDebitedOperation(
    RewardRedemptionOperation operation,
  ) async {
    try {
      await _claimedRewardRepository.addClaimedReward(
        operation.claim,
        idempotencyKey: operation.claimIdempotencyKey,
      );
    } catch (error) {
      final claims = await _claimedRewardRepository.loadClaimedRewards();
      if (claims.any((item) => item.id == operation.claim.id)) {
        await _mark(operation, RewardRedemptionOperationState.completed);
        return RewardRedemptionOutcome.success;
      }
      return _compensate(operation, error);
    }
    final claims = await _claimedRewardRepository.loadClaimedRewards();
    if (claims.any((item) => item.id == operation.claim.id)) {
      await _mark(operation, RewardRedemptionOperationState.completed);
      return RewardRedemptionOutcome.success;
    }
    return _compensate(
      operation,
      StateError('Claim was not durably persisted.'),
    );
  }

  Future<void> _recoverClaimWithoutDebit(
    RewardRedemptionOperation operation,
  ) async {
    final transactions = await _walletRepository.loadTransactions();
    final balance = transactions.fold<int>(
      0,
      (value, item) =>
          value +
          (item.type == RewardTransactionType.credit
              ? item.amount
              : -item.amount),
    );
    if (balance >= operation.debit.amount) {
      try {
        await _walletRepository.appendTransaction(operation.debit);
        final refreshed = await _walletRepository.loadTransactions();
        if (refreshed.any(
          (item) => item.idempotencyKey == operation.debit.idempotencyKey,
        )) {
          await _mark(operation, RewardRedemptionOperationState.completed);
          return;
        }
      } catch (_) {
        // The unusable claim is removed below if the debit cannot be confirmed.
      }
    }
    await _claimedRewardRepository.removeClaimedReward(operation.claim.id);
    await _mark(operation, RewardRedemptionOperationState.compensated);
  }

  Future<RewardRedemptionOutcome> _compensate(
    RewardRedemptionOperation operation,
    Object error,
  ) async {
    final compensation = RewardTransaction(
      id: 'compensation-${operation.id}',
      type: RewardTransactionType.credit,
      amount: operation.debit.amount,
      reason: 'Reward redemption restored',
      createdAt: DateTime.now(),
      sourceRewardId: operation.claim.rewardId,
      idempotencyKey: operation.compensationIdempotencyKey,
    );
    try {
      await _walletRepository.appendTransaction(compensation);
      final transactions = await _walletRepository.loadTransactions();
      if (!transactions.any(
        (item) => item.idempotencyKey == operation.compensationIdempotencyKey,
      )) {
        throw StateError('Compensation was not durably persisted.');
      }
      await _mark(operation, RewardRedemptionOperationState.compensated);
      return RewardRedemptionOutcome.compensated;
    } catch (compensationError) {
      await _recordError(operation, compensationError);
      return RewardRedemptionOutcome.incomplete;
    }
  }

  Future<void> _recordError(
    RewardRedemptionOperation operation,
    Object error,
  ) async {
    try {
      await _redemptionRepository.saveOperation(
        operation.copyWith(lastErrorDescription: error.toString()),
      );
    } catch (_) {
      // The already-persisted prepared operation remains recoverable.
    }
  }

  Future<void> _mark(
    RewardRedemptionOperation operation,
    RewardRedemptionOperationState state,
  ) => _redemptionRepository.saveOperation(operation.copyWith(state: state));
}
