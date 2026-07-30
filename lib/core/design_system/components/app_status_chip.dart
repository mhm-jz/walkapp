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
    final colors = context.appTheme;
    final (foreground, container) = switch (status) {
      AppStatus.success => (colors.successForeground, colors.successContainer),
      AppStatus.info => (
        colors.informationForeground,
        colors.informationContainer,
      ),
      AppStatus.warning => (colors.warningForeground, colors.warningContainer),
      AppStatus.error => (colors.errorForeground, colors.errorContainer),
      AppStatus.neutral => (colors.neutralForeground, colors.neutralContainer),
    };
    return Chip(
      avatar: icon == null ? null : Icon(icon, size: 18, color: foreground),
      label: Text(label),
      backgroundColor: container,
      labelStyle: TextStyle(color: foreground, fontWeight: FontWeight.w600),
    );
  }
}
