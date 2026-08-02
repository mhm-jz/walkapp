import '../domain/coupon_status.dart';
import '../domain/reward_channel.dart';
import '../../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

String rewardDate(AppLocalizations l10n, DateTime value) =>
    DateFormat.yMMMd(l10n.localeName).format(value);

String rewardChannelLabel(AppLocalizations l10n, RewardChannel channel) =>
    switch (channel) {
      RewardChannel.online => l10n.onlineChannel,
      RewardChannel.inStore => l10n.inStoreChannel,
      RewardChannel.onlineAndInStore => l10n.onlineAndInStoreChannel,
    };

String couponStatusLabel(AppLocalizations l10n, CouponStatus status) =>
    switch (status) {
      CouponStatus.available => l10n.availableStatus,
      CouponStatus.used => l10n.used,
      CouponStatus.expired => l10n.expiredStatus,
    };

String localizedRewardTerm(AppLocalizations l10n, String term) =>
    term == 'Prototype reward terms apply.' ? l10n.prototypeRewardTerms : term;
