import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../l10n/app_localizations.dart';
import 'step_diagnostic_exporter.dart';
import 'step_diagnostic_session.dart';
import 'step_diagnostic_store.dart';

final class StepDiagnosticsPage extends StatefulWidget {
  const StepDiagnosticsPage({super.key});

  @override
  State<StepDiagnosticsPage> createState() => _StepDiagnosticsPageState();
}

final class _StepDiagnosticsPageState extends State<StepDiagnosticsPage> {
  StepDiagnosticStore? _store;
  List<StepDiagnosticSession> _sessions = const <StepDiagnosticSession>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final directory = await getApplicationSupportDirectory();
    final store = StepDiagnosticStore(applicationSupportPath: directory.path);
    await store.recoverIncompleteSessions();
    final sessions = (await store.listSessions())
        .where((session) => !session.active)
        .toList(growable: false);
    if (!mounted) return;
    setState(() {
      _store = store;
      _sessions = sessions;
    });
  }

  Future<void> _editMetadata(StepDiagnosticSession session) async {
    final store = _store;
    if (store == null) return;
    final existing = await store.readMetadata(session.id);
    if (!mounted) return;
    final testName = TextEditingController(text: existing.testName);
    final steps = TextEditingController(
      text: existing.manuallyCountedSteps?.toString() ?? '',
    );
    final route = TextEditingController(text: existing.routeDescription);
    final notes = TextEditingController(text: existing.notes);
    final l10n = AppLocalizations.of(context);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.diagnosticTestMetadata),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: testName,
                decoration: InputDecoration(labelText: l10n.diagnosticTestName),
              ),
              TextField(
                controller: steps,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: l10n.diagnosticManualSteps,
                ),
              ),
              TextField(
                controller: route,
                decoration: InputDecoration(
                  labelText: l10n.diagnosticRouteDescription,
                ),
              ),
              TextField(
                controller: notes,
                decoration: InputDecoration(labelText: l10n.diagnosticNotes),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final count = steps.text.isEmpty
                  ? null
                  : int.tryParse(steps.text);
              if (count == null && steps.text.isNotEmpty ||
                  count != null && count < 0) {
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (saved == true) {
      await store.writeMetadata(
        session.id,
        StepDiagnosticMetadata(
          testName: testName.text.trim(),
          manuallyCountedSteps: steps.text.isEmpty
              ? null
              : int.parse(steps.text),
          routeDescription: route.text.trim(),
          notes: notes.text.trim(),
        ),
      );
      await _load();
    }
    testName.dispose();
    steps.dispose();
    route.dispose();
    notes.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diagnosticReports),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.diagnosticClearReports,
            onPressed: _sessions.isEmpty
                ? null
                : () async {
                    await _store?.clearCompletedSessions();
                    await _load();
                  },
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: _store == null
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
          ? Center(child: Text(l10n.diagnosticNoReports))
          : ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                return FutureBuilder<Map<String, Object?>>(
                  future: StepDiagnosticExporter(
                    _store!,
                  ).readSummary(session.id),
                  builder: (context, snapshot) {
                    final summary = snapshot.data ?? const <String, Object?>{};
                    return Card(
                      margin: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        8,
                        16,
                        8,
                      ),
                      child: ListTile(
                        title: Text(
                          session.startedAtUtc.toLocal().toString(),
                          textDirection: TextDirection.ltr,
                        ),
                        subtitle: Text(
                          l10n.diagnosticSessionDetails(
                            'transition',
                            (summary['sessionDurationMs'] as int? ?? 0) ~/ 1000,
                            summary['candidateSteps'] as int? ?? 0,
                            summary['acceptedSteps'] as int? ?? 0,
                            summary['rejectedSteps'] as int? ?? 0,
                            summary['confirmedGainedDuringSession'] as int? ??
                                0,
                            summary['manuallyCountedSteps']?.toString() ?? '—',
                          ),
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'metadata') {
                              await _editMetadata(session);
                            } else if (value == 'export') {
                              await StepDiagnosticExporter(
                                _store!,
                              ).exportAndShare(session.id);
                            } else if (value == 'delete') {
                              await _store!.deleteSession(session.id);
                              await _load();
                            }
                          },
                          itemBuilder: (context) => <PopupMenuEntry<String>>[
                            PopupMenuItem(
                              value: 'metadata',
                              child: Text(l10n.diagnosticEditMetadata),
                            ),
                            PopupMenuItem(
                              value: 'export',
                              child: Text(l10n.diagnosticExportReport),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(l10n.diagnosticDeleteSession),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
