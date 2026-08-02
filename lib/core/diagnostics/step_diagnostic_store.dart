import 'dart:convert';
import 'dart:io';

import 'step_diagnostic_config.dart';
import 'step_diagnostic_session.dart';

final class StepDiagnosticStore {
  StepDiagnosticStore(this.supportPath);
  final String supportPath;
  Directory get directory => Directory('$supportPath/diagnostics');
  File events(String id, String source) =>
      File('${directory.path}/$id-$source.jsonl');
  File session(String id) => File('${directory.path}/$id-session.json');
  File metadata(String id) => File('${directory.path}/$id-metadata.json');

  Future<void> writeJson(File file, Map<String, Object?> value) async {
    await directory.create(recursive: true);
    await file.writeAsString(jsonEncode(value), flush: true);
  }

  Future<Map<String, Object?>> readJson(File file) async {
    if (!await file.exists()) return <String, Object?>{};
    final decoded = jsonDecode(await file.readAsString());
    return decoded is Map
        ? decoded.map((key, value) => MapEntry(key.toString(), value))
        : <String, Object?>{};
  }

  Future<List<Map<String, Object?>>> sessions() async {
    await directory.create(recursive: true);
    final result = <Map<String, Object?>>[];
    await for (final entity in directory.list()) {
      if (entity is File && entity.path.endsWith('-session.json')) {
        try {
          result.add(await readJson(entity));
        } catch (_) {}
      }
    }
    result.sort(
      (a, b) =>
          b['startedAtUtc'].toString().compareTo(a['startedAtUtc'].toString()),
    );
    return result;
  }

  Future<void> finalize(
    String id,
    DateTime started, {
    bool incomplete = false,
  }) async {
    await writeJson(
      session(id),
      StepDiagnosticSession(
        id: id,
        startedAtUtc: started,
        endedAtUtc: DateTime.now().toUtc(),
        active: false,
        incomplete: incomplete,
      ).toJson(),
    );
    await _retain();
  }

  Future<void> delete(String id) async {
    await directory.create(recursive: true);
    await for (final entity in directory.list()) {
      if (entity is File && entity.uri.pathSegments.last.startsWith('$id-')) {
        await entity.delete();
      }
    }
  }

  Future<void> clearCompleted() async {
    for (final value in await sessions()) {
      if (value['active'] != true) await delete(value['sessionId'].toString());
    }
  }

  Future<void> _retain() async {
    final values = await sessions();
    for (final old in values.skip(StepDiagnosticConfig.maxSessions)) {
      await delete(old['sessionId'].toString());
    }
    var files = await directory
        .list()
        .where((e) => e is File)
        .cast<File>()
        .toList();
    var bytes = 0;
    for (final file in files) {
      bytes += await file.length();
    }
    for (final old in values.reversed) {
      if (bytes <= StepDiagnosticConfig.maxBytes) break;
      await delete(old['sessionId'].toString());
      files = await directory
          .list()
          .where((e) => e is File)
          .cast<File>()
          .toList();
      bytes = 0;
      for (final file in files) {
        bytes += await file.length();
      }
    }
  }
}
