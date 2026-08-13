import '../../domain/step_snapshot.dart';
import '../dto/step_snapshot_dto.dart';

abstract final class StepSnapshotMapper {
  static StepSnapshot toDomain(StepSnapshotDto dto) =>
      StepSnapshot.fromPersistedMap(dto.payload);

  static StepSnapshotDto toDto(StepSnapshot snapshot) =>
      StepSnapshotDto(snapshot.toPersistedMap());
}
