import 'dart:async';
import 'package:get/get.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/presentation/reactive_controller.dart';

import '../../../../core/preferences/app_settings_controller.dart';
import '../../../campaigns/presentation/getx/campaign_enrollment_controller.dart';
import '../../../campaigns/domain/campaign_enrollment_status.dart';
import '../../../campaigns/domain/campaign_reward_type.dart';
import '../../../campaigns/domain/campaign_type.dart';
import '../../../rewards/presentation/getx/rewards_controller.dart';
import '../../../rewards/domain/coupon_status.dart';
import '../../../step_counter/presentation/getx/step_counter_controller.dart';
import '../../domain/app_notification.dart';
import '../../domain/app_notification_destination.dart';
import '../../domain/app_notification_status.dart';
import '../../domain/app_notification_type.dart';
import '../../domain/usecases/notification_use_cases.dart';

enum NotificationViewState { loading, content, empty, error }

final class NotificationController extends ReactiveController {
  NotificationController({
    required NotificationUseCases useCases,
    required StepCounterController stepController,
    required CampaignEnrollmentController campaignController,
    required RewardsController rewardsController,
    required AppSettingsController settingsController,
  }) : this._(
         useCases,
         stepController,
         campaignController,
         rewardsController,
         settingsController,
       );

  NotificationController._(
    this._useCases,
    this._stepController,
    this._campaignController,
    this._rewardsController,
    this._settingsController,
  );

  final NotificationUseCases _useCases;
  final StepCounterController _stepController;
  final CampaignEnrollmentController _campaignController;
  final RewardsController _rewardsController;
  final AppSettingsController _settingsController;

  final Rx<NotificationViewState> _viewState =
      NotificationViewState.loading.obs;
  final Rx<List<AppNotification>> _notifications = Rx<List<AppNotification>>(
    const <AppNotification>[],
  );
  final RxnString _userMessage = RxnString();
  bool _evaluating = false;
  bool _evaluationPending = false;
  final List<Worker> _sourceWorkers = <Worker>[];
  bool _disposed = false;

  NotificationViewState get viewState => _viewState.value;
  List<AppNotification> get notifications => _notifications.value;
  String? get userMessage => _userMessage.value;
  int get unreadCount => _notifications.value
      .where((item) => item.status == AppNotificationStatus.unread)
      .length;
  int get readCount => _notifications.value.length - unreadCount;

  Future<void> initialize() async {
    await reload(evaluate: false);
    if (_sourceWorkers.isEmpty) {
      _sourceWorkers.addAll(<Worker>[
        _stepController.watch(_queueEvaluation),
        _campaignController.watch(_queueEvaluation),
        _rewardsController.watch(_queueEvaluation),
        _settingsController.watch(_queueEvaluation),
      ]);
    }
    _queueEvaluation();
  }

  Future<void> reload({bool evaluate = true}) async {
    try {
      _notifications.value = await _useCases.getRecentNotifications();
      _viewState.value = _notifications.value.isEmpty
          ? NotificationViewState.empty
          : NotificationViewState.content;
      _userMessage.value = null;
    } catch (_) {
      _viewState.value = _notifications.value.isEmpty
          ? NotificationViewState.error
          : NotificationViewState.content;
      _userMessage.value = lookupAppLocalizations(
        _settingsController.locale,
      ).notificationsRefreshError;
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
        _notifications.value = await _useCases.getRecentNotifications();
        _viewState.value = _notifications.value.isEmpty
            ? NotificationViewState.empty
            : NotificationViewState.content;
        _userMessage.value = null;
      } catch (_) {
        _userMessage.value = lookupAppLocalizations(
          _settingsController.locale,
        ).notificationUpdatesPending;
        if (_notifications.value.isEmpty) {
          _viewState.value = NotificationViewState.error;
        }
      }
      _notify();
    }
    _evaluating = false;
  }

  Future<void> markAsRead(AppNotification notification) async {
    _replaceInMemory(notification.copyWith(status: AppNotificationStatus.read));
    _notify();
    try {
      await _useCases.markAsRead(notification.id);
    } catch (_) {
      _userMessage.value = lookupAppLocalizations(
        _settingsController.locale,
      ).notificationReadPending;
      _notify();
    }
  }

  Future<void> markAllAsRead() async {
    _notifications.value = _notifications.value
        .map((item) => item.copyWith(status: AppNotificationStatus.read))
        .toList(growable: false);
    _notify();
    try {
      await _useCases.markAllAsRead();
    } catch (_) {
      _userMessage.value = lookupAppLocalizations(
        _settingsController.locale,
      ).readStatusSaveError;
      _notify();
    }
  }

  Future<int> deleteReadNotifications() async {
    final count = readCount;
    _notifications.value = _notifications.value
        .where((item) => item.status == AppNotificationStatus.unread)
        .toList(growable: false);
    _viewState.value = _notifications.value.isEmpty
        ? NotificationViewState.empty
        : NotificationViewState.content;
    _notify();
    try {
      return await _useCases.deleteReadNotifications();
    } catch (_) {
      _userMessage.value = lookupAppLocalizations(
        _settingsController.locale,
      ).readNotificationsClearError;
      _notify();
      return count;
    }
  }

  void _queueEvaluation() {
    _evaluationPending = true;
    if (!_evaluating) unawaited(evaluateNow());
  }

  Future<void> _evaluate(DateTime now) async {
    final l10n = lookupAppLocalizations(_settingsController.locale);
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
        title: l10n.dailyGoalCompletedNotification,
        message: l10n.dailyGoalCompletedMessage,
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
        title: l10n.dailyGoalReminderTitle,
        message: l10n.dailyGoalReminderMessage(goal - displayed),
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
              ? l10n.campaignStepsRemaining(
                  ((campaign.targetSteps ?? 0) - enrollment.totalEligibleSteps)
                      .clamp(0, 1 << 31),
                )
              : l10n.goalDaysRemaining(
                  ((campaign.requiredGoalDays ?? 0) -
                          _campaignController.completedGoalDays(enrollment))
                      .clamp(0, 366),
                );
          await _create(
            now: now,
            key: 'campaign-ending:${enrollment.id}:$date',
            type: AppNotificationType.campaignEndingSoon,
            title: l10n.campaignEndingSoonNotification,
            message: remaining,
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
            title: l10n.campaignCompleted,
            message: l10n.campaignCompletedMessage(campaign.title),
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
              title: l10n.campaignRewardReadyTitle,
              message: l10n.campaignRewardReadyMessage(campaign.reward.title),
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
            title: l10n.pointsAddedTitle,
            message: l10n.pointsAddedMessage(transaction.amount),
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
            title: l10n.rewardExpiringSoonTitle,
            message: l10n.rewardExpiringSoonMessage(
              claim.rewardTitle,
              _friendlyDate(claim.expiresAt),
            ),
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
    if (_notifications.value.any((item) => item.idempotencyKey == key)) return;
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
    if (await _useCases.createIfAbsent(item)) {
      _notifications.value = <AppNotification>[item, ..._notifications.value];
    }
  }

  void _replaceInMemory(AppNotification notification) {
    _notifications.value = _notifications.value
        .map((item) => item.id == notification.id ? notification : item)
        .toList(growable: false);
  }

  void _notify() {
    if (!_disposed) refreshState();
  }

  static String _dateKey(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  static String _friendlyDate(DateTime value) =>
      '${value.day}.${value.month}.${value.year}';

  @override
  void onClose() {
    _disposed = true;
    for (final worker in _sourceWorkers) {
      worker.dispose();
    }
    super.onClose();
  }
}
