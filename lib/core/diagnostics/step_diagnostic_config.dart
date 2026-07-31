import 'package:flutter/foundation.dart';

abstract final class StepDiagnosticConfig {
  static const int schemaVersion = 2;
  static const String validationMode = 'transition';
  static const String applicationId = 'com.example.walkingapp.transition';
  static const String applicationVersion = '1.0.0+1';
  static const int maxCompletedSessions = 10;
  static const int maxTotalBytes = 20 * 1024 * 1024;
  static const int maxQueuedEvents = 2048;
  static const Duration flushInterval = Duration(seconds: 2);

  static const bool enabled = bool.fromEnvironment(
    'STEP_DIAGNOSTICS',
    defaultValue: kDebugMode,
  );
}
