import 'claimed_reward_source_type.dart';
import 'coupon_status.dart';

final class ClaimedReward {
  const ClaimedReward({
    required this.id,
    required this.rewardId,
    required this.brandName,
    required this.rewardTitle,
    required this.sourceType,
    required this.claimedAt,
    required this.couponCode,
    required this.couponStatus,
    required this.expiresAt,
    required this.pointsSpent,
    required this.discountLabel,
    required this.usageChannel,
    required this.minimumPurchaseDescription,
    required this.terms,
    this.sourceCampaignId,
  });

  final String id;
  final String rewardId;
  final String brandName;
  final String rewardTitle;
  final ClaimedRewardSourceType sourceType;
  final String? sourceCampaignId;
  final DateTime claimedAt;
  final String couponCode;
  final CouponStatus couponStatus;
  final DateTime expiresAt;
  final int pointsSpent;
  final String discountLabel;
  final String usageChannel;
  final String minimumPurchaseDescription;
  final List<String> terms;

  CouponStatus statusAt(DateTime now) {
    if (couponStatus == CouponStatus.used) return CouponStatus.used;
    return now.isAfter(expiresAt) ? CouponStatus.expired : couponStatus;
  }

  ClaimedReward copyWith({CouponStatus? couponStatus}) => ClaimedReward(
    id: id,
    rewardId: rewardId,
    brandName: brandName,
    rewardTitle: rewardTitle,
    sourceType: sourceType,
    sourceCampaignId: sourceCampaignId,
    claimedAt: claimedAt,
    couponCode: couponCode,
    couponStatus: couponStatus ?? this.couponStatus,
    expiresAt: expiresAt,
    pointsSpent: pointsSpent,
    discountLabel: discountLabel,
    usageChannel: usageChannel,
    minimumPurchaseDescription: minimumPurchaseDescription,
    terms: terms,
  );

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'rewardId': rewardId,
    'brandName': brandName,
    'rewardTitle': rewardTitle,
    'sourceType': sourceType.name,
    'sourceCampaignId': sourceCampaignId,
    'claimedAt': claimedAt.toIso8601String(),
    'couponCode': couponCode,
    'couponStatus': couponStatus.name,
    'expiresAt': expiresAt.toIso8601String(),
    'pointsSpent': pointsSpent,
    'discountLabel': discountLabel,
    'usageChannel': usageChannel,
    'minimumPurchaseDescription': minimumPurchaseDescription,
    'terms': terms,
  };

  static ClaimedReward? fromMap(Map<dynamic, dynamic> map) {
    final claimedAt = DateTime.tryParse(map['claimedAt']?.toString() ?? '');
    final expiresAt = DateTime.tryParse(map['expiresAt']?.toString() ?? '');
    if (map['id'] == null ||
        map['rewardId'] == null ||
        claimedAt == null ||
        expiresAt == null) {
      return null;
    }
    return ClaimedReward(
      id: map['id'].toString(),
      rewardId: map['rewardId'].toString(),
      brandName: map['brandName']?.toString() ?? 'WalkApp partner',
      rewardTitle: map['rewardTitle']?.toString() ?? 'Campaign reward',
      sourceType:
          map['sourceType']?.toString() ==
              ClaimedRewardSourceType.pointRedemption.name
          ? ClaimedRewardSourceType.pointRedemption
          : ClaimedRewardSourceType.campaign,
      sourceCampaignId: map['sourceCampaignId']?.toString(),
      claimedAt: claimedAt,
      couponCode: map['couponCode']?.toString() ?? 'WALK-DEMO-SAVED',
      couponStatus: switch (map['couponStatus']?.toString()) {
        'used' => CouponStatus.used,
        'expired' => CouponStatus.expired,
        _ => CouponStatus.available,
      },
      expiresAt: expiresAt,
      pointsSpent: map['pointsSpent'] is int
          ? map['pointsSpent'] as int
          : int.tryParse(map['pointsSpent']?.toString() ?? '') ?? 0,
      discountLabel: map['discountLabel']?.toString() ?? 'Reward offer',
      usageChannel: map['usageChannel']?.toString() ?? 'See reward terms',
      minimumPurchaseDescription:
          map['minimumPurchaseDescription']?.toString() ?? 'See reward terms',
      terms: (map['terms'] is List)
          ? (map['terms'] as List).map((item) => item.toString()).toList()
          : const <String>['Prototype reward terms apply.'],
    );
  }
}
