import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../data/step_snapshot.dart';
import '../domain/tracking_activity.dart';
import 'step_counter_controller.dart';

class StepCounterPage extends StatefulWidget {
  const StepCounterPage({required this.controller, super.key});

  final StepCounterController controller;

  @override
  State<StepCounterPage> createState() => _StepCounterPageState();
}

class _StepCounterPageState extends State<StepCounterPage> {
  late final StepCounterController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller;

    _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: WithForegroundTask(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('قدم‌شمار'),
            actions: <Widget>[
              IconButton(
                onPressed: _controller.refresh,
                icon: const Icon(Icons.refresh),
                tooltip: 'به‌روزرسانی',
              ),
            ],
          ),
          body: SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final snapshot = _controller.snapshot;
                final shownError = _controller.uiError ?? snapshot.error;

                return RefreshIndicator(
                  onRefresh: _controller.refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: <Widget>[
                      _buildStatusCard(context, snapshot),
                      const SizedBox(height: 16),
                      _buildStepsCard(context, snapshot),
                      const SizedBox(height: 16),
                      _buildActivityCard(context, snapshot),
                      if (shownError != null) ...<Widget>[
                        const SizedBox(height: 16),
                        _buildErrorCard(context, shownError),
                      ],
                      const SizedBox(height: 24),
                      _buildActions(snapshot),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, StepSnapshot snapshot) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundColor: snapshot.isTracking
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              child: Icon(
                snapshot.isTracking ? Icons.directions_walk : Icons.pause,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    snapshot.isTracking ? 'سرویس فعال است' : 'سرویس متوقف است',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _statusDescription(snapshot),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (_controller.isBusy)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsCard(BuildContext context, StepSnapshot snapshot) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: <Widget>[
            Text(
              '${snapshot.displayedSteps}',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text('قدم', style: Theme.of(context).textTheme.titleMedium),
            if (snapshot.provisionalSteps > 0) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                '${snapshot.provisionalSteps} قدم در انتظار بررسی فعالیت',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, StepSnapshot snapshot) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            _infoRow(
              context,
              title: 'فعالیت فعلی',
              value: _activityLabel(snapshot.activity),
            ),
            const Divider(height: 24),
            _infoRow(
              context,
              title: 'اطمینان تشخیص',
              value: _confidenceLabel(snapshot.confidence),
            ),
            const Divider(height: 24),
            _infoRow(
              context,
              title: 'وضعیت سنسور',
              value: snapshot.sensorReady
                  ? 'آماده'
                  : snapshot.isTracking
                  ? 'در انتظار baseline'
                  : 'غیرفعال',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(StepSnapshot snapshot) {
    final busy = _controller.isBusy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!snapshot.isTracking)
          FilledButton.icon(
            onPressed: busy ? null : _controller.start,
            icon: const Icon(Icons.play_arrow),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('شروع شمارش'),
            ),
          )
        else
          FilledButton.tonalIcon(
            onPressed: busy ? null : _controller.stop,
            icon: const Icon(Icons.stop),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('توقف شمارش'),
            ),
          ),
      ],
    );
  }

  String _statusDescription(StepSnapshot snapshot) {
    if (!snapshot.isTracking) {
      return 'در این حالت هیچ قدمی برای اپ ثبت نمی‌شود.';
    }

    if (!snapshot.sensorReady) {
      return 'اولین مقدار سنسور فقط به‌عنوان baseline ثبت می‌شود.';
    }

    return 'شمارش در پس‌زمینه ادامه دارد.';
  }

  String _activityLabel(TrackingActivity value) {
    return switch (value) {
      TrackingActivity.walking => 'پیاده‌روی',
      TrackingActivity.running => 'دویدن',
      TrackingActivity.inVehicle => 'داخل خودرو',
      TrackingActivity.onBicycle => 'دوچرخه',
      TrackingActivity.still => 'بدون حرکت',
      _ => 'نامشخص',
    };
  }

  String _confidenceLabel(TrackingConfidence value) {
    return switch (value) {
      TrackingConfidence.high => 'زیاد',
      TrackingConfidence.medium => 'متوسط',
      _ => 'کم',
    };
  }
}
