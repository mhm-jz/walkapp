import 'package:flutter/material.dart';
import 'package:walkingapp/l10n/app_localizations_extension.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/embedded_destination_page.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../about/presentation/about_page.dart';
import '../../achievements/presentation/achievements_page.dart';
import '../../history/presentation/history_page.dart';
import '../../history/domain/daily_step_record.dart';
import '../../insights/presentation/insights_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../step_counter/presentation/step_counter_controller.dart';
import '../../history/application/daily_step_history_controller.dart';
import '../../campaigns/application/campaign_enrollment_controller.dart';
import '../../achievements/domain/health_achievement.dart';
import '../../campaigns/presentation/campaign_formatters.dart';
import '../../notifications/application/notification_controller.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({
    required this.controller,
    required this.settingsController,
    required this.historyController,
    required this.campaignController,
    required this.onLogout,
    required this.notificationController,
    required this.onOpenNotifications,
    super.key,
  });

  final StepCounterController controller;
  final AppSettingsController settingsController;
  final DailyStepHistoryController historyController;
  final CampaignEnrollmentController campaignController;
  final VoidCallback onLogout;
  final NotificationController notificationController;
  final VoidCallback onOpenNotifications;

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          controller,
          settingsController,
          historyController,
          campaignController,
          notificationController,
        ]),
        builder: (context, child) {
          final historyReady =
              historyController.viewState == DailyHistoryViewState.ready;
          final now = DateTime.now();
          final monday = DateUtils.dateOnly(
            now.subtract(Duration(days: now.weekday - 1)),
          );
          final weekRecords =
              (historyReady
                      ? historyController.recentRecords
                      : const <DailyStepRecord>[])
                  .where((record) {
                    final date = DailyStepHistoryController.parseDate(
                      record.date,
                    );
                    return !date.isBefore(monday) &&
                        !date.isAfter(monday.add(const Duration(days: 6)));
                  })
                  .toList(growable: false);
          final achievements = HealthAchievementEvaluator.evaluate(
            records: historyReady
                ? historyController.recentRecords
                : const <DailyStepRecord>[],
            enrollments: campaignController.enrollments,
          );
          final unlocked = achievements
              .where((achievement) => achievement.isUnlocked)
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSizes.contentMaxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      context.l10n.progress,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.progressPageDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (historyController.viewState ==
                        DailyHistoryViewState.loading)
                      AppCard(
                        child: AppLoadingIndicator(
                          label: context.l10n.loadingProgressSummary,
                        ),
                      )
                    else if (historyController.viewState ==
                        DailyHistoryViewState.error)
                      AppCard(
                        child: AppErrorView(
                          message:
                              historyController.userMessage ??
                              context.l10n.progressHistoryUnavailable,
                          compact: true,
                          onRetry: historyController.retry,
                        ),
                      )
                    else
                      _ProgressSummary(
                        weeklyConfirmed: historyController.totalFor(
                          weekRecords,
                        ),
                        weeklyGoalDays: historyController.goalDaysFor(
                          weekRecords,
                        ),
                        currentStreak: historyController.currentGoalStreak(),
                        lifetimeConfirmed:
                            historyController.lifetimeConfirmedSteps,
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionTitle(title: context.l10n.yourProgress),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: <Widget>[
                          _DestinationRow(
                            icon: Icons.notifications_outlined,
                            title: context.l10n.notifications,
                            description: context.l10n.unreadNotificationCount(
                              notificationController.unreadCount,
                            ),
                            onTap: onOpenNotifications,
                          ),
                          const Divider(height: 1),
                          _DestinationRow(
                            icon: Icons.history,
                            title: context.l10n.history,
                            description: historyReady
                                ? context.l10n.localDayCount(
                                    historyController.recordsForDays(7).length,
                                  )
                                : context.l10n.historyMetricsUnavailable,
                            onTap: () => _openPage(
                              context,
                              EmbeddedDestinationPage(
                                title: context.l10n.history,
                                bodyBuilder: (showHeading) => HistoryPage(
                                  controller: historyController,
                                  showHeading: showHeading,
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          _DestinationRow(
                            icon: Icons.insights_outlined,
                            title: context.l10n.insights,
                            description: historyReady
                                ? context.l10n.goalDaysThisWeek(
                                    historyController.goalDaysFor(weekRecords),
                                  )
                                : context.l10n.insightsHistoryUnavailable,
                            onTap: () => _openPage(
                              context,
                              EmbeddedDestinationPage(
                                title: context.l10n.insights,
                                bodyBuilder: (showHeading) => InsightsPage(
                                  controller: controller,
                                  settingsController: settingsController,
                                  historyController: historyController,
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          _DestinationRow(
                            icon: Icons.emoji_events_outlined,
                            title: context.l10n.achievements,
                            description: context.l10n.achievementsUnlocked(
                              unlocked,
                            ),
                            onTap: () => _openPage(
                              context,
                              AchievementsPage(
                                controller: controller,
                                historyController: historyController,
                                campaignController: campaignController,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionTitle(title: context.l10n.yourAccount),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: <Widget>[
                          _DestinationRow(
                            icon: Icons.person_outline,
                            title: context.l10n.profile,
                            description: context.l10n.manageProfileDescription,
                            onTap: () => _openPage(
                              context,
                              ProfilePage(
                                settingsController: settingsController,
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          _DestinationRow(
                            icon: Icons.settings_outlined,
                            title: context.l10n.settings,
                            description: context.l10n.settingsDescription,
                            onTap: () => _openPage(
                              context,
                              EmbeddedDestinationPage(
                                title: context.l10n.settings,
                                bodyBuilder: (showHeading) => SettingsPage(
                                  settingsController: settingsController,
                                  onLogout: onLogout,
                                  showHeading: showHeading,
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          _DestinationRow(
                            icon: Icons.info_outline,
                            title: context.l10n.about,
                            description:
                                context.l10n.aboutDestinationDescription,
                            onTap: () => _openPage(context, const AboutPage()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({
    required this.weeklyConfirmed,
    required this.weeklyGoalDays,
    required this.currentStreak,
    required this.lifetimeConfirmed,
  });

  final int weeklyConfirmed;
  final int weeklyGoalDays;
  final int currentStreak;
  final int lifetimeConfirmed;

  @override
  Widget build(BuildContext context) {
    final metrics = <({String label, String value})>[
      (
        label: context.l10n.confirmedThisWeek,
        value: formatCampaignNumber(weeklyConfirmed),
      ),
      (label: context.l10n.goalDaysThisWeekLabel, value: '$weeklyGoalDays'),
      (
        label: context.l10n.currentGoalStreak,
        value: context.l10n.dayCount(currentStreak),
      ),
      (
        label: context.l10n.recordedOnDevice,
        value: formatCampaignNumber(lifetimeConfirmed),
      ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            context.l10n.localProgressSummary,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - AppSpacing.md) / 2;
              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.lg,
                children: <Widget>[
                  for (final metric in metrics)
                    SizedBox(
                      width: itemWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FittedBox(
                            child: Text(
                              metric.value,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            metric.label,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: context.appTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
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

class _DestinationRow extends StatelessWidget {
  const _DestinationRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: AppSizes.minTouchTarget,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
