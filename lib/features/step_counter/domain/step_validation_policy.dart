import 'tracking_activity.dart';

/// Stateless rules used by [StepValidationSession].
final class StepValidationPolicy {
  const StepValidationPolicy({
    this.windowDuration = const Duration(seconds: 30),
    this.bucketDuration = const Duration(seconds: 10),
    this.bucketCount = 3,
    this.maxRawDeltaPerEvent = 120,
    this.maximumActivityEvidenceAge = const Duration(seconds: 30),
  });

  final Duration windowDuration;
  final Duration bucketDuration;
  final int bucketCount;
  final int maxRawDeltaPerEvent;
  final Duration maximumActivityEvidenceAge;

  bool isValidRawDelta(int delta) {
    return delta > 0 && delta <= maxRawDeltaPerEvent;
  }

  int? bucketIndex(Duration elapsed) {
    if (elapsed.isNegative || elapsed >= windowDuration) return null;

    final index = elapsed.inMicroseconds ~/ bucketDuration.inMicroseconds;
    return index < bucketCount ? index : null;
  }

  bool isValidBucket({
    required bool observedWalkingOrRunning,
    required bool observedVehicleOrBicycle,
    required TrackingConfidence bestWalkingConfidence,
  }) {
    return observedWalkingOrRunning &&
        !observedVehicleOrBicycle &&
        bestWalkingConfidence != TrackingConfidence.low;
  }
}
