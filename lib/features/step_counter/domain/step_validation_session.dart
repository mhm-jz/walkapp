import 'step_validation_policy.dart';
import 'tracking_activity.dart';

enum RawStepStatus { baselineEstablished, ignored, provisionalAdded }

enum ActivityTransitionType {
  enter,
  exit;

  String get storageName => name.toUpperCase();
}

final class ActivityTransitionEvidence {
  const ActivityTransitionEvidence({
    required this.id,
    required this.sessionId,
    required this.activity,
    required this.transition,
    required this.eventElapsedRealtimeNanos,
    required this.receivedElapsedRealtimeNanos,
  });

  final String id;
  final String sessionId;
  final TrackingActivity activity;
  final ActivityTransitionType transition;
  final int eventElapsedRealtimeNanos;
  final int receivedElapsedRealtimeNanos;
}

final class StepCandidateSample {
  const StepCandidateSample({
    required this.delta,
    required this.sessionElapsedRealtimeNanos,
    required this.bucketIndex,
  });

  final int delta;
  final int sessionElapsedRealtimeNanos;
  final int bucketIndex;
}

final class RawStepUpdate {
  const RawStepUpdate({
    required this.status,
    this.delta = 0,
    this.bucketIndex,
    this.startedWindow = false,
    this.appliedActivityEvidence,
  });

  final RawStepStatus status;
  final int delta;
  final int? bucketIndex;
  final bool startedWindow;
  final AppliedActivityEvidence? appliedActivityEvidence;
}

/// Legacy API shape retained only so rollback-era callers continue to compile.
/// The active transition handler never creates this sampling evidence.
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

final class ActivityInterval {
  const ActivityInterval({
    required this.activity,
    required this.startElapsedRealtimeNanos,
    required this.endElapsedRealtimeNanos,
  });

  final TrackingActivity activity;
  final int startElapsedRealtimeNanos;
  final int endElapsedRealtimeNanos;
}

final class TransitionBucketValidation {
  const TransitionBucketValidation({
    required this.bucketIndex,
    required this.candidateSteps,
    required this.acceptedSteps,
    required this.rejectedSteps,
    required this.qualifyingIntervals,
    required this.disqualifyingIntervals,
  });

  final int bucketIndex;
  final int candidateSteps;
  final int acceptedSteps;
  final int rejectedSteps;
  final List<ActivityInterval> qualifyingIntervals;
  final List<ActivityInterval> disqualifyingIntervals;
}

final class WindowValidationResult {
  const WindowValidationResult({
    required this.windowStartElapsedRealtimeNanos,
    required this.windowEndElapsedRealtimeNanos,
    required this.confirmedStepsAdded,
    required this.stepsRejected,
    required this.displayedStepsBefore,
    required this.displayedStepsAfter,
    required this.buckets,
  });

  final int windowStartElapsedRealtimeNanos;
  final int windowEndElapsedRealtimeNanos;
  final int confirmedStepsAdded;
  final int stepsRejected;
  final int displayedStepsBefore;
  final int displayedStepsAfter;
  final List<TransitionBucketValidation> buckets;
}

/// In-memory transition-only validation state for one tracking session.
///
/// A batched Pedometer delta is intentionally assigned in full to the
/// callback's monotonic timestamp. No individual step times are invented.
final class StepValidationSession {
  StepValidationSession({
    required int confirmedSteps,
    this.policy = const StepValidationPolicy(),
  }) : _confirmedSteps = confirmedSteps < 0 ? 0 : confirmedSteps;

  final StepValidationPolicy policy;
  final List<ActivityTransitionEvidence> _transitions =
      <ActivityTransitionEvidence>[];
  final Set<String> _transitionIds = <String>{};
  late final List<_LegacyBucket> _legacyBuckets = List<_LegacyBucket>.generate(
    policy.bucketCount,
    (_) => _LegacyBucket(),
  );

  int _confirmedSteps;
  int _provisionalSteps = 0;
  int? _lastRawSteps;
  _CandidateWindow? _activeWindow;
  _CandidateWindow? _pendingWindow;
  TrackingActivity? _legacyActivity;
  TrackingConfidence? _legacyConfidence;
  DateTime? _legacyActivityTimestamp;

  int get confirmedSteps => _confirmedSteps;
  int get provisionalSteps => _provisionalSteps;
  int get displayedSteps => _confirmedSteps + _provisionalSteps;
  bool get sensorReady => _lastRawSteps != null;
  bool get hasActiveWindow => _activeWindow != null;
  bool get hasPendingWindow => _pendingWindow != null;
  int? get activeWindowStartElapsedRealtimeNanos =>
      _activeWindow?.startElapsedRealtimeNanos;
  int? get activeWindowEndElapsedRealtimeNanos =>
      _activeWindow?.endElapsedRealtimeNanos;
  int? get pendingWindowStartElapsedRealtimeNanos =>
      _pendingWindow?.startElapsedRealtimeNanos;
  int? get pendingWindowEndElapsedRealtimeNanos =>
      _pendingWindow?.endElapsedRealtimeNanos;
  int? get lastRawSteps => _lastRawSteps;
  List<StepBucketSnapshot> get buckets => List<StepBucketSnapshot>.unmodifiable(
    _legacyBuckets.map((bucket) => bucket.snapshot),
  );

  bool isActiveWindowExpired(int elapsedRealtimeNanos) {
    final window = _activeWindow;
    return window != null &&
        elapsedRealtimeNanos >= window.endElapsedRealtimeNanos;
  }

  RawStepUpdate recordRawReading({
    required int cumulativeRawSteps,
    int? elapsedRealtimeNanos,
    DateTime? timestamp,
  }) {
    final legacyElapsedNanos = timestamp == null
        ? null
        : timestamp.microsecondsSinceEpoch * 1000;
    final resolvedElapsedNanos = elapsedRealtimeNanos ?? legacyElapsedNanos;
    if (resolvedElapsedNanos == null) {
      throw ArgumentError(
        'elapsedRealtimeNanos is required for transition validation.',
      );
    }
    final previousRawSteps = _lastRawSteps;
    _lastRawSteps = cumulativeRawSteps;

    if (previousRawSteps == null) {
      return const RawStepUpdate(status: RawStepStatus.baselineEstablished);
    }

    final delta = cumulativeRawSteps - previousRawSteps;
    if (!policy.isValidRawDelta(delta)) {
      return const RawStepUpdate(status: RawStepStatus.ignored);
    }
    if (isActiveWindowExpired(resolvedElapsedNanos)) {
      throw StateError('Close the expired candidate window first.');
    }

    final startedWindow = _activeWindow == null;
    _activeWindow ??= _CandidateWindow(
      startElapsedRealtimeNanos: resolvedElapsedNanos,
      endElapsedRealtimeNanos:
          resolvedElapsedNanos + policy.windowDuration.inMicroseconds * 1000,
    );
    final window = _activeWindow!;
    final elapsedNanos =
        resolvedElapsedNanos - window.startElapsedRealtimeNanos;
    final bucketIndex =
        elapsedNanos ~/ (policy.bucketDuration.inMicroseconds * 1000);
    if (bucketIndex < 0 || bucketIndex >= policy.bucketCount) {
      return const RawStepUpdate(status: RawStepStatus.ignored);
    }

    window.samples.add(
      StepCandidateSample(
        delta: delta,
        sessionElapsedRealtimeNanos: resolvedElapsedNanos,
        bucketIndex: bucketIndex,
      ),
    );
    _provisionalSteps += delta;
    AppliedActivityEvidence? legacyEvidence;
    if (timestamp != null) {
      final bucket = _legacyBuckets[bucketIndex];
      bucket.candidateSteps += delta;
      final activity = _legacyActivity;
      final confidence = _legacyConfidence;
      final activityTimestamp = _legacyActivityTimestamp;
      if (activity != null &&
          confidence != null &&
          activityTimestamp != null &&
          !timestamp.isBefore(activityTimestamp)) {
        bucket.record(activity, confidence);
        legacyEvidence = AppliedActivityEvidence(
          activity: activity,
          confidence: confidence,
          age: timestamp.difference(activityTimestamp),
          bucketIndex: bucketIndex,
          bucketCandidateSteps: bucket.candidateSteps,
        );
      }
    }
    return RawStepUpdate(
      status: RawStepStatus.provisionalAdded,
      delta: delta,
      bucketIndex: bucketIndex,
      startedWindow: startedWindow,
      appliedActivityEvidence: legacyEvidence,
    );
  }

  /// Compatibility-only sampling API. The active StepTaskHandler never calls
  /// this method in the transition experiment.
  bool recordActivity({
    required TrackingActivity activity,
    required TrackingConfidence confidence,
    required DateTime timestamp,
  }) {
    _legacyActivity = activity;
    _legacyConfidence = confidence;
    _legacyActivityTimestamp = timestamp;
    final window = _activeWindow;
    if (window == null) return false;
    final elapsedNanos =
        timestamp.microsecondsSinceEpoch * 1000 -
        window.startElapsedRealtimeNanos;
    final bucketIndex =
        elapsedNanos ~/ (policy.bucketDuration.inMicroseconds * 1000);
    if (bucketIndex < 0 || bucketIndex >= policy.bucketCount) return false;
    _legacyBuckets[bucketIndex].record(activity, confidence);
    return true;
  }

  /// Compatibility-only whole-bucket completion for rollback-era callers.
  /// Transition runtime uses [finalizePendingWindow] exclusively.
  WindowValidationResult completeWindow() {
    final window = _activeWindow;
    if (window == null) {
      return WindowValidationResult(
        windowStartElapsedRealtimeNanos: 0,
        windowEndElapsedRealtimeNanos: 0,
        confirmedStepsAdded: 0,
        stepsRejected: 0,
        displayedStepsBefore: displayedSteps,
        displayedStepsAfter: displayedSteps,
        buckets: const <TransitionBucketValidation>[],
      );
    }
    final displayedBefore = displayedSteps;
    var accepted = 0;
    for (final bucket in _legacyBuckets) {
      if (bucket.observedWalkingOrRunning &&
          !bucket.observedVehicleOrBicycle &&
          bucket.bestWalkingConfidence != TrackingConfidence.low) {
        accepted += bucket.candidateSteps;
      }
    }
    final candidateTotal = window.samples.fold<int>(
      0,
      (total, sample) => total + sample.delta,
    );
    _confirmedSteps += accepted;
    _provisionalSteps -= candidateTotal;
    _activeWindow = null;
    _clearLegacyBuckets();
    return WindowValidationResult(
      windowStartElapsedRealtimeNanos: window.startElapsedRealtimeNanos,
      windowEndElapsedRealtimeNanos: window.endElapsedRealtimeNanos,
      confirmedStepsAdded: accepted,
      stepsRejected: candidateTotal - accepted,
      displayedStepsBefore: displayedBefore,
      displayedStepsAfter: displayedSteps,
      buckets: const <TransitionBucketValidation>[],
    );
  }

  void closeActiveWindow() {
    final window = _activeWindow;
    if (window == null) return;
    if (_pendingWindow != null) {
      throw StateError('Only one closed transition window may be pending.');
    }
    _activeWindow = null;
    _pendingWindow = window;
  }

  bool recordTransition(ActivityTransitionEvidence evidence) {
    if (!_transitionIds.add(evidence.id)) return false;
    _transitions.add(evidence);
    _transitions.sort(
      (left, right) => left.eventElapsedRealtimeNanos.compareTo(
        right.eventElapsedRealtimeNanos,
      ),
    );
    return true;
  }

  TrackingActivity activityAt(int elapsedRealtimeNanos) {
    final active = <TrackingActivity, bool>{
      for (final activity in _supportedActivities) activity: false,
    };
    for (final event in _transitions) {
      if (event.eventElapsedRealtimeNanos > elapsedRealtimeNanos) break;
      active[event.activity] = event.transition == ActivityTransitionType.enter;
    }
    if (active[TrackingActivity.inVehicle] ?? false) {
      return TrackingActivity.inVehicle;
    }
    if (active[TrackingActivity.onBicycle] ?? false) {
      return TrackingActivity.onBicycle;
    }
    if (active[TrackingActivity.running] ?? false) {
      return TrackingActivity.running;
    }
    if (active[TrackingActivity.walking] ?? false) {
      return TrackingActivity.walking;
    }
    if (active[TrackingActivity.still] ?? false) {
      return TrackingActivity.still;
    }
    return TrackingActivity.unknown;
  }

  WindowValidationResult? finalizePendingWindow() {
    final window = _pendingWindow;
    if (window == null) return null;
    _pendingWindow = null;

    final displayedBefore = displayedSteps;
    final qualifying = _intervalsForWindow(window, const <TrackingActivity>{
      TrackingActivity.walking,
      TrackingActivity.running,
    });
    final disqualifying = _intervalsForWindow(window, const <TrackingActivity>{
      TrackingActivity.inVehicle,
      TrackingActivity.onBicycle,
    });
    final bucketResults = <TransitionBucketValidation>[];
    var acceptedTotal = 0;
    var candidateTotal = 0;

    for (var bucketIndex = 0; bucketIndex < policy.bucketCount; bucketIndex++) {
      final samples = window.samples
          .where((sample) => sample.bucketIndex == bucketIndex)
          .toList(growable: false);
      final bucketStart =
          window.startElapsedRealtimeNanos +
          bucketIndex * policy.bucketDuration.inMicroseconds * 1000;
      final bucketEnd =
          bucketStart + policy.bucketDuration.inMicroseconds * 1000;
      final candidateSteps = samples.fold<int>(
        0,
        (total, sample) => total + sample.delta,
      );
      final acceptedSteps = samples.fold<int>(
        0,
        (total, sample) =>
            total +
            (_isAcceptedAt(sample.sessionElapsedRealtimeNanos)
                ? sample.delta
                : 0),
      );
      candidateTotal += candidateSteps;
      acceptedTotal += acceptedSteps;
      bucketResults.add(
        TransitionBucketValidation(
          bucketIndex: bucketIndex,
          candidateSteps: candidateSteps,
          acceptedSteps: acceptedSteps,
          rejectedSteps: candidateSteps - acceptedSteps,
          qualifyingIntervals: _clipIntervals(
            qualifying,
            bucketStart,
            bucketEnd,
          ),
          disqualifyingIntervals: _clipIntervals(
            disqualifying,
            bucketStart,
            bucketEnd,
          ),
        ),
      );
    }

    _confirmedSteps += acceptedTotal;
    _provisionalSteps -= candidateTotal;
    if (_provisionalSteps < 0) {
      throw StateError('Provisional steps became negative.');
    }
    return WindowValidationResult(
      windowStartElapsedRealtimeNanos: window.startElapsedRealtimeNanos,
      windowEndElapsedRealtimeNanos: window.endElapsedRealtimeNanos,
      confirmedStepsAdded: acceptedTotal,
      stepsRejected: candidateTotal - acceptedTotal,
      displayedStepsBefore: displayedBefore,
      displayedStepsAfter: displayedSteps,
      buckets: List<TransitionBucketValidation>.unmodifiable(bucketResults),
    );
  }

  int stop() {
    final discardedSteps = _provisionalSteps;
    _lastRawSteps = null;
    _clearTransientState();
    return discardedSteps;
  }

  void reset() {
    _confirmedSteps = 0;
    _clearTransientState();
  }

  void _clearTransientState() {
    _provisionalSteps = 0;
    _activeWindow = null;
    _pendingWindow = null;
    _transitions.clear();
    _transitionIds.clear();
    _legacyActivity = null;
    _legacyConfidence = null;
    _legacyActivityTimestamp = null;
    _clearLegacyBuckets();
  }

  void _clearLegacyBuckets() {
    for (final bucket in _legacyBuckets) {
      bucket.clear();
    }
  }

  bool _isAcceptedAt(int elapsedRealtimeNanos) {
    final qualifying =
        _isActivityActive(TrackingActivity.walking, elapsedRealtimeNanos) ||
        _isActivityActive(TrackingActivity.running, elapsedRealtimeNanos);
    final disqualifying =
        _isActivityActive(TrackingActivity.inVehicle, elapsedRealtimeNanos) ||
        _isActivityActive(TrackingActivity.onBicycle, elapsedRealtimeNanos);
    return qualifying && !disqualifying;
  }

  bool _isActivityActive(TrackingActivity activity, int elapsedRealtimeNanos) {
    var active = false;
    for (final event in _transitions) {
      if (event.eventElapsedRealtimeNanos > elapsedRealtimeNanos) break;
      if (event.activity == activity) {
        active = event.transition == ActivityTransitionType.enter;
      }
    }
    return active;
  }

  List<ActivityInterval> _intervalsForWindow(
    _CandidateWindow window,
    Set<TrackingActivity> activities,
  ) {
    final intervals = <ActivityInterval>[];
    for (final activity in activities) {
      int? activeStart;
      for (final event in _transitions.where(
        (event) => event.activity == activity,
      )) {
        if (event.transition == ActivityTransitionType.enter) {
          activeStart ??= event.eventElapsedRealtimeNanos;
        } else if (activeStart != null) {
          intervals.add(
            ActivityInterval(
              activity: activity,
              startElapsedRealtimeNanos: activeStart,
              endElapsedRealtimeNanos: event.eventElapsedRealtimeNanos,
            ),
          );
          activeStart = null;
        }
      }
      if (activeStart != null) {
        intervals.add(
          ActivityInterval(
            activity: activity,
            startElapsedRealtimeNanos: activeStart,
            endElapsedRealtimeNanos: window.endElapsedRealtimeNanos,
          ),
        );
      }
    }
    return _clipIntervals(
      intervals,
      window.startElapsedRealtimeNanos,
      window.endElapsedRealtimeNanos,
    );
  }

  List<ActivityInterval> _clipIntervals(
    List<ActivityInterval> intervals,
    int start,
    int end,
  ) {
    return intervals
        .where(
          (interval) =>
              interval.startElapsedRealtimeNanos < end &&
              interval.endElapsedRealtimeNanos > start,
        )
        .map(
          (interval) => ActivityInterval(
            activity: interval.activity,
            startElapsedRealtimeNanos:
                interval.startElapsedRealtimeNanos < start
                ? start
                : interval.startElapsedRealtimeNanos,
            endElapsedRealtimeNanos: interval.endElapsedRealtimeNanos > end
                ? end
                : interval.endElapsedRealtimeNanos,
          ),
        )
        .toList(growable: false);
  }
}

final class _CandidateWindow {
  _CandidateWindow({
    required this.startElapsedRealtimeNanos,
    required this.endElapsedRealtimeNanos,
  });

  final int startElapsedRealtimeNanos;
  final int endElapsedRealtimeNanos;
  final List<StepCandidateSample> samples = <StepCandidateSample>[];
}

const Set<TrackingActivity> _supportedActivities = <TrackingActivity>{
  TrackingActivity.walking,
  TrackingActivity.running,
  TrackingActivity.still,
  TrackingActivity.onBicycle,
  TrackingActivity.inVehicle,
};

final class _LegacyBucket {
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

  void record(TrackingActivity activity, TrackingConfidence confidence) {
    if (activity == TrackingActivity.inVehicle ||
        activity == TrackingActivity.onBicycle) {
      observedVehicleOrBicycle = true;
    } else if (activity == TrackingActivity.walking ||
        activity == TrackingActivity.running) {
      observedWalkingOrRunning = true;
      if (confidence.index > bestWalkingConfidence.index) {
        bestWalkingConfidence = confidence;
      }
    }
  }

  void clear() {
    candidateSteps = 0;
    observedWalkingOrRunning = false;
    observedVehicleOrBicycle = false;
    bestWalkingConfidence = TrackingConfidence.low;
  }
}
