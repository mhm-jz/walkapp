import 'step_diagnostic_config.dart';

final class StepDiagnosticSession {
  const StepDiagnosticSession({
    required this.id,
    required this.startedAtUtc,
    required this.active,
    this.endedAtUtc,
    this.incomplete = false,
  });
  final String id;
  final DateTime startedAtUtc;
  final DateTime? endedAtUtc;
  final bool active;
  final bool incomplete;
  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': StepDiagnosticConfig.schemaVersion,
    'sessionId': id,
    'validationMode': StepDiagnosticConfig.validationMode,
    'applicationId': StepDiagnosticConfig.applicationId,
    'applicationVersion': StepDiagnosticConfig.applicationVersion,
    'startedAtUtc': startedAtUtc.toUtc().toIso8601String(),
    'endedAtUtc': endedAtUtc?.toUtc().toIso8601String(),
    'active': active,
    'incomplete': incomplete,
  };
}

final class StepDiagnosticMetadata {
  const StepDiagnosticMetadata({
    this.testName = '',
    this.manuallyCountedSteps,
    this.routeDescription = '',
    this.testNotes = '',
    this.phonePlacement = '',
    this.testScenario = 'CUSTOM',
  });
  final String testName;
  final int? manuallyCountedSteps;
  final String routeDescription;
  final String testNotes;
  final String phonePlacement;
  final String testScenario;
  Map<String, Object?> toJson() => <String, Object?>{
    'testName': testName,
    'manuallyCountedSteps': manuallyCountedSteps,
    'routeDescription': routeDescription,
    'testNotes': testNotes,
    'phonePlacement': phonePlacement,
    'testScenario': testScenario,
  };
}
