import 'campaign_brand.dart';
import 'campaign_category.dart';
import 'campaign_reward.dart';
import 'campaign_status.dart';
import 'campaign_type.dart';

final class Campaign {
  const Campaign({
    required this.id,
    required this.brand,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.category,
    required this.type,
    required this.startAt,
    required this.endAt,
    required this.targetSteps,
    required this.requiredGoalDays,
    required this.reward,
    required this.terms,
    required this.visualStyle,
    required this.isFeatured,
  });

  final String id;
  final CampaignBrand brand;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final CampaignCategory category;
  final CampaignType type;
  final DateTime startAt;
  final DateTime endAt;
  final int? targetSteps;
  final int? requiredGoalDays;
  final CampaignReward reward;
  final List<String> terms;
  final String visualStyle;
  final bool isFeatured;

  CampaignStatus statusAt(DateTime now) {
    if (now.isAfter(endAt)) return CampaignStatus.expired;
    if (now.isBefore(startAt)) return CampaignStatus.upcoming;
    if (endAt.difference(now) <= const Duration(days: 3)) {
      return CampaignStatus.endingSoon;
    }
    return CampaignStatus.available;
  }

  int get durationDays => endAt.difference(startAt).inDays + 1;
}
