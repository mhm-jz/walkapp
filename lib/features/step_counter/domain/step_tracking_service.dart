typedef StepTaskDataCallback = void Function(Object data);

enum ActivityAccessStatus { granted, denied, permanentlyDenied, unsupported }

abstract interface class ActivityAccessRequester {
  Future<ActivityAccessStatus> requestActivityAccess();
}

abstract interface class StepDiagnosticRecorder {
  String? get diagnosticSessionId;

  Future<void> prepareDiagnosticSession(Map<String, Object?> startSnapshot);

  void recordDiagnosticEvent(String eventType, {Map<String, Object?> payload});
}

abstract interface class StepTrackingService {
  void initialize();

  Future<bool> isRunning();

  Future<void> start();

  Future<void> stop();

  void requestSnapshot();

  void requestReset();

  void addDataCallback(StepTaskDataCallback callback);

  void removeDataCallback(StepTaskDataCallback callback);
}
