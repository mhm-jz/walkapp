import 'tracking_activity.dart';

const Object _unset = Object();

final class StepSnapshot {
  const StepSnapshot({
    required this.confirmedSteps,
    required this.provisionalSteps,
    required this.isTracking,
    required this.sensorReady,
    required this.activity,
    required this.confidence,
    required this.updatedAt,
    this.startedAt,
    this.error,
    this.stopReason,
  });

  factory StepSnapshot.initial() {
    return StepSnapshot(
      confirmedSteps: 0,
      provisionalSteps: 0,
      isTracking: false,
      sensorReady: false,
      activity: TrackingActivity.unknown,
      confidence: TrackingConfidence.low,
      updatedAt: DateTime.now(),
    );
  }

  final int confirmedSteps;
  final int provisionalSteps;
  int get displayedSteps => confirmedSteps + provisionalSteps;

  final bool isTracking;
  final bool sensorReady;
  final TrackingActivity activity;
  final TrackingConfidence confidence;
  final DateTime? startedAt;
  final DateTime updatedAt;
  final String? error;
  final String? stopReason;

  StepSnapshot copyWith({
    int? confirmedSteps,
    int? provisionalSteps,
    bool? isTracking,
    bool? sensorReady,
    TrackingActivity? activity,
    TrackingConfidence? confidence,
    Object? startedAt = _unset,
    DateTime? updatedAt,
    Object? error = _unset,
    Object? stopReason = _unset,
  }) {
    return StepSnapshot(
      confirmedSteps: confirmedSteps ?? this.confirmedSteps,
      provisionalSteps: provisionalSteps ?? this.provisionalSteps,
      isTracking: isTracking ?? this.isTracking,
      sensorReady: sensorReady ?? this.sensorReady,
      activity: activity ?? this.activity,
      confidence: confidence ?? this.confidence,
      startedAt: identical(startedAt, _unset)
          ? this.startedAt
          : startedAt as DateTime?,
      updatedAt: updatedAt ?? this.updatedAt,
      error: identical(error, _unset) ? this.error : error as String?,
      stopReason: identical(stopReason, _unset)
          ? this.stopReason
          : stopReason as String?,
    );
  }

  /// Full in-memory transport payload sent from the service to the UI.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...toPersistedMap(),
      'provisionalSteps': provisionalSteps,
      'sensorReady': sensorReady,
      'activity': activity.storageName,
      'confidence': confidence.storageName,
    };
  }

  /// Durable Hive payload. Provisional validation state is intentionally absent.
  Map<String, dynamic> toPersistedMap() {
    return <String, dynamic>{
      'confirmedSteps': confirmedSteps,
      'isTracking': isTracking,
      'startedAt': startedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'error': error,
      'stopReason': stopReason,
    };
  }

  factory StepSnapshot.fromMap(Map<String, dynamic> map) {
    return StepSnapshot._fromMap(map, includeProvisional: true);
  }

  factory StepSnapshot.fromPersistedMap(Map<String, dynamic> map) {
    return StepSnapshot._fromMap(map, includeProvisional: false);
  }

  factory StepSnapshot._fromMap(
    Map<String, dynamic> map, {
    required bool includeProvisional,
  }) {
    return StepSnapshot(
      // acceptedSteps supports migration from the previous schema.
      confirmedSteps: _asInt(map['confirmedSteps'] ?? map['acceptedSteps']),
      provisionalSteps: includeProvisional
          ? _asInt(map['provisionalSteps'] ?? map['pendingSteps'])
          : 0,
      isTracking: map['isTracking'] == true,
      sensorReady: includeProvisional && map['sensorReady'] == true,
      activity: includeProvisional
          ? TrackingActivity.fromStorage(map['activity'])
          : TrackingActivity.unknown,
      confidence: includeProvisional
          ? TrackingConfidence.fromStorage(map['confidence'])
          : TrackingConfidence.low,
      startedAt: _asDateTime(map['startedAt']),
      updatedAt: _asDateTime(map['updatedAt']) ?? DateTime.now(),
      error: map['error']?.toString(),
      stopReason: map['stopReason']?.toString(),
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _asDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
