import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/components/app_selection.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../step_counter/presentation/widgets/daily_goal_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.settingsController,
    required this.onLogout,
    this.showHeading = true,
    super.key,
  });

  final AppSettingsController settingsController;
  final VoidCallback onLogout;
  final bool showHeading;

  Future<void> _editGoal(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final goal = await DailyGoalSheet.show(
      context,
      currentGoal: settingsController.dailyGoal,
    );
    if (goal == null || !context.mounted) return;
    await settingsController.setDailyGoal(goal);
    if (context.mounted) AppSnackbar.show(context, l10n.dailyGoalUpdated);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.show<bool>(
      context,
      title: l10n.logoutQuestion,
      content: Text(l10n.logoutDescription),
      actions: <Widget>[
        AppButton(
          label: l10n.cancel,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: l10n.logout,
          variant: AppButtonVariant.destructive,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirmed == true && context.mounted) onLogout();
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final minutes = settingsController.inAppDailyGoalReminderTime ?? 18 * 60;
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    if (selected == null) return;
    await settingsController.setInAppDailyGoalReminderTime(
      selected.hour * 60 + selected.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: settingsController,
        builder: (context, child) => CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsetsDirectional.fromSTEB(
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
                        if (showHeading) ...<Widget>[
                          Text(
                            l10n.settings,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                        ],
                        Text(
                          l10n.personalizeWalkingExperience,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: context.appTheme.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: l10n.appearance),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: <Widget>[
                              _themeButton(
                                mode: ThemeMode.system,
                                label: l10n.systemTheme,
                                icon: Icons.brightness_auto,
                              ),
                              _themeButton(
                                mode: ThemeMode.light,
                                label: l10n.lightTheme,
                                icon: Icons.light_mode_outlined,
                              ),
                              _themeButton(
                                mode: ThemeMode.dark,
                                label: l10n.darkTheme,
                                icon: Icons.dark_mode_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: l10n.appLanguage),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: RadioGroup<String>(
                            groupValue: settingsController.locale.languageCode,
                            onChanged: (value) {
                              if (value != null) {
                                settingsController.setLocale(Locale(value));
                              }
                            },
                            child: Column(
                              children: <Widget>[
                                RadioListTile<String>(
                                  value: 'fa',
                                  title: Text(l10n.persianLanguage),
                                ),
                                RadioListTile<String>(
                                  value: 'en',
                                  title: Text(l10n.englishLanguage),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: l10n.dailyGoal),
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
                                      l10n.dailyGoalStepCount(
                                        settingsController.dailyGoal,
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    Text(
                                      l10n.persistedDailyTarget,
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
                                tooltip: l10n.editDailyGoal,
                                onPressed: () => _editGoal(context),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: l10n.inAppNotifications),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  AppSpacing.lg,
                                  AppSpacing.lg,
                                  AppSpacing.lg,
                                  AppSpacing.sm,
                                ),
                                child: Text(
                                  l10n.reminderPrototypeDescription,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: context.appTheme.textSecondary,
                                      ),
                                ),
                              ),
                              AppSwitch(
                                label: l10n.dailyGoalReminder,
                                value: settingsController
                                    .inAppDailyGoalReminderEnabled,
                                onChanged: (value) => settingsController
                                    .setInAppDailyGoalReminder(enabled: value),
                              ),
                              if (settingsController
                                  .inAppDailyGoalReminderEnabled)
                                ListTile(
                                  minTileHeight: AppSizes.minTouchTarget,
                                  leading: const Icon(Icons.schedule_outlined),
                                  title: Text(l10n.reminderTime),
                                  subtitle: Text(
                                    _formatTime(
                                      context,
                                      settingsController
                                              .inAppDailyGoalReminderTime ??
                                          18 * 60,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => _pickReminderTime(context),
                                ),
                              AppSwitch(
                                label: l10n.goalCompletionUpdates,
                                value: settingsController
                                    .inAppGoalCompletionEnabled,
                                onChanged: settingsController
                                    .setInAppGoalCompletionEnabled,
                              ),
                              AppSwitch(
                                label: l10n.campaignUpdates,
                                value: settingsController
                                    .inAppCampaignUpdatesEnabled,
                                onChanged: settingsController
                                    .setInAppCampaignUpdatesEnabled,
                              ),
                              AppSwitch(
                                label: l10n.rewardUpdates,
                                value: settingsController
                                    .inAppRewardUpdatesEnabled,
                                onChanged: settingsController
                                    .setInAppRewardUpdatesEnabled,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: l10n.trackingInformation),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          child: Column(
                            children: <Widget>[
                              _InformationRow(
                                icon: Icons.phone_android_outlined,
                                title: l10n.backgroundTracking,
                                description: l10n.backgroundTrackingDescription,
                              ),
                              Divider(height: AppSpacing.xl),
                              _InformationRow(
                                icon: Icons.fact_check_outlined,
                                title: l10n.stepValidation,
                                description: l10n.stepValidationDescription,
                              ),
                              Divider(height: AppSpacing.xl),
                              _InformationRow(
                                icon: Icons.directions_walk_outlined,
                                title: l10n.activityRecognition,
                                description:
                                    l10n.activityRecognitionDescription,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: l10n.about),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
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
                                    Text(l10n.aboutDescription),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _SectionTitle(title: l10n.account),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: AppStatusChip(
                                  label: l10n.prototypeAccount,
                                  status: AppStatus.neutral,
                                  icon: Icons.person_outline,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppButton(
                                label: l10n.logout,
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

  String _formatTime(BuildContext context, int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);

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
