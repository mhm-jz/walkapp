import 'package:flutter/material.dart';
import 'package:walkingapp/l10n/app_localizations_extension.dart';

import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(context.l10n.about),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Icon(
                      Icons.directions_walk_rounded,
                      size: 48,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'WalkApp',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.aboutPageDescription,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.appTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    child: Column(
                      children: <Widget>[
                        _AboutRow(
                          icon: Icons.palette_outlined,
                          title: context.l10n.materialThreeDesign,
                          description: context.l10n.materialThreeDescription,
                        ),
                        Divider(height: AppSpacing.xl),
                        _AboutRow(
                          icon: Icons.shield_outlined,
                          title: context.l10n.localPreferences,
                          description: context.l10n.localPreferencesDescription,
                        ),
                        Divider(height: AppSpacing.xl),
                        _AboutRow(
                          icon: Icons.directions_walk_outlined,
                          title: context.l10n.purposefulTracking,
                          description:
                              context.l10n.purposefulTrackingDescription,
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
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({
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
        Icon(icon, color: Theme.of(context).colorScheme.primary),
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
