import 'package:flutter/material.dart';

import 'app_preferences.dart';

final class AppSettingsController extends ChangeNotifier {
  AppSettingsController(AppPreferences preferences)
    : _preferences = preferences,
      _themeMode = preferences.themeMode,
      _dailyGoal = preferences.dailyGoal,
      _profileName = preferences.profileName,
      _profileEmail = preferences.profileEmail,
      _onboardingCompleted = preferences.onboardingCompleted,
      _rewardInterests = preferences.rewardInterests,
      _selectedCity = preferences.selectedCity;

  AppSettingsController.inMemory()
    : _preferences = null,
      _themeMode = ThemeMode.system,
      _dailyGoal = AppPreferences.defaultDailyGoal,
      _profileName = '',
      _profileEmail = '',
      _onboardingCompleted = false,
      _rewardInterests = const <String>[],
      _selectedCity = 'Prefer not to say';

  final AppPreferences? _preferences;
  ThemeMode _themeMode;
  int _dailyGoal;
  String _profileName;
  String _profileEmail;
  bool _onboardingCompleted;
  List<String> _rewardInterests;
  String _selectedCity;

  ThemeMode get themeMode => _themeMode;
  int get dailyGoal => _dailyGoal;
  String get profileName => _profileName;
  String get profileEmail => _profileEmail;
  bool get onboardingCompleted => _onboardingCompleted;
  List<String> get rewardInterests =>
      List<String>.unmodifiable(_rewardInterests);
  String get selectedCity => _selectedCity;

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
    await _preferences?.setThemeMode(value);
  }

  Future<void> setDailyGoal(int value) async {
    final validValue = value.clamp(1000, 100000);
    if (_dailyGoal == validValue) return;
    _dailyGoal = validValue;
    notifyListeners();
    await _preferences?.setDailyGoal(validValue);
  }

  Future<void> setProfile({
    required String fullName,
    required String email,
  }) async {
    final normalizedName = fullName.trim();
    final normalizedEmail = email.trim();
    if (_profileName == normalizedName && _profileEmail == normalizedEmail) {
      return;
    }
    _profileName = normalizedName;
    _profileEmail = normalizedEmail;
    notifyListeners();
    await _preferences?.setProfile(
      fullName: normalizedName,
      email: normalizedEmail,
    );
  }

  Future<void> setPersonalization({
    required List<String> rewardInterests,
    required String selectedCity,
  }) async {
    final normalized = List<String>.unmodifiable(
      rewardInterests.toSet().toList(growable: false),
    );
    if (_rewardInterests.length == normalized.length &&
        _rewardInterests.every(normalized.contains) &&
        _selectedCity == selectedCity) {
      return;
    }
    _rewardInterests = normalized;
    _selectedCity = selectedCity;
    notifyListeners();
    await _preferences?.setPersonalization(
      rewardInterests: normalized,
      selectedCity: selectedCity,
    );
  }

  Future<void> completeOnboarding() async {
    if (_onboardingCompleted) return;
    await _preferences?.setOnboardingCompleted(true);
    _onboardingCompleted = true;
    notifyListeners();
  }
}
