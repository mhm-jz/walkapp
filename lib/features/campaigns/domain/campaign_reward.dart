final class CampaignReward {
  const CampaignReward({
    required this.title,
    required this.description,
    required this.discountLabel,
    required this.minimumPurchaseDescription,
    required this.usageChannel,
    required this.expirationDescription,
    required this.inventoryLabel,
  });

  final String title;
  final String description;
  final String discountLabel;
  final String minimumPurchaseDescription;
  final String usageChannel;
  final String expirationDescription;
  final String inventoryLabel;
}
