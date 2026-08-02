import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'step_diagnostic_config.dart';
import 'step_diagnostic_event.dart';
import 'step_diagnostic_session.dart';
import 'step_diagnostic_store.dart';

final class StepDiagnosticLogger {
  StepDiagnosticLogger._(
    this.sessionId,
    this.source,
    this.store,
    this.startedAtUtc,
    int? sessionStartedElapsedRealtimeMs,
  ) : sessionStartedElapsedRealtimeMs =
          sessionStartedElapsedRealtimeMs ?? _platformElapsedRealtimeMs(),
      _recordingAnchorElapsedRealtimeMs = _platformElapsedRealtimeMs(),
      _clock = Stopwatch()..start();
  final String sessionId;
  final String source;
  final StepDiagnosticStore store;
  final DateTime startedAtUtc;
  final int sessionStartedElapsedRealtimeMs;
  final int _recordingAnchorElapsedRealtimeMs;
  final Stopwatch _clock;
  final List<String> _buffer = <String>[];
  int _sequence = 0;
  int droppedEventCount = 0;
  int errorCount = 0;
  Timer? _timer;

  static String newId() {
    final utc = DateTime.now().toUtc().toIso8601String().replaceAll(':', '');
    final suffix = Random.secure()
        .nextInt(0x1000000)
        .toRadixString(16)
        .padLeft(6, '0');
    return 'sampling-$utc-$suffix';
  }

  static int _platformElapsedRealtimeMs() {
    if (!Platform.isAndroid) return 0;
    try {
      final seconds = double.parse(
        File('/proc/uptime').readAsStringSync().split(RegExp(r'\s+')).first,
      );
      return (seconds * 1000).round();
    } catch (_) {
      return 0;
    }
  }

  static Future<StepDiagnosticLogger?> create({
    required String supportPath,
    required String source,
    String? sessionId,
    bool createSession = false,
    int? sessionStartedElapsedRealtimeMs,
  }) async {
    if (!StepDiagnosticConfig.enabled) return null;
    try {
      final id = sessionId ?? newId();
      final store = StepDiagnosticStore(supportPath);
      final logger = StepDiagnosticLogger._(
        id,
        source,
        store,
        DateTime.now().toUtc(),
        sessionStartedElapsedRealtimeMs,
      );
      if (createSession) {
        await store.writeJson(
          store.session(id),
          StepDiagnosticSession(
            id: id,
            startedAtUtc: logger.startedAtUtc,
            active: true,
          ).toJson(),
        );
      }
      logger._timer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => unawaited(logger.flush()),
      );
      return logger;
    } catch (_) {
      return null;
    }
  }

  int get nowElapsedMs =>
      _recordingAnchorElapsedRealtimeMs + _clock.elapsedMilliseconds;
  void record(
    String type, {
    Map<String, Object?> payload = const {},
    int? windowId,
    int? bucketIndex,
    bool flush = false,
  }) {
    if (_buffer.length >= StepDiagnosticConfig.maxQueuedEvents) {
      droppedEventCount++;
      return;
    }
    try {
      _buffer.add(
        jsonEncode(
          StepDiagnosticEvent(
            sessionId: sessionId,
            eventType: type,
            sequenceNumber: ++_sequence,
            source: source,
            recordedAtElapsedRealtimeMs: nowElapsedMs,
            recordedAtWallClockUtc: DateTime.now().toUtc(),
            sessionStartedElapsedRealtimeMs: sessionStartedElapsedRealtimeMs,
            windowId: windowId,
            bucketIndex: bucketIndex,
            payload: payload,
          ).toJson(),
        ),
      );
      if (flush) unawaited(this.flush());
    } catch (_) {
      errorCount++;
    }
  }

  Future<void> flush() async {
    if (_buffer.isEmpty) return;
    final batch = List<String>.of(_buffer);
    _buffer.clear();
    try {
      final file = store.events(sessionId, source);
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
  }

  Future<void> close({bool finalize = false, bool incomplete = false}) async {
    record(
      StepDiagnosticEventType.sessionFinalized,
      payload: {
        'diagnosticDroppedEventCount': droppedEventCount,
        'diagnosticErrorCount': errorCount,
      },
    );
    _timer?.cancel();
    await flush();
    if (finalize) {
      await store.finalize(sessionId, startedAtUtc, incomplete: incomplete);
    }
  }
}
