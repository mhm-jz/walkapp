import '../domain/campaign.dart';
import '../domain/campaign_brand.dart';
import '../domain/campaign_category.dart';
import '../domain/campaign_reward.dart';
import '../domain/campaign_reward_type.dart';
import '../domain/campaign_type.dart';
import 'campaign_repository.dart';

final class LocalCampaignRepository implements CampaignRepository {
  @override
  Future<List<Campaign>> getCampaigns() async {
    final today = _dateOnly(DateTime.now());

    return <Campaign>[
      Campaign(
        id: 'movewear-30k',
        brand: const CampaignBrand(name: 'MoveWear', initials: 'MW'),
        title: '30,000 Step Week',
        shortDescription:
            'Build an active week with a clear verified-step target.',
        fullDescription:
            'Walk 30,000 eligible verified steps during the seven-day campaign period to unlock a saving on selected sportswear.',
        category: CampaignCategory.clothing,
        type: CampaignType.stepTarget,
        startAt: today.subtract(const Duration(days: 1)),
        endAt: today.add(const Duration(days: 5)),
        targetSteps: 30000,
        requiredGoalDays: null,
        reward: const CampaignReward(
          rewardId: 'campaign-movewear-20',
          title: 'Selected sportswear saving',
          description: 'Save on eligible MoveWear sportswear.',
          discountLabel: '20% off selected sportswear',
          minimumPurchaseDescription: 'Minimum purchase of €50',
          usageChannel: 'Online and in participating stores',
          expirationDescription: 'Use within 14 days of unlocking',
          inventoryLabel: 'Subject to availability of eligible items',
        ),
        terms: const <String>[
          'Discount applies only to items marked as campaign eligible.',
          'Cannot be combined with another promotional offer.',
          'One reward may be unlocked per participant.',
        ],
        visualStyle: 'active_green',
        isFeatured: true,
      ),
      Campaign(
        id: 'greenbite-goal-days',
        brand: const CampaignBrand(name: 'GreenBite', initials: 'GB'),
        title: 'Five Goal Days',
        shortDescription:
            'Reach your personal walking goal on five campaign days.',
        fullDescription:
            'Reach your current personal daily goal on five of the seven campaign days to unlock a healthy-meal saving.',
        category: CampaignCategory.food,
        type: CampaignType.dailyGoalConsistency,
        startAt: today.subtract(const Duration(days: 5)),
        endAt: today.add(const Duration(days: 1)),
        targetSteps: null,
        requiredGoalDays: 5,
        reward: const CampaignReward(
          type: CampaignRewardType.points,
          pointsAmount: 250,
          title: '250 reward points',
          description: 'Earn points to spend in the Reward Catalog.',
          discountLabel: '250 points',
          minimumPurchaseDescription: 'Minimum purchase of €25',
          usageChannel: 'Online ordering only',
          expirationDescription: 'Use within 10 days of unlocking',
          inventoryLabel: 'Available while campaign reward stock lasts',
        ),
        terms: const <String>[
          'Applies to eligible meal items only.',
          'Delivery and service fees are excluded.',
          'One reward may be unlocked per participant.',
        ],
        visualStyle: 'fresh_food',
        isFeatured: false,
      ),
      Campaign(
        id: 'urbanfit-city-walk',
        brand: const CampaignBrand(name: 'UrbanFit', initials: 'UF'),
        title: 'City Walk Challenge',
        shortDescription:
            'A two-week walking target designed for everyday movement.',
        fullDescription:
            'Walk 60000 eligible verified steps over fourteen days to unlock a saving on selected training accessories.',
        category: CampaignCategory.sports,
        type: CampaignType.stepTarget,
        startAt: today.add(const Duration(days: 4)),
        endAt: today.add(const Duration(days: 17)),
        targetSteps: 60000,
        requiredGoalDays: null,
        reward: const CampaignReward(
          type: CampaignRewardType.points,
          pointsAmount: 400,
          title: '400 reward points',
          description: 'Earn points to spend in the Reward Catalog.',
          discountLabel: '400 points',
          minimumPurchaseDescription: 'Minimum purchase of €35',
          usageChannel: 'Online only',
          expirationDescription: 'Use within 21 days of unlocking',
          inventoryLabel: 'Eligible products are subject to availability',
        ),
        terms: const <String>[
          'Only accessories identified as eligible are included.',
          'Cannot be exchanged for cash.',
          'One reward may be unlocked per participant.',
        ],
        visualStyle: 'city_blue',
        isFeatured: false,
      ),
      Campaign(
        id: 'stepstyle-consistency',
        brand: const CampaignBrand(name: 'StepStyle', initials: 'SS'),
        title: 'Consistent Steps',
        shortDescription: 'Meet your personal daily goal on eight of ten days.',
        fullDescription:
            'Build a consistent walking routine by reaching your personal daily goal on eight separate campaign days.',
        category: CampaignCategory.clothing,
        type: CampaignType.dailyGoalConsistency,
        startAt: today.subtract(const Duration(days: 1)),
        endAt: today.add(const Duration(days: 8)),
        targetSteps: null,
        requiredGoalDays: 8,
        reward: const CampaignReward(
          rewardId: 'campaign-stepstyle-18',
          title: 'Walking apparel saving',
          description: 'Save on selected StepStyle walking apparel.',
          discountLabel: '18% off eligible walking apparel',
          minimumPurchaseDescription: 'Minimum purchase of €60',
          usageChannel: 'Online and in participating stores',
          expirationDescription: 'Use within 14 days of unlocking',
          inventoryLabel: 'Sizes and styles are subject to availability',
        ),
        terms: const <String>[
          'Discount excludes clearance items.',
          'Cannot be combined with membership pricing.',
          'One reward may be unlocked per participant.',
        ],
        visualStyle: 'steady_purple',
        isFeatured: false,
      ),
      Campaign(
        id: 'freshday-weekend',
        brand: const CampaignBrand(name: 'FreshDay', initials: 'FD'),
        title: 'Fresh Start Walk',
        shortDescription:
            'Collect 20,000 verified steps during a five-day reset.',
        fullDescription:
            'Walk 20000 eligible verified steps during the campaign period and unlock a saving on an eligible wellness bundle.',
        category: CampaignCategory.wellness,
        type: CampaignType.stepTarget,
        startAt: today,
        endAt: today.add(const Duration(days: 4)),
        targetSteps: 20000,
        requiredGoalDays: null,
        reward: const CampaignReward(
          rewardId: 'campaign-freshday-10',
          title: 'Wellness bundle saving',
          description: 'Save on one eligible FreshDay wellness bundle.',
          discountLabel: '€10 off an eligible wellness bundle',
          minimumPurchaseDescription: 'Minimum purchase of €40',
          usageChannel: 'Online only',
          expirationDescription: 'Use within 7 days of unlocking',
          inventoryLabel: 'Limited to available eligible bundles',
        ),
        terms: const <String>[
          'Applies to campaign-marked bundles only.',
          'Shipping charges do not count toward the minimum purchase.',
          'One reward may be unlocked per participant.',
        ],
        visualStyle: 'calm_teal',
        isFeatured: false,
      ),
      Campaign(
        id: 'activelife-goal-week',
        brand: const CampaignBrand(name: 'ActiveLife', initials: 'AL'),
        title: 'Active Goal Week',
        shortDescription:
            'A completed prototype campaign focused on daily goals.',
        fullDescription:
            'This campaign asked participants to reach their personal daily goal on four of seven campaign days.',
        category: CampaignCategory.wellness,
        type: CampaignType.dailyGoalConsistency,
        startAt: today.subtract(const Duration(days: 14)),
        endAt: today.subtract(const Duration(days: 8)),
        targetSteps: null,
        requiredGoalDays: 4,
        reward: const CampaignReward(
          rewardId: 'campaign-activelife-25',
          title: 'Wellness session saving',
          description: 'A saving on an eligible ActiveLife session.',
          discountLabel: '25% off one eligible wellness session',
          minimumPurchaseDescription: 'No minimum purchase',
          usageChannel: 'In participating locations',
          expirationDescription: 'Reward availability period has ended',
          inventoryLabel: 'Was subject to appointment availability',
        ),
        terms: const <String>[
          'Applied to selected sessions only.',
          'Advance booking was required.',
          'The campaign and its reward period have ended.',
        ],
        visualStyle: 'inactive_neutral',
        isFeatured: false,
      ),
    ];
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
