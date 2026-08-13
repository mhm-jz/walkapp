/// Hive representation of a snapshot; runtime validation state is excluded.
final class StepSnapshotDto {
  const StepSnapshotDto(this.payload);

  factory StepSnapshotDto.fromMap(Map<String, dynamic> map) =>
      StepSnapshotDto(Map<String, dynamic>.unmodifiable(map));

  final Map<String, dynamic> payload;

  Map<String, dynamic> toMap() => payload;
}
