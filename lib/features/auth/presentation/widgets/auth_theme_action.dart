import 'package:flutter/material.dart';
import 'package:walkingapp/l10n/app_localizations_extension.dart';

import '../../../../core/design_system/components/app_button.dart';
import '../../../../core/preferences/app_settings_controller.dart';

class AuthThemeAction extends StatelessWidget {
  const AuthThemeAction({required this.settingsController, super.key});

  final AppSettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ThemeMode>(
      tooltip: context.l10n.chooseTheme,
      icon: Icon(_icon(settingsController.themeMode)),
      onSelected: settingsController.setThemeMode,
      itemBuilder: (context) => <PopupMenuEntry<ThemeMode>>[
        PopupMenuItem(
          value: ThemeMode.system,
          child: ListTile(
            leading: Icon(Icons.brightness_auto),
            title: Text(context.l10n.systemTheme),
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.light,
          child: ListTile(
            leading: Icon(Icons.light_mode_outlined),
            title: Text(context.l10n.lightTheme),
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: ListTile(
            leading: Icon(Icons.dark_mode_outlined),
            title: Text(context.l10n.darkTheme),
          ),
        ),
      ],
    );
  }

  IconData _icon(ThemeMode mode) => switch (mode) {
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
    ThemeMode.system => Icons.brightness_auto,
  };
}

class PasswordVisibilityButton extends StatelessWidget {
  const PasswordVisibilityButton({
    required this.obscured,
    required this.onPressed,
    super.key,
  });

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: obscured
          ? Icons.visibility_outlined
          : Icons.visibility_off_outlined,
      tooltip: obscured ? context.l10n.showPassword : context.l10n.hidePassword,
      onPressed: onPressed,
    );
  }
}
