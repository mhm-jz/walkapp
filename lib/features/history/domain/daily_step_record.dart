final class DailyStepRecord {
  const DailyStepRecord({
    required this.date,
    required this.confirmedSteps,
    required this.goalSnapshot,
    required this.goalReached,
    required this.updatedAt,
    required this.isFinalized,
    this.finalizedAt,
  });

  final String date;
  final int confirmedSteps;
  final int goalSnapshot;
  final bool goalReached;
  final DateTime updatedAt;
  final DateTime? finalizedAt;
  final bool isFinalized;

  DailyStepRecord copyWith({
    int? confirmedSteps,
    int? goalSnapshot,
    bool? goalReached,
    DateTime? updatedAt,
    DateTime? finalizedAt,
    bool? isFinalized,
  }) => DailyStepRecord(
    date: date,
    confirmedSteps: confirmedSteps ?? this.confirmedSteps,
    goalSnapshot: goalSnapshot ?? this.goalSnapshot,
    goalReached: goalReached ?? this.goalReached,
    updatedAt: updatedAt ?? this.updatedAt,
    finalizedAt: finalizedAt ?? this.finalizedAt,
    isFinalized: isFinalized ?? this.isFinalized,
  );

  Map<String, Object?> toMap() => <String, Object?>{
    'date': date,
    'confirmedSteps': confirmedSteps,
    'goalSnapshot': goalSnapshot,
    'goalReached': goalReached,
    'updatedAt': updatedAt.toIso8601String(),
    'finalizedAt': finalizedAt?.toIso8601String(),
    'isFinalized': isFinalized,
  };

  static DailyStepRecord? fromMap(Map<dynamic, dynamic> map) {
    final date = map['date']?.toString();
    final updatedAt = DateTime.tryParse(map['updatedAt']?.toString() ?? '');
    if (date == null || updatedAt == null) return null;
    final confirmed = _asInt(map['confirmedSteps']);
    final goal = _asInt(map['goalSnapshot']).clamp(1000, 100000);
    return DailyStepRecord(
      date: date,
      confirmedSteps: confirmed,
      goalSnapshot: goal,
      goalReached: map['goalReached'] == true || confirmed >= goal,
      updatedAt: updatedAt,
      finalizedAt: DateTime.tryParse(map['finalizedAt']?.toString() ?? ''),
      isFinalized: map['isFinalized'] == true,
    );
  }

  static int _asInt(Object? value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}
