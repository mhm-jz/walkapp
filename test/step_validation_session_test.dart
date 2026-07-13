import 'package:flutter_test/flutter_test.dart';
import 'package:walkingapp/features/step_counter/domain/step_validation_session.dart';
import 'package:walkingapp/features/step_counter/domain/tracking_activity.dart';

void main() {
  final origin = DateTime.utc(2026, 7, 13, 10);

  test('first pedometer value establishes only the baseline', () {
    final session = StepValidationSession(confirmedSteps: 10);

    final update = session.recordRawReading(
      cumulativeRawSteps: 1000,
      timestamp: origin,
    );

    expect(update.status, RawStepStatus.baselineEstablished);
    expect(session.confirmedSteps, 10);
    expect(session.provisionalSteps, 0);
    expect(session.displayedSteps, 10);
    expect(session.hasActiveWindow, isFalse);
  });

  test('raw delta immediately increases provisional and displayed steps', () {
    final session = _sessionWithBaseline(origin, confirmedSteps: 100);

    final update = session.recordRawReading(
      cumulativeRawSteps: 1020,
      timestamp: origin.add(const Duration(seconds: 1)),
    );

    expect(update.status, RawStepStatus.provisionalAdded);
    expect(update.startedWindow, isTrue);
    expect(session.provisionalSteps, 20);
    expect(session.displayedSteps, 120);
    expect(session.confirmedSteps, 100);
  });

  test('fresh walking evidence before first step validates new bucket', () {
    final session = _sessionWithBaseline(origin);
    final activityTime = origin.add(const Duration(seconds: 1));

    final appliedImmediately = session.recordActivity(
      activity: TrackingActivity.walking,
      confidence: TrackingConfidence.high,
      timestamp: activityTime,
    );
    final update = session.recordRawReading(
      cumulativeRawSteps: 1010,
      timestamp: activityTime.add(const Duration(seconds: 1)),
    );
    final result = session.completeWindow();

    expect(appliedImmediately, isFalse);
    expect(update.appliedActivityEvidence, isNotNull);
    expect(update.appliedActivityEvidence!.bucketIndex, 0);
    expect(result.confirmedStepsAdded, 10);
  });

  test('one fresh walking event is reused across all three buckets', () {
    final session = _sessionWithBaseline(origin);
    final activityTime = origin.add(const Duration(seconds: 1));
    final windowStart = origin.add(const Duration(seconds: 2));
    session.recordActivity(
      activity: TrackingActivity.walking,
      confidence: TrackingConfidence.high,
      timestamp: activityTime,
    );

    final first = session.recordRawReading(
      cumulativeRawSteps: 1005,
      timestamp: windowStart,
    );
    final second = session.recordRawReading(
      cumulativeRawSteps: 1012,
      timestamp: windowStart.add(const Duration(seconds: 11)),
    );
    final third = session.recordRawReading(
      cumulativeRawSteps: 1020,
      timestamp: windowStart.add(const Duration(seconds: 21)),
    );
    final result = session.completeWindow();

    expect(first.appliedActivityEvidence?.bucketIndex, 0);
    expect(second.appliedActivityEvidence?.bucketIndex, 1);
    expect(third.appliedActivityEvidence?.bucketIndex, 2);
    expect(result.confirmedStepsAdded, 20);
    expect(result.stepsRejected, 0);
  });

  test('stale walking evidence does not validate a new bucket', () {
    final session = _sessionWithBaseline(origin);
    session.recordActivity(
      activity: TrackingActivity.walking,
      confidence: TrackingConfidence.high,
      timestamp: origin,
    );

    final update = session.recordRawReading(
      cumulativeRawSteps: 1010,
      timestamp: origin.add(const Duration(seconds: 31)),
    );
    final result = session.completeWindow();

    expect(update.appliedActivityEvidence, isNull);
    expect(update.staleActivityEvidenceAge, const Duration(seconds: 31));
    expect(result.confirmedStepsAdded, 0);
    expect(result.stepsRejected, 10);
  });

  test('steps enter the correct ten-second buckets', () {
    final session = _sessionWithBaseline(origin);
    final windowStart = origin.add(const Duration(seconds: 1));

    session.recordRawReading(cumulativeRawSteps: 1005, timestamp: windowStart);
    session.recordRawReading(
      cumulativeRawSteps: 1012,
      timestamp: windowStart.add(const Duration(seconds: 10)),
    );
    session.recordRawReading(
      cumulativeRawSteps: 1021,
      timestamp: windowStart.add(const Duration(seconds: 20)),
    );

    expect(session.buckets.map((bucket) => bucket.candidateSteps), <int>[
      5,
      7,
      9,
    ]);
  });

  test('walking bucket with sufficient confidence is confirmed', () {
    final session = _sessionWithBaseline(origin, confirmedSteps: 50);
    final windowStart = origin.add(const Duration(seconds: 1));
    session.recordRawReading(cumulativeRawSteps: 1010, timestamp: windowStart);
    session.recordActivity(
      activity: TrackingActivity.walking,
      confidence: TrackingConfidence.medium,
      timestamp: windowStart.add(const Duration(seconds: 2)),
    );

    final result = session.completeWindow();

    expect(result.confirmedStepsAdded, 10);
    expect(result.stepsRejected, 0);
    expect(result.displayedStepsBefore, 60);
    expect(result.displayedStepsAfter, 60);
    expect(session.confirmedSteps, 60);
    expect(session.provisionalSteps, 0);
    expect(session.displayedSteps, 60);
  });

  test('vehicle evidence rejects its bucket', () {
    final session = _sessionWithBaseline(origin);
    final windowStart = origin.add(const Duration(seconds: 1));
    session.recordRawReading(cumulativeRawSteps: 1010, timestamp: windowStart);
    session.recordActivity(
      activity: TrackingActivity.walking,
      confidence: TrackingConfidence.high,
      timestamp: windowStart.add(const Duration(seconds: 2)),
    );
    session.recordActivity(
      activity: TrackingActivity.inVehicle,
      confidence: TrackingConfidence.high,
      timestamp: windowStart.add(const Duration(seconds: 3)),
    );

    final result = session.completeWindow();

    expect(result.confirmedStepsAdded, 0);
    expect(result.stepsRejected, 10);
  });

  test('mixed valid and invalid buckets confirm only valid steps', () {
    final session = _sessionWithBaseline(origin, confirmedSteps: 100);
    final windowStart = origin.add(const Duration(seconds: 1));

    _addBucketEvidence(
      session,
      rawSteps: 1005,
      timestamp: windowStart,
      activity: TrackingActivity.walking,
    );
    _addBucketEvidence(
      session,
      rawSteps: 1013,
      timestamp: windowStart.add(const Duration(seconds: 11)),
      activity: TrackingActivity.inVehicle,
    );
    _addBucketEvidence(
      session,
      rawSteps: 1020,
      timestamp: windowStart.add(const Duration(seconds: 21)),
      activity: TrackingActivity.unknown,
    );

    final result = session.completeWindow();

    expect(result.confirmedStepsAdded, 5);
    expect(result.stepsRejected, 15);
    expect(session.confirmedSteps, 105);
  });

  test('validation correction decreases displayed count', () {
    final session = _sessionWithBaseline(origin, confirmedSteps: 100);
    final windowStart = origin.add(const Duration(seconds: 1));
    session.recordRawReading(cumulativeRawSteps: 1020, timestamp: windowStart);
    session.recordActivity(
      activity: TrackingActivity.still,
      confidence: TrackingConfidence.high,
      timestamp: windowStart.add(const Duration(seconds: 2)),
    );

    expect(session.displayedSteps, 120);
    final result = session.completeWindow();

    expect(result.displayedStepsBefore, 120);
    expect(result.displayedStepsAfter, 100);
    expect(session.displayedSteps, 100);
  });

  test('stopping before validation discards provisional steps', () {
    final session = _sessionWithBaseline(origin, confirmedSteps: 100);
    session.recordRawReading(
      cumulativeRawSteps: 1020,
      timestamp: origin.add(const Duration(seconds: 1)),
    );

    final discarded = session.stop();

    expect(discarded, 20);
    expect(session.confirmedSteps, 100);
    expect(session.provisionalSteps, 0);
    expect(session.displayedSteps, 100);
    expect(session.sensorReady, isFalse);
  });

  test('invalid raw reading does not discard an active window', () {
    final session = _sessionWithBaseline(origin, confirmedSteps: 100);
    final windowStart = origin.add(const Duration(seconds: 1));
    session.recordRawReading(cumulativeRawSteps: 1010, timestamp: windowStart);

    final update = session.recordRawReading(
      cumulativeRawSteps: 900,
      timestamp: windowStart.add(const Duration(seconds: 2)),
    );

    expect(update.status, RawStepStatus.ignored);
    expect(session.provisionalSteps, 10);
    expect(session.buckets.first.candidateSteps, 10);
  });
}

StepValidationSession _sessionWithBaseline(
  DateTime origin, {
  int confirmedSteps = 0,
}) {
  final session = StepValidationSession(confirmedSteps: confirmedSteps);
  session.recordRawReading(cumulativeRawSteps: 1000, timestamp: origin);
  return session;
}

void _addBucketEvidence(
  StepValidationSession session, {
  required int rawSteps,
  required DateTime timestamp,
  required TrackingActivity activity,
}) {
  session.recordRawReading(cumulativeRawSteps: rawSteps, timestamp: timestamp);
  session.recordActivity(
    activity: activity,
    confidence: TrackingConfidence.high,
    timestamp: timestamp.add(const Duration(milliseconds: 1)),
  );
}
