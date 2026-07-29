import '../domain/campaign.dart';
import '../domain/campaign_category.dart';
import '../domain/campaign_status.dart';
import '../domain/campaign_type.dart';

String formatCampaignNumber(int value) {
  final digits = value.toString();
  final output = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) output.write(',');
    output.write(digits[index]);
  }
  return output.toString();
}

String campaignDate(DateTime value) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}

String campaignStatusLabel(CampaignStatus status) => switch (status) {
  CampaignStatus.available => 'Available',
  CampaignStatus.endingSoon => 'Ending soon',
  CampaignStatus.upcoming => 'Upcoming',
  CampaignStatus.expired => 'Expired',
};

String campaignTypeLabel(CampaignType type) => switch (type) {
  CampaignType.stepTarget => 'Step target',
  CampaignType.dailyGoalConsistency => 'Goal consistency',
};

String campaignCategoryLabel(CampaignCategory category) => switch (category) {
  CampaignCategory.clothing => 'Clothing',
  CampaignCategory.sports => 'Sports',
  CampaignCategory.food => 'Food',
  CampaignCategory.wellness => 'Wellness',
};

String campaignGoalSummary(Campaign campaign) => switch (campaign.type) {
  CampaignType.stepTarget => '${campaign.targetSteps} eligible steps',
  CampaignType.dailyGoalConsistency =>
    'Reach your goal on ${campaign.requiredGoalDays} of '
        '${campaign.durationDays} days',
};

String campaignTiming(Campaign campaign, DateTime now) {
  final status = campaign.statusAt(now);
  return switch (status) {
    CampaignStatus.upcoming => 'Starts ${campaignDate(campaign.startAt)}',
    CampaignStatus.expired => 'Ended ${campaignDate(campaign.endAt)}',
    CampaignStatus.available ||
    CampaignStatus.endingSoon => _remainingTime(campaign.endAt, now),
  };
}

String _remainingTime(DateTime endAt, DateTime now) {
  final remaining = endAt.difference(now).inDays + 1;
  return remaining <= 1 ? 'Ends today' : '$remaining days remaining';
}
