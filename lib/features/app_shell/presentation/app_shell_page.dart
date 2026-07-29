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
import '../../settings/presentation/settings_page.dart';
import '../../step_counter/presentation/step_counter_controller.dart';
import '../../step_counter/presentation/step_counter_page.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({
    required this.stepController,
    required this.settingsController,
    required this.enrollmentRepository,
    required this.onLogout,
    super.key,
  });

  final StepCounterController stepController;
  final AppSettingsController settingsController;
  final CampaignEnrollmentRepository enrollmentRepository;
  final VoidCallback onLogout;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<Widget> _pages;
  late final LocalCampaignRepository _campaignRepository;
  late final CampaignEnrollmentController _campaignController;
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
    _campaignController.initialize();
    _pages = <Widget>[
      StepCounterPage(
        controller: widget.stepController,
        settingsController: widget.settingsController,
        embedded: true,
        onOpenAccount: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      CampaignsPage(
        repository: _campaignRepository,
        enrollmentController: _campaignController,
        settingsController: widget.settingsController,
      ),
      RewardsPage(enrollmentController: _campaignController),
      ProgressPage(
        controller: widget.stepController,
        settingsController: widget.settingsController,
        onLogout: widget.onLogout,
      ),
    ];
  }

  @override
  void dispose() {
    _campaignController.dispose();
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
      body: IndexedStack(index: _selectedIndex, children: _pages),
      endDrawer: AccountMenu(
        settingsController: widget.settingsController,
        onProfile: () => _openPage(
          ProfilePage(settingsController: widget.settingsController),
        ),
        onAchievements: () =>
            _openPage(AchievementsPage(controller: widget.stepController)),
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
          if (_selectedIndex == index) return;
          setState(() => _selectedIndex = index);
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
