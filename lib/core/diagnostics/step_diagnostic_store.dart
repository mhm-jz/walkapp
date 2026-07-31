import 'dart:convert';
import 'dart:io';

import 'step_diagnostic_config.dart';
import 'step_diagnostic_session.dart';

final class StepDiagnosticStore {
  StepDiagnosticStore({required this.applicationSupportPath});

  final String applicationSupportPath;

  Directory get directory => Directory('$applicationSupportPath/diagnostics');

  File eventFile(String sessionId, String source) =>
      File('${directory.path}/$sessionId-$source.jsonl');
  File sessionFile(String sessionId) =>
      File('${directory.path}/$sessionId-session.json');
  File summaryFile(String sessionId) =>
      File('${directory.path}/$sessionId-summary.json');
  File metadataFile(String sessionId) =>
      File('${directory.path}/$sessionId-metadata.json');

  Future<void> ensureReady() => directory.create(recursive: true);

  Future<void> writeJson(File file, Map<String, Object?> json) async {
    await ensureReady();
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode(json), flush: true);
    await temporary.rename(file.path);
  }

  Future<Map<String, Object?>> readJson(File file) async {
    if (!await file.exists()) return <String, Object?>{};
    final decoded = jsonDecode(await file.readAsString());
    return decoded is Map
        ? decoded.map<String, Object?>(
            (key, value) => MapEntry(key.toString(), value),
          )
        : <String, Object?>{};
  }

  Future<void> createSession(StepDiagnosticSession session) =>
      writeJson(sessionFile(session.id), session.toJson());

  Future<void> finalizeSession(
    String sessionId, {
    required bool incomplete,
  }) async {
    final existing = StepDiagnosticSession.fromJson(
      await readJson(sessionFile(sessionId)),
    );
    await createSession(
      StepDiagnosticSession(
        id: sessionId,
        startedAtUtc: existing.startedAtUtc,
        endedAtUtc: DateTime.now().toUtc(),
        active: false,
        incomplete: incomplete,
      ),
    );
    await enforceRetention();
  }

  Future<void> recoverIncompleteSessions() async {
    await ensureReady();
    for (final session in await listSessions()) {
      if (session.active) {
        await createSession(
          StepDiagnosticSession(
            id: session.id,
            startedAtUtc: session.startedAtUtc,
            endedAtUtc: DateTime.now().toUtc(),
            active: false,
            incomplete: true,
          ),
        );
      }
    }
  }

  Future<List<StepDiagnosticSession>> listSessions() async {
    await ensureReady();
    final result = <StepDiagnosticSession>[];
    await for (final entity in directory.list()) {
      if (entity is! File || !entity.path.endsWith('-session.json')) continue;
      try {
        final session = StepDiagnosticSession.fromJson(await readJson(entity));
        if (session.id.isNotEmpty) result.add(session);
      } catch (_) {
        // A corrupt diagnostic file must not affect application behavior.
      }
    }
    result.sort((a, b) => b.startedAtUtc.compareTo(a.startedAtUtc));
    return result;
  }

  Future<StepDiagnosticMetadata> readMetadata(String sessionId) async =>
      StepDiagnosticMetadata.fromJson(await readJson(metadataFile(sessionId)));

  Future<void> writeMetadata(
    String sessionId,
    StepDiagnosticMetadata metadata,
  ) => writeJson(metadataFile(sessionId), metadata.toJson());

  Future<void> deleteSession(String sessionId) async {
    await ensureReady();
    await for (final entity in directory.list()) {
      if (entity is File &&
          entity.uri.pathSegments.last.startsWith('$sessionId-')) {
        await entity.delete();
      }
    }
  }

  Future<void> clearCompletedSessions() async {
    for (final session in await listSessions()) {
      if (!session.active) await deleteSession(session.id);
    }
  }

  Future<void> enforceRetention() async {
    final completed = (await listSessions())
        .where((session) => !session.active)
        .toList(growable: false);
    var totalBytes = await _totalBytes();
    for (
      var index = StepDiagnosticConfig.maxCompletedSessions;
      index < completed.length;
      index++
    ) {
      await deleteSession(completed[index].id);
    }
    if (completed.length > StepDiagnosticConfig.maxCompletedSessions) {
      totalBytes = await _totalBytes();
    }
    for (final session in completed.reversed) {
      if (totalBytes <= StepDiagnosticConfig.maxTotalBytes) break;
      if (!await sessionFile(session.id).exists()) continue;
      final bytes = await _sessionBytes(session.id);
      await deleteSession(session.id);
      totalBytes -= bytes;
    }
  }

  Future<int> _totalBytes() async {
    var total = 0;
    await for (final entity in directory.list()) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }

  Future<int> _sessionBytes(String sessionId) async {
    var total = 0;
    await for (final entity in directory.list()) {
      if (entity is File &&
          entity.uri.pathSegments.last.startsWith('$sessionId-')) {
        total += await entity.length();
      }
    }
    return total;
  }
}
