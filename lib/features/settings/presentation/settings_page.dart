import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../step_counter/presentation/widgets/daily_goal_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.settingsController,
    required this.onLogout,
    super.key,
  });

  final AppSettingsController settingsController;
  final VoidCallback onLogout;

  Future<void> _editGoal(BuildContext context) async {
    final goal = await DailyGoalSheet.show(
      context,
      currentGoal: settingsController.dailyGoal,
    );
    if (goal == null || !context.mounted) return;
    await settingsController.setDailyGoal(goal);
    if (context.mounted) AppSnackbar.show(context, 'Daily goal updated');
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await AppDialog.show<bool>(
      context,
      title: 'Log out?',
      content: const Text(
        'You’ll return to Login. Your step data and preferences will stay on this device.',
      ),
      actions: <Widget>[
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: 'Log out',
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
      bottom: false,
      child: AnimatedBuilder(
        animation: settingsController,
        builder: (context, child) => CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.contentMaxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          'Settings',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Personalize your walking experience.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: context.appTheme.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: 'Appearance'),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: <Widget>[
                              _themeButton(
                                mode: ThemeMode.system,
                                label: 'System',
                                icon: Icons.brightness_auto,
                              ),
                              _themeButton(
                                mode: ThemeMode.light,
                                label: 'Light',
                                icon: Icons.light_mode_outlined,
                              ),
                              _themeButton(
                                mode: ThemeMode.dark,
                                label: 'Dark',
                                icon: Icons.dark_mode_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: 'Daily goal'),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.flag_outlined,
                                color: context.appTheme.warning,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${settingsController.dailyGoal} steps',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    Text(
                                      'Your persisted target for each day',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color:
                                                context.appTheme.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              AppIconButton(
                                icon: Icons.edit_outlined,
                                tooltip: 'Edit daily goal',
                                onPressed: () => _editGoal(context),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: 'Tracking information'),
                        const SizedBox(height: AppSpacing.sm),
                        const AppCard(
                          child: Column(
                            children: <Widget>[
                              _InformationRow(
                                icon: Icons.phone_android_outlined,
                                title: 'Background tracking',
                                description:
                                    'Steps continue to be processed while tracking is active.',
                              ),
                              Divider(height: AppSpacing.xl),
                              _InformationRow(
                                icon: Icons.fact_check_outlined,
                                title: 'Step validation',
                                description:
                                    'Candidate steps are confirmed using activity information.',
                              ),
                              Divider(height: AppSpacing.xl),
                              _InformationRow(
                                icon: Icons.directions_walk_outlined,
                                title: 'Activity detection',
                                description:
                                    'Walking, running, cycling, and vehicle activity help validate steps.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: 'About'),
                        const SizedBox(height: AppSpacing.sm),
                        const AppCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.directions_walk_rounded),
                              SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'WalkApp',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'A focused step tracker for building a healthier daily routine.',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: 'Account'),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: AppStatusChip(
                                  label: 'Local profile',
                                  status: AppStatus.neutral,
                                  icon: Icons.person_outline,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppButton(
                                label: 'Log out',
                                variant: AppButtonVariant.destructive,
                                icon: Icons.logout,
                                expanded: true,
                                onPressed: () => _confirmLogout(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeButton({
    required ThemeMode mode,
    required String label,
    required IconData icon,
  }) {
    final selected = settingsController.themeMode == mode;
    return AppButton(
      label: label,
      icon: selected ? Icons.check : icon,
      variant: selected
          ? AppButtonVariant.secondary
          : AppButtonVariant.outlined,
      onPressed: () => settingsController.setThemeMode(mode),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(description),
            ],
          ),
        ),
      ],
    );
  }
}
