import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'step_diagnostic_config.dart';
import 'step_diagnostic_event.dart';
import 'step_diagnostic_session.dart';
import 'step_diagnostic_store.dart';

final class StepDiagnosticLogger {
  StepDiagnosticLogger._({
    required this.sessionId,
    required this.source,
    required this.store,
    required this.startedAtUtc,
    required this.sessionStartElapsedRealtimeMs,
    required this._recordingClockAnchorElapsedRealtimeMs,
  });

  final String sessionId;
  final String source;
  final StepDiagnosticStore store;
  final DateTime startedAtUtc;
  int? sessionStartElapsedRealtimeMs;
  Stopwatch? _recordingClock;
  int? _recordingClockAnchorElapsedRealtimeMs;
  final List<String> _buffer = <String>[];
  Future<void> _writeChain = Future<void>.value();
  Timer? _flushTimer;
  int _sequence = 0;
  int droppedEventCount = 0;
  int errorCount = 0;
  final Set<String> _importedDiagnosticIds = <String>{};
  bool _closed = false;

  static String createSessionId([DateTime? now]) {
    final timestamp = (now ?? DateTime.now()).toUtc();
    final compact = timestamp
        .toIso8601String()
        .replaceAll('-', '')
        .replaceAll(':', '')
        .replaceAll('.000', '');
    final suffix = Random.secure()
        .nextInt(0x1000000)
        .toRadixString(16)
        .padLeft(6, '0');
    return '${StepDiagnosticConfig.validationMode}-$compact-$suffix';
  }

  static Future<StepDiagnosticLogger?> create({
    required String applicationSupportPath,
    required String source,
    String? sessionId,
    int? sessionStartElapsedRealtimeMs,
    int? recordingClockAnchorElapsedRealtimeMs,
    bool createDescriptor = false,
  }) async {
    if (!StepDiagnosticConfig.enabled) return null;
    try {
      final startedAt = DateTime.now().toUtc();
      final id = sessionId ?? createSessionId(startedAt);
      final store = StepDiagnosticStore(
        applicationSupportPath: applicationSupportPath,
      );
      await store.ensureReady();
      if (createDescriptor) {
        await store.recoverIncompleteSessions();
        await store.createSession(
          StepDiagnosticSession(
            id: id,
            startedAtUtc: startedAt,
            active: true,
            incomplete: false,
          ),
        );
      }
      final logger = StepDiagnosticLogger._(
        sessionId: id,
        source: source,
        store: store,
        startedAtUtc: startedAt,
        sessionStartElapsedRealtimeMs: sessionStartElapsedRealtimeMs,
        recordingClockAnchorElapsedRealtimeMs:
            recordingClockAnchorElapsedRealtimeMs ??
            sessionStartElapsedRealtimeMs,
      );
      final existingFile = store.eventFile(id, source);
      if (await existingFile.exists()) {
        for (final line in await existingFile.readAsLines()) {
          try {
            final decoded = jsonDecode(line);
            if (decoded is Map && decoded['diagnosticId'] != null) {
              logger._importedDiagnosticIds.add(
                decoded['diagnosticId'].toString(),
              );
            }
          } catch (_) {
            // Existing valid diagnostics remain usable when one line is bad.
          }
        }
      }
      if (sessionStartElapsedRealtimeMs != null) {
        logger._recordingClock = Stopwatch()..start();
      }
      logger._flushTimer = Timer.periodic(
        StepDiagnosticConfig.flushInterval,
        (_) => unawaited(logger.flush()),
      );
      return logger;
    } catch (_) {
      return null;
    }
  }

  void record(
    String eventType, {
    Map<String, Object?> payload = const <String, Object?>{},
    int? elapsedRealtimeMs,
    int? windowId,
    int? bucketIndex,
    bool flush = false,
  }) {
    if (_closed) return;
    if (_buffer.length >= StepDiagnosticConfig.maxQueuedEvents) {
      droppedEventCount++;
      return;
    }
    try {
      final recordedAtElapsedRealtimeMs =
          _recordingClockAnchorElapsedRealtimeMs == null
          ? null
          : _recordingClockAnchorElapsedRealtimeMs! +
                (_recordingClock?.elapsedMilliseconds ?? 0);
      final event = StepDiagnosticEvent(
        sessionId: sessionId,
        eventType: eventType,
        sequenceNumber: ++_sequence,
        source: source,
        wallClockUtc: DateTime.now().toUtc(),
        elapsedRealtimeMs: elapsedRealtimeMs,
        recordedAtElapsedRealtimeMs: recordedAtElapsedRealtimeMs,
        sessionStartedElapsedRealtimeMs: sessionStartElapsedRealtimeMs,
        sessionOffsetMs:
            recordedAtElapsedRealtimeMs == null ||
                sessionStartElapsedRealtimeMs == null
            ? null
            : recordedAtElapsedRealtimeMs - sessionStartElapsedRealtimeMs!,
        windowId: windowId,
        bucketIndex: bucketIndex,
        payload: payload,
      );
      _buffer.add(jsonEncode(event.toJson()));
      if (flush) unawaited(this.flush());
    } catch (_) {
      errorCount++;
    }
  }

  void attachMonotonicSessionClock(int sessionStartElapsedRealtimeMs) {
    this.sessionStartElapsedRealtimeMs ??= sessionStartElapsedRealtimeMs;
    _recordingClockAnchorElapsedRealtimeMs ??= sessionStartElapsedRealtimeMs;
    _recordingClock ??= Stopwatch()..start();
  }

  bool importPersistedEvent(Map<String, Object?> event) {
    if (_closed || event['sessionId'] != sessionId) return false;
    final diagnosticId = event['diagnosticId']?.toString();
    if (diagnosticId == null || !_importedDiagnosticIds.add(diagnosticId)) {
      return false;
    }
    if (_buffer.length >= StepDiagnosticConfig.maxQueuedEvents) {
      droppedEventCount++;
      _importedDiagnosticIds.remove(diagnosticId);
      return false;
    }
    _buffer.add(jsonEncode(event));
    return true;
  }

  bool hasImportedDiagnosticId(String diagnosticId) =>
      _importedDiagnosticIds.contains(diagnosticId);

  Future<void> flush() async {
    if (_buffer.isEmpty) return;
    final batch = List<String>.of(_buffer);
    _buffer.clear();
    _writeChain = _writeChain.then<void>((_) async {
      try {
        final file = store.eventFile(sessionId, source);
        await file.parent.create(recursive: true);
        await file.writeAsString(
          '${batch.join('\n')}\n',
          mode: FileMode.append,
          flush: true,
        );
      } catch (_) {
        errorCount++;
        droppedEventCount += batch.length;
      }
    });
    await _writeChain;
  }

  Future<void> close({bool finalize = false, bool incomplete = false}) async {
    if (_closed) return;
    record(
      StepDiagnosticEventType.sessionFinalized,
      payload: <String, Object?>{
        'droppedEventCount': droppedEventCount,
        'diagnosticErrorCount': errorCount,
        'incomplete': incomplete,
      },
    );
    _closed = true;
    _flushTimer?.cancel();
    await flush();
    await _writeChain;
    if (finalize) {
      await store.finalizeSession(sessionId, incomplete: incomplete);
    }
  }
}
