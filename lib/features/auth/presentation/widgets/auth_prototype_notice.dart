import 'package:flutter/material.dart';

import '../../../../core/design_system/components/app_card.dart';
import '../../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../../core/design_system/tokens/app_tokens.dart';
import '../../../../l10n/app_localizations_extension.dart';

class AuthPrototypeNotice extends StatelessWidget {
  const AuthPrototypeNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.localMvpAuthentication,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.localMvpAuthenticationDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
