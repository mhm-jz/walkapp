import 'package:flutter/material.dart';

import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_card.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/app_fields.dart';
import '../../../core/design_system/components/app_status_chip.dart';
import '../../../core/design_system/extensions/app_theme_extension.dart';
import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
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
          'Choose at least one interest or No preference.',
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
                  padding: const EdgeInsets.fromLTRB(
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
                          tooltip: 'Previous setup step',
                          onPressed: _controller.isBusy
                              ? null
                              : _controller.previous,
                        )
                      else
                        const SizedBox(width: AppSizes.minTouchTarget),
                      Expanded(
                        child: Semantics(
                          label: 'Setup step ${_controller.step + 1} of 6',
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
                            ? 'Continue to account setup'
                            : 'Continue',
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
    title: 'Walk toward healthier habits',
    message:
        'WalkApp keeps personal health progress first. Campaigns are optional, '
        'and verified walking may unlock useful points or rewards.',
    child: const AppCard(
      child: Column(
        children: <Widget>[
          _Pillar(
            icon: Icons.monitor_heart_outlined,
            text: 'Track daily walking progress',
          ),
          Divider(height: AppSpacing.xl),
          _Pillar(
            icon: Icons.flag_outlined,
            text: 'Build habits with a personal goal',
          ),
          Divider(height: AppSpacing.xl),
          _Pillar(
            icon: Icons.campaign_outlined,
            text: 'Join optional campaigns when you choose',
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
    const goals = <(int, String)>[
      (5000, 'A comfortable starting point'),
      (7500, 'A balanced everyday goal'),
      (10000, 'A popular active target'),
      (12000, 'For already active walkers'),
    ];
    return _StepLayout(
      icon: Icons.flag_outlined,
      title: 'Choose your daily goal',
      message:
          'Choose a goal that feels realistic for you. You can change it later.',
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
                    title: Text('${goal.$1} steps'),
                    subtitle: Text(goal.$2),
                  ),
                ),
              ),
            AppButton(
              label: 'Custom goal',
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
      title: 'What interests you?',
      message:
          'Interests only help order local prototype content. Nothing is hidden.',
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          for (final value in values)
            Semantics(
              selected: controller.selectedInterests.contains(value),
              child: FilterChip(
                label: Text(value),
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
    title: 'Choose your city',
    message:
        'Your city may later help us highlight locally available campaigns. '
        'WalkApp does not use GPS for this choice.',
    child: AppDropdownField<String>(
      label: 'City',
      value: controller.selectedCity,
      items: <DropdownMenuItem<String>>[
        for (final city in PersonalizationOptions.cities)
          DropdownMenuItem<String>(value: city, child: Text(city)),
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
    title: 'Activity access',
    message:
        'Activity access helps WalkApp detect walking and validate step progress. '
        'Background tracking lets active sessions continue with the screen off. '
        'Continuous GPS is not needed.',
    child: AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (controller.permissionStatus != null)
            AppStatusChip(
              label: _permissionLabel(controller.permissionStatus!),
              status:
                  controller.permissionStatus == ActivityAccessStatus.granted
                  ? AppStatus.success
                  : AppStatus.warning,
            ),
          if (controller.permissionStatus != null)
            const SizedBox(height: AppSpacing.md),
          Text(_permissionMessage(controller.permissionStatus)),
          const SizedBox(height: AppSpacing.md),
          if (controller.permissionStatus !=
              ActivityAccessStatus.permanentlyDenied)
            AppButton(
              label: controller.permissionStatus == null
                  ? 'Allow Activity Access'
                  : 'Retry Activity Access',
              isLoading: controller.isBusy,
              onPressed: controller.isBusy
                  ? null
                  : controller.requestPermission,
            ),
          if (controller.permissionStatus ==
              ActivityAccessStatus.permanentlyDenied) ...<Widget>[
            const Text(
              'Android: Settings → Apps → WalkApp → Permissions → Physical activity, then allow access.',
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Continue without tracking',
              variant: AppButtonVariant.outlined,
              onPressed: controller.isBusy ? null : controller.next,
            ),
          ],
        ],
      ),
    ),
  );

  static String _permissionLabel(ActivityAccessStatus status) =>
      switch (status) {
        ActivityAccessStatus.granted => 'Activity access granted',
        ActivityAccessStatus.denied => 'Activity access not granted',
        ActivityAccessStatus.permanentlyDenied =>
          'Enable access in app settings',
        ActivityAccessStatus.unsupported => 'Activity sensor unavailable',
      };

  static String _permissionMessage(
    ActivityAccessStatus? status,
  ) => switch (status) {
    null => 'Permission is requested only after you choose the action below.',
    ActivityAccessStatus.granted =>
      'You can start tracking from Home when you are ready.',
    ActivityAccessStatus.denied =>
      'You can continue, but step tracking needs activity access.',
    ActivityAccessStatus.permanentlyDenied =>
      'Open this app’s system settings and enable activity access manually.',
    ActivityAccessStatus.unsupported =>
      'This device does not support the prototype activity permission flow.',
  };
}

class _CompletionStep extends StatelessWidget {
  const _CompletionStep({required this.controller});
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) => _StepLayout(
    icon: Icons.check_circle_outline,
    title: 'You’re ready',
    message:
        'Health tracking stays independent. Start it from Home whenever you choose.',
    child: AppCard(
      child: Column(
        children: <Widget>[
          _Summary(
            label: 'Daily goal',
            value: '${controller.selectedGoal} steps',
          ),
          const Divider(height: AppSpacing.xl),
          _Summary(
            label: 'Interests',
            value: controller.selectedInterests.isEmpty
                ? PersonalizationOptions.noPreference
                : controller.selectedInterests.join(', '),
          ),
          const Divider(height: AppSpacing.xl),
          _Summary(label: 'City', value: controller.selectedCity),
          const Divider(height: AppSpacing.xl),
          _Summary(
            label: 'Activity access',
            value: controller.permissionStatus == ActivityAccessStatus.granted
                ? 'Granted'
                : 'Not granted',
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
