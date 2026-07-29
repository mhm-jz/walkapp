import 'reward_channel.dart';
import 'reward_type.dart';

final class Reward {
  const Reward({
    required this.id,
    required this.brandName,
    required this.brandInitials,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.type,
    required this.category,
    required this.requiredPoints,
    required this.discountLabel,
    required this.usageChannel,
    required this.minimumPurchaseDescription,
    required this.terms,
    required this.expirationDescription,
    required this.validForDays,
    required this.inventoryLabel,
    required this.isFeatured,
    required this.isAvailable,
    this.isLimitedToOne = true,
  });

  final String id;
  final String brandName;
  final String brandInitials;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final RewardType type;
  final String category;
  final int requiredPoints;
  final String discountLabel;
  final RewardChannel usageChannel;
  final String minimumPurchaseDescription;
  final List<String> terms;
  final String expirationDescription;
  final int validForDays;
  final String inventoryLabel;
  final bool isFeatured;
  final bool isAvailable;
  final bool isLimitedToOne;
}
