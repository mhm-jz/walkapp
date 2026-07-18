import 'package:flutter/material.dart';

import '../extensions/app_theme_extension.dart';

enum AppStatus { success, info, warning, error, neutral }

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    required this.label,
    this.status = AppStatus.neutral,
    this.icon,
    super.key,
  });

  final String label;
  final AppStatus status;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = switch (status) {
      AppStatus.success => context.appTheme.success,
      AppStatus.info => scheme.secondary,
      AppStatus.warning => context.appTheme.warning,
      AppStatus.error => scheme.error,
      AppStatus.neutral => scheme.onSurfaceVariant,
    };
    final foreground = scheme.brightness == Brightness.light
        ? Color.alphaBlend(Colors.black.withValues(alpha: 0.32), base)
        : base;
    return Semantics(
      label: label,
      child: Chip(
        avatar: icon == null ? null : Icon(icon, size: 18, color: foreground),
        label: Text(label),
        backgroundColor: base.withValues(alpha: 0.14),
        labelStyle: TextStyle(color: foreground, fontWeight: FontWeight.w600),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
