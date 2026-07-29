import 'package:flutter/material.dart';

import '../../../core/preferences/app_settings_controller.dart';
import '../../about/presentation/about_page.dart';
import '../../achievements/presentation/achievements_page.dart';
import '../../campaigns/data/local_campaign_repository.dart';
import '../../campaigns/data/campaign_enrollment_repository.dart';
import '../../campaigns/application/campaign_enrollment_controller.dart';
import '../../campaigns/presentation/campaigns_page.dart';
import '../../progress/presentation/progress_page.dart';
import '../../profile/presentation/account_menu.dart';
import '../../profile/presentation/profile_page.dart';
import '../../rewards/presentation/rewards_page.dart';
import '../../rewards/application/rewards_controller.dart';
import '../../rewards/data/claimed_reward_repository.dart';
import '../../rewards/data/local_reward_catalog_repository.dart';
import '../../rewards/data/reward_wallet_repository.dart';
import '../../settings/presentation/settings_page.dart';
import '../../step_counter/presentation/step_counter_controller.dart';
import '../../home/presentation/home_page.dart';
import '../../history/application/daily_step_history_controller.dart';
import '../../history/data/daily_step_history_repository.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({
    required this.stepController,
    required this.settingsController,
    required this.enrollmentRepository,
    required this.rewardWalletRepository,
    required this.claimedRewardRepository,
    required this.dailyStepHistoryRepository,
    required this.onLogout,
    super.key,
  });

  final StepCounterController stepController;
  final AppSettingsController settingsController;
  final CampaignEnrollmentRepository enrollmentRepository;
  final RewardWalletRepository rewardWalletRepository;
  final ClaimedRewardRepository claimedRewardRepository;
  final DailyStepHistoryRepository dailyStepHistoryRepository;
  final VoidCallback onLogout;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<Widget> _pages;
  late final LocalCampaignRepository _campaignRepository;
  late final CampaignEnrollmentController _campaignController;
  late final RewardsController _rewardsController;
  late final DailyStepHistoryController _historyController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _campaignRepository = LocalCampaignRepository();
    _campaignController = CampaignEnrollmentController(
      widget.enrollmentRepository,
      _campaignRepository,
      widget.stepController,
    );
    _rewardsController = RewardsController(
      LocalRewardCatalogRepository(),
      widget.rewardWalletRepository,
      widget.claimedRewardRepository,
      _campaignController,
    );
    _historyController = DailyStepHistoryController(
      widget.dailyStepHistoryRepository,
      widget.stepController,
      widget.settingsController,
    );
    _initializeControllers();
    _pages = <Widget>[
      HomePage(
        stepController: widget.stepController,
        settingsController: widget.settingsController,
        onOpenAccount: () => _scaffoldKey.currentState?.openEndDrawer(),
        campaignController: _campaignController,
        rewardsController: _rewardsController,
        onOpenCampaigns: () => _selectTab(1),
        onOpenRewards: () => _selectTab(2),
      ),
      CampaignsPage(
        repository: _campaignRepository,
        enrollmentController: _campaignController,
        settingsController: widget.settingsController,
        rewardsController: _rewardsController,
      ),
      RewardsPage(controller: _rewardsController),
      ProgressPage(
        controller: widget.stepController,
        settingsController: widget.settingsController,
        historyController: _historyController,
        campaignController: _campaignController,
        onLogout: widget.onLogout,
      ),
    ];
  }

  Future<void> _initializeControllers() async {
    await widget.stepController.initialize();
    await _historyController.initialize();
    await _campaignController.initialize();
    await _rewardsController.initialize();
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  void dispose() {
    _rewardsController.dispose();
    _campaignController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  void _openPage(Widget page) {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _pages[_selectedIndex],
      endDrawer: AccountMenu(
        settingsController: widget.settingsController,
        onProfile: () => _openPage(
          ProfilePage(settingsController: widget.settingsController),
        ),
        onAchievements: () => _openPage(
          AchievementsPage(
            controller: widget.stepController,
            historyController: _historyController,
            campaignController: _campaignController,
          ),
        ),
        onSettings: () => _openPage(
          SettingsPage(
            settingsController: widget.settingsController,
            onLogout: widget.onLogout,
          ),
        ),
        onAbout: () => _openPage(const AboutPage()),
        onLogout: widget.onLogout,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          _selectTab(index);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Campaigns',
          ),
          NavigationDestination(
            icon: Icon(Icons.redeem_outlined),
            selectedIcon: Icon(Icons.redeem),
            label: 'Rewards',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}
