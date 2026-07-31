final class StepDiagnosticEvent {
  const StepDiagnosticEvent({
    required this.sessionId,
    required this.eventType,
    required this.sequenceNumber,
    required this.source,
    required this.wallClockUtc,
    required this.payload,
    this.elapsedRealtimeMs,
    this.recordedAtElapsedRealtimeMs,
    this.sessionStartedElapsedRealtimeMs,
    this.sessionOffsetMs,
    this.windowId,
    this.bucketIndex,
  });

  final String sessionId;
  final String eventType;
  final int sequenceNumber;
  final String source;
  final DateTime wallClockUtc;
  final int? elapsedRealtimeMs;
  final int? recordedAtElapsedRealtimeMs;
  final int? sessionStartedElapsedRealtimeMs;
  final int? sessionOffsetMs;
  final int? windowId;
  final int? bucketIndex;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': 2,
    'sessionId': sessionId,
    'validationMode': 'transition',
    'applicationId': 'com.example.walkingapp.transition',
    'applicationVersion': '1.0.0+1',
    'eventType': eventType,
    'sequenceNumber': sequenceNumber,
    'source': source,
    'wallClockUtc': wallClockUtc.toUtc().toIso8601String(),
    'recordedAtWallClockUtc': wallClockUtc.toUtc().toIso8601String(),
    if (recordedAtElapsedRealtimeMs != null)
      'recordedAtElapsedRealtimeMs': recordedAtElapsedRealtimeMs,
    if (sessionStartedElapsedRealtimeMs != null)
      'sessionStartedElapsedRealtimeMs': sessionStartedElapsedRealtimeMs,
    if (sessionOffsetMs != null) 'sessionOffsetMs': sessionOffsetMs,
    if (windowId != null) 'windowId': windowId,
    if (bucketIndex != null) 'bucketIndex': bucketIndex,
    'payload': payload,
  };
}

abstract final class StepDiagnosticEventType {
  static const sessionCreated = 'DIAGNOSTIC_SESSION_CREATED';
  static const sessionFinalized = 'DIAGNOSTIC_SESSION_FINALIZED';
  static const trackingStartRequested = 'TRACKING_START_REQUESTED';
  static const trackingStarted = 'TRACKING_STARTED';
  static const trackingStopRequested = 'TRACKING_STOP_REQUESTED';
  static const trackingStopped = 'TRACKING_STOPPED';
  static const serviceStart = 'SERVICE_START';
  static const serviceStop = 'SERVICE_STOP';
  static const serviceDestroy = 'SERVICE_DESTROY';
  static const serviceError = 'SERVICE_ERROR';
  static const permissionState = 'PERMISSION_STATE';
  static const pedometerSubscribe = 'PEDOMETER_SUBSCRIBE';
  static const pedometerBaseline = 'PEDOMETER_BASELINE';
  static const pedometerCallback = 'PEDOMETER_CALLBACK';
  static const pedometerError = 'PEDOMETER_ERROR';
  static const pedometerUnsubscribe = 'PEDOMETER_UNSUBSCRIBE';
  static const rawDeltaAccepted = 'RAW_DELTA_ACCEPTED';
  static const rawDeltaRejected = 'RAW_DELTA_REJECTED';
  static const candidateSampleCreated = 'CANDIDATE_SAMPLE_CREATED';
  static const windowOpen = 'WINDOW_OPEN';
  static const windowClose = 'WINDOW_CLOSE';
  static const bucketAssignment = 'BUCKET_ASSIGNMENT';
  static const graceStart = 'GRACE_PERIOD_START';
  static const graceExpired = 'GRACE_PERIOD_EXPIRED';
  static const bucketValidation = 'BUCKET_VALIDATION';
  static const windowValidation = 'WINDOW_VALIDATION';
  static const snapshotCreated = 'SNAPSHOT_CREATED';
  static const snapshotSent = 'SNAPSHOT_SENT';
  static const snapshotReceived = 'SNAPSHOT_RECEIVED';
  static const uiStateUpdated = 'UI_STATE_UPDATED';
  static const hiveWrite = 'HIVE_WRITE';
  static const hiveRead = 'HIVE_READ';
  static const resetRequested = 'RESET_REQUESTED';
  static const resetCompleted = 'RESET_COMPLETED';
  static const transitionRegisterRequest = 'TRANSITION_REGISTER_REQUEST';
  static const transitionRegisterSuccess = 'TRANSITION_REGISTER_SUCCESS';
  static const transitionRegisterFailure = 'TRANSITION_REGISTER_FAILURE';
  static const transitionReceiverEnter = 'TRANSITION_RECEIVER_ENTER';
  static const transitionEventReceived = 'TRANSITION_EVENT_RECEIVED';
  static const transitionEventDelivered = 'TRANSITION_EVENT_DELIVERED';
  static const transitionEventFiltered = 'TRANSITION_EVENT_FILTERED';
  static const transitionIntervalOpened = 'TRANSITION_INTERVAL_OPENED';
  static const transitionIntervalClosed = 'TRANSITION_INTERVAL_CLOSED';
  static const transitionUnregister = 'TRANSITION_UNREGISTER';
  static const diagnosticError = 'DIAGNOSTIC_ERROR';
}
