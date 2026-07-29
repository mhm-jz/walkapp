import 'campaign_reward_type.dart';

final class CampaignReward {
  const CampaignReward({
    this.type = CampaignRewardType.directOffer,
    this.rewardId,
    this.pointsAmount,
    required this.title,
    required this.description,
    required this.discountLabel,
    required this.minimumPurchaseDescription,
    required this.usageChannel,
    required this.expirationDescription,
    required this.inventoryLabel,
    this.terms = const <String>[],
  });

  final CampaignRewardType type;
  final String? rewardId;
  final int? pointsAmount;
  final String title;
  final String description;
  final String discountLabel;
  final String minimumPurchaseDescription;
  final String usageChannel;
  final String expirationDescription;
  final String inventoryLabel;
  final List<String> terms;
}
