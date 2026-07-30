import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/preferences/app_settings_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../step_counter/presentation/step_counter_controller.dart';
import '../data/daily_step_history_repository.dart';
import '../domain/daily_step_record.dart';

enum DailyHistoryViewState { loading, ready, error }

final class DailyStepHistoryController extends ChangeNotifier {
  DailyStepHistoryController(
    this._repository,
    this._stepController,
    this._settingsController,
  );

  final DailyStepHistoryRepository _repository;
  final StepCounterController _stepController;
  final AppSettingsController _settingsController;

  DailyHistoryViewState _viewState = DailyHistoryViewState.loading;
  List<DailyStepRecord> _recentRecords = const <DailyStepRecord>[];
  int _lifetimeConfirmedSteps = 0;
  String? _userMessage;
  String? _observedDate;
  int _lastObservedConfirmed = 0;
  int _currentDayAccumulated = 0;
  bool _processing = false;
  bool _pending = false;
  bool _disposed = false;
  bool _observing = false;
  Timer? _rolloverTimer;

  DailyHistoryViewState get viewState => _viewState;
  List<DailyStepRecord> get recentRecords => _recentRecords;
  int get lifetimeConfirmedSteps => _lifetimeConfirmedSteps;
  String? get userMessage => _userMessage;

  List<DailyStepRecord> recordsForDays(int days, [DateTime? now]) {
    final end = dateOnly(now ?? DateTime.now());
    final start = end.subtract(Duration(days: days - 1));
    return _recentRecords
        .where((record) => record.date.compareTo(dateKey(start)) >= 0)
        .where((record) => record.date.compareTo(dateKey(end)) <= 0)
        .toList(growable: false);
  }

  Future<void> initialize() async {
    _viewState = DailyHistoryViewState.loading;
    _userMessage = null;
    _notify();
    try {
      final now = DateTime.now();
      final today = dateKey(now);
      final nonFinalized = await _repository.getNonFinalizedRecords();
      DailyStepRecord? previous;
      for (final record in nonFinalized) {
        if (record.date == today) continue;
        previous = record;
        await _repository.upsert(
          record.copyWith(
            isFinalized: true,
            finalizedAt: now,
            goalReached: record.confirmedSteps >= record.goalSnapshot,
            updatedAt: now,
          ),
        );
      }
      final existingToday = await _repository.getRecord(today);
      final currentConfirmed = _stepController.snapshot.confirmedSteps;
      final initialSteps =
          existingToday?.confirmedSteps ??
          (previous == null ? currentConfirmed : 0);
      final todayRecord = DailyStepRecord(
        date: today,
        confirmedSteps: initialSteps,
        goalSnapshot: _settingsController.dailyGoal,
        goalReached: initialSteps >= _settingsController.dailyGoal,
        updatedAt: now,
        isFinalized: false,
      );
      await _repository.upsert(todayRecord);
      _observedDate = today;
      _lastObservedConfirmed = currentConfirmed;
      _currentDayAccumulated = initialSteps;
      if (!_observing) {
        _stepController.addListener(_queueObservation);
        _settingsController.addListener(_queueObservation);
        _observing = true;
      }
      _viewState = DailyHistoryViewState.ready;
      await _reload();
      _scheduleRollover();
    } catch (_) {
      _viewState = DailyHistoryViewState.error;
      _userMessage = lookupAppLocalizations(
        _settingsController.locale,
      ).historyLoadControllerError;
    }
    _notify();
  }

  Future<void> retry() => initialize();

  Future<List<DailyStepRecord>> getRange(int days) async {
    final end = dateOnly(DateTime.now());
    final start = end.subtract(Duration(days: days - 1));
    return _repository.getRecordsBetween(dateKey(start), dateKey(end));
  }

  int totalFor(List<DailyStepRecord> records) =>
      records.fold(0, (total, record) => total + record.confirmedSteps);

  int activeDaysFor(List<DailyStepRecord> records) =>
      records.where((record) => record.confirmedSteps > 0).length;

  int goalDaysFor(List<DailyStepRecord> records) =>
      records.where((record) => record.goalReached).length;

  DailyStepRecord? bestDay(List<DailyStepRecord> records) {
    DailyStepRecord? best;
    for (final record in records) {
      if (record.confirmedSteps > 0 &&
          (best == null || record.confirmedSteps > best.confirmedSteps)) {
        best = record;
      }
    }
    return best;
  }

  int currentGoalStreak([DateTime? now]) {
    final byDate = <String, DailyStepRecord>{
      for (final record in _recentRecords) record.date: record,
    };
    var cursor = dateOnly(now ?? DateTime.now());
    var streak = 0;
    while (byDate[dateKey(cursor)]?.goalReached == true) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int longestGoalStreak() {
    final sorted = _recentRecords.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    var longest = 0;
    var current = 0;
    DateTime? previous;
    for (final record in sorted) {
      final date = parseDate(record.date);
      final consecutive =
          previous != null && date.difference(previous).inDays == 1;
      if (!consecutive) current = 0;
      if (record.goalReached) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
      previous = date;
    }
    return longest;
  }

  void _queueObservation() {
    _pending = true;
    if (_processing) return;
    unawaited(_process());
  }

  Future<void> _process() async {
    _processing = true;
    while (_pending && !_disposed) {
      _pending = false;
      await _observe();
    }
    _processing = false;
  }

  Future<void> _observe() async {
    final now = DateTime.now();
    final today = dateKey(now);
    final current = _stepController.snapshot.confirmedSteps;
    try {
      if (_observedDate != today) {
        await _rollover(now, current);
        return;
      }
      final existing = await _repository.getRecord(today);
      if (existing?.isFinalized == true) return;
      var accumulated = _currentDayAccumulated;
      if (current > _lastObservedConfirmed) {
        accumulated += current - _lastObservedConfirmed;
      }
      accumulated = mathMax(accumulated, existing?.confirmedSteps ?? 0);
      final goal = _settingsController.dailyGoal;
      final changed =
          existing == null ||
          existing.confirmedSteps != accumulated ||
          existing.goalSnapshot != goal;
      _lastObservedConfirmed = current;
      _currentDayAccumulated = accumulated;
      if (!changed) return;
      await _repository.upsert(
        DailyStepRecord(
          date: today,
          confirmedSteps: accumulated,
          goalSnapshot: goal,
          goalReached: accumulated >= goal,
          updatedAt: now,
          isFinalized: false,
        ),
      );
      _userMessage = null;
      await _reload();
      _notify();
    } catch (_) {
      _lastObservedConfirmed = current;
      _userMessage = lookupAppLocalizations(
        _settingsController.locale,
      ).historySaveControllerError;
      _notify();
    }
  }

  Future<void> _rollover(DateTime now, int currentConfirmed) async {
    final priorDate = _observedDate;
    if (priorDate != null) {
      final previous = await _repository.getRecord(priorDate);
      if (previous != null && !previous.isFinalized) {
        await _repository.upsert(
          previous.copyWith(
            isFinalized: true,
            finalizedAt: now,
            goalReached: previous.confirmedSteps >= previous.goalSnapshot,
            updatedAt: now,
          ),
        );
      }
    }
    final today = dateKey(now);
    final existing = await _repository.getRecord(today);
    _currentDayAccumulated = existing?.confirmedSteps ?? 0;
    _lastObservedConfirmed = currentConfirmed;
    _observedDate = today;
    await _repository.upsert(
      existing ??
          DailyStepRecord(
            date: today,
            confirmedSteps: 0,
            goalSnapshot: _settingsController.dailyGoal,
            goalReached: false,
            updatedAt: now,
            isFinalized: false,
          ),
    );
    await _reload();
    _scheduleRollover();
    _notify();
  }

  Future<void> _reload() async {
    final end = dateOnly(DateTime.now());
    final start = end.subtract(const Duration(days: 59));
    _recentRecords = await _repository.getRecordsBetween(
      dateKey(start),
      dateKey(end),
    );
    _lifetimeConfirmedSteps = await _repository.getLifetimeConfirmedSteps();
  }

  void _scheduleRollover() {
    _rolloverTimer?.cancel();
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _rolloverTimer = Timer(nextDay.difference(now), _queueObservation);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  static int mathMax(int a, int b) => a > b ? a : b;

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static String dateKey(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static DateTime parseDate(String value) =>
      DateTime.parse('${value}T00:00:00');

  @override
  void dispose() {
    _disposed = true;
    _rolloverTimer?.cancel();
    if (_observing) {
      _stepController.removeListener(_queueObservation);
      _settingsController.removeListener(_queueObservation);
    }
    super.dispose();
  }
}
