import 'package:flutter_test/flutter_test.dart';
import 'package:walkingapp/features/step_counter/data/step_snapshot.dart';
import 'package:walkingapp/features/step_counter/domain/step_validation_session.dart';
import 'package:walkingapp/features/step_counter/domain/tracking_activity.dart';

void main() {
  test('transport snapshot includes provisional and displayed steps', () {
    final snapshot = _snapshot(confirmedSteps: 120, provisionalSteps: 3);

    final restored = StepSnapshot.fromMap(snapshot.toMap());

    expect(restored.confirmedSteps, 120);
    expect(restored.provisionalSteps, 3);
    expect(restored.displayedSteps, 123);
    expect(restored.activity, TrackingActivity.walking);
    expect(restored.confidence, TrackingConfidence.high);
  });

  test('durable snapshot excludes provisional validation state', () {
    final snapshot = _snapshot(confirmedSteps: 120, provisionalSteps: 8);
    final persistedMap = snapshot.toPersistedMap();

    expect(persistedMap, isNot(contains('provisionalSteps')));
    expect(persistedMap, isNot(contains('sensorReady')));
    expect(persistedMap, isNot(contains('activity')));

    final restored = StepSnapshot.fromPersistedMap(persistedMap);
    expect(restored.confirmedSteps, 120);
    expect(restored.provisionalSteps, 0);
    expect(restored.displayedSteps, 120);
  });

  test('restart cannot recover provisional steps', () {
    final beforeStop = _snapshot(confirmedSteps: 100, provisionalSteps: 20);
    final restored = StepSnapshot.fromPersistedMap(beforeStop.toPersistedMap());
    final restartedSession = StepValidationSession(
      confirmedSteps: restored.confirmedSteps,
    );

    expect(restartedSession.confirmedSteps, 100);
    expect(restartedSession.provisionalSteps, 0);
    expect(restartedSession.displayedSteps, 100);
    expect(restartedSession.sensorReady, isFalse);
  });

  test('previous acceptedSteps schema migrates to confirmedSteps', () {
    final restored = StepSnapshot.fromPersistedMap(<String, dynamic>{
      'acceptedSteps': 72,
      'pendingSteps': 9,
    });

    expect(restored.confirmedSteps, 72);
    expect(restored.provisionalSteps, 0);
  });
}

StepSnapshot _snapshot({
  required int confirmedSteps,
  required int provisionalSteps,
}) {
  return StepSnapshot(
    confirmedSteps: confirmedSteps,
    provisionalSteps: provisionalSteps,
    isTracking: true,
    sensorReady: true,
    activity: TrackingActivity.walking,
    confidence: TrackingConfidence.high,
    startedAt: DateTime.utc(2026, 7, 13, 10),
    updatedAt: DateTime.utc(2026, 7, 13, 10, 1),
  );
}
