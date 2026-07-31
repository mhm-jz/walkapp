import 'step_diagnostic_config.dart';

final class StepDiagnosticSession {
  const StepDiagnosticSession({
    required this.id,
    required this.startedAtUtc,
    required this.active,
    required this.incomplete,
    this.endedAtUtc,
  });

  final String id;
  final DateTime startedAtUtc;
  final DateTime? endedAtUtc;
  final bool active;
  final bool incomplete;

  factory StepDiagnosticSession.fromJson(Map<String, Object?> json) {
    return StepDiagnosticSession(
      id: json['sessionId']?.toString() ?? '',
      startedAtUtc:
          DateTime.tryParse(json['startedAtUtc']?.toString() ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      endedAtUtc: DateTime.tryParse(
        json['endedAtUtc']?.toString() ?? '',
      )?.toUtc(),
      active: json['active'] == true,
      incomplete: json['incomplete'] == true,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': StepDiagnosticConfig.schemaVersion,
    'sessionId': id,
    'validationMode': StepDiagnosticConfig.validationMode,
    'applicationId': StepDiagnosticConfig.applicationId,
    'applicationVersion': StepDiagnosticConfig.applicationVersion,
    'startedAtUtc': startedAtUtc.toIso8601String(),
    'endedAtUtc': endedAtUtc?.toIso8601String(),
    'active': active,
    'incomplete': incomplete,
  };
}

final class StepDiagnosticMetadata {
  const StepDiagnosticMetadata({
    this.testName = '',
    this.manuallyCountedSteps,
    this.routeDescription = '',
    this.notes = '',
  });

  final String testName;
  final int? manuallyCountedSteps;
  final String routeDescription;
  final String notes;

  factory StepDiagnosticMetadata.fromJson(Map<String, Object?> json) =>
      StepDiagnosticMetadata(
        testName: json['testName']?.toString() ?? '',
        manuallyCountedSteps: json['manuallyCountedSteps'] is int
            ? json['manuallyCountedSteps'] as int
            : int.tryParse(json['manuallyCountedSteps']?.toString() ?? ''),
        routeDescription: json['routeDescription']?.toString() ?? '',
        notes: json['notes']?.toString() ?? '',
      );

  Map<String, Object?> toJson() => <String, Object?>{
    'testName': testName,
    'manuallyCountedSteps': manuallyCountedSteps,
    'routeDescription': routeDescription,
    'notes': notes,
  };
}
