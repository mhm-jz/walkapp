import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'step_diagnostic_config.dart';
import 'step_diagnostic_store.dart';

final class StepDiagnosticExporter {
  StepDiagnosticExporter(this.store);

  final StepDiagnosticStore store;
  static const MethodChannel _shareChannel = MethodChannel(
    'com.example.walkingapp/diagnostic_share',
  );

  Future<File> export(String sessionId) async {
    final session = await store.readJson(store.sessionFile(sessionId));
    final metadata = await store.readMetadata(sessionId);
    final events = await _readEvents(sessionId);
    final nativeReceiverDiagnostics = events
        .where(_isNativeReceiverDiagnostic)
        .toList(growable: false);
    final orderedEvents = events
        .where((event) => !_isNativeReceiverDiagnostic(event))
        .toList(growable: false);
    final summary = _summarize(session, events);
    final timingSummary = _timingSummary(events);
    final output = <String, Object?>{
      'schemaVersion': StepDiagnosticConfig.schemaVersion,
      'sessionMetadata': session,
      'manualGroundTruth': metadata.toJson(),
      'summary': summary,
      'nativeReceiverDiagnostics': nativeReceiverDiagnostics,
      'orderedEvents': orderedEvents,
      'timingSummary': timingSummary,
      'timingInvariants': <String, Object?>{
        'passed': timingSummary['timingInvariantFailureCount'] == 0,
        'failureCount': timingSummary['timingInvariantFailureCount'],
        'failures': _timingInvariantFailures(events),
      },
      'invariants': <String, Object?>{
        'acceptedPlusRejectedEqualsCandidates':
            (summary['acceptedSteps'] as int) +
                (summary['rejectedSteps'] as int) ==
            summary['candidateSteps'],
      },
      'diagnosticErrors': events
          .where((event) => event['eventType'] == 'DIAGNOSTIC_ERROR')
          .toList(growable: false),
    };
    final file = File(
      '${store.directory.path}/walkapp-${StepDiagnosticConfig.validationMode}-$sessionId-diagnostic.json',
    );
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(output),
      flush: true,
    );
    return file;
  }

  Future<Map<String, Object?>> readSummary(String sessionId) async {
    final session = await store.readJson(store.sessionFile(sessionId));
    final summary = _summarize(session, await _readEvents(sessionId));
    final metadata = await store.readMetadata(sessionId);
    summary['manuallyCountedSteps'] = metadata.manuallyCountedSteps;
    await store.writeJson(store.summaryFile(sessionId), summary);
    return summary;
  }

  Future<void> exportAndShare(String sessionId) async {
    final file = await export(sessionId);
    await _shareChannel.invokeMethod<void>('shareFile', <String, Object?>{
      'path': file.path,
      'mimeType': 'application/json',
      'title': file.uri.pathSegments.last,
    });
  }

  Future<List<Map<String, Object?>>> _readEvents(String sessionId) async {
    final result = <Map<String, Object?>>[];
    await for (final entity in store.directory.list()) {
      if (entity is! File ||
          !entity.uri.pathSegments.last.startsWith('$sessionId-') ||
          !entity.path.endsWith('.jsonl')) {
        continue;
      }
      for (final line in await entity.readAsLines()) {
        try {
          final decoded = jsonDecode(line);
          if (decoded is Map) {
            result.add(
              decoded.map<String, Object?>(
                (key, value) => MapEntry(key.toString(), value),
              ),
            );
          }
        } catch (_) {
          // Keep other valid events exportable.
        }
      }
    }
    result.sort((left, right) {
      final leftElapsed =
          left['recordedAtElapsedRealtimeMs'] as int? ??
          left['elapsedRealtimeMs'] as int?;
      final rightElapsed =
          right['recordedAtElapsedRealtimeMs'] as int? ??
          right['elapsedRealtimeMs'] as int?;
      if (leftElapsed != null && rightElapsed != null) {
        final byElapsed = leftElapsed.compareTo(rightElapsed);
        if (byElapsed != 0) return byElapsed;
      } else if (leftElapsed != null) {
        return -1;
      } else if (rightElapsed != null) {
        return 1;
      }
      final bySource = left['source'].toString().compareTo(
        right['source'].toString(),
      );
      if (bySource != 0) return bySource;
      return (left['sequenceNumber'] as int? ?? 0).compareTo(
        right['sequenceNumber'] as int? ?? 0,
      );
    });
    return result;
  }

  Map<String, Object?> _summarize(
    Map<String, Object?> session,
    List<Map<String, Object?>> events,
  ) {
    int sum(String type, String field) => events
        .where((event) => event['eventType'] == type)
        .fold<int>(0, (total, event) {
          final payload = event['payload'];
          return total + (payload is Map ? (payload[field] as int? ?? 0) : 0);
        });
    final callbacks = events
        .where((event) => event['eventType'] == 'PEDOMETER_CALLBACK')
        .toList(growable: false);
    final accepted = sum('WINDOW_VALIDATION', 'acceptedSteps');
    final rejected = sum('WINDOW_VALIDATION', 'rejectedSteps');
    final candidate = sum('CANDIDATE_SAMPLE_CREATED', 'delta');
    Map<Object?, Object?> payloadOf(Map<String, Object?>? event) {
      final payload = event?['payload'];
      return payload is Map ? payload : const <Object?, Object?>{};
    }

    final created = events
        .where((event) => event['eventType'] == 'DIAGNOSTIC_SESSION_CREATED')
        .firstOrNull;
    final snapshots = events
        .where(
          (event) =>
              event['eventType'] == 'SNAPSHOT_SENT' ||
              event['eventType'] == 'SNAPSHOT_RECEIVED',
        )
        .toList(growable: false);
    final confirmedBefore =
        payloadOf(created)['confirmedStepsBeforeStart'] as int? ?? 0;
    final finalPayload = payloadOf(snapshots.lastOrNull);
    final confirmedAfter =
        finalPayload['confirmedSteps'] as int? ?? confirmedBefore;
    final provisionalFinal = finalPayload['provisionalSteps'] as int? ?? 0;
    int? firstElapsed(String type) => events
        .where((event) => event['eventType'] == type)
        .map((event) => event['elapsedRealtimeMs'] as int?)
        .whereType<int>()
        .firstOrNull;
    final firstQualifying = events
        .where((event) {
          if (event['eventType'] != 'TRANSITION_INTERVAL_OPENED') return false;
          final activity = payloadOf(event)['activity'];
          return activity == 'WALKING' || activity == 'RUNNING';
        })
        .map((event) => event['elapsedRealtimeMs'] as int?)
        .whereType<int>()
        .firstOrNull;
    final firstCandidate = firstElapsed('CANDIDATE_SAMPLE_CREATED');
    final activityCounts = <String, int>{};
    final transitionCounts = <String, int>{};
    for (final event in events.where(
      (event) => event['eventType'] == 'TRANSITION_EVENT_RECEIVED',
    )) {
      final payload = payloadOf(event);
      final activity = payload['activity']?.toString() ?? 'UNKNOWN';
      final transition = payload['transition']?.toString() ?? 'UNKNOWN';
      activityCounts[activity] = (activityCounts[activity] ?? 0) + 1;
      final key = '${activity}_$transition';
      transitionCounts[key] = (transitionCounts[key] ?? 0) + 1;
    }
    final start = DateTime.tryParse(session['startedAtUtc']?.toString() ?? '');
    final end = DateTime.tryParse(session['endedAtUtc']?.toString() ?? '');
    return <String, Object?>{
      'sessionId': session['sessionId'],
      'validationMode': StepDiagnosticConfig.validationMode,
      'applicationId': StepDiagnosticConfig.applicationId,
      'applicationVersion': StepDiagnosticConfig.applicationVersion,
      'deviceModel': null,
      'androidVersion': Platform.operatingSystemVersion,
      'sessionStartUtc': session['startedAtUtc'],
      'sessionEndUtc': session['endedAtUtc'],
      'sessionDurationMs': start == null || end == null
          ? null
          : end.difference(start).inMilliseconds,
      'confirmedBeforeSession': confirmedBefore,
      'confirmedAfterSession': confirmedAfter,
      'confirmedGainedDuringSession': confirmedAfter - confirmedBefore,
      'rawPedometerCallbackCount': callbacks.length,
      'rawPositiveDeltaCallbackCount': callbacks.where((event) {
        final payload = event['payload'];
        return payload is Map && (payload['delta'] as int? ?? 0) > 0;
      }).length,
      'candidateSteps': candidate,
      'acceptedSteps': accepted,
      'rejectedSteps': rejected,
      'provisionalFinalTotal': provisionalFinal,
      'windowCount': events
          .where((event) => event['eventType'] == 'WINDOW_VALIDATION')
          .length,
      'bucketCount': events
          .where((event) => event['eventType'] == 'BUCKET_VALIDATION')
          .length,
      'transitionEventCount': events
          .where((event) => event['eventType'] == 'TRANSITION_EVENT_RECEIVED')
          .length,
      'firstCandidateElapsedRealtimeMs': firstCandidate,
      'firstQualifyingActivityElapsedRealtimeMs': firstQualifying,
      'firstAcceptedStepElapsedRealtimeMs': accepted > 0
          ? firstQualifying
          : null,
      'stepsBeforeFirstQualifyingActivity': firstQualifying == null
          ? candidate
          : events
                .where(
                  (event) =>
                      event['eventType'] == 'CANDIDATE_SAMPLE_CREATED' &&
                      (event['elapsedRealtimeMs'] as int? ?? 0) <
                          firstQualifying,
                )
                .fold<int>(
                  0,
                  (total, event) =>
                      total + (payloadOf(event)['delta'] as int? ?? 0),
                ),
      'stepsAfterFirstQualifyingActivity': firstQualifying == null
          ? 0
          : events
                .where(
                  (event) =>
                      event['eventType'] == 'CANDIDATE_SAMPLE_CREATED' &&
                      (event['elapsedRealtimeMs'] as int? ?? 0) >=
                          firstQualifying,
                )
                .fold<int>(
                  0,
                  (total, event) =>
                      total + (payloadOf(event)['delta'] as int? ?? 0),
                ),
      'activityEventCountsByType': activityCounts,
      'transitionEnterExitCounts': transitionCounts,
      'serviceToUiFinalValues': finalPayload,
      'hiveFinalValues': payloadOf(
        events.where((event) => event['eventType'] == 'HIVE_WRITE').lastOrNull,
      ),
      'diagnosticDroppedEventCount': events.fold<int>(0, (total, event) {
        final payload = event['payload'];
        return total +
            (payload is Map ? (payload['droppedEventCount'] as int? ?? 0) : 0);
      }),
      'diagnosticErrorCount': events
          .where((event) => event['eventType'] == 'DIAGNOSTIC_ERROR')
          .length,
      'candidateAccountingInvariantPassed': accepted + rejected == candidate,
    };
  }

  Map<String, Object?> _timingSummary(List<Map<String, Object?>> events) {
    Map<Object?, Object?> payloadOf(Map<String, Object?> event) {
      final payload = event['payload'];
      return payload is Map ? payload : const <Object?, Object?>{};
    }

    int count(String type) =>
        events.where((event) => event['eventType'] == type).length;
    List<num> values(String field) => events
        .map((event) => payloadOf(event)[field])
        .whereType<num>()
        .toList(growable: false);
    Map<String, Object?> statistics(String prefix, List<num> samples) {
      if (samples.isEmpty) {
        return <String, Object?>{
          'minimum${prefix}Ms': null,
          'maximum${prefix}Ms': null,
          'average${prefix}Ms': null,
        };
      }
      final total = samples.fold<double>(0, (sum, value) => sum + value);
      return <String, Object?>{
        'minimum${prefix}Ms': samples.reduce((a, b) => a < b ? a : b),
        'maximum${prefix}Ms': samples.reduce((a, b) => a > b ? a : b),
        'average${prefix}Ms': total / samples.length,
      };
    }

    return <String, Object?>{
      'receiverInvocationCount': events
          .where((event) => event['eventType'] == 'TRANSITION_RECEIVER_ENTER')
          .map((event) => payloadOf(event)['receiverInvocationId'])
          .whereType<String>()
          .toSet()
          .length,
      'receiverNullIntentCount': count('TRANSITION_RECEIVER_NULL_INTENT'),
      'receiverNoResultCount': count('TRANSITION_RECEIVER_NO_RESULT'),
      'receiverResultCount': count('TRANSITION_RECEIVER_RESULT_PARSED'),
      'receiverEventCount': count('TRANSITION_RECEIVER_EVENT_PARSED'),
      'receiverQueueSuccessCount': count('TRANSITION_RECEIVER_QUEUE_SUCCESS'),
      'receiverQueueFailureCount': count('TRANSITION_RECEIVER_QUEUE_FAILURE'),
      'receiverErrorCount': count('TRANSITION_RECEIVER_ERROR'),
      ...statistics(
        'TransitionDeliveryDelay',
        values('transitionDeliveryDelayMs'),
      ),
      ...statistics('NativeToDartDelay', values('nativeToDartDelayMs')),
      'timingInvariantFailureCount': _timingInvariantFailures(events).length,
    };
  }

  List<Map<String, Object?>> _timingInvariantFailures(
    List<Map<String, Object?>> events,
  ) {
    final result = <Map<String, Object?>>[];
    for (final event in events) {
      final payload = event['payload'];
      if (payload is! Map || payload['timingInvariantPassed'] != false) {
        continue;
      }
      final failures = payload['timingInvariantFailures'];
      if (failures is! List) continue;
      for (final failure in failures) {
        result.add(<String, Object?>{
          'diagnosticId': event['diagnosticId'],
          'eventType': event['eventType'],
          'source': event['source'],
          'failure': failure.toString(),
        });
      }
    }
    return result;
  }

  bool _isNativeReceiverDiagnostic(Map<String, Object?> event) =>
      event['source'] == 'native-receiver' ||
      event['eventType']?.toString().startsWith('TRANSITION_RECEIVER_') == true;
}
