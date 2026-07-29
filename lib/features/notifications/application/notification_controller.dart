import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/preferences/app_settings_controller.dart';
import '../../campaigns/application/campaign_enrollment_controller.dart';
import '../../campaigns/domain/campaign_enrollment_status.dart';
import '../../campaigns/domain/campaign_reward_type.dart';
import '../../campaigns/domain/campaign_type.dart';
import '../../rewards/application/rewards_controller.dart';
import '../../rewards/domain/coupon_status.dart';
import '../../step_counter/presentation/step_counter_controller.dart';
import '../data/notification_repository.dart';
import '../domain/app_notification.dart';
import '../domain/app_notification_destination.dart';
import '../domain/app_notification_status.dart';
import '../domain/app_notification_type.dart';

enum NotificationViewState { loading, content, empty, error }

final class NotificationController extends ChangeNotifier {
  NotificationController({
    required NotificationRepository repository,
    required StepCounterController stepController,
    required CampaignEnrollmentController campaignController,
    required RewardsController rewardsController,
    required AppSettingsController settingsController,
  }) : this._(
         repository,
         stepController,
         campaignController,
         rewardsController,
         settingsController,
       );

  NotificationController._(
    this._repository,
    this._stepController,
    this._campaignController,
    this._rewardsController,
    this._settingsController,
  );

  final NotificationRepository _repository;
  final StepCounterController _stepController;
  final CampaignEnrollmentController _campaignController;
  final RewardsController _rewardsController;
  final AppSettingsController _settingsController;

  NotificationViewState _viewState = NotificationViewState.loading;
  List<AppNotification> _notifications = const <AppNotification>[];
  String? _userMessage;
  bool _evaluating = false;
  bool _evaluationPending = false;
  bool _observing = false;
  bool _disposed = false;

  NotificationViewState get viewState => _viewState;
  List<AppNotification> get notifications => _notifications;
  String? get userMessage => _userMessage;
  int get unreadCount => _notifications
      .where((item) => item.status == AppNotificationStatus.unread)
      .length;
  int get readCount => _notifications.length - unreadCount;

  Future<void> initialize() async {
    await refresh(evaluate: false);
    if (!_observing) {
      _stepController.addListener(_queueEvaluation);
      _campaignController.addListener(_queueEvaluation);
      _rewardsController.addListener(_queueEvaluation);
      _settingsController.addListener(_queueEvaluation);
      _observing = true;
    }
    _queueEvaluation();
  }

  Future<void> refresh({bool evaluate = true}) async {
    try {
      _notifications = await _repository.getRecentNotifications();
      _viewState = _notifications.isEmpty
          ? NotificationViewState.empty
          : NotificationViewState.content;
      _userMessage = null;
    } catch (_) {
      _viewState = _notifications.isEmpty
          ? NotificationViewState.error
          : NotificationViewState.content;
      _userMessage =
          'Notifications could not be refreshed. Your other WalkApp data is unaffected.';
    }
    _notify();
    if (evaluate) _queueEvaluation();
  }

  Future<void> evaluateNow() async {
    _evaluationPending = true;
    if (_evaluating) return;
    _evaluating = true;
    while (_evaluationPending && !_disposed) {
      _evaluationPending = false;
      try {
        await _evaluate(DateTime.now());
        _notifications = await _repository.getRecentNotifications();
        _viewState = _notifications.isEmpty
            ? NotificationViewState.empty
            : NotificationViewState.content;
        _userMessage = null;
      } catch (_) {
        _userMessage =
            'Some notification updates are waiting to be saved locally.';
        if (_notifications.isEmpty) _viewState = NotificationViewState.error;
      }
      _notify();
    }
    _evaluating = false;
  }

  Future<void> markAsRead(AppNotification notification) async {
    _replaceInMemory(notification.copyWith(status: AppNotificationStatus.read));
    _notify();
    try {
      await _repository.markAsRead(notification.id);
    } catch (_) {
      _userMessage = 'This notification will be marked read when saving works.';
      _notify();
    }
  }

  Future<void> markAllAsRead() async {
    _notifications = _notifications
        .map((item) => item.copyWith(status: AppNotificationStatus.read))
        .toList(growable: false);
    _notify();
    try {
      await _repository.markAllAsRead();
    } catch (_) {
      _userMessage = 'Read status could not be saved yet.';
      _notify();
    }
  }

  Future<int> deleteReadNotifications() async {
    final count = readCount;
    _notifications = _notifications
        .where((item) => item.status == AppNotificationStatus.unread)
        .toList(growable: false);
    _viewState = _notifications.isEmpty
        ? NotificationViewState.empty
        : NotificationViewState.content;
    _notify();
    try {
      return await _repository.deleteReadNotifications();
    } catch (_) {
      _userMessage = 'Read notifications could not be cleared yet.';
      _notify();
      return count;
    }
  }

  void _queueEvaluation() {
    _evaluationPending = true;
    if (!_evaluating) unawaited(evaluateNow());
  }

  Future<void> _evaluate(DateTime now) async {
    if (!_settingsController.onboardingCompleted) return;
    final date = _dateKey(now);
    final confirmed = _stepController.snapshot.confirmedSteps;
    final displayed = _stepController.snapshot.displayedSteps;
    final goal = _settingsController.dailyGoal;

    if (_settingsController.inAppGoalCompletionEnabled && confirmed >= goal) {
      await _create(
        now: now,
        key: 'daily-goal-completed:$date',
        type: AppNotificationType.dailyGoalCompleted,
        title: 'Daily goal completed',
        message: 'You reached your walking goal for today.',
        destination: AppNotificationDestination.home,
      );
    }

    final reminderTime = _settingsController.inAppDailyGoalReminderTime;
    if (_settingsController.inAppDailyGoalReminderEnabled &&
        reminderTime != null &&
        displayed < goal &&
        (now.hour * 60 + now.minute) >= reminderTime) {
      await _create(
        now: now,
        key: 'daily-goal-reminder:$date',
        type: AppNotificationType.dailyGoalReminder,
        title: 'A few more steps today?',
        message:
            'You have ${goal - displayed} steps left to reach your daily goal.',
        destination: AppNotificationDestination.home,
      );
    }

    if (_settingsController.inAppCampaignUpdatesEnabled) {
      for (final enrollment in _campaignController.enrollments) {
        final campaign = _campaignController.campaignFor(enrollment);
        if (campaign == null) continue;
        if (enrollment.status == CampaignEnrollmentStatus.active &&
            !now.isAfter(campaign.endAt) &&
            campaign.endAt.difference(now) <= const Duration(hours: 24)) {
          final remaining = campaign.type == CampaignType.stepTarget
              ? '${((campaign.targetSteps ?? 0) - enrollment.totalEligibleSteps).clamp(0, 1 << 31)} campaign steps remaining.'
              : '${((campaign.requiredGoalDays ?? 0) - _campaignController.completedGoalDays(enrollment)).clamp(0, 366)} more goal day${((campaign.requiredGoalDays ?? 0) - _campaignController.completedGoalDays(enrollment)) == 1 ? '' : 's'} before the deadline.';
          await _create(
            now: now,
            key: 'campaign-ending:${enrollment.id}:$date',
            type: AppNotificationType.campaignEndingSoon,
            title: 'Your campaign ends soon',
            message: 'You need $remaining',
            destination: AppNotificationDestination.activeCampaign,
            campaignId: campaign.id,
            enrollmentId: enrollment.id,
          );
        }
        if (enrollment.status == CampaignEnrollmentStatus.completed) {
          await _create(
            now: enrollment.completedAt ?? now,
            key: 'campaign-completed:${enrollment.id}',
            type: AppNotificationType.campaignCompleted,
            title: 'Campaign completed',
            message: 'You completed ${campaign.title}.',
            destination: AppNotificationDestination.rewards,
            campaignId: campaign.id,
            enrollmentId: enrollment.id,
          );
        }
      }
    }

    if (_settingsController.inAppRewardUpdatesEnabled) {
      for (final enrollment in _campaignController.enrollments) {
        final campaign = _campaignController.campaignFor(enrollment);
        if (campaign == null ||
            enrollment.status != CampaignEnrollmentStatus.completed) {
          continue;
        }
        if (campaign.reward.type == CampaignRewardType.directOffer) {
          if (_rewardsController.claimedRewardForCampaign(campaign.id) ==
              null) {
            await _create(
              now: now,
              key: 'campaign-reward-ready:${enrollment.id}',
              type: AppNotificationType.campaignRewardReady,
              title: 'Reward ready to claim',
              message: 'Your ${campaign.reward.title} is ready.',
              destination: AppNotificationDestination.rewards,
              campaignId: campaign.id,
              enrollmentId: enrollment.id,
              rewardId: campaign.reward.rewardId,
            );
          }
          continue;
        }
        final transactionKey = 'campaign-completion-points:${enrollment.id}';
        final transaction = _rewardsController.transactions
            .where((item) => item.idempotencyKey == transactionKey)
            .firstOrNull;
        if (transaction != null) {
          await _create(
            now: transaction.createdAt,
            key: 'campaign-points-earned:${enrollment.id}',
            type: AppNotificationType.campaignPointsEarned,
            title: 'Points added',
            message:
                '${transaction.amount} points were added to your Rewards balance.',
            destination: AppNotificationDestination.rewards,
            campaignId: campaign.id,
            enrollmentId: enrollment.id,
          );
        }
      }
      for (final claim in _rewardsController.claimedRewards) {
        final remaining = claim.expiresAt.difference(now);
        if (claim.statusAt(now) == CouponStatus.available &&
            !remaining.isNegative &&
            remaining <= const Duration(days: 3)) {
          await _create(
            now: now,
            key: 'coupon-expiring:${claim.id}',
            type: AppNotificationType.couponExpiringSoon,
            title: 'Your reward expires soon',
            message:
                'Use ${claim.rewardTitle} before ${_friendlyDate(claim.expiresAt)}.',
            destination: AppNotificationDestination.couponDetails,
            rewardId: claim.rewardId,
            claimedRewardId: claim.id,
          );
        }
      }
    }
  }

  Future<void> _create({
    required DateTime now,
    required String key,
    required AppNotificationType type,
    required String title,
    required String message,
    required AppNotificationDestination destination,
    String? campaignId,
    String? enrollmentId,
    String? rewardId,
    String? claimedRewardId,
  }) async {
    if (_notifications.any((item) => item.idempotencyKey == key)) return;
    final item = AppNotification(
      id: 'notification:$key',
      type: type,
      title: title,
      message: message,
      createdAt: now,
      status: AppNotificationStatus.unread,
      destination: destination,
      relatedCampaignId: campaignId,
      relatedEnrollmentId: enrollmentId,
      relatedRewardId: rewardId,
      relatedClaimedRewardId: claimedRewardId,
      idempotencyKey: key,
    );
    if (await _repository.createIfAbsent(item)) {
      _notifications = <AppNotification>[item, ..._notifications];
    }
  }

  void _replaceInMemory(AppNotification notification) {
    _notifications = _notifications
        .map((item) => item.id == notification.id ? notification : item)
        .toList(growable: false);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  static String _dateKey(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  static String _friendlyDate(DateTime value) =>
      '${value.day}.${value.month}.${value.year}';

  @override
  void dispose() {
    _disposed = true;
    if (_observing) {
      _stepController.removeListener(_queueEvaluation);
      _campaignController.removeListener(_queueEvaluation);
      _rewardsController.removeListener(_queueEvaluation);
      _settingsController.removeListener(_queueEvaluation);
    }
    super.dispose();
  }
}
