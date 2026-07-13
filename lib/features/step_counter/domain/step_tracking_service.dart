typedef StepTaskDataCallback = void Function(Object data);

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
