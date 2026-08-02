import 'package:flutter/material.dart';
import 'package:walkingapp/l10n/app_localizations_extension.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';

class AccountMenu extends StatelessWidget {
  const AccountMenu({
    required this.settingsController,
    required this.onProfile,
    required this.onAchievements,
    required this.onSettings,
    required this.onAbout,
    required this.onLogout,
    super.key,
  });

  final AppSettingsController settingsController;
  final VoidCallback onProfile;
  final VoidCallback onAchievements;
  final VoidCallback onSettings;
  final VoidCallback onAbout;
  final VoidCallback onLogout;

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await AppDialog.show<bool>(
      context,
      title: context.l10n.logoutQuestion,
      content: Text(context.l10n.accountLogoutDescription),
      actions: <Widget>[
        AppButton(
          label: context.l10n.cancel,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: context.l10n.logout,
          variant: AppButtonVariant.destructive,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirmed == true && context.mounted) onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: NavigationDrawer(
        selectedIndex: null,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: AnimatedBuilder(
              animation: settingsController,
              builder: (context, child) => Row(
                children: <Widget>[
                  AccountAvatar(
                    fullName: settingsController.profileName,
                    radius: 28,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          settingsController.profileName.isEmpty
                              ? context.l10n.yourProfile
                              : settingsController.profileName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          settingsController.profileEmail.isEmpty
                              ? context.l10n.addNameAndEmail
                              : settingsController.profileEmail,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: context.appTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          NavigationDrawerDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: Text(context.l10n.profile),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events),
            label: Text(context.l10n.achievements),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: Text(context.l10n.settings),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.info_outline),
            selectedIcon: const Icon(Icons.info),
            label: Text(context.l10n.about),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppButton(
              label: context.l10n.logout,
              icon: Icons.logout,
              variant: AppButtonVariant.destructive,
              expanded: true,
              onPressed: () => _confirmLogout(context),
            ),
          ),
        ],
        onDestinationSelected: (index) {
          Navigator.of(context).pop();
          switch (index) {
            case 0:
              onProfile();
            case 1:
              onAchievements();
            case 2:
              onSettings();
            case 3:
              onAbout();
          }
        },
      ),
    );
  }
}

class AccountAvatar extends StatelessWidget {
  const AccountAvatar({required this.fullName, this.radius = 20, super.key});

  final String fullName;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(fullName);
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      child: initials.isEmpty
          ? const Icon(Icons.person_outline)
          : Text(
              initials,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
