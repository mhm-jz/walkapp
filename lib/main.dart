import 'package:flutter/material.dart';

import 'features/step_counter/presentation/step_counter_page.dart';
import 'features/step_counter/presentation/step_counter_controller.dart';
import 'features/step_counter/data/step_local_store.dart';
import 'features/step_counter/service/step_foreground_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final trackingService = StepForegroundService()..initialize();
  final controller = StepCounterController(
    trackingService: trackingService,
    storeFactory: const AppStepSnapshotStoreFactory(),
  );
  runApp(WalkingApp(controller: controller));
}

class WalkingApp extends StatefulWidget {
  const WalkingApp({required this.controller, super.key});

  final StepCounterController controller;

  @override
  State<WalkingApp> createState() => _WalkingAppState();
}

class _WalkingAppState extends State<WalkingApp> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StepCounterPage(controller: widget.controller),
    );
  }
}
