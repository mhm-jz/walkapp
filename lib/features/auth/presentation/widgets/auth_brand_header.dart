import 'package:flutter/material.dart';

import '../../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../../core/design_system/tokens/app_tokens.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        Semantics(
          label: 'WalkApp',
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
            ),
            child: Icon(
              Icons.directions_walk_rounded,
              size: 34,
              color: scheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'WalkApp',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: scheme.primary),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: context.appTheme.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
