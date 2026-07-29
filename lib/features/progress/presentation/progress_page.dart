import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../about/presentation/about_page.dart';
import '../../achievements/presentation/achievements_page.dart';
import '../../history/presentation/history_page.dart';
import '../../insights/presentation/insights_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../step_counter/presentation/step_counter_controller.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({
    required this.controller,
    required this.settingsController,
    required this.onLogout,
    super.key,
  });

  final StepCounterController controller;
  final AppSettingsController settingsController;
  final VoidCallback onLogout;

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (context) => page));
  }

  Widget _embeddedDestination({required String title, required Widget body}) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(title)),
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          controller,
          settingsController,
        ]),
        builder: (context, child) {
          final snapshot = controller.snapshot;
          final goal = settingsController.dailyGoal;
          final percentage = math.max(
            (snapshot.displayedSteps / goal * 100).round(),
            0,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
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
                      'Progress',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Your health progress and account in one place.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _ProgressSummary(
                      displayedSteps: snapshot.displayedSteps,
                      dailyGoal: goal,
                      percentage: percentage,
                      confirmedSteps: snapshot.confirmedSteps,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionTitle(title: 'Your progress'),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: <Widget>[
                          _DestinationRow(
                            icon: Icons.history,
                            title: 'History',
                            description:
                                'Review completed walking days and goals.',
                            onTap: () => _openPage(
                              context,
                              _embeddedDestination(
                                title: 'History',
                                body: const HistoryPage(),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          _DestinationRow(
                            icon: Icons.insights_outlined,
                            title: 'Insights',
                            description:
                                'Explore today’s activity and goal progress.',
                            onTap: () => _openPage(
                              context,
                              _embeddedDestination(
                                title: 'Insights',
                                body: InsightsPage(
                                  controller: controller,
                                  settingsController: settingsController,
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          _DestinationRow(
                            icon: Icons.emoji_events_outlined,
                            title: 'Achievements',
                            description:
                                'See milestones reached with confirmed steps.',
                            onTap: () => _openPage(
                              context,
                              AchievementsPage(controller: controller),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _SectionTitle(title: 'Your account'),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: <Widget>[
                          _DestinationRow(
                            icon: Icons.person_outline,
                            title: 'Profile',
                            description:
                                'Manage your name and contact details.',
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
                            title: 'Settings',
                            description:
                                'Adjust your goal, theme, and preferences.',
                            onTap: () => _openPage(
                              context,
                              _embeddedDestination(
                                title: 'Settings',
                                body: SettingsPage(
                                  settingsController: settingsController,
                                  onLogout: onLogout,
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          _DestinationRow(
                            icon: Icons.info_outline,
                            title: 'About',
                            description:
                                'Learn more about WalkApp and tracking.',
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
    required this.displayedSteps,
    required this.dailyGoal,
    required this.percentage,
    required this.confirmedSteps,
  });

  final int displayedSteps;
  final int dailyGoal;
  final int percentage;
  final int confirmedSteps;

  @override
  Widget build(BuildContext context) {
    final metrics = <({String label, String value})>[
      (label: 'Today', value: '$displayedSteps'),
      (label: 'Daily goal', value: '$dailyGoal'),
      (label: 'Goal complete', value: '$percentage%'),
      (label: 'Confirmed', value: '$confirmedSteps'),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Today’s summary',
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
