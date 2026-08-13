import 'dart:async';
import 'package:get/get.dart';

import '../../../../core/presentation/reactive_controller.dart';

import '../../../../core/preferences/app_settings_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../campaigns/presentation/getx/campaign_enrollment_controller.dart';
import '../../../campaigns/domain/campaign.dart';
import '../../../campaigns/domain/campaign_enrollment.dart';
import '../../../campaigns/domain/campaign_enrollment_status.dart';
import '../../../campaigns/domain/campaign_reward_type.dart';
import '../../domain/claimed_reward.dart';
import '../../domain/claimed_reward_source_type.dart';
import '../../domain/coupon_status.dart';
import '../../domain/reward.dart';
import '../../domain/reward_channel.dart';
import '../../domain/reward_status.dart';
import '../../domain/reward_transaction.dart';
import '../../domain/reward_transaction_type.dart';
import '../../domain/reward_wallet.dart';
import '../../domain/usecases/reward_use_cases.dart';

enum RewardsViewState { loading, content, empty, error }

enum RewardActionResult {
  success,
  alreadyClaimed,
  insufficientPoints,
  unavailable,
  failed,
}

final class RewardsController extends ReactiveController {
  RewardsController(
    this._useCases,
    this._campaignController,
    this._settingsController,
  );

  final RewardUseCases _useCases;
  final CampaignEnrollmentController _campaignController;
  final AppSettingsController _settingsController;

  AppLocalizations get _l10n =>
      lookupAppLocalizations(_settingsController.locale);

  final Rx<RewardsViewState> _viewState = RewardsViewState.loading.obs;
  final Rx<List<Reward>> _catalog = Rx<List<Reward>>(const <Reward>[]);
  final Rx<List<RewardTransaction>> _transactions = Rx<List<RewardTransaction>>(
    const <RewardTransaction>[],
  );
  final Rx<List<ClaimedReward>> _claimedRewards = Rx<List<ClaimedReward>>(
    const <ClaimedReward>[],
  );
  final RxnString _userMessage = RxnString();
  final RxBool _isSaving = false.obs;
  bool _processingCompletions = false;
  bool _completionPending = false;
  Worker? _campaignWorker;
  bool _disposed = false;

  RewardsViewState get viewState => _viewState.value;
  List<Reward> get catalog => _catalog.value;
  List<RewardTransaction> get transactions => _transactions.value;
  List<ClaimedReward> get claimedRewards => _claimedRewards.value;
  RewardWallet get wallet => RewardWallet(_transactions.value);
  String? get userMessage => _userMessage.value;
  bool get isSaving => _isSaving.value;

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
    _viewState.value = RewardsViewState.loading;
    _userMessage.value = null;
    _notify();
    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        _useCases.getRewards(),
        _useCases.loadTransactions(),
        _useCases.loadClaimedRewards(),
      ]);
      _catalog.value = results[0] as List<Reward>;
      _transactions.value = results[1] as List<RewardTransaction>;
      _claimedRewards.value = results[2] as List<ClaimedReward>;
      _viewState.value = _catalog.value.isEmpty
          ? RewardsViewState.empty
          : RewardsViewState.content;
      _campaignWorker ??= _campaignController.watch(
        _queueCampaignCompletionProcessing,
      );
      _queueCampaignCompletionProcessing();
    } catch (_) {
      _viewState.value = RewardsViewState.error;
      _userMessage.value = _l10n.rewardsLoadTryAgain;
    }
    _notify();
  }

  Reward? rewardById(String id) {
    for (final reward in _catalog.value) {
      if (reward.id == id) return reward;
    }
    return null;
  }

  ClaimedReward? claimedRewardById(String id) {
    for (final reward in _claimedRewards.value) {
      if (reward.id == id) return reward;
    }
    return null;
  }

  ClaimedReward? claimedRewardForReward(String rewardId) {
    for (final claimed in _claimedRewards.value) {
      if (claimed.rewardId == rewardId &&
          claimed.sourceType == ClaimedRewardSourceType.pointRedemption) {
        return claimed;
      }
    }
    return null;
  }

  ClaimedReward? claimedRewardForCampaign(String campaignId) {
    for (final claimed in _claimedRewards.value) {
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

  bool campaignPointsAdded(CampaignEnrollment enrollment) =>
      _transactions.value.any(
        (item) =>
            item.idempotencyKey ==
            'campaign-completion-points:${enrollment.id}',
      );

  Future<RewardActionResult> claimCampaignReward(
    CampaignEnrollment enrollment,
  ) async {
    if (_isSaving.value ||
        enrollment.status != CampaignEnrollmentStatus.completed) {
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
      final added = await _useCases.addClaimedReward(
        claim,
        idempotencyKey: 'campaign-direct-reward:${enrollment.id}',
      );
      await _reloadClaims();
      _userMessage.value = null;
      _setSaving(false);
      return added
          ? RewardActionResult.success
          : RewardActionResult.alreadyClaimed;
    } catch (_) {
      _userMessage.value = _l10n.campaignRewardClaimError;
      _setSaving(false);
      return RewardActionResult.failed;
    }
  }

  Future<RewardActionResult> redeemReward(Reward reward) async {
    if (_isSaving.value) return RewardActionResult.unavailable;
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
      reason: _l10n.rewardRedeemedTransaction(reward.brandName, reward.title),
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
      usageChannel: channelLabel(_l10n, reward.usageChannel),
      minimumPurchaseDescription: reward.minimumPurchaseDescription,
      terms: reward.terms,
    );
    try {
      if (wallet.balance < reward.requiredPoints) {
        _setSaving(false);
        return RewardActionResult.insufficientPoints;
      }
      await _useCases.appendTransaction(debit);
      await _reloadTransactions();
      try {
        await _useCases.addClaimedReward(claim, idempotencyKey: debitKey);
      } catch (_) {
        await _compensateFailedRedemption(reward, claimId);
        rethrow;
      }
      await _reloadClaims();
      _userMessage.value = null;
      _setSaving(false);
      return RewardActionResult.success;
    } catch (_) {
      _userMessage.value = _l10n.rewardSafeRedeemError;
      _setSaving(false);
      return RewardActionResult.failed;
    }
  }

  Future<bool> markClaimedRewardUsed(ClaimedReward reward) async {
    if (_isSaving.value ||
        reward.statusAt(DateTime.now()) != CouponStatus.available) {
      return false;
    }
    _setSaving(true);
    try {
      await _useCases.updateClaimedReward(
        reward.copyWith(couponStatus: CouponStatus.used),
      );
      await _reloadClaims();
      _userMessage.value = null;
      _setSaving(false);
      return true;
    } catch (_) {
      _userMessage.value = _l10n.couponStatusUpdateError;
      _setSaving(false);
      return false;
    }
  }

  void refreshExpirationState() => _notify();

  Future<void> _compensateFailedRedemption(
    Reward reward,
    String claimId,
  ) async {
    await _useCases.appendTransaction(
      RewardTransaction(
        id: 'compensation-$claimId',
        type: RewardTransactionType.credit,
        amount: reward.requiredPoints,
        reason: _l10n.rewardRedemptionRestoredTransaction(reward.brandName),
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
          await _useCases.appendTransaction(
            RewardTransaction(
              id: 'credit-${enrollment.id}',
              type: RewardTransactionType.credit,
              amount: amount,
              reason: _l10n.campaignCompletedTransaction(campaign.title),
              createdAt: enrollment.completedAt ?? DateTime.now(),
              sourceCampaignId: campaign.id,
              idempotencyKey: key,
            ),
          );
          await _reloadTransactions();
          _userMessage.value = null;
        } catch (_) {
          _userMessage.value = _l10n.campaignPointsPending;
        }
      }
      _notify();
    }
    _processingCompletions = false;
  }

  Future<void> _reloadTransactions() async {
    _transactions.value = await _useCases.loadTransactions();
  }

  Future<void> _reloadClaims() async {
    _claimedRewards.value = await _useCases.loadClaimedRewards();
  }

  void _setSaving(bool value) {
    _isSaving.value = value;
    _notify();
  }

  void _notify() {
    if (!_disposed) refreshState();
  }

  static String _couponCode(String rewardId, String claimId) {
    String short(String value) => value
        .replaceAll(RegExp('[^A-Za-z0-9]'), '')
        .toUpperCase()
        .padRight(6, 'X')
        .substring(0, 6);
    return 'WALK-${short(rewardId)}-${short(claimId)}';
  }

  static String channelLabel(AppLocalizations l10n, RewardChannel channel) =>
      switch (channel) {
        RewardChannel.online => l10n.onlineChannel,
        RewardChannel.inStore => l10n.inStoreChannel,
        RewardChannel.onlineAndInStore => l10n.onlineAndInStoreChannel,
      };

  @override
  void onClose() {
    _disposed = true;
    _campaignWorker?.dispose();
    super.onClose();
  }
}
