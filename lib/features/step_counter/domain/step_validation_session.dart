import 'step_validation_policy.dart';
import 'tracking_activity.dart';

enum RawStepStatus { baselineEstablished, ignored, provisionalAdded }

final class RawStepUpdate {
  const RawStepUpdate({
    required this.status,
    this.delta = 0,
    this.bucketIndex,
    this.startedWindow = false,
    this.appliedActivityEvidence,
    this.staleActivityEvidenceAge,
  });

  final RawStepStatus status;
  final int delta;
  final int? bucketIndex;
  final bool startedWindow;
  final AppliedActivityEvidence? appliedActivityEvidence;
  final Duration? staleActivityEvidenceAge;
}

final class AppliedActivityEvidence {
  const AppliedActivityEvidence({
    required this.activity,
    required this.confidence,
    required this.age,
    required this.bucketIndex,
    required this.bucketCandidateSteps,
  });

  final TrackingActivity activity;
  final TrackingConfidence confidence;
  final Duration age;
  final int bucketIndex;
  final int bucketCandidateSteps;
}

final class StepBucketSnapshot {
  const StepBucketSnapshot({
    required this.candidateSteps,
    required this.observedWalkingOrRunning,
    required this.observedVehicleOrBicycle,
    required this.bestWalkingConfidence,
  });

  final int candidateSteps;
  final bool observedWalkingOrRunning;
  final bool observedVehicleOrBicycle;
  final TrackingConfidence bestWalkingConfidence;
}

final class WindowValidationResult {
  const WindowValidationResult({
    required this.confirmedStepsAdded,
    required this.stepsRejected,
    required this.displayedStepsBefore,
    required this.displayedStepsAfter,
  });

  final int confirmedStepsAdded;
  final int stepsRejected;
  final int displayedStepsBefore;
  final int displayedStepsAfter;
}

/// Pure in-memory state machine for one active step-tracking session.
///
/// It has no dependency on timers, sensors, Hive, Flutter, or Android. The
/// foreground handler supplies event timestamps and schedules the one-shot
/// timer requested by [RawStepUpdate.startedWindow].
final class StepValidationSession {
  StepValidationSession({
    required int confirmedSteps,
    this.policy = const StepValidationPolicy(),
  }) : _confirmedSteps = confirmedSteps < 0 ? 0 : confirmedSteps,
       _buckets = List<_MutableStepBucket>.generate(
         policy.bucketCount,
         (_) => _MutableStepBucket(),
       );

  final StepValidationPolicy policy;
  final List<_MutableStepBucket> _buckets;

  int _confirmedSteps;
  int _provisionalSteps = 0;
  int? _lastRawSteps;
  DateTime? _windowStartedAt;
  TrackingActivity? _latestActivity;
  TrackingConfidence? _latestActivityConfidence;
  DateTime? _latestActivityTimestamp;

  int get confirmedSteps => _confirmedSteps;
  int get provisionalSteps => _provisionalSteps;
  int get displayedSteps => _confirmedSteps + _provisionalSteps;
  bool get sensorReady => _lastRawSteps != null;
  bool get hasActiveWindow => _windowStartedAt != null;
  DateTime? get windowStartedAt => _windowStartedAt;
  int? get lastRawSteps => _lastRawSteps;
  TrackingActivity? get latestActivity => _latestActivity;
  TrackingConfidence? get latestActivityConfidence => _latestActivityConfidence;
  DateTime? get latestActivityTimestamp => _latestActivityTimestamp;

  List<StepBucketSnapshot> get buckets {
    return List<StepBucketSnapshot>.unmodifiable(
      _buckets.map((bucket) => bucket.snapshot),
    );
  }

  bool isWindowExpired(DateTime timestamp) {
    final startedAt = _windowStartedAt;
    return startedAt != null &&
        !timestamp.isBefore(startedAt.add(policy.windowDuration));
  }

  RawStepUpdate recordRawReading({
    required int cumulativeRawSteps,
    required DateTime timestamp,
  }) {
    final previousRawSteps = _lastRawSteps;

    // Always move the baseline forward so resets and bad readings cannot be
    // accidentally counted by the next valid sensor event.
    _lastRawSteps = cumulativeRawSteps;

    if (previousRawSteps == null) {
      return const RawStepUpdate(status: RawStepStatus.baselineEstablished);
    }

    final delta = cumulativeRawSteps - previousRawSteps;
    if (!policy.isValidRawDelta(delta)) {
      return const RawStepUpdate(status: RawStepStatus.ignored);
    }

    if (isWindowExpired(timestamp)) {
      throw StateError('Complete the expired validation window first.');
    }

    final startedWindow = _windowStartedAt == null;
    _windowStartedAt ??= timestamp;
    final elapsed = timestamp.difference(_windowStartedAt!);
    final bucketIndex = policy.bucketIndex(elapsed);

    if (bucketIndex == null) {
      return const RawStepUpdate(status: RawStepStatus.ignored);
    }

    _buckets[bucketIndex].candidateSteps += delta;
    _provisionalSteps += delta;

    final evidenceResult = _applyLatestActivityEvidence(
      bucketIndex: bucketIndex,
      timestamp: timestamp,
    );

    return RawStepUpdate(
      status: RawStepStatus.provisionalAdded,
      delta: delta,
      bucketIndex: bucketIndex,
      startedWindow: startedWindow,
      appliedActivityEvidence: evidenceResult.applied,
      staleActivityEvidenceAge: evidenceResult.staleAge,
    );
  }

  bool recordActivity({
    required TrackingActivity activity,
    required TrackingConfidence confidence,
    required DateTime timestamp,
  }) {
    _latestActivity = activity;
    _latestActivityConfidence = confidence;
    _latestActivityTimestamp = timestamp;

    final startedAt = _windowStartedAt;
    if (startedAt == null || isWindowExpired(timestamp)) return false;

    final bucketIndex = policy.bucketIndex(timestamp.difference(startedAt));
    if (bucketIndex == null) return false;

    _buckets[bucketIndex].recordActivity(activity, confidence);
    return true;
  }

  int? bucketIndexAt(DateTime timestamp) {
    final startedAt = _windowStartedAt;
    if (startedAt == null || isWindowExpired(timestamp)) return null;
    return policy.bucketIndex(timestamp.difference(startedAt));
  }

  void recordActivityForBucket({
    required int bucketIndex,
    required TrackingActivity activity,
    required TrackingConfidence confidence,
  }) {
    if (bucketIndex < 0 || bucketIndex >= _buckets.length) {
      throw RangeError.index(bucketIndex, _buckets, 'bucketIndex');
    }
    _buckets[bucketIndex].recordActivity(activity, confidence);
  }

  WindowValidationResult completeWindow() {
    final displayedBefore = displayedSteps;
    var confirmedStepsAdded = 0;

    for (final bucket in _buckets) {
      if (policy.isValidBucket(
        observedWalkingOrRunning: bucket.observedWalkingOrRunning,
        observedVehicleOrBicycle: bucket.observedVehicleOrBicycle,
        bestWalkingConfidence: bucket.bestWalkingConfidence,
      )) {
        confirmedStepsAdded += bucket.candidateSteps;
      }
    }

    final rejectedSteps = _provisionalSteps - confirmedStepsAdded;
    _confirmedSteps += confirmedStepsAdded;
    _clearWindow();

    return WindowValidationResult(
      confirmedStepsAdded: confirmedStepsAdded,
      stepsRejected: rejectedSteps,
      displayedStepsBefore: displayedBefore,
      displayedStepsAfter: displayedSteps,
    );
  }

  int stop() {
    final discardedSteps = _provisionalSteps;
    _lastRawSteps = null;
    _latestActivity = null;
    _latestActivityConfidence = null;
    _latestActivityTimestamp = null;
    _clearWindow();
    return discardedSteps;
  }

  void reset() {
    _confirmedSteps = 0;
    _clearWindow();
  }

  void _clearWindow() {
    _provisionalSteps = 0;
    _windowStartedAt = null;
    for (final bucket in _buckets) {
      bucket.clear();
    }
  }

  _ActivityEvidenceResult _applyLatestActivityEvidence({
    required int bucketIndex,
    required DateTime timestamp,
  }) {
    final activity = _latestActivity;
    final confidence = _latestActivityConfidence;
    final evidenceTimestamp = _latestActivityTimestamp;
    if (activity == null || confidence == null || evidenceTimestamp == null) {
      return const _ActivityEvidenceResult();
    }

    final age = timestamp.difference(evidenceTimestamp);
    if (age.isNegative || age > policy.maximumActivityEvidenceAge) {
      return _ActivityEvidenceResult(staleAge: age);
    }

    recordActivityForBucket(
      bucketIndex: bucketIndex,
      activity: activity,
      confidence: confidence,
    );
    return _ActivityEvidenceResult(
      applied: AppliedActivityEvidence(
        activity: activity,
        confidence: confidence,
        age: age,
        bucketIndex: bucketIndex,
        bucketCandidateSteps: _buckets[bucketIndex].candidateSteps,
      ),
    );
  }
}

final class _ActivityEvidenceResult {
  const _ActivityEvidenceResult({this.applied, this.staleAge});

  final AppliedActivityEvidence? applied;
  final Duration? staleAge;
}

final class _MutableStepBucket {
  int candidateSteps = 0;
  bool observedWalkingOrRunning = false;
  bool observedVehicleOrBicycle = false;
  TrackingConfidence bestWalkingConfidence = TrackingConfidence.low;

  StepBucketSnapshot get snapshot => StepBucketSnapshot(
    candidateSteps: candidateSteps,
    observedWalkingOrRunning: observedWalkingOrRunning,
    observedVehicleOrBicycle: observedVehicleOrBicycle,
    bestWalkingConfidence: bestWalkingConfidence,
  );

  void recordActivity(
    TrackingActivity activity,
    TrackingConfidence confidence,
  ) {
    if (activity == TrackingActivity.inVehicle ||
        activity == TrackingActivity.onBicycle) {
      observedVehicleOrBicycle = true;
      return;
    }

    if (activity != TrackingActivity.walking &&
        activity != TrackingActivity.running) {
      return;
    }

    observedWalkingOrRunning = true;
    if (confidence.index > bestWalkingConfidence.index) {
      bestWalkingConfidence = confidence;
    }
  }

  void clear() {
    candidateSteps = 0;
    observedWalkingOrRunning = false;
    observedVehicleOrBicycle = false;
    bestWalkingConfidence = TrackingConfidence.low;
  }
}
