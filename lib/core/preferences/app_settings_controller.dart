import 'package:flutter/material.dart';

import 'app_preferences.dart';

final class AppSettingsController extends ChangeNotifier {
  AppSettingsController(AppPreferences preferences)
    : _preferences = preferences,
      _themeMode = preferences.themeMode,
      _dailyGoal = preferences.dailyGoal,
      _profileName = preferences.profileName,
      _profileEmail = preferences.profileEmail;

  AppSettingsController.inMemory()
    : _preferences = null,
      _themeMode = ThemeMode.system,
      _dailyGoal = AppPreferences.defaultDailyGoal,
      _profileName = '',
      _profileEmail = '';

  final AppPreferences? _preferences;
  ThemeMode _themeMode;
  int _dailyGoal;
  String _profileName;
  String _profileEmail;

  ThemeMode get themeMode => _themeMode;
  int get dailyGoal => _dailyGoal;
  String get profileName => _profileName;
  String get profileEmail => _profileEmail;

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
}
