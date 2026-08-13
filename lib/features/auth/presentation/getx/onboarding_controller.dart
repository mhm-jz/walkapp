import 'package:get/get.dart';

import '../../../../core/presentation/reactive_controller.dart';
import '../../../../core/preferences/app_settings_controller.dart';
import '../../../../core/preferences/personalization_options.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../step_counter/domain/step_tracking_service.dart';
import '../../../step_counter/presentation/getx/step_counter_controller.dart';

final class OnboardingController extends ReactiveController {
  OnboardingController({
    required this.settingsController,
    required this.stepController,
  }) : _selectedGoal = settingsController.dailyGoal.obs,
       _selectedInterests = settingsController.rewardInterests.toSet().obs,
       _selectedCity = settingsController.selectedCity.obs;

  final AppSettingsController settingsController;
  final StepCounterController stepController;

  final RxInt _step = 0.obs;
  final RxInt _selectedGoal;
  final RxSet<String> _selectedInterests;
  final RxString _selectedCity;
  final Rx<ActivityAccessStatus?> _permissionStatus = Rx<ActivityAccessStatus?>(
    null,
  );
  final RxBool _isBusy = false.obs;
  final RxnString _userMessage = RxnString();

  int get step => _step.value;
  int get selectedGoal => _selectedGoal.value;
  Set<String> get selectedInterests =>
      Set<String>.unmodifiable(_selectedInterests);
  String get selectedCity => _selectedCity.value;
  ActivityAccessStatus? get permissionStatus => _permissionStatus.value;
  bool get isBusy => _isBusy.value;
  String? get userMessage => _userMessage.value;

  bool get isLastStep => step == 5;
  bool get canContinue =>
      _step.value != 2 ||
      _selectedInterests.isNotEmpty ||
      _selectedInterests.contains(PersonalizationOptions.noPreference);

  void next() {
    if (_step.value >= 5) return;
    _step.value++;
    _userMessage.value = null;
    refreshState();
  }

  void previous() {
    if (_step.value <= 0 || _isBusy.value) return;
    _step.value--;
    _userMessage.value = null;
    refreshState();
  }

  void selectGoal(int value) {
    _selectedGoal.value = value.clamp(1000, 100000);
    refreshState();
  }

  void toggleInterest(String value) {
    if (value == PersonalizationOptions.noPreference) {
      _selectedInterests.assignAll(<String>{value});
    } else {
      _selectedInterests.remove(PersonalizationOptions.noPreference);
      _selectedInterests.contains(value)
          ? _selectedInterests.remove(value)
          : _selectedInterests.add(value);
    }
    refreshState();
  }

  void selectCity(String value) {
    _selectedCity.value = value;
    refreshState();
  }

  Future<void> requestPermission() async {
    if (_isBusy.value) return;
    _isBusy.value = true;
    _userMessage.value = null;
    refreshState();
    try {
      _permissionStatus.value = await stepController.requestActivityAccess();
    } catch (_) {
      _permissionStatus.value = ActivityAccessStatus.denied;
      _userMessage.value = lookupAppLocalizations(
        settingsController.locale,
      ).activityAccessRequestError;
    } finally {
      _isBusy.value = false;
      refreshState();
    }
  }

  Future<bool> complete() async {
    if (_isBusy.value) return false;
    _isBusy.value = true;
    _userMessage.value = null;
    refreshState();
    try {
      await settingsController.setDailyGoal(_selectedGoal.value);
      await settingsController.setPersonalization(
        rewardInterests: _selectedInterests.toList(growable: false),
        selectedCity: _selectedCity.value,
      );
      await settingsController.completeOnboarding();
      return true;
    } catch (_) {
      _userMessage.value = lookupAppLocalizations(
        settingsController.locale,
      ).setupSaveError;
      return false;
    } finally {
      _isBusy.value = false;
      refreshState();
    }
  }
}
