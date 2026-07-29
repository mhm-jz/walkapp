import 'package:flutter/foundation.dart';

import '../../../core/preferences/app_settings_controller.dart';
import '../../../core/preferences/personalization_options.dart';
import '../../step_counter/domain/step_tracking_service.dart';
import '../../step_counter/presentation/step_counter_controller.dart';

final class OnboardingController extends ChangeNotifier {
  OnboardingController({
    required this.settingsController,
    required this.stepController,
  }) : selectedGoal = settingsController.dailyGoal,
       selectedInterests = settingsController.rewardInterests.toSet(),
       selectedCity = settingsController.selectedCity;

  final AppSettingsController settingsController;
  final StepCounterController stepController;

  int step = 0;
  int selectedGoal;
  Set<String> selectedInterests;
  String selectedCity;
  ActivityAccessStatus? permissionStatus;
  bool isBusy = false;
  String? userMessage;

  bool get isLastStep => step == 5;
  bool get canContinue =>
      step != 2 ||
      selectedInterests.isNotEmpty ||
      selectedInterests.contains(PersonalizationOptions.noPreference);

  void next() {
    if (step >= 5) return;
    step++;
    userMessage = null;
    notifyListeners();
  }

  void previous() {
    if (step <= 0 || isBusy) return;
    step--;
    userMessage = null;
    notifyListeners();
  }

  void selectGoal(int value) {
    selectedGoal = value.clamp(1000, 100000);
    notifyListeners();
  }

  void toggleInterest(String value) {
    if (value == PersonalizationOptions.noPreference) {
      selectedInterests = <String>{value};
    } else {
      selectedInterests.remove(PersonalizationOptions.noPreference);
      selectedInterests.contains(value)
          ? selectedInterests.remove(value)
          : selectedInterests.add(value);
    }
    notifyListeners();
  }

  void selectCity(String value) {
    selectedCity = value;
    notifyListeners();
  }

  Future<void> requestPermission() async {
    if (isBusy) return;
    isBusy = true;
    userMessage = null;
    notifyListeners();
    try {
      permissionStatus = await stepController.requestActivityAccess();
    } catch (_) {
      permissionStatus = ActivityAccessStatus.denied;
      userMessage = 'Activity access could not be requested. Please try again.';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> complete() async {
    if (isBusy) return false;
    isBusy = true;
    userMessage = null;
    notifyListeners();
    try {
      await settingsController.setDailyGoal(selectedGoal);
      await settingsController.setPersonalization(
        rewardInterests: selectedInterests.toList(growable: false),
        selectedCity: selectedCity,
      );
      await settingsController.completeOnboarding();
      return true;
    } catch (_) {
      userMessage = 'Your setup could not be saved locally. Please try again.';
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
