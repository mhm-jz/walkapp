import 'package:flutter/material.dart';

import 'core/preferences/app_preferences.dart';
import 'core/preferences/app_settings_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/onboarding_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/app_shell/presentation/app_shell_page.dart';
import 'features/campaigns/data/hive_campaign_enrollment_repository.dart';
import 'features/campaigns/data/campaign_enrollment_repository.dart';
import 'features/rewards/data/claimed_reward_repository.dart';
import 'features/rewards/data/hive_claimed_reward_repository.dart';
import 'features/rewards/data/hive_reward_wallet_repository.dart';
import 'features/rewards/data/reward_wallet_repository.dart';
import 'features/step_counter/data/step_local_store.dart';
import 'features/step_counter/presentation/step_counter_controller.dart';
import 'features/step_counter/service/step_foreground_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await AppPreferences.open();
  final campaignEnrollmentRepository =
      await HiveCampaignEnrollmentRepository.open();
  final rewardWalletRepository = await HiveRewardWalletRepository.open();
  final claimedRewardRepository = await HiveClaimedRewardRepository.open();
  final settingsController = AppSettingsController(preferences);
  final trackingService = StepForegroundService()..initialize();
  final controller = StepCounterController(
    trackingService: trackingService,
    storeFactory: const AppStepSnapshotStoreFactory(),
  );
  runApp(
    WalkingApp(
      controller: controller,
      settingsController: settingsController,
      campaignEnrollmentRepository: campaignEnrollmentRepository,
      rewardWalletRepository: rewardWalletRepository,
      claimedRewardRepository: claimedRewardRepository,
    ),
  );
}

class WalkingApp extends StatefulWidget {
  const WalkingApp({
    required this.controller,
    this.campaignEnrollmentRepository,
    this.rewardWalletRepository,
    this.claimedRewardRepository,
    this.settingsController,
    super.key,
  });

  final StepCounterController controller;
  final CampaignEnrollmentRepository? campaignEnrollmentRepository;
  final RewardWalletRepository? rewardWalletRepository;
  final ClaimedRewardRepository? claimedRewardRepository;
  final AppSettingsController? settingsController;

  @override
  State<WalkingApp> createState() => _WalkingAppState();
}

class _WalkingAppState extends State<WalkingApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppSettingsController _settingsController =
      widget.settingsController ?? AppSettingsController.inMemory();
  late final CampaignEnrollmentRepository _campaignEnrollmentRepository =
      widget.campaignEnrollmentRepository ??
      InMemoryCampaignEnrollmentRepository();
  late final RewardWalletRepository _rewardWalletRepository =
      widget.rewardWalletRepository ?? InMemoryRewardWalletRepository();
  late final ClaimedRewardRepository _claimedRewardRepository =
      widget.claimedRewardRepository ?? InMemoryClaimedRewardRepository();

  Route<void> _routeTo(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.025, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
    );
  }

  void _openAppShell() {
    _navigatorKey.currentState?.pushAndRemoveUntil(
      _routeTo(
        AppShellPage(
          stepController: widget.controller,
          settingsController: _settingsController,
          enrollmentRepository: _campaignEnrollmentRepository,
          rewardWalletRepository: _rewardWalletRepository,
          claimedRewardRepository: _claimedRewardRepository,
          onLogout: _logout,
        ),
      ),
      (route) => false,
    );
  }

  void _logout() {
    _navigatorKey.currentState?.pushAndRemoveUntil(
      _routeTo(_loginPage()),
      (route) => false,
    );
  }

  RegisterPage _registerPage() {
    return RegisterPage(
      settingsController: _settingsController,
      onAuthenticated: _openAppShell,
      onLogin: _replaceWithLogin,
      onBack: () => _navigatorKey.currentState?.pop(),
    );
  }

  LoginPage _loginPage() {
    return LoginPage(
      settingsController: _settingsController,
      onAuthenticated: _openAppShell,
      onRegister: _replaceWithRegister,
      onBack: () => _navigatorKey.currentState?.pop(),
    );
  }

  void _openRegister() {
    _navigatorKey.currentState?.push(_routeTo(_registerPage()));
  }

  void _openLogin() {
    _navigatorKey.currentState?.push(_routeTo(_loginPage()));
  }

  void _replaceWithRegister() {
    _navigatorKey.currentState?.pushReplacement(_routeTo(_registerPage()));
  }

  void _replaceWithLogin() {
    _navigatorKey.currentState?.pushReplacement(_routeTo(_loginPage()));
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settingsController,
      builder: (context, child) => MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'WalkApp',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _settingsController.themeMode,
        themeAnimationDuration: const Duration(milliseconds: 350),
        home: OnboardingPage(
          settingsController: _settingsController,
          onGetStarted: _openRegister,
          onLogin: _openLogin,
        ),
      ),
    );
  }
}
