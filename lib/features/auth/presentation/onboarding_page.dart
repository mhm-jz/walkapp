import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_fields.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../../l10n/app_localizations_extension.dart';
import '../../../core/preferences/personalization_options.dart';
import '../../step_counter/domain/step_tracking_service.dart';
import '../../step_counter/presentation/step_counter_controller.dart';
import '../../step_counter/presentation/widgets/daily_goal_sheet.dart';
import 'onboarding_controller.dart';
import 'widgets/auth_theme_action.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.settingsController,
    required this.stepController,
    required this.onGetStarted,
    super.key,
  });

  final AppSettingsController settingsController;
  final StepCounterController stepController;
  final VoidCallback onGetStarted;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController(
      settingsController: widget.settingsController,
      stepController: widget.stepController,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _customGoal() async {
    final goal = await DailyGoalSheet.show(
      context,
      currentGoal: _controller.selectedGoal,
    );
    if (goal != null) _controller.selectGoal(goal);
  }

  Future<void> _primary() async {
    if (!_controller.isLastStep) {
      if (!_controller.canContinue) {
        AppSnackbar.show(
          context,
          context.l10n.chooseInterestError,
          isError: true,
        );
        return;
      }
      _controller.next();
      return;
    }
    final completed = await _controller.complete();
    if (completed && mounted) widget.onGetStarted();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _controller.step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _controller.previous();
      },
      child: Scaffold(
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.sm,
                    0,
                  ),
                  child: Row(
                    children: <Widget>[
                      if (_controller.step > 0)
                        AppIconButton(
                          icon: Icons.arrow_back,
                          tooltip: context.l10n.previousSetupStep,
                          onPressed: _controller.isBusy
                              ? null
                              : _controller.previous,
                        )
                      else
                        const SizedBox(width: AppSizes.minTouchTarget),
                      Expanded(
                        child: Semantics(
                          label: context.l10n.setupStepProgress(
                            _controller.step + 1,
                            6,
                          ),
                          child: LinearProgressIndicator(
                            value: (_controller.step + 1) / 6,
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AuthThemeAction(
                        settingsController: widget.settingsController,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppDurations.medium,
                    child: SingleChildScrollView(
                      key: ValueKey<int>(_controller.step),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: _stepContent(),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_controller.userMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: AppErrorView(
                      message: _controller.userMessage!,
                      compact: true,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: AppButton(
                        label: _controller.isLastStep
                            ? context.l10n.continueToAccountSetup
                            : context.l10n.continueAction,
                        icon: Icons.arrow_forward,
                        expanded: true,
                        isLoading: _controller.isBusy,
                        onPressed: _controller.isBusy ? null : _primary,
                      ),
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

  Widget _stepContent() => switch (_controller.step) {
    0 => const _IntroStep(),
    1 => _GoalStep(controller: _controller, onCustom: _customGoal),
    2 => _InterestsStep(controller: _controller),
    3 => _CityStep(controller: _controller),
    4 => _PermissionStep(controller: _controller),
    _ => _CompletionStep(controller: _controller),
  };
}

class _IntroStep extends StatelessWidget {
  const _IntroStep();

  @override
  Widget build(BuildContext context) => _StepLayout(
    icon: Icons.directions_walk_rounded,
    title: context.l10n.walkTowardHealthierHabits,
    message: context.l10n.onboardingIntroDescription,
    child: AppCard(
      child: Column(
        children: <Widget>[
          _Pillar(
            icon: Icons.monitor_heart_outlined,
            text: context.l10n.trackDailyProgress,
          ),
          Divider(height: AppSpacing.xl),
          _Pillar(
            icon: Icons.flag_outlined,
            text: context.l10n.buildHabitsWithGoal,
          ),
          Divider(height: AppSpacing.xl),
          _Pillar(
            icon: Icons.campaign_outlined,
            text: context.l10n.joinOptionalCampaigns,
          ),
        ],
      ),
    ),
  );
}

class _GoalStep extends StatelessWidget {
  const _GoalStep({required this.controller, required this.onCustom});
  final OnboardingController controller;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final goals = <(int, String)>[
      (5000, context.l10n.comfortableStartingPoint),
      (7500, context.l10n.balancedEverydayGoal),
      (10000, context.l10n.popularActiveTarget),
      (12000, context.l10n.activeWalkerGoal),
    ];
    return _StepLayout(
      icon: Icons.flag_outlined,
      title: context.l10n.chooseDailyGoal,
      message: context.l10n.chooseDailyGoalDescription,
      child: RadioGroup<int>(
        groupValue: controller.selectedGoal,
        onChanged: (value) {
          if (value != null) controller.selectGoal(value);
        },
        child: Column(
          children: <Widget>[
            for (final goal in goals)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  child: RadioListTile<int>(
                    value: goal.$1,
                    title: Text(context.l10n.stepCount(goal.$1)),
                    subtitle: Text(goal.$2),
                  ),
                ),
              ),
            AppButton(
              label: context.l10n.customGoal,
              variant: AppButtonVariant.outlined,
              onPressed: onCustom,
            ),
          ],
        ),
      ),
    );
  }
}

class _InterestsStep extends StatelessWidget {
  const _InterestsStep({required this.controller});
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final values = <String>[
      ...PersonalizationOptions.rewardInterests,
      PersonalizationOptions.noPreference,
    ];
    return _StepLayout(
      icon: Icons.interests_outlined,
      title: context.l10n.whatInterestsYou,
      message: context.l10n.interestsDescription,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          for (final value in values)
            Semantics(
              selected: controller.selectedInterests.contains(value),
              child: FilterChip(
                label: Text(_personalizationLabel(context, value)),
                selected: controller.selectedInterests.contains(value),
                onSelected: (_) => controller.toggleInterest(value),
              ),
            ),
        ],
      ),
    );
  }
}

class _CityStep extends StatelessWidget {
  const _CityStep({required this.controller});
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) => _StepLayout(
    icon: Icons.location_city_outlined,
    title: context.l10n.chooseYourCity,
    message: context.l10n.citySelectionDescription,
    child: AppDropdownField<String>(
      label: context.l10n.city,
      value: controller.selectedCity,
      items: <DropdownMenuItem<String>>[
        for (final city in PersonalizationOptions.cities)
          DropdownMenuItem<String>(
            value: city,
            child: Text(_personalizationLabel(context, city)),
          ),
      ],
      onChanged: (value) {
        if (value != null) controller.selectCity(value);
      },
    ),
  );
}

class _PermissionStep extends StatelessWidget {
  const _PermissionStep({required this.controller});
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) => _StepLayout(
    icon: Icons.privacy_tip_outlined,
    title: context.l10n.physicalActivityAccess,
    message: context.l10n.activityPermissionDescription,
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (controller.permissionStatus != null)
            AppStatusChip(
              label: _permissionLabel(context, controller.permissionStatus!),
              status:
                  controller.permissionStatus == ActivityAccessStatus.granted
                  ? AppStatus.success
                  : AppStatus.warning,
            ),
          if (controller.permissionStatus != null)
            const SizedBox(height: AppSpacing.md),
          Text(_permissionMessage(context, controller.permissionStatus)),
          const SizedBox(height: AppSpacing.md),
          if (controller.permissionStatus !=
              ActivityAccessStatus.permanentlyDenied)
            AppButton(
              label: controller.permissionStatus == null
                  ? context.l10n.allowActivityAccess
                  : context.l10n.retryActivityAccess,
              isLoading: controller.isBusy,
              onPressed: controller.isBusy
                  ? null
                  : controller.requestPermission,
            ),
          if (controller.permissionStatus ==
              ActivityAccessStatus.permanentlyDenied) ...<Widget>[
            Text(context.l10n.androidPermissionInstructions),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: context.l10n.continueWithoutTracking,
              variant: AppButtonVariant.outlined,
              onPressed: controller.isBusy ? null : controller.next,
            ),
          ],
        ],
      ),
    ),
  );

  static String _permissionLabel(
    BuildContext context,
    ActivityAccessStatus status,
  ) => switch (status) {
    ActivityAccessStatus.granted => context.l10n.activityAccessGranted,
    ActivityAccessStatus.denied => context.l10n.activityAccessNotGranted,
    ActivityAccessStatus.permanentlyDenied =>
      context.l10n.enableAccessInSettings,
    ActivityAccessStatus.unsupported => context.l10n.activitySensorUnavailable,
  };

  static String _permissionMessage(
    BuildContext context,
    ActivityAccessStatus? status,
  ) => switch (status) {
    null => context.l10n.permissionBeforeRequest,
    ActivityAccessStatus.granted => context.l10n.trackingReadyDescription,
    ActivityAccessStatus.denied => context.l10n.trackingNeedsPermission,
    ActivityAccessStatus.permanentlyDenied =>
      context.l10n.enableActivityManually,
    ActivityAccessStatus.unsupported => context.l10n.permissionUnsupported,
  };
}

class _CompletionStep extends StatelessWidget {
  const _CompletionStep({required this.controller});
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) => _StepLayout(
    icon: Icons.check_circle_outline,
    title: context.l10n.youAreReady,
    message: context.l10n.completionDescription,
    child: AppCard(
      child: Column(
        children: <Widget>[
          _Summary(
            label: context.l10n.dailyGoal,
            value: context.l10n.stepCount(controller.selectedGoal),
          ),
          const Divider(height: AppSpacing.xl),
          _Summary(
            label: context.l10n.interests,
            value: controller.selectedInterests.isEmpty
                ? PersonalizationOptions.noPreference
                : controller.selectedInterests
                      .map((item) => _personalizationLabel(context, item))
                      .join('، '),
          ),
          const Divider(height: AppSpacing.xl),
          _Summary(
            label: context.l10n.city,
            value: _personalizationLabel(context, controller.selectedCity),
          ),
          const Divider(height: AppSpacing.xl),
          _Summary(
            label: context.l10n.physicalActivityAccess,
            value: controller.permissionStatus == ActivityAccessStatus.granted
                ? context.l10n.granted
                : context.l10n.notGranted,
          ),
        ],
      ),
    ),
  );
}

class _StepLayout extends StatelessWidget {
  const _StepLayout({
    required this.icon,
    required this.title,
    required this.message,
    required this.child,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: AppSpacing.lg),
      Text(
        title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: context.appTheme.textSecondary),
      ),
      const SizedBox(height: AppSpacing.xl),
      child,
    ],
  );
}

class _Pillar extends StatelessWidget {
  const _Pillar({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Icon(icon),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: Text(text)),
    ],
  );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Expanded(child: Text(label)),
      const SizedBox(width: AppSpacing.md),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    ],
  );
}

String _personalizationLabel(BuildContext context, String value) =>
    switch (value) {
      'Clothing' => context.l10n.clothing,
      'Sports' => context.l10n.sports,
      'Food' => context.l10n.food,
      'Wellness' => context.l10n.wellness,
      'No preference' => context.l10n.noPreference,
      'Tehran' => context.l10n.tehran,
      'Karaj' => context.l10n.karaj,
      'Mashhad' => context.l10n.mashhad,
      'Isfahan' => context.l10n.isfahan,
      'Shiraz' => context.l10n.shiraz,
      'Tabriz' => context.l10n.tabriz,
      'Other' => context.l10n.other,
      'Prefer not to say' => context.l10n.preferNotToSay,
      _ => value,
    };
