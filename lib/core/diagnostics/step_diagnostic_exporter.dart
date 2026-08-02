import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'step_diagnostic_store.dart';

final class StepDiagnosticExporter {
  StepDiagnosticExporter(this.store);
  final StepDiagnosticStore store;
  static const _channel = MethodChannel(
    'com.example.walkingapp/diagnostic_share',
  );

  Future<List<Map<String, Object?>>> events(String id) async {
    final result = <Map<String, Object?>>[];
    await for (final entity in store.directory.list()) {
      if (entity is! File ||
          !entity.path.endsWith('.jsonl') ||
          !entity.uri.pathSegments.last.startsWith('$id-')) {
        continue;
      }
      for (final line in await entity.readAsLines()) {
        try {
          final value = jsonDecode(line);
          if (value is Map) {
            result.add(value.map((k, v) => MapEntry(k.toString(), v)));
          }
        } catch (_) {}
      }
    }
    result.sort((a, b) {
      final time = (a['recordedAtElapsedRealtimeMs'] as int? ?? 0).compareTo(
        b['recordedAtElapsedRealtimeMs'] as int? ?? 0,
      );
      if (time != 0) return time;
      final source = a['source'].toString().compareTo(b['source'].toString());
      return source != 0
          ? source
          : (a['sequenceNumber'] as int? ?? 0).compareTo(
              b['sequenceNumber'] as int? ?? 0,
            );
    });
    return result;
  }

  Future<File> export(String id) async {
    final all = await events(id);
    Map<Object?, Object?> payload(Map<String, Object?> e) =>
        e['payload'] is Map ? e['payload'] as Map : const {};
    int sum(String type, String key) => all
        .where((e) => e['eventType'] == type)
        .fold(0, (v, e) => v + (payload(e)[key] as int? ?? 0));
    int count(String type) => all.where((e) => e['eventType'] == type).length;
    List<num> values(String key) =>
        all.map((e) => payload(e)[key]).whereType<num>().toList();
    Map<String, Object?> stats(String name, List<num> samples) => {
      'minimum$name': samples.isEmpty
          ? null
          : samples.reduce((a, b) => a < b ? a : b),
      'maximum$name': samples.isEmpty
          ? null
          : samples.reduce((a, b) => a > b ? a : b),
      'average$name': samples.isEmpty
          ? null
          : samples.fold<double>(0, (s, v) => s + v) / samples.length,
    };
    final candidates = sum('CANDIDATE_SAMPLE_CREATED', 'delta');
    final accepted = sum('WINDOW_VALIDATION', 'acceptedStepTotal');
    final rejected = sum('WINDOW_VALIDATION', 'rejectedStepTotal');
    final timingFailures = all.expand((e) {
      final p = payload(e);
      return p['timingInvariantFailures'] is List
          ? p['timingInvariantFailures'] as List
          : const [];
    }).toList();
    final activityCounts = <String, int>{};
    final confidenceCounts = <String, int>{};
    for (final event in all.where(
      (e) => e['eventType'] == 'SAMPLING_ACTIVITY_PARSED',
    )) {
      final p = payload(event);
      final activity = p['mappedActivityType']?.toString() ?? 'UNKNOWN';
      final confidence = p['mappedConfidence']?.toString() ?? 'UNKNOWN';
      activityCounts[activity] = (activityCounts[activity] ?? 0) + 1;
      confidenceCounts[confidence] = (confidenceCounts[confidence] ?? 0) + 1;
    }
    int? firstTime(String type, [bool Function(Map<Object?, Object?>)? test]) =>
        all
            .where(
              (e) => e['eventType'] == type && (test?.call(payload(e)) ?? true),
            )
            .map((e) => e['recordedAtElapsedRealtimeMs'] as int?)
            .whereType<int>()
            .firstOrNull;
    final firstCandidate = firstTime('CANDIDATE_SAMPLE_CREATED');
    final firstSampling = firstTime('SAMPLING_CALLBACK_ENTER');
    final firstWalking = firstTime(
      'SAMPLING_ACTIVITY_PARSED',
      (p) =>
          p['mappedActivityType'] == 'WALKING' ||
          p['mappedActivityType'] == 'RUNNING',
    );
    final created = all
        .where((e) => e['eventType'] == 'DIAGNOSTIC_SESSION_CREATED')
        .firstOrNull;
    final createdPayload = created == null
        ? const <Object?, Object?>{}
        : payload(created);
    final snapshots = all
        .where((e) => e['eventType'] == 'SNAPSHOT_SENT')
        .toList();
    final finalSnapshot = snapshots.isEmpty
        ? const <Object?, Object?>{}
        : payload(snapshots.last);
    final samplingSummary = <String, Object?>{
      'samplingSubscribeRequestCount': count('SAMPLING_SUBSCRIBE_REQUEST'),
      'samplingSubscribeSuccessCount': count('SAMPLING_SUBSCRIBE_SUCCESS'),
      'samplingSubscribeFailureCount': count('SAMPLING_SUBSCRIBE_FAILURE'),
      'samplingCallbackCount': count('SAMPLING_CALLBACK_ENTER'),
      'samplingCallbackProcessingErrorCount': count(
        'SAMPLING_ACTIVITY_IGNORED',
      ),
      'samplingStreamErrorCount': count('SAMPLING_STREAM_ERROR'),
      'samplingStreamDoneCount': count('SAMPLING_STREAM_DONE'),
      'activityCountsByType': activityCounts,
      'confidenceCounts': confidenceCounts,
      ...stats(
        'CallbackProcessingDurationMs',
        values('samplingCallbackProcessingDurationMs'),
      ),
      ...stats('EvidenceAgeUsedMs', values('evidenceAgeAtValidationStartMs')),
      'timingInvariantFailureCount': timingFailures.length,
      'firstCandidateToFirstSamplingCallbackMs':
          firstCandidate == null || firstSampling == null
          ? null
          : firstSampling - firstCandidate,
      'firstCandidateToFirstWalkingOrRunningCallbackMs':
          firstCandidate == null || firstWalking == null
          ? null
          : firstWalking - firstCandidate,
    };
    final report = <String, Object?>{
      'schemaVersion': 2,
      'session': await store.readJson(store.session(id)),
      'manualGroundTruth': await store.readJson(store.metadata(id)),
      'summary': {
        'schemaVersion': 2,
        'sessionId': id,
        'validationMode': 'sampling',
        'applicationId': 'com.example.walkingapp',
        'applicationVersion': '1.0.0+1',
        'confirmedBefore': createdPayload['confirmedStepsBeforeStart'] ?? 0,
        'confirmedAfter': finalSnapshot['confirmedSteps'],
        'confirmedGained': finalSnapshot['confirmedSteps'] is int
            ? (finalSnapshot['confirmedSteps'] as int) -
                  (createdPayload['confirmedStepsBeforeStart'] as int? ?? 0)
            : null,
        'provisionalBefore': createdPayload['provisionalStepsBeforeStart'] ?? 0,
        'provisionalFinal': finalSnapshot['provisionalSteps'],
        'pedometerBaseline': all
            .where((e) => e['eventType'] == 'PEDOMETER_BASELINE')
            .map((e) => payload(e)['sensorCumulativeValue'])
            .firstOrNull,
        'pedometerFinal': all
            .where((e) => e['eventType'] == 'PEDOMETER_CALLBACK')
            .map((e) => payload(e)['sensorCumulativeValue'])
            .lastOrNull,
        'candidateStepTotal': candidates,
        'acceptedStepTotal': accepted,
        'rejectedStepTotal': rejected,
        'candidateInvariantPassed': accepted + rejected == candidates,
        'candidateInvariantDifference': candidates - accepted - rejected,
        'pedometerCallbackCount': count('PEDOMETER_CALLBACK'),
        'positiveDeltaCallbackCount': all
            .where(
              (e) =>
                  e['eventType'] == 'PEDOMETER_CALLBACK' &&
                  (payload(e)['calculatedDelta'] as int? ?? 0) > 0,
            )
            .length,
        'windowCount': count('WINDOW_VALIDATION'),
        'bucketCount': count('BUCKET_VALIDATION'),
        'samplingCallbackCount': count('SAMPLING_CALLBACK_ENTER'),
        'samplingCallbacksByActivity': activityCounts,
        'samplingCallbacksByConfidence': confidenceCounts,
        'firstCandidateElapsedRealtimeMs': firstCandidate,
        'firstSamplingCallbackElapsedRealtimeMs': firstSampling,
        'firstWalkingOrRunningCallbackElapsedRealtimeMs': firstWalking,
        'maximumEvidenceAgeUsedMs':
            values('evidenceAgeAtValidationStartMs').isEmpty
            ? null
            : values(
                'evidenceAgeAtValidationStartMs',
              ).reduce((a, b) => a > b ? a : b),
        'averageEvidenceAgeUsedMs':
            values('evidenceAgeAtValidationStartMs').isEmpty
            ? null
            : values(
                    'evidenceAgeAtValidationStartMs',
                  ).fold<double>(0, (s, v) => s + v) /
                  values('evidenceAgeAtValidationStartMs').length,
        'finalBackgroundConfirmed': finalSnapshot['confirmedSteps'],
      },
      'orderedEvents': all,
      'samplingTimingSummary': samplingSummary,
      'timingInvariants': {
        'passed': timingFailures.isEmpty,
        'failures': timingFailures,
      },
      'diagnosticErrors': all
          .where((e) => e['eventType'].toString().contains('ERROR'))
          .toList(),
    };
    final file = File(
      '${store.directory.path}/walkapp-sampling-$id-diagnostic.json',
    );
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(report),
      flush: true,
    );
    return file;
  }

  Future<void> share(String id) async {
    final file = await export(id);
    await _channel.invokeMethod<void>('shareFile', {
      'path': file.path,
      'mimeType': 'application/json',
    });
  }
}
