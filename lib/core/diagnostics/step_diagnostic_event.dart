import 'step_diagnostic_config.dart';

final class StepDiagnosticEvent {
  const StepDiagnosticEvent({
    required this.sessionId,
    required this.eventType,
    required this.sequenceNumber,
    required this.source,
    required this.recordedAtElapsedRealtimeMs,
    required this.recordedAtWallClockUtc,
    required this.sessionStartedElapsedRealtimeMs,
    required this.payload,
    this.windowId,
    this.bucketIndex,
  });

  final String sessionId;
  final String eventType;
  final int sequenceNumber;
  final String source;
  final int recordedAtElapsedRealtimeMs;
  final DateTime recordedAtWallClockUtc;
  final int sessionStartedElapsedRealtimeMs;
  final int? windowId;
  final int? bucketIndex;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': StepDiagnosticConfig.schemaVersion,
    'sessionId': sessionId,
    'validationMode': StepDiagnosticConfig.validationMode,
    'applicationId': StepDiagnosticConfig.applicationId,
    'applicationVersion': StepDiagnosticConfig.applicationVersion,
    'eventType': eventType,
    'sequenceNumber': sequenceNumber,
    'source': source,
    'recordedAtElapsedRealtimeMs': recordedAtElapsedRealtimeMs,
    'recordedAtWallClockUtc': recordedAtWallClockUtc.toUtc().toIso8601String(),
    'sessionStartedElapsedRealtimeMs': sessionStartedElapsedRealtimeMs,
    'sessionOffsetMs':
        recordedAtElapsedRealtimeMs - sessionStartedElapsedRealtimeMs,
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
  static const candidateCreated = 'CANDIDATE_SAMPLE_CREATED';
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
  static const uiUpdated = 'UI_STATE_UPDATED';
  static const hiveRead = 'HIVE_READ';
  static const hiveWrite = 'HIVE_WRITE';
  static const resetRequested = 'RESET_REQUESTED';
  static const resetCompleted = 'RESET_COMPLETED';
  static const samplingSubscribeRequest = 'SAMPLING_SUBSCRIBE_REQUEST';
  static const samplingSubscribeSuccess = 'SAMPLING_SUBSCRIBE_SUCCESS';
  static const samplingSubscribeFailure = 'SAMPLING_SUBSCRIBE_FAILURE';
  static const samplingCallbackEnter = 'SAMPLING_CALLBACK_ENTER';
  static const samplingActivityParsed = 'SAMPLING_ACTIVITY_PARSED';
  static const samplingActivityApplied = 'SAMPLING_ACTIVITY_APPLIED';
  static const samplingActivityIgnored = 'SAMPLING_ACTIVITY_IGNORED';
  static const samplingEvidenceUpdated = 'SAMPLING_EVIDENCE_UPDATED';
  static const samplingStreamError = 'SAMPLING_STREAM_ERROR';
  static const samplingStreamDone = 'SAMPLING_STREAM_DONE';
  static const samplingUnsubscribeRequest = 'SAMPLING_UNSUBSCRIBE_REQUEST';
  static const samplingUnsubscribeCompleted = 'SAMPLING_UNSUBSCRIBE_COMPLETED';
  static const samplingUnsubscribeFailure = 'SAMPLING_UNSUBSCRIBE_FAILURE';
}
