import 'package:flutter/foundation.dart';

abstract final class StepDiagnosticConfig {
  static const schemaVersion = 2;
  static const validationMode = 'sampling';
  static const applicationId = 'com.example.walkingapp';
  static const applicationVersion = '1.0.0+1';
  static const maxSessions = 10;
  static const maxBytes = 20 * 1024 * 1024;
  static const maxQueuedEvents = 2048;
  static const enabled = bool.fromEnvironment(
    'STEP_DIAGNOSTICS',
    defaultValue: kDebugMode,
  );
}
