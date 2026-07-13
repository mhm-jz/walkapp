/// Ensures explicit stop and service destruction share one final write.
final class FinalSnapshotPersistence {
  Future<void>? _operation;

  bool get hasStarted => _operation != null;

  Future<void> run(Future<void> Function() operation) {
    return _operation ??= operation();
  }
}
