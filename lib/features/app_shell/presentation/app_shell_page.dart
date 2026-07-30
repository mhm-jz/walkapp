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
import '../../notifications/application/notification_controller.dart';
import '../../notifications/data/notification_repository.dart';
import '../../notifications/domain/app_notification.dart';
import '../../notifications/domain/app_notification_destination.dart';
import '../../notifications/presentation/notification_center_page.dart';
import '../../campaigns/presentation/active_campaign_page.dart';
import '../../rewards/presentation/my_rewards_page.dart';
import '../../rewards/presentation/coupon_details_page.dart';
import '../../history/presentation/history_page.dart';
import '../../../core/design_system/components/app_feedback.dart';
import '../../../core/design_system/components/embedded_destination_page.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({
    required this.stepController,
    required this.settingsController,
    required this.enrollmentRepository,
    required this.rewardWalletRepository,
    required this.claimedRewardRepository,
    required this.dailyStepHistoryRepository,
    required this.notificationRepository,
    required this.onLogout,
    super.key,
  });

  final StepCounterController stepController;
  final AppSettingsController settingsController;
  final CampaignEnrollmentRepository enrollmentRepository;
  final RewardWalletRepository rewardWalletRepository;
  final ClaimedRewardRepository claimedRewardRepository;
  final DailyStepHistoryRepository dailyStepHistoryRepository;
  final NotificationRepository notificationRepository;
  final VoidCallback onLogout;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage>
    with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<Widget> _pages;
  late final LocalCampaignRepository _campaignRepository;
  late final CampaignEnrollmentController _campaignController;
  late final RewardsController _rewardsController;
  late final DailyStepHistoryController _historyController;
  late final NotificationController _notificationController;
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
    _notificationController = NotificationController(
      repository: widget.notificationRepository,
      stepController: widget.stepController,
      campaignController: _campaignController,
      rewardsController: _rewardsController,
      settingsController: widget.settingsController,
    );
    WidgetsBinding.instance.addObserver(this);
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
        notificationController: _notificationController,
        onOpenNotifications: _openNotificationCenter,
      ),
      CampaignsPage(
        repository: _campaignRepository,
        enrollmentController: _campaignController,
        settingsController: widget.settingsController,
        rewardsController: _rewardsController,
      ),
      RewardsPage(
        controller: _rewardsController,
        settingsController: widget.settingsController,
      ),
      ProgressPage(
        controller: widget.stepController,
        settingsController: widget.settingsController,
        historyController: _historyController,
        campaignController: _campaignController,
        onLogout: widget.onLogout,
        notificationController: _notificationController,
        onOpenNotifications: _openNotificationCenter,
      ),
    ];
  }

  Future<void> _initializeControllers() async {
    await widget.stepController.initialize();
    await _historyController.initialize();
    await _campaignController.initialize();
    await _rewardsController.initialize();
    await _notificationController.initialize();
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationController.dispose();
    _rewardsController.dispose();
    _campaignController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _rewardsController.refreshExpirationState();
    _notificationController.evaluateNow();
  }

  void _openNotificationCenter() {
    _openPage(
      NotificationCenterPage(
        controller: _notificationController,
        onOpenNotification: _openNotificationDestination,
      ),
    );
  }

  Future<void> _openNotificationDestination(
    AppNotification notification,
  ) async {
    await _notificationController.markAsRead(notification);
    if (!mounted) return;
    switch (notification.destination) {
      case AppNotificationDestination.home:
        Navigator.of(context).popUntil((route) => route.isFirst);
        _selectTab(0);
      case AppNotificationDestination.campaigns:
        Navigator.of(context).popUntil((route) => route.isFirst);
        _selectTab(1);
      case AppNotificationDestination.rewards:
        Navigator.of(context).popUntil((route) => route.isFirst);
        _selectTab(2);
      case AppNotificationDestination.activeCampaign:
        final enrollment = _campaignController.enrollments
            .where((item) => item.id == notification.relatedEnrollmentId)
            .firstOrNull;
        if (enrollment == null) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          _selectTab(1);
          AppSnackbar.show(
            context,
            'That campaign is no longer available. Showing Campaigns.',
          );
          return;
        }
        _openPage(
          ActiveCampaignPage(
            controller: _campaignController,
            rewardsController: _rewardsController,
          ),
        );
      case AppNotificationDestination.myRewards:
        _openPage(MyRewardsPage(controller: _rewardsController));
      case AppNotificationDestination.couponDetails:
        final claim = _rewardsController.claimedRewardById(
          notification.relatedClaimedRewardId ?? '',
        );
        if (claim == null) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          _selectTab(2);
          AppSnackbar.show(
            context,
            'That coupon is no longer available. Showing Rewards.',
          );
          return;
        }
        _openPage(
          CouponDetailsPage(
            claimedRewardId: claim.id,
            controller: _rewardsController,
          ),
        );
      case AppNotificationDestination.history:
        _openPage(
          EmbeddedDestinationPage(
            title: 'History',
            bodyBuilder: (showHeading) => HistoryPage(
              controller: _historyController,
              showHeading: showHeading,
            ),
          ),
        );
      case AppNotificationDestination.none:
        break;
    }
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
        onAchievements: () => _openPage(
          AchievementsPage(
            controller: widget.stepController,
            historyController: _historyController,
            campaignController: _campaignController,
          ),
        ),
        onSettings: () => _openPage(
          EmbeddedDestinationPage(
            title: 'Settings',
            bodyBuilder: (showHeading) => SettingsPage(
              settingsController: widget.settingsController,
              onLogout: widget.onLogout,
              showHeading: showHeading,
            ),
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
