import 'dart:async';
import 'package:get/get.dart';

import '../../../../core/presentation/reactive_controller.dart';

import '../../../../core/preferences/app_settings_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../step_counter/presentation/getx/step_counter_controller.dart';
import '../../domain/campaign.dart';
import '../../domain/campaign_enrollment.dart';
import '../../domain/campaign_enrollment_status.dart';
import '../../domain/campaign_status.dart';
import '../../domain/campaign_type.dart';
import '../../domain/usecases/campaign_use_cases.dart';

enum CampaignEnrollmentViewState { loading, ready, error }

enum CampaignJoinResult {
  joined,
  activeConflict,
  unavailable,
  alreadyCompleted,
  persistenceFailed,
}

final class CampaignEnrollmentController extends ReactiveController {
  CampaignEnrollmentController(
    this._useCases,
    this._stepController,
    this._settingsController,
  );

  final CampaignUseCases _useCases;
  final StepCounterController _stepController;
  final AppSettingsController _settingsController;

  AppLocalizations get _l10n =>
      lookupAppLocalizations(_settingsController.locale);

  final Rx<CampaignEnrollmentViewState> _viewState =
      CampaignEnrollmentViewState.loading.obs;
  final Rx<List<Campaign>> _campaigns = Rx<List<Campaign>>(const <Campaign>[]);
  final Rx<List<CampaignEnrollment>> _enrollments =
      Rx<List<CampaignEnrollment>>(const <CampaignEnrollment>[]);
  final RxnString _userMessage = RxnString();
  Timer? _expirationTimer;
  Worker? _stepWorker;
  bool _processingObservation = false;
  bool _observationPending = false;
  bool _disposed = false;

  CampaignEnrollmentViewState get viewState => _viewState.value;
  List<Campaign> get campaigns => _campaigns.value;
  List<CampaignEnrollment> get enrollments => _enrollments.value;
  String? get userMessage => _userMessage.value;
  StepCounterController get stepController => _stepController;

  CampaignEnrollment? get activeEnrollment {
    for (final enrollment in _enrollments.value.reversed) {
      if (enrollment.status == CampaignEnrollmentStatus.active) {
        return enrollment;
      }
    }
    return null;
  }

  CampaignEnrollment? get recentEnrollment {
    final active = activeEnrollment;
    if (active != null) return active;
    for (final enrollment in _enrollments.value.reversed) {
      if (enrollment.status == CampaignEnrollmentStatus.completed ||
          enrollment.status == CampaignEnrollmentStatus.expired) {
        return enrollment;
      }
    }
    return null;
  }

  Campaign? get activeCampaign {
    final enrollment = activeEnrollment;
    return enrollment == null ? null : campaignFor(enrollment);
  }

  int get completedEnrollmentCount => _enrollments.value
      .where(
        (enrollment) => enrollment.status == CampaignEnrollmentStatus.completed,
      )
      .length;

  Future<void> initialize() async {
    _viewState.value = CampaignEnrollmentViewState.loading;
    _userMessage.value = null;
    _notify();
    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        _useCases.getCampaigns(),
        _useCases.loadEnrollments(),
      ]);
      _campaigns.value = results[0] as List<Campaign>;
      _enrollments.value = results[1] as List<CampaignEnrollment>;
      _viewState.value = CampaignEnrollmentViewState.ready;
      _stepWorker ??= _stepController.watch(_queueConfirmedStepObservation);
      await _expireIfNeeded();
      _scheduleExpiration();
    } catch (_) {
      _viewState.value = CampaignEnrollmentViewState.error;
      _userMessage.value = _l10n.campaignEnrollmentError;
    }
    _notify();
  }

  Campaign? campaignFor(CampaignEnrollment enrollment) {
    for (final campaign in _campaigns.value) {
      if (campaign.id == enrollment.campaignId) return campaign;
    }
    return null;
  }

  CampaignEnrollment? enrollmentFor(String campaignId) {
    for (final enrollment in _enrollments.value.reversed) {
      if (enrollment.campaignId == campaignId) return enrollment;
    }
    return null;
  }

  Future<CampaignJoinResult> join(
    Campaign campaign, {
    required int currentDailyGoal,
  }) async {
    await _expireIfNeeded();
    if (activeEnrollment != null) return CampaignJoinResult.activeConflict;
    final previous = enrollmentFor(campaign.id);
    if (previous?.status == CampaignEnrollmentStatus.completed) {
      return CampaignJoinResult.alreadyCompleted;
    }
    final now = DateTime.now();
    final availability = campaign.statusAt(now);
    if ((availability != CampaignStatus.available &&
            availability != CampaignStatus.endingSoon) ||
        now.isBefore(campaign.startAt) ||
        now.isAfter(campaign.endAt)) {
      return CampaignJoinResult.unavailable;
    }

    final enrollment = CampaignEnrollment(
      id: '${campaign.id}-${now.microsecondsSinceEpoch}',
      campaignId: campaign.id,
      joinedAt: now,
      status: CampaignEnrollmentStatus.active,
      goalAtEnrollment: campaign.type == CampaignType.dailyGoalConsistency
          ? currentDailyGoal
          : null,
      eligibleStepsByDate: const <String, int>{},
      totalEligibleSteps: 0,
      lastObservedConfirmedSteps: _stepController.snapshot.confirmedSteps,
      lastObservedDate: dateKey(now),
    );
    try {
      await _useCases.saveEnrollment(enrollment);
      _replaceEnrollment(enrollment);
      _userMessage.value = null;
      _scheduleExpiration();
      _notify();
      return CampaignJoinResult.joined;
    } catch (_) {
      _userMessage.value = _l10n.campaignJoinLocalError;
      _notify();
      return CampaignJoinResult.persistenceFailed;
    }
  }

  Future<bool> leaveActiveCampaign() async {
    final enrollment = activeEnrollment;
    if (enrollment == null) return false;
    final left = enrollment.copyWith(
      status: CampaignEnrollmentStatus.left,
      leftAt: DateTime.now(),
    );
    try {
      await _useCases.saveEnrollment(left);
      _replaceEnrollment(left);
      _expirationTimer?.cancel();
      _userMessage.value = null;
      _notify();
      return true;
    } catch (_) {
      _userMessage.value = _l10n.campaignLeaveLocalError;
      _notify();
      return false;
    }
  }

  Future<void> acknowledgeCompletion() async {
    final enrollment = recentEnrollment;
    if (enrollment == null ||
        enrollment.status != CampaignEnrollmentStatus.completed ||
        enrollment.completionAcknowledged) {
      return;
    }
    final acknowledged = enrollment.copyWith(completionAcknowledged: true);
    try {
      await _useCases.saveEnrollment(acknowledged);
      _replaceEnrollment(acknowledged);
      _notify();
    } catch (_) {
      // A failed acknowledgement can safely be retried on the next page visit.
    }
  }

  int eligibleStepsToday(CampaignEnrollment enrollment, [DateTime? now]) =>
      enrollment.eligibleStepsByDate[dateKey(now ?? DateTime.now())] ?? 0;

  int completedGoalDays(CampaignEnrollment enrollment) {
    final goal = enrollment.goalAtEnrollment;
    if (goal == null || goal <= 0) return 0;
    return enrollment.eligibleStepsByDate.values
        .where((steps) => steps >= goal)
        .length;
  }

  double progressFor(Campaign campaign, CampaignEnrollment enrollment) {
    if (campaign.type == CampaignType.stepTarget) {
      final target = campaign.targetSteps ?? 1;
      return (enrollment.totalEligibleSteps / target).clamp(0, 1);
    }
    final requiredDays = campaign.requiredGoalDays ?? 1;
    return (completedGoalDays(enrollment) / requiredDays).clamp(0, 1);
  }

  void clearUserMessage() => _userMessage.value = null;

  void _queueConfirmedStepObservation() {
    _observationPending = true;
    if (_processingObservation) return;
    unawaited(_processObservations());
  }

  Future<void> _processObservations() async {
    _processingObservation = true;
    while (_observationPending && !_disposed) {
      _observationPending = false;
      await _observeConfirmedSteps();
    }
    _processingObservation = false;
  }

  Future<void> _observeConfirmedSteps() async {
    await _expireIfNeeded();
    final enrollment = activeEnrollment;
    final campaign = activeCampaign;
    if (enrollment == null || campaign == null) return;

    final now = DateTime.now();
    final today = dateKey(now);
    final current = _stepController.snapshot.confirmedSteps;
    var delta = 0;
    if (today == enrollment.lastObservedDate) {
      if (current > enrollment.lastObservedConfirmedSteps) {
        delta = current - enrollment.lastObservedConfirmedSteps;
      }
    } else {
      // The existing health counter is daily. Its current value belongs to the
      // newly observed local date; prior campaign dates remain untouched.
      delta = current > 0 ? current : 0;
    }

    final byDate = Map<String, int>.of(enrollment.eligibleStepsByDate);
    if (delta > 0) byDate[today] = (byDate[today] ?? 0) + delta;
    if (delta == 0 &&
        current == enrollment.lastObservedConfirmedSteps &&
        today == enrollment.lastObservedDate) {
      return;
    }
    var updated = enrollment.copyWith(
      eligibleStepsByDate: byDate,
      totalEligibleSteps: enrollment.totalEligibleSteps + delta,
      lastObservedConfirmedSteps: current,
      lastObservedDate: today,
    );
    if (_isComplete(campaign, updated)) {
      updated = updated.copyWith(
        status: CampaignEnrollmentStatus.completed,
        completedAt: now,
      );
    }
    if (updated == enrollment) return;
    try {
      await _useCases.saveEnrollment(updated);
      _replaceEnrollment(updated);
      if (updated.status == CampaignEnrollmentStatus.completed) {
        _expirationTimer?.cancel();
      }
      _notify();
    } catch (_) {
      _userMessage.value = _l10n.campaignProgressSaveError;
      _notify();
    }
  }

  bool _isComplete(Campaign campaign, CampaignEnrollment enrollment) {
    return switch (campaign.type) {
      CampaignType.stepTarget =>
        enrollment.totalEligibleSteps >= (campaign.targetSteps ?? 1),
      CampaignType.dailyGoalConsistency =>
        completedGoalDays(enrollment) >= (campaign.requiredGoalDays ?? 1),
    };
  }

  Future<void> _expireIfNeeded() async {
    final enrollment = activeEnrollment;
    if (enrollment == null) return;
    final campaign = campaignFor(enrollment);
    if (campaign == null) {
      _userMessage.value = _l10n.savedCampaignDeviceUnavailable;
      return;
    }
    if (!DateTime.now().isAfter(campaign.endAt)) return;
    final expired = enrollment.copyWith(
      status: CampaignEnrollmentStatus.expired,
    );
    try {
      await _useCases.saveEnrollment(expired);
      _replaceEnrollment(expired);
      _expirationTimer?.cancel();
    } catch (_) {
      _userMessage.value = _l10n.campaignStatusUpdateError;
    }
  }

  void _scheduleExpiration() {
    _expirationTimer?.cancel();
    final campaign = activeCampaign;
    if (campaign == null) return;
    final delay = campaign.endAt.difference(DateTime.now());
    if (delay <= Duration.zero) {
      unawaited(_expireAndNotify());
      return;
    }
    _expirationTimer = Timer(delay, _expireAndNotify);
  }

  Future<void> _expireAndNotify() async {
    await _expireIfNeeded();
    _notify();
  }

  void _replaceEnrollment(CampaignEnrollment enrollment) {
    final mutable = _enrollments.value.toList();
    final index = mutable.indexWhere((item) => item.id == enrollment.id);
    if (index < 0) {
      mutable.add(enrollment);
    } else {
      mutable[index] = enrollment;
    }
    _enrollments.value = List<CampaignEnrollment>.unmodifiable(mutable);
  }

  void _notify() {
    if (!_disposed) refreshState();
  }

  static String dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  @override
  void onClose() {
    _disposed = true;
    _expirationTimer?.cancel();
    _stepWorker?.dispose();
    super.onClose();
  }
}
