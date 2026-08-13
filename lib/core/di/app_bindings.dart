import 'package:get/get.dart';

import '../../features/campaigns/domain/repositories/campaign_enrollment_repository.dart';
import '../../features/history/domain/repositories/daily_step_history_repository.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/rewards/domain/repositories/claimed_reward_repository.dart';
import '../../features/rewards/domain/repositories/reward_wallet_repository.dart';
import '../../features/step_counter/presentation/getx/step_counter_controller.dart';
import '../preferences/app_settings_controller.dart';

/// Registers application-lifetime dependencies in one GetX composition root.
final class AppBindings extends Bindings {
  AppBindings({
    required this.settingsController,
    required this.stepController,
    required this.campaignEnrollmentRepository,
    required this.rewardWalletRepository,
    required this.claimedRewardRepository,
    required this.dailyStepHistoryRepository,
    required this.notificationRepository,
  });

  final AppSettingsController settingsController;
  final StepCounterController stepController;
  final CampaignEnrollmentRepository campaignEnrollmentRepository;
  final RewardWalletRepository rewardWalletRepository;
  final ClaimedRewardRepository claimedRewardRepository;
  final DailyStepHistoryRepository dailyStepHistoryRepository;
  final NotificationRepository notificationRepository;

  @override
  void dependencies() {
    _putPermanent<AppSettingsController>(settingsController);
    _putPermanent<StepCounterController>(stepController);
    _putPermanent<CampaignEnrollmentRepository>(campaignEnrollmentRepository);
    _putPermanent<RewardWalletRepository>(rewardWalletRepository);
    _putPermanent<ClaimedRewardRepository>(claimedRewardRepository);
    _putPermanent<DailyStepHistoryRepository>(dailyStepHistoryRepository);
    _putPermanent<NotificationRepository>(notificationRepository);
  }

  void _putPermanent<T>(T dependency) {
    if (!Get.isRegistered<T>()) {
      Get.put<T>(dependency, permanent: true);
    }
  }
}
