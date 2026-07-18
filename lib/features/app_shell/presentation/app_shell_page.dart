import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/app_tokens.dart';
import '../../../core/preferences/app_settings_controller.dart';
import '../../about/presentation/about_page.dart';
import '../../achievements/presentation/achievements_page.dart';
import '../../history/presentation/history_page.dart';
import '../../insights/presentation/insights_page.dart';
import '../../profile/presentation/account_menu.dart';
import '../../profile/presentation/profile_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../step_counter/presentation/step_counter_controller.dart';
import '../../step_counter/presentation/step_counter_page.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({
    required this.stepController,
    required this.settingsController,
    required this.onLogout,
    super.key,
  });

  final StepCounterController stepController;
  final AppSettingsController settingsController;
  final VoidCallback onLogout;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<Widget> _pages;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      StepCounterPage(
        controller: widget.stepController,
        settingsController: widget.settingsController,
        embedded: true,
        onOpenAccount: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      const HistoryPage(),
      InsightsPage(
        controller: widget.stepController,
        settingsController: widget.settingsController,
      ),
      SettingsPage(
        settingsController: widget.settingsController,
        onLogout: widget.onLogout,
      ),
    ];
  }

  void _openPage(Widget page) {
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute<void>(builder: (context) => page));
  }

  void _openSettings() {
    setState(() => _selectedIndex = 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _PreservedTabStack(selectedIndex: _selectedIndex, children: _pages),
      endDrawer: AccountMenu(
        settingsController: widget.settingsController,
        onProfile: () => _openPage(
          ProfilePage(settingsController: widget.settingsController),
        ),
        onAchievements: () =>
            _openPage(AchievementsPage(controller: widget.stepController)),
        onSettings: _openSettings,
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
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _PreservedTabStack extends StatelessWidget {
  const _PreservedTabStack({
    required this.selectedIndex,
    required this.children,
  });

  final int selectedIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        for (var index = 0; index < children.length; index++)
          TickerMode(
            enabled: index == selectedIndex,
            child: ExcludeSemantics(
              excluding: index != selectedIndex,
              child: IgnorePointer(
                ignoring: index != selectedIndex,
                child: AnimatedOpacity(
                  opacity: index == selectedIndex ? 1 : 0,
                  duration: AppDurations.fast,
                  curve: Curves.easeOut,
                  child: children[index],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
