import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart';

final class AppPreferences {
  AppPreferences._(this._box);

  static const _boxName = 'app_preferences_box';
  static const _themeModeKey = 'theme_mode';
  static const _dailyGoalKey = 'daily_goal';
  static const _profileNameKey = 'profile_name';
  static const _profileEmailKey = 'profile_email';
  static const _onboardingCompletedKey = 'onboarding_completed';
  static const _rewardInterestsKey = 'reward_interests';
  static const _selectedCityKey = 'selected_city';
  static const defaultDailyGoal = 10000;

  final Box<dynamic> _box;

  static Future<AppPreferences> open() async {
    final directory = await getApplicationSupportDirectory();
    Hive.init(directory.path);
    return AppPreferences._(await Hive.openBox<dynamic>(_boxName));
  }

  ThemeMode get themeMode {
    return switch (_box.get(_themeModeKey)?.toString()) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  int get dailyGoal {
    final value = _box.get(_dailyGoalKey);
    final parsed = value is int ? value : int.tryParse(value?.toString() ?? '');
    return (parsed ?? defaultDailyGoal).clamp(1000, 100000);
  }

  String get profileName => _box.get(_profileNameKey)?.toString().trim() ?? '';

  String get profileEmail =>
      _box.get(_profileEmailKey)?.toString().trim() ?? '';

  bool get onboardingCompleted {
    final stored = _box.get(_onboardingCompletedKey);
    if (stored is bool) return stored;
    return _box.containsKey(_dailyGoalKey) ||
        _box.containsKey(_profileNameKey) ||
        _box.containsKey(_profileEmailKey);
  }

  List<String> get rewardInterests {
    final raw = _box.get(_rewardInterestsKey);
    if (raw is! List) return const <String>[];
    return raw.map((item) => item.toString()).toList(growable: false);
  }

  String get selectedCity =>
      _box.get(_selectedCityKey)?.toString().trim() ?? 'Prefer not to say';

  Future<void> setThemeMode(ThemeMode value) =>
      _box.put(_themeModeKey, value.name);

  Future<void> setDailyGoal(int value) =>
      _box.put(_dailyGoalKey, value.clamp(1000, 100000));

  Future<void> setProfile({required String fullName, required String email}) {
    return _box.putAll(<String, String>{
      _profileNameKey: fullName.trim(),
      _profileEmailKey: email.trim(),
    });
  }

  Future<void> setPersonalization({
    required List<String> rewardInterests,
    required String selectedCity,
  }) => _box.putAll(<String, Object>{
    _rewardInterestsKey: rewardInterests,
    _selectedCityKey: selectedCity,
  });

  Future<void> setOnboardingCompleted(bool value) =>
      _box.put(_onboardingCompletedKey, value);
}
