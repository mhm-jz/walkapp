import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../step_counter/presentation/step_counter_controller.dart';
import '../data/campaign_enrollment_repository.dart';
import '../data/campaign_repository.dart';
import '../domain/campaign.dart';
import '../domain/campaign_enrollment.dart';
import '../domain/campaign_enrollment_status.dart';
import '../domain/campaign_status.dart';
import '../domain/campaign_type.dart';

enum CampaignEnrollmentViewState { loading, ready, error }

enum CampaignJoinResult {
  joined,
  activeConflict,
  unavailable,
  alreadyCompleted,
  persistenceFailed,
}

final class CampaignEnrollmentController extends ChangeNotifier {
  CampaignEnrollmentController(
    this._enrollmentRepository,
    this._campaignRepository,
    this._stepController,
  );

  final CampaignEnrollmentRepository _enrollmentRepository;
  final CampaignRepository _campaignRepository;
  final StepCounterController _stepController;

  CampaignEnrollmentViewState _viewState = CampaignEnrollmentViewState.loading;
  List<Campaign> _campaigns = const <Campaign>[];
  List<CampaignEnrollment> _enrollments = const <CampaignEnrollment>[];
  String? _userMessage;
  Timer? _expirationTimer;
  bool _observing = false;
  bool _processingObservation = false;
  bool _observationPending = false;
  bool _disposed = false;

  CampaignEnrollmentViewState get viewState => _viewState;
  List<Campaign> get campaigns => _campaigns;
  List<CampaignEnrollment> get enrollments => _enrollments;
  String? get userMessage => _userMessage;
  StepCounterController get stepController => _stepController;

  CampaignEnrollment? get activeEnrollment {
    for (final enrollment in _enrollments.reversed) {
      if (enrollment.status == CampaignEnrollmentStatus.active) {
        return enrollment;
      }
    }
    return null;
  }

  CampaignEnrollment? get recentEnrollment {
    final active = activeEnrollment;
    if (active != null) return active;
    for (final enrollment in _enrollments.reversed) {
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

  int get completedEnrollmentCount => _enrollments
      .where(
        (enrollment) => enrollment.status == CampaignEnrollmentStatus.completed,
      )
      .length;

  Future<void> initialize() async {
    _viewState = CampaignEnrollmentViewState.loading;
    _userMessage = null;
    _notify();
    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        _campaignRepository.getCampaigns(),
        _enrollmentRepository.loadEnrollments(),
      ]);
      _campaigns = results[0] as List<Campaign>;
      _enrollments = results[1] as List<CampaignEnrollment>;
      _viewState = CampaignEnrollmentViewState.ready;
      if (!_observing) {
        _stepController.addListener(_queueConfirmedStepObservation);
        _observing = true;
      }
      await _expireIfNeeded();
      _scheduleExpiration();
    } catch (_) {
      _viewState = CampaignEnrollmentViewState.error;
      _userMessage =
          'Campaign enrollment could not be loaded. Please try again.';
    }
    _notify();
  }

  Campaign? campaignFor(CampaignEnrollment enrollment) {
    for (final campaign in _campaigns) {
      if (campaign.id == enrollment.campaignId) return campaign;
    }
    return null;
  }

  CampaignEnrollment? enrollmentFor(String campaignId) {
    for (final enrollment in _enrollments.reversed) {
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
      await _enrollmentRepository.saveEnrollment(enrollment);
      _replaceEnrollment(enrollment);
      _userMessage = null;
      _scheduleExpiration();
      _notify();
      return CampaignJoinResult.joined;
    } catch (_) {
      _userMessage =
          'The campaign could not be joined locally. Please try again.';
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
      await _enrollmentRepository.saveEnrollment(left);
      _replaceEnrollment(left);
      _expirationTimer?.cancel();
      _userMessage = null;
      _notify();
      return true;
    } catch (_) {
      _userMessage =
          'The campaign could not be left locally. Please try again.';
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
      await _enrollmentRepository.saveEnrollment(acknowledged);
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

  void clearUserMessage() => _userMessage = null;

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
      await _enrollmentRepository.saveEnrollment(updated);
      _replaceEnrollment(updated);
      if (updated.status == CampaignEnrollmentStatus.completed) {
        _expirationTimer?.cancel();
      }
      _notify();
    } catch (_) {
      _userMessage =
          'Campaign progress could not be saved. Tracking can continue while you retry.';
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
      _userMessage =
          'This saved campaign is not available on this device. Its local progress is preserved.';
      return;
    }
    if (!DateTime.now().isAfter(campaign.endAt)) return;
    final expired = enrollment.copyWith(
      status: CampaignEnrollmentStatus.expired,
    );
    try {
      await _enrollmentRepository.saveEnrollment(expired);
      _replaceEnrollment(expired);
      _expirationTimer?.cancel();
    } catch (_) {
      _userMessage =
          'The campaign status could not be updated locally. Please try again.';
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
    final mutable = _enrollments.toList();
    final index = mutable.indexWhere((item) => item.id == enrollment.id);
    if (index < 0) {
      mutable.add(enrollment);
    } else {
      mutable[index] = enrollment;
    }
    _enrollments = List<CampaignEnrollment>.unmodifiable(mutable);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  static String dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  @override
  void dispose() {
    _disposed = true;
    _expirationTimer?.cancel();
    if (_observing) {
      _stepController.removeListener(_queueConfirmedStepObservation);
    }
    super.dispose();
  }
}
