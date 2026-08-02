import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../l10n/app_localizations.dart';
import 'step_diagnostic_exporter.dart';
import 'step_diagnostic_store.dart';

final class StepDiagnosticsPage extends StatefulWidget {
  const StepDiagnosticsPage({super.key});
  @override
  State<StepDiagnosticsPage> createState() => _State();
}

final class _State extends State<StepDiagnosticsPage> {
  StepDiagnosticStore? store;
  List<Map<String, Object?>> sessions = const [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dir = await getApplicationSupportDirectory();
    final next = StepDiagnosticStore(dir.path);
    final values = (await next.sessions())
        .where((e) => e['active'] != true)
        .toList();
    if (mounted) {
      setState(() {
        store = next;
        sessions = values;
      });
    }
  }

  Future<void> _edit(String id) async {
    final l = AppLocalizations.of(context);
    final name = TextEditingController();
    final steps = TextEditingController();
    final route = TextEditingController();
    final notes = TextEditingController();
    final placement = TextEditingController();
    final scenario = TextEditingController(text: 'CUSTOM');
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.diagnosticEdit),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(labelText: l.diagnosticTestName),
              ),
              TextField(
                controller: steps,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(labelText: l.diagnosticManualSteps),
              ),
              TextField(
                controller: route,
                decoration: InputDecoration(labelText: l.diagnosticRoute),
              ),
              TextField(
                controller: notes,
                decoration: InputDecoration(labelText: l.diagnosticNotes),
              ),
              TextField(
                controller: placement,
                decoration: InputDecoration(
                  labelText: l.diagnosticPhonePlacement,
                ),
              ),
              TextField(
                controller: scenario,
                decoration: InputDecoration(labelText: l.diagnosticScenario),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              final count = steps.text.isEmpty
                  ? null
                  : int.tryParse(steps.text);
              if ((steps.text.isNotEmpty && count == null) ||
                  (count != null && count < 0)) {
                return;
              }
              Navigator.pop(context, true);
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (save == true) {
      await store!.writeJson(store!.metadata(id), {
        'testName': name.text.trim(),
        'manuallyCountedSteps': steps.text.isEmpty
            ? null
            : int.parse(steps.text),
        'routeDescription': route.text.trim(),
        'testNotes': notes.text.trim(),
        'phonePlacement': placement.text.trim(),
        'testScenario': scenario.text.trim().isEmpty
            ? 'CUSTOM'
            : scenario.text.trim(),
      });
    }
    name.dispose();
    steps.dispose();
    route.dispose();
    notes.dispose();
    placement.dispose();
    scenario.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.diagnosticReports),
        actions: [
          IconButton(
            tooltip: l.diagnosticClear,
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              await store?.clearCompleted();
              await _load();
            },
          ),
        ],
      ),
      body: store == null
          ? const Center(child: CircularProgressIndicator())
          : sessions.isEmpty
          ? Center(child: Text(l.diagnosticNoReports))
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final id = session['sessionId'].toString();
                return FutureBuilder<List<Map<String, Object?>>>(
                  future: StepDiagnosticExporter(store!).events(id),
                  builder: (context, snap) {
                    final events = snap.data ?? const [];
                    int sum(String type, String key) => events
                        .where((e) => e['eventType'] == type)
                        .fold(0, (v, e) {
                          final p = e['payload'];
                          return v + (p is Map ? p[key] as int? ?? 0 : 0);
                        });
                    final candidates = sum('CANDIDATE_SAMPLE_CREATED', 'delta');
                    final accepted = sum(
                      'WINDOW_VALIDATION',
                      'acceptedStepTotal',
                    );
                    final rejected = sum(
                      'WINDOW_VALIDATION',
                      'rejectedStepTotal',
                    );
                    return ListTile(
                      title: Text(
                        session['startedAtUtc'].toString(),
                        textDirection: TextDirection.ltr,
                      ),
                      subtitle: Text(
                        l.diagnosticSummary(candidates, accepted, rejected),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') await _edit(id);
                          if (value == 'export') {
                            await StepDiagnosticExporter(store!).share(id);
                          }
                          if (value == 'delete') {
                            await store!.delete(id);
                            await _load();
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(l.diagnosticEdit),
                          ),
                          PopupMenuItem(
                            value: 'export',
                            child: Text(l.diagnosticExport),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(l.diagnosticDelete),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
