import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../campaigns/application/campaign_enrollment_controller.dart';
import '../../campaigns/domain/campaign.dart';
import '../../campaigns/domain/campaign_enrollment.dart';
import '../../campaigns/domain/campaign_enrollment_status.dart';
import '../../campaigns/domain/campaign_reward_type.dart';
import '../data/claimed_reward_repository.dart';
import '../data/reward_catalog_repository.dart';
import '../data/reward_wallet_repository.dart';
import '../domain/claimed_reward.dart';
import '../domain/claimed_reward_source_type.dart';
import '../domain/coupon_status.dart';
import '../domain/reward.dart';
import '../domain/reward_channel.dart';
import '../domain/reward_status.dart';
import '../domain/reward_transaction.dart';
import '../domain/reward_transaction_type.dart';
import '../domain/reward_wallet.dart';

enum RewardsViewState { loading, content, empty, error }

enum RewardActionResult {
  success,
  alreadyClaimed,
  insufficientPoints,
  unavailable,
  failed,
}

final class RewardsController extends ChangeNotifier {
  RewardsController(
    this._catalogRepository,
    this._walletRepository,
    this._claimedRewardRepository,
    this._campaignController,
  );

  final RewardCatalogRepository _catalogRepository;
  final RewardWalletRepository _walletRepository;
  final ClaimedRewardRepository _claimedRewardRepository;
  final CampaignEnrollmentController _campaignController;

  RewardsViewState _viewState = RewardsViewState.loading;
  List<Reward> _catalog = const <Reward>[];
  List<RewardTransaction> _transactions = const <RewardTransaction>[];
  List<ClaimedReward> _claimedRewards = const <ClaimedReward>[];
  String? _userMessage;
  bool _isSaving = false;
  bool _processingCompletions = false;
  bool _completionPending = false;
  bool _observingCampaigns = false;
  bool _disposed = false;

  RewardsViewState get viewState => _viewState;
  List<Reward> get catalog => _catalog;
  List<RewardTransaction> get transactions => _transactions;
  List<ClaimedReward> get claimedRewards => _claimedRewards;
  RewardWallet get wallet => RewardWallet(_transactions);
  String? get userMessage => _userMessage;
  bool get isSaving => _isSaving;

  List<({Campaign campaign, CampaignEnrollment enrollment})>
  get directRewardsReady {
    final result = <({Campaign campaign, CampaignEnrollment enrollment})>[];
    for (final enrollment in _campaignController.enrollments) {
      if (enrollment.status != CampaignEnrollmentStatus.completed) continue;
      final campaign = _campaignController.campaignFor(enrollment);
      if (campaign == null ||
          campaign.reward.type != CampaignRewardType.directOffer ||
          claimedRewardForCampaign(campaign.id) != null) {
        continue;
      }
      result.add((campaign: campaign, enrollment: enrollment));
    }
    return result;
  }

  Future<void> initialize() async {
    _viewState = RewardsViewState.loading;
    _userMessage = null;
    _notify();
    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        _catalogRepository.getRewards(),
        _walletRepository.loadTransactions(),
        _claimedRewardRepository.loadClaimedRewards(),
      ]);
      _catalog = results[0] as List<Reward>;
      _transactions = results[1] as List<RewardTransaction>;
      _claimedRewards = results[2] as List<ClaimedReward>;
      _viewState = _catalog.isEmpty
          ? RewardsViewState.empty
          : RewardsViewState.content;
      if (!_observingCampaigns) {
        _campaignController.addListener(_queueCampaignCompletionProcessing);
        _observingCampaigns = true;
      }
      _queueCampaignCompletionProcessing();
    } catch (_) {
      _viewState = RewardsViewState.error;
      _userMessage = 'Rewards could not be loaded. Please try again.';
    }
    _notify();
  }

  Reward? rewardById(String id) {
    for (final reward in _catalog) {
      if (reward.id == id) return reward;
    }
    return null;
  }

  ClaimedReward? claimedRewardById(String id) {
    for (final reward in _claimedRewards) {
      if (reward.id == id) return reward;
    }
    return null;
  }

  ClaimedReward? claimedRewardForReward(String rewardId) {
    for (final claimed in _claimedRewards) {
      if (claimed.rewardId == rewardId &&
          claimed.sourceType == ClaimedRewardSourceType.pointRedemption) {
        return claimed;
      }
    }
    return null;
  }

  ClaimedReward? claimedRewardForCampaign(String campaignId) {
    for (final claimed in _claimedRewards) {
      if (claimed.sourceCampaignId == campaignId &&
          claimed.sourceType == ClaimedRewardSourceType.campaign) {
        return claimed;
      }
    }
    return null;
  }

  RewardStatus statusFor(Reward reward) {
    if (!reward.isAvailable) return RewardStatus.unavailable;
    if (reward.isLimitedToOne && claimedRewardForReward(reward.id) != null) {
      return RewardStatus.claimed;
    }
    if (wallet.balance < reward.requiredPoints) {
      return RewardStatus.insufficientPoints;
    }
    return RewardStatus.available;
  }

  bool campaignPointsAdded(CampaignEnrollment enrollment) => _transactions.any(
    (item) =>
        item.idempotencyKey == 'campaign-completion-points:${enrollment.id}',
  );

  Future<RewardActionResult> claimCampaignReward(
    CampaignEnrollment enrollment,
  ) async {
    if (_isSaving || enrollment.status != CampaignEnrollmentStatus.completed) {
      return RewardActionResult.unavailable;
    }
    final campaign = _campaignController.campaignFor(enrollment);
    if (campaign == null ||
        campaign.reward.type != CampaignRewardType.directOffer) {
      return RewardActionResult.unavailable;
    }
    final existing = claimedRewardForCampaign(campaign.id);
    if (existing != null) return RewardActionResult.alreadyClaimed;
    _setSaving(true);
    final now = DateTime.now();
    final claimId = 'claim-${enrollment.id}';
    final rewardId =
        campaign.reward.rewardId ?? 'campaign-${campaign.id}-offer';
    final claim = ClaimedReward(
      id: claimId,
      rewardId: rewardId,
      brandName: campaign.brand.name,
      rewardTitle: campaign.reward.title,
      sourceType: ClaimedRewardSourceType.campaign,
      sourceCampaignId: campaign.id,
      claimedAt: now,
      couponCode: _couponCode(rewardId, claimId),
      couponStatus: CouponStatus.available,
      expiresAt: now.add(const Duration(days: 14)),
      pointsSpent: 0,
      discountLabel: campaign.reward.discountLabel,
      usageChannel: campaign.reward.usageChannel,
      minimumPurchaseDescription: campaign.reward.minimumPurchaseDescription,
      terms: campaign.reward.terms.isEmpty
          ? campaign.terms
          : campaign.reward.terms,
    );
    try {
      final added = await _claimedRewardRepository.addClaimedReward(
        claim,
        idempotencyKey: 'campaign-direct-reward:${enrollment.id}',
      );
      await _reloadClaims();
      _userMessage = null;
      _setSaving(false);
      return added
          ? RewardActionResult.success
          : RewardActionResult.alreadyClaimed;
    } catch (_) {
      _userMessage =
          'The campaign reward could not be claimed. Please try again.';
      _setSaving(false);
      return RewardActionResult.failed;
    }
  }

  Future<RewardActionResult> redeemReward(Reward reward) async {
    if (_isSaving) return RewardActionResult.unavailable;
    final status = statusFor(reward);
    if (status == RewardStatus.claimed) {
      return RewardActionResult.alreadyClaimed;
    }
    if (status == RewardStatus.insufficientPoints) {
      return RewardActionResult.insufficientPoints;
    }
    if (status != RewardStatus.available) {
      return RewardActionResult.unavailable;
    }
    _setSaving(true);
    final now = DateTime.now();
    final claimId = 'redeem-${reward.id}-${now.microsecondsSinceEpoch}';
    final debitKey = 'reward-redemption:${reward.id}:$claimId';
    final debit = RewardTransaction(
      id: 'transaction-$claimId',
      type: RewardTransactionType.debit,
      amount: reward.requiredPoints,
      reason: 'Redeemed ${reward.brandName} ${reward.title}',
      createdAt: now,
      sourceRewardId: reward.id,
      idempotencyKey: debitKey,
    );
    final claim = ClaimedReward(
      id: claimId,
      rewardId: reward.id,
      brandName: reward.brandName,
      rewardTitle: reward.title,
      sourceType: ClaimedRewardSourceType.pointRedemption,
      claimedAt: now,
      couponCode: _couponCode(reward.id, claimId),
      couponStatus: CouponStatus.available,
      expiresAt: now.add(Duration(days: reward.validForDays)),
      pointsSpent: reward.requiredPoints,
      discountLabel: reward.discountLabel,
      usageChannel: channelLabel(reward.usageChannel),
      minimumPurchaseDescription: reward.minimumPurchaseDescription,
      terms: reward.terms,
    );
    try {
      if (wallet.balance < reward.requiredPoints) {
        _setSaving(false);
        return RewardActionResult.insufficientPoints;
      }
      await _walletRepository.appendTransaction(debit);
      await _reloadTransactions();
      try {
        await _claimedRewardRepository.addClaimedReward(
          claim,
          idempotencyKey: debitKey,
        );
      } catch (_) {
        await _compensateFailedRedemption(reward, claimId);
        rethrow;
      }
      await _reloadClaims();
      _userMessage = null;
      _setSaving(false);
      return RewardActionResult.success;
    } catch (_) {
      _userMessage =
          'The reward could not be redeemed safely. Your local wallet was restored when possible.';
      _setSaving(false);
      return RewardActionResult.failed;
    }
  }

  Future<bool> markClaimedRewardUsed(ClaimedReward reward) async {
    if (_isSaving ||
        reward.statusAt(DateTime.now()) != CouponStatus.available) {
      return false;
    }
    _setSaving(true);
    try {
      await _claimedRewardRepository.updateClaimedReward(
        reward.copyWith(couponStatus: CouponStatus.used),
      );
      await _reloadClaims();
      _userMessage = null;
      _setSaving(false);
      return true;
    } catch (_) {
      _userMessage = 'The coupon status could not be updated.';
      _setSaving(false);
      return false;
    }
  }

  void refreshExpirationState() => _notify();

  Future<void> _compensateFailedRedemption(
    Reward reward,
    String claimId,
  ) async {
    await _walletRepository.appendTransaction(
      RewardTransaction(
        id: 'compensation-$claimId',
        type: RewardTransactionType.credit,
        amount: reward.requiredPoints,
        reason: 'Restored failed ${reward.brandName} redemption',
        createdAt: DateTime.now(),
        sourceRewardId: reward.id,
        idempotencyKey: 'reward-redemption-compensation:$claimId',
      ),
    );
    await _reloadTransactions();
  }

  void _queueCampaignCompletionProcessing() {
    _completionPending = true;
    if (_processingCompletions) return;
    unawaited(_processCampaignCompletions());
  }

  Future<void> _processCampaignCompletions() async {
    _processingCompletions = true;
    while (_completionPending && !_disposed) {
      _completionPending = false;
      for (final enrollment in _campaignController.enrollments) {
        if (enrollment.status != CampaignEnrollmentStatus.completed) continue;
        final campaign = _campaignController.campaignFor(enrollment);
        if (campaign == null ||
            campaign.reward.type != CampaignRewardType.points) {
          continue;
        }
        final amount = campaign.reward.pointsAmount ?? 0;
        if (amount <= 0 || campaignPointsAdded(enrollment)) continue;
        final key = 'campaign-completion-points:${enrollment.id}';
        try {
          await _walletRepository.appendTransaction(
            RewardTransaction(
              id: 'credit-${enrollment.id}',
              type: RewardTransactionType.credit,
              amount: amount,
              reason: '${campaign.title} completed',
              createdAt: enrollment.completedAt ?? DateTime.now(),
              sourceCampaignId: campaign.id,
              idempotencyKey: key,
            ),
          );
          await _reloadTransactions();
          _userMessage = null;
        } catch (_) {
          _userMessage =
              'Campaign points could not be added yet. Rewards will retry safely.';
        }
      }
      _notify();
    }
    _processingCompletions = false;
  }

  Future<void> _reloadTransactions() async {
    _transactions = await _walletRepository.loadTransactions();
  }

  Future<void> _reloadClaims() async {
    _claimedRewards = await _claimedRewardRepository.loadClaimedRewards();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  static String _couponCode(String rewardId, String claimId) {
    String short(String value) => value
        .replaceAll(RegExp('[^A-Za-z0-9]'), '')
        .toUpperCase()
        .padRight(6, 'X')
        .substring(0, 6);
    return 'WALK-${short(rewardId)}-${short(claimId)}';
  }

  static String channelLabel(RewardChannel channel) => switch (channel) {
    RewardChannel.online => 'Online',
    RewardChannel.inStore => 'In participating stores',
    RewardChannel.onlineAndInStore => 'Online and in participating stores',
  };

  @override
  void dispose() {
    _disposed = true;
    if (_observingCampaigns) {
      _campaignController.removeListener(_queueCampaignCompletionProcessing);
    }
    super.dispose();
  }
}
