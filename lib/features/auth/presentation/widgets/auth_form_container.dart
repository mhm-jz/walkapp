import 'package:flutter/material.dart';

import '../../../../core/design_system/components/app_card.dart';
import '../../../../core/design_system/tokens/app_tokens.dart';

class AuthFormContainer extends StatelessWidget {
  const AuthFormContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(padding: const EdgeInsets.all(AppSpacing.xl), child: child);
  }
}

class AuthPageLayout extends StatelessWidget {
  const AuthPageLayout({
    required this.header,
    required this.form,
    required this.themeAction,
    required this.backAction,
    super.key,
  });

  final Widget header;
  final Widget form;
  final Widget themeAction;
  final Widget backAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: FocusManager.instance.primaryFocus?.unfocus,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -80,
                right: -70,
                child: IgnorePointer(
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    72,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: AppDurations.medium,
                        curve: Curves.easeOut,
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 12 * (1 - value)),
                            child: child,
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            header,
                            const SizedBox(height: AppSpacing.xl),
                            form,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: themeAction,
              ),
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: backAction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
