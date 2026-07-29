import '../domain/coupon_status.dart';
import '../domain/reward_channel.dart';

String rewardDate(DateTime value) {
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

String rewardChannelLabel(RewardChannel channel) => switch (channel) {
  RewardChannel.online => 'Online',
  RewardChannel.inStore => 'In participating stores',
  RewardChannel.onlineAndInStore => 'Online and in participating stores',
};

String couponStatusLabel(CouponStatus status) => switch (status) {
  CouponStatus.available => 'Available',
  CouponStatus.used => 'Used',
  CouponStatus.expired => 'Expired',
};
