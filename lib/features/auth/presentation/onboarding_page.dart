import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import 'widgets/auth_theme_action.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.settingsController,
    required this.onGetStarted,
    required this.onLogin,
    super.key,
  });

  final AppSettingsController settingsController;
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _pages = <_OnboardingContent>[
    _OnboardingContent(
      titlePrefix: 'Step by step\nto a ',
      highlightedTitle: 'better you',
      description:
          'Track your steps, stay active and build a healthier lifestyle.',
      icon: Icons.directions_walk_rounded,
      semanticsLabel: 'A person walking toward a healthier lifestyle',
    ),
    _OnboardingContent(
      titlePrefix: 'Track every move',
      description:
          'See your confirmed steps, activity status and daily progress.',
      icon: Icons.monitor_heart_outlined,
      semanticsLabel: 'Health and activity progress',
    ),
    _OnboardingContent(
      titlePrefix: 'Reach your daily goal',
      description: 'Build consistency and create a healthier daily routine.',
      icon: Icons.flag_rounded,
      semanticsLabel: 'A daily walking goal',
    ),
  ];

  late final PageController _pageController;
  int _activePage = 0;

  bool get _isLastPage => _activePage == _pages.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePrimaryAction() {
    if (_isLastPage) {
      widget.onGetStarted();
      return;
    }
    _pageController.nextPage(
      duration: AppDurations.medium,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: AuthThemeAction(
                  settingsController: widget.settingsController,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (page) {
                      setState(() => _activePage = page);
                    },
                    itemBuilder: (context, index) =>
                        _OnboardingPageContent(content: _pages[index]),
                  ),
                ),
              ),
            ),
            _PageIndicator(pageCount: _pages.length, activePage: _activePage),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 472),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppButton(
                        label: _isLastPage ? 'Get Started' : 'Next',
                        icon: Icons.arrow_forward_rounded,
                        expanded: true,
                        onPressed: _handlePrimaryAction,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          const Text('Already have an account?'),
                          AppButton(
                            label: 'Login',
                            variant: AppButtonVariant.text,
                            onPressed: widget.onLogin,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageContent extends StatelessWidget {
  const _OnboardingPageContent({required this.content});

  final _OnboardingContent content;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: _WalkingIllustration(
                  icon: content.icon,
                  semanticsLabel: content.semanticsLabel,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(text: content.titlePrefix),
                    if (content.highlightedTitle != null)
                      TextSpan(
                        text: content.highlightedTitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                content.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.appTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalkingIllustration extends StatelessWidget {
  const _WalkingIllustration({
    required this.icon,
    required this.semanticsLabel,
  });

  final IconData icon;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: AspectRatio(
        aspectRatio: 1.45,
        child: Container(
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -28,
                  right: -18,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.secondaryContainer.withValues(alpha: 0.72),
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  bottom: 24,
                  child: Icon(
                    Icons.eco_outlined,
                    size: 62,
                    color: scheme.primary.withValues(alpha: 0.55),
                  ),
                ),
                Positioned(
                  right: 30,
                  bottom: 24,
                  child: Icon(
                    Icons.park_outlined,
                    size: 72,
                    color: scheme.primary.withValues(alpha: 0.45),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.02),
                  child: AnimatedSwitcher(
                    duration: AppDurations.medium,
                    child: Container(
                      key: ValueKey<IconData>(icon),
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Icon(icon, size: 66, color: scheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.pageCount, required this.activePage});

  final int pageCount;
  final int activePage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Page ${activePage + 1} of $pageCount',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var index = 0; index < pageCount; index++) ...<Widget>[
            if (index > 0) const SizedBox(width: AppSpacing.sm),
            AnimatedContainer(
              duration: AppDurations.fast,
              curve: Curves.easeOut,
              width: index == activePage ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: index == activePage ? scheme.primary : scheme.outline,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OnboardingContent {
  const _OnboardingContent({
    required this.titlePrefix,
    required this.description,
    required this.icon,
    required this.semanticsLabel,
    this.highlightedTitle,
  });

  final String titlePrefix;
  final String? highlightedTitle;
  final String description;
  final IconData icon;
  final String semanticsLabel;
}
