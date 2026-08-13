import '../../../../core/preferences/app_settings_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/campaign.dart';
import '../../domain/campaign_brand.dart';
import '../../domain/campaign_category.dart';
import '../../domain/campaign_reward.dart';
import '../../domain/campaign_reward_type.dart';
import '../../domain/campaign_type.dart';
import 'campaign_catalog_local_data_source.dart';

final class LocalCampaignCatalogDataSource
    implements CampaignCatalogLocalDataSource {
  LocalCampaignCatalogDataSource(this._settingsController);

  final AppSettingsController _settingsController;

  @override
  Future<List<Campaign>> getCampaigns() async {
    final today = _dateOnly(DateTime.now());
    final l10n = lookupAppLocalizations(_settingsController.locale);

    return <Campaign>[
      Campaign(
        id: 'movewear-30k',
        brand: const CampaignBrand(name: 'MoveWear', initials: 'MW'),
        title: l10n.campaignMoveWearContent('title'),
        shortDescription: l10n.campaignMoveWearContent('short'),
        fullDescription: l10n.campaignMoveWearContent('full'),
        category: CampaignCategory.clothing,
        type: CampaignType.stepTarget,
        startAt: today.subtract(const Duration(days: 1)),
        endAt: today.add(const Duration(days: 5)),
        targetSteps: 30000,
        requiredGoalDays: null,
        reward: CampaignReward(
          rewardId: 'campaign-movewear-20',
          title: l10n.campaignMoveWearContent('rewardTitle'),
          description: l10n.campaignMoveWearContent('rewardDescription'),
          discountLabel: l10n.campaignMoveWearContent('discount'),
          minimumPurchaseDescription: l10n.campaignMoveWearContent('minimum'),
          usageChannel: l10n.campaignMoveWearContent('usage'),
          expirationDescription: l10n.campaignMoveWearContent('expiration'),
          inventoryLabel: l10n.campaignMoveWearContent('inventory'),
        ),
        terms: <String>[
          l10n.campaignMoveWearContent('term1'),
          l10n.campaignMoveWearContent('term2'),
          l10n.campaignMoveWearContent('term3'),
        ],
        visualStyle: 'active_green',
        isFeatured: true,
      ),
      Campaign(
        id: 'greenbite-goal-days',
        brand: const CampaignBrand(name: 'GreenBite', initials: 'GB'),
        title: l10n.campaignGreenBiteContent('title'),
        shortDescription: l10n.campaignGreenBiteContent('short'),
        fullDescription: l10n.campaignGreenBiteContent('full'),
        category: CampaignCategory.food,
        type: CampaignType.dailyGoalConsistency,
        startAt: today.subtract(const Duration(days: 5)),
        endAt: today.add(const Duration(days: 1)),
        targetSteps: null,
        requiredGoalDays: 5,
        reward: CampaignReward(
          type: CampaignRewardType.points,
          pointsAmount: 250,
          title: l10n.campaignGreenBiteContent('rewardTitle'),
          description: l10n.campaignGreenBiteContent('rewardDescription'),
          discountLabel: l10n.campaignGreenBiteContent('discount'),
          minimumPurchaseDescription: l10n.campaignGreenBiteContent('minimum'),
          usageChannel: l10n.campaignGreenBiteContent('usage'),
          expirationDescription: l10n.campaignGreenBiteContent('expiration'),
          inventoryLabel: l10n.campaignGreenBiteContent('inventory'),
        ),
        terms: <String>[
          l10n.campaignGreenBiteContent('term1'),
          l10n.campaignGreenBiteContent('term2'),
          l10n.campaignGreenBiteContent('term3'),
        ],
        visualStyle: 'fresh_food',
        isFeatured: false,
      ),
      Campaign(
        id: 'urbanfit-city-walk',
        brand: const CampaignBrand(name: 'UrbanFit', initials: 'UF'),
        title: l10n.campaignUrbanFitContent('title'),
        shortDescription: l10n.campaignUrbanFitContent('short'),
        fullDescription: l10n.campaignUrbanFitContent('full'),
        category: CampaignCategory.sports,
        type: CampaignType.stepTarget,
        startAt: today.add(const Duration(days: 4)),
        endAt: today.add(const Duration(days: 17)),
        targetSteps: 60000,
        requiredGoalDays: null,
        reward: CampaignReward(
          type: CampaignRewardType.points,
          pointsAmount: 400,
          title: l10n.campaignUrbanFitContent('rewardTitle'),
          description: l10n.campaignUrbanFitContent('rewardDescription'),
          discountLabel: l10n.campaignUrbanFitContent('discount'),
          minimumPurchaseDescription: l10n.campaignUrbanFitContent('minimum'),
          usageChannel: l10n.campaignUrbanFitContent('usage'),
          expirationDescription: l10n.campaignUrbanFitContent('expiration'),
          inventoryLabel: l10n.campaignUrbanFitContent('inventory'),
        ),
        terms: <String>[
          l10n.campaignUrbanFitContent('term1'),
          l10n.campaignUrbanFitContent('term2'),
          l10n.campaignUrbanFitContent('term3'),
        ],
        visualStyle: 'city_blue',
        isFeatured: false,
      ),
      Campaign(
        id: 'stepstyle-consistency',
        brand: const CampaignBrand(name: 'StepStyle', initials: 'SS'),
        title: l10n.campaignStepStyleContent('title'),
        shortDescription: l10n.campaignStepStyleContent('short'),
        fullDescription: l10n.campaignStepStyleContent('full'),
        category: CampaignCategory.clothing,
        type: CampaignType.dailyGoalConsistency,
        startAt: today.subtract(const Duration(days: 1)),
        endAt: today.add(const Duration(days: 8)),
        targetSteps: null,
        requiredGoalDays: 8,
        reward: CampaignReward(
          rewardId: 'campaign-stepstyle-18',
          title: l10n.campaignStepStyleContent('rewardTitle'),
          description: l10n.campaignStepStyleContent('rewardDescription'),
          discountLabel: l10n.campaignStepStyleContent('discount'),
          minimumPurchaseDescription: l10n.campaignStepStyleContent('minimum'),
          usageChannel: l10n.campaignStepStyleContent('usage'),
          expirationDescription: l10n.campaignStepStyleContent('expiration'),
          inventoryLabel: l10n.campaignStepStyleContent('inventory'),
        ),
        terms: <String>[
          l10n.campaignStepStyleContent('term1'),
          l10n.campaignStepStyleContent('term2'),
          l10n.campaignStepStyleContent('term3'),
        ],
        visualStyle: 'steady_purple',
        isFeatured: false,
      ),
      Campaign(
        id: 'freshday-weekend',
        brand: const CampaignBrand(name: 'FreshDay', initials: 'FD'),
        title: l10n.campaignFreshDayContent('title'),
        shortDescription: l10n.campaignFreshDayContent('short'),
        fullDescription: l10n.campaignFreshDayContent('full'),
        category: CampaignCategory.wellness,
        type: CampaignType.stepTarget,
        startAt: today,
        endAt: today.add(const Duration(days: 4)),
        targetSteps: 20000,
        requiredGoalDays: null,
        reward: CampaignReward(
          rewardId: 'campaign-freshday-10',
          title: l10n.campaignFreshDayContent('rewardTitle'),
          description: l10n.campaignFreshDayContent('rewardDescription'),
          discountLabel: l10n.campaignFreshDayContent('discount'),
          minimumPurchaseDescription: l10n.campaignFreshDayContent('minimum'),
          usageChannel: l10n.campaignFreshDayContent('usage'),
          expirationDescription: l10n.campaignFreshDayContent('expiration'),
          inventoryLabel: l10n.campaignFreshDayContent('inventory'),
        ),
        terms: <String>[
          l10n.campaignFreshDayContent('term1'),
          l10n.campaignFreshDayContent('term2'),
          l10n.campaignFreshDayContent('term3'),
        ],
        visualStyle: 'calm_teal',
        isFeatured: false,
      ),
      Campaign(
        id: 'activelife-goal-week',
        brand: const CampaignBrand(name: 'ActiveLife', initials: 'AL'),
        title: l10n.campaignActiveLifeContent('title'),
        shortDescription: l10n.campaignActiveLifeContent('short'),
        fullDescription: l10n.campaignActiveLifeContent('full'),
        category: CampaignCategory.wellness,
        type: CampaignType.dailyGoalConsistency,
        startAt: today.subtract(const Duration(days: 14)),
        endAt: today.subtract(const Duration(days: 8)),
        targetSteps: null,
        requiredGoalDays: 4,
        reward: CampaignReward(
          rewardId: 'campaign-activelife-25',
          title: l10n.campaignActiveLifeContent('rewardTitle'),
          description: l10n.campaignActiveLifeContent('rewardDescription'),
          discountLabel: l10n.campaignActiveLifeContent('discount'),
          minimumPurchaseDescription: l10n.campaignActiveLifeContent('minimum'),
          usageChannel: l10n.campaignActiveLifeContent('usage'),
          expirationDescription: l10n.campaignActiveLifeContent('expiration'),
          inventoryLabel: l10n.campaignActiveLifeContent('inventory'),
        ),
        terms: <String>[
          l10n.campaignActiveLifeContent('term1'),
          l10n.campaignActiveLifeContent('term2'),
          l10n.campaignActiveLifeContent('term3'),
        ],
        visualStyle: 'inactive_neutral',
        isFeatured: false,
      ),
    ];
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
