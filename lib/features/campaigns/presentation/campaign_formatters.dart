import '../domain/campaign.dart';
import '../domain/campaign_category.dart';
import '../domain/campaign_status.dart';
import '../domain/campaign_type.dart';
import '../../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

String formatCampaignNumber(int value) {
  final digits = value.toString();
  final output = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) output.write(',');
    output.write(digits[index]);
  }
  return output.toString();
}

String campaignDate(AppLocalizations l10n, DateTime value) =>
    DateFormat.yMMMd(l10n.localeName).format(value);

String campaignStatusLabel(AppLocalizations l10n, CampaignStatus status) =>
    switch (status) {
      CampaignStatus.available => l10n.campaignAvailableStatus,
      CampaignStatus.endingSoon => l10n.endingSoon,
      CampaignStatus.upcoming => l10n.campaignUpcomingStatus,
      CampaignStatus.expired => l10n.campaignExpiredStatus,
    };

String campaignTypeLabel(AppLocalizations l10n, CampaignType type) =>
    switch (type) {
      CampaignType.stepTarget => l10n.stepTargetType,
      CampaignType.dailyGoalConsistency => l10n.goalConsistencyType,
    };

String campaignCategoryLabel(
  AppLocalizations l10n,
  CampaignCategory category,
) => switch (category) {
  CampaignCategory.clothing => l10n.clothingCategory,
  CampaignCategory.sports => l10n.sportsCategory,
  CampaignCategory.food => l10n.foodCategory,
  CampaignCategory.wellness => l10n.wellnessCategory,
};

String campaignGoalSummary(AppLocalizations l10n, Campaign campaign) =>
    switch (campaign.type) {
      CampaignType.stepTarget => l10n.eligibleStepsCount(
        formatCampaignNumber(campaign.targetSteps!),
      ),
      CampaignType.dailyGoalConsistency => l10n.goalConsistencySummary(
        campaign.requiredGoalDays!,
        campaign.durationDays,
      ),
    };

String campaignTiming(AppLocalizations l10n, Campaign campaign, DateTime now) {
  final status = campaign.statusAt(now);
  return switch (status) {
    CampaignStatus.upcoming => l10n.campaignStarts(
      campaignDate(l10n, campaign.startAt),
    ),
    CampaignStatus.expired => l10n.campaignEnded(
      campaignDate(l10n, campaign.endAt),
    ),
    CampaignStatus.available ||
    CampaignStatus.endingSoon => _remainingTime(l10n, campaign.endAt, now),
  };
}

String _remainingTime(AppLocalizations l10n, DateTime endAt, DateTime now) {
  final remaining = endAt.difference(now).inDays + 1;
  return remaining <= 1 ? l10n.endsToday : l10n.daysRemaining(remaining);
}
