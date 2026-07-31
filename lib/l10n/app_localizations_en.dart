// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WalkApp';

  @override
  String get startWalking => 'Start Walking';

  @override
  String get stopTracking => 'Stop Tracking';

  @override
  String get todaySteps => 'Today\'s Steps';

  @override
  String get confirmedSteps => 'Confirmed Steps';

  @override
  String get provisionalSteps => 'Provisional Steps';

  @override
  String get stepHistory => 'Step History';

  @override
  String get reset => 'Reset';

  @override
  String get walking => 'Walking';

  @override
  String get running => 'Running';

  @override
  String get still => 'Still';

  @override
  String get unknown => 'Unknown';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get home => 'Home';

  @override
  String get campaigns => 'Campaigns';

  @override
  String get rewards => 'Rewards';

  @override
  String get progress => 'Progress';

  @override
  String get notifications => 'Notifications';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get history => 'History';

  @override
  String get insights => 'Insights';

  @override
  String get achievements => 'Achievements';

  @override
  String get about => 'About';

  @override
  String get login => 'Log in';

  @override
  String get register => 'Create account';

  @override
  String get loading => 'Loading';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get logout => 'Log out';

  @override
  String get dailyGoal => 'Daily goal';

  @override
  String get trackingActive => 'Tracking active';

  @override
  String get trackingStopped => 'Tracking stopped';

  @override
  String get validating => 'Validating';

  @override
  String get remaining => 'Remaining';

  @override
  String get inVehicle => 'In vehicle';

  @override
  String get cycling => 'Cycling';

  @override
  String get detectingActivity => 'Detecting activity';

  @override
  String get appLanguage => 'App language';

  @override
  String get persianLanguage => 'فارسی';

  @override
  String get englishLanguage => 'English';

  @override
  String get personalizeWalkingExperience =>
      'Personalize your walking experience.';

  @override
  String get appearance => 'Appearance';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get dailyGoalUpdated => 'Daily goal updated';

  @override
  String dailyGoalStepCount(int count) {
    return '$count steps';
  }

  @override
  String get persistedDailyTarget => 'Your saved target for each day';

  @override
  String get editDailyGoal => 'Edit daily goal';

  @override
  String get inAppNotifications => 'In-app notifications';

  @override
  String get reminderPrototypeDescription =>
      'WalkApp checks these reminders while the app is open or when you return to it. System notifications are not enabled in this prototype.';

  @override
  String get dailyGoalReminder => 'Daily goal reminder';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get goalCompletionUpdates => 'Goal completion updates';

  @override
  String get campaignUpdates => 'Campaign updates';

  @override
  String get rewardUpdates => 'Reward updates';

  @override
  String get trackingInformation => 'Tracking information';

  @override
  String get backgroundTracking => 'Background tracking';

  @override
  String get backgroundTrackingDescription =>
      'Steps continue to be processed while tracking is active.';

  @override
  String get stepValidation => 'Step validation';

  @override
  String get stepValidationDescription =>
      'Candidate steps are confirmed using activity information.';

  @override
  String get activityRecognition => 'Activity recognition';

  @override
  String get activityRecognitionDescription =>
      'Walking, running, cycling, and vehicle activity help validate steps.';

  @override
  String get aboutDescription =>
      'A focused step tracker for building a healthier daily routine.';

  @override
  String get account => 'Account';

  @override
  String get prototypeAccount => 'Prototype account';

  @override
  String get logoutQuestion => 'Log out?';

  @override
  String get logoutDescription =>
      'You’ll return to Log in. Your step history and preferences will stay on this device.';

  @override
  String get trackingPaused => 'Tracking paused';

  @override
  String get preparingSensor => 'Preparing sensor';

  @override
  String get validatingRecentSteps => 'Validating recent steps';

  @override
  String get upToDate => 'Up to date';

  @override
  String get sensorReady => 'Step sensor ready';

  @override
  String get sensorPreparing => 'Preparing step sensor';

  @override
  String get sensorInactive => 'Step sensor inactive';

  @override
  String get lowConfidence => 'Low confidence';

  @override
  String get mediumConfidence => 'Medium confidence';

  @override
  String get highConfidence => 'High confidence';

  @override
  String currentActivityValue(String activity) {
    return 'Current activity: $activity';
  }

  @override
  String get emailExample => 'you@example.com';

  @override
  String get newToWalkApp => 'New to WalkApp?';

  @override
  String setupStepProgress(int current, int total) {
    return 'Setup step $current of $total';
  }

  @override
  String stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String goalValue(String goal) {
    return 'Goal: $goal';
  }

  @override
  String percentageValue(int percentage) {
    return '$percentage%';
  }

  @override
  String percentageComplete(int percentage) {
    return '$percentage% complete';
  }

  @override
  String goalNumber(int goal) {
    return 'Goal $goal';
  }

  @override
  String campaignProgressPercent(int percentage) {
    return 'Campaign progress $percentage%';
  }

  @override
  String rewardValue(String reward) {
    return 'Reward: $reward';
  }

  @override
  String pointsAvailable(int count) {
    return '$count points available';
  }

  @override
  String pointsRequired(int count) {
    return '$count points required';
  }

  @override
  String currentBalance(int count) {
    return 'Current balance: $count';
  }

  @override
  String currentBalancePoints(int count) {
    return 'Current balance: $count points';
  }

  @override
  String claimedOn(String date) {
    return 'Claimed on $date';
  }

  @override
  String expiresOn(String date) {
    return 'Expires on $date';
  }

  @override
  String redeemRewardQuestion(String reward) {
    return 'Redeem $reward?';
  }

  @override
  String importantTerms(String terms) {
    return 'Important terms: $terms';
  }

  @override
  String joinCampaignQuestion(String campaign) {
    return 'Join $campaign?';
  }

  @override
  String requirementValue(String requirement) {
    return 'Requirement: $requirement';
  }

  @override
  String endsOn(String date) {
    return 'Ends: $date';
  }

  @override
  String rewardPreviewValue(String reward) {
    return 'Reward preview: $reward';
  }

  @override
  String get openAccountMenu => 'Open account menu';

  @override
  String get discoverCampaigns => 'Discover campaigns';

  @override
  String get back => 'Back';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginWelcomeMessage =>
      'Continue your journey and reach today’s goal.';

  @override
  String get emailAddress => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get passwordRecoveryUnavailable =>
      'Password recovery will be available when authentication is connected.';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get registerWelcomeMessage =>
      'Start building a healthier daily routine.';

  @override
  String get fullName => 'Full name';

  @override
  String get yourName => 'Your name';

  @override
  String get minimumEightCharacters => 'At least 8 characters';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get acceptTermsAndPrivacy =>
      'I accept the Terms of Use and Privacy Policy';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get chooseTheme => 'Choose theme';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get localMvpAuthentication => 'Local MVP authentication';

  @override
  String get localMvpAuthenticationDescription =>
      'Credentials are not sent to or verified by a backend in this prototype.';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get enterEmailAddress => 'Enter your email address';

  @override
  String get enterValidEmailAddress => 'Enter a valid email address';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get useAtLeastEightCharacters => 'Use at least 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get acceptTermsToContinue =>
      'Accept the terms and privacy policy to continue';

  @override
  String get loadingLabel => 'Loading';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get clearReadNotificationsQuestion => 'Clear read notifications?';

  @override
  String readNotificationsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count read notifications will be removed from this device. Unread notifications will stay.',
      one:
          '1 read notification will be removed from this device. Unread notifications will stay.',
    );
    return '$_temp0';
  }

  @override
  String get clearReadNotifications => 'Clear read notifications';

  @override
  String get loadingNotifications => 'Loading notifications';

  @override
  String get notificationsLoadError => 'Notifications could not be loaded.';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get notificationEmptyDescription =>
      'Updates about goals, campaigns, and rewards will appear here.';

  @override
  String get notificationPageDescription =>
      'Updates about your health goals, campaigns, and rewards.';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get unread => 'Unread';

  @override
  String get earlier => 'Earlier';

  @override
  String get accountLogoutDescription =>
      'You’ll return to Log in. Your steps, goals, theme, and profile will stay on this device.';

  @override
  String get yourProfile => 'Your profile';

  @override
  String get addNameAndEmail => 'Add your name and email';

  @override
  String get aboutPageDescription =>
      'A focused walking companion for tracking daily steps and building a healthier routine.';

  @override
  String get materialThreeDesign => 'Material 3 design';

  @override
  String get materialThreeDescription =>
      'Responsive light and dark themes use a modern health-focused Material 3 design system.';

  @override
  String get localPreferences => 'Local preferences';

  @override
  String get localPreferencesDescription =>
      'Theme, daily goal, and profile details stay in the app’s local preferences.';

  @override
  String get purposefulTracking => 'Purposeful tracking';

  @override
  String get purposefulTrackingDescription =>
      'Step validation and activity information work together while tracking is active.';

  @override
  String get progressPageDescription =>
      'Your health progress and account in one place.';

  @override
  String get loadingProgressSummary => 'Loading progress summary';

  @override
  String get progressHistoryUnavailable =>
      'Progress history is temporarily unavailable.';

  @override
  String get yourProgress => 'Your progress';

  @override
  String unreadNotificationCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread',
      one: '1 unread',
    );
    return '$_temp0';
  }

  @override
  String localDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days recorded locally.',
      one: '1 day recorded locally.',
    );
    return '$_temp0';
  }

  @override
  String get historyMetricsUnavailable =>
      'History metrics are currently unavailable.';

  @override
  String goalDaysThisWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count goal days this week.',
      one: '1 goal day this week.',
    );
    return '$_temp0';
  }

  @override
  String get insightsHistoryUnavailable =>
      'Insights will show when history is available.';

  @override
  String achievementsUnlocked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count achievements unlocked.',
      one: '1 achievement unlocked.',
    );
    return '$_temp0';
  }

  @override
  String get yourAccount => 'Your account';

  @override
  String get manageProfileDescription =>
      'Manage your name and contact details.';

  @override
  String get settingsDescription => 'Adjust your goal, theme, and preferences.';

  @override
  String get aboutDestinationDescription =>
      'Learn more about WalkApp and tracking.';

  @override
  String get confirmedThisWeek => 'Confirmed this week';

  @override
  String get goalDaysThisWeekLabel => 'Goal days this week';

  @override
  String get currentGoalStreak => 'Current goal streak';

  @override
  String dayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get recordedOnDevice => 'Recorded on this device';

  @override
  String get localProgressSummary => 'Local progress summary';

  @override
  String get yourAchievements => 'Your achievements';

  @override
  String achievementProgress(int unlocked, int total) {
    return '$unlocked of $total unlocked from real local activity.';
  }

  @override
  String get firstStepsAchievement => 'First Steps';

  @override
  String get firstStepsAchievementDescription =>
      'Record at least 1,000 confirmed steps in one day.';

  @override
  String get goalGetterAchievement => 'Goal Getter';

  @override
  String get goalGetterAchievementDescription =>
      'Reach the recorded daily goal for the first time.';

  @override
  String get threeActiveDaysAchievement => 'Three Active Days';

  @override
  String get threeActiveDaysAchievementDescription =>
      'Record confirmed steps on three separate dates.';

  @override
  String get consistentWalkerAchievement => 'Consistent Walker';

  @override
  String get consistentWalkerAchievementDescription =>
      'Reach the daily goal on three consecutive dates.';

  @override
  String get weeklyExplorerAchievement => 'Weekly Explorer';

  @override
  String get weeklyExplorerAchievementDescription =>
      'Record 50,000 confirmed steps across seven consecutive days.';

  @override
  String get campaignFinisherAchievement => 'Campaign Finisher';

  @override
  String get campaignFinisherAchievementDescription =>
      'Complete one walking campaign.';

  @override
  String get healthCategory => 'Health';

  @override
  String get campaignCategory => 'Campaign';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get locked => 'Locked';

  @override
  String unlockedOn(String date) {
    return 'Unlocked $date';
  }

  @override
  String get profileDetails => 'Your account details';

  @override
  String get completeProfile => 'Complete your profile';

  @override
  String get profileStorageDescription =>
      'Stored privately with your local app preferences.';

  @override
  String get personalization => 'Personalization';

  @override
  String get city => 'City';

  @override
  String get rewardInterests => 'Reward interests';

  @override
  String dailyGoalWithSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return 'Daily goal: $_temp0';
  }

  @override
  String get notAdded => 'Not added';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileSaveError =>
      'Profile could not be saved. Please try again.';

  @override
  String get rewardInterestsUpdated => 'Reward interests updated';

  @override
  String get insightsDescription =>
      'Real trends from confirmed steps recorded on this device.';

  @override
  String get thisWeek => 'This week';

  @override
  String confirmedStepCount(String count) {
    return '$count confirmed steps';
  }

  @override
  String dailyAverage(String count) {
    return '$count daily average';
  }

  @override
  String activeDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active days',
      one: '1 active day',
    );
    return '$_temp0';
  }

  @override
  String goalDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count goal days',
      one: '1 goal day',
    );
    return '$_temp0';
  }

  @override
  String get moreWeeklyComparisons => 'More weekly comparisons are coming';

  @override
  String get keepTrackingForTrend =>
      'Keep tracking your walks to build a meaningful trend.';

  @override
  String get consistency => 'Consistency';

  @override
  String currentGoalDayStreak(int count) {
    return '$count current goal-day streak';
  }

  @override
  String longestLocalStreak(int count) {
    return '$count longest local streak';
  }

  @override
  String goalCompletionThirtyDays(int percentage) {
    return '$percentage% goal completion over 30 days';
  }

  @override
  String get bestDay => 'Best day';

  @override
  String datedConfirmedSteps(String date, String count) {
    return '$date — $count confirmed steps';
  }

  @override
  String get recordedGoalReached => 'Recorded goal reached';

  @override
  String get recordedGoalNotReached => 'Recorded goal not reached';

  @override
  String liveDisplayedSteps(String count) {
    return '$count live displayed steps';
  }

  @override
  String confirmedValue(String count) {
    return '$count confirmed';
  }

  @override
  String validatingValue(String count) {
    return '$count validating';
  }

  @override
  String dailyGoalFormatted(String goal) {
    return 'Daily goal: $goal';
  }

  @override
  String get liveStepsExplanation =>
      'Live displayed steps may include activity still being validated. Historical totals use confirmed steps only.';

  @override
  String percentageMore(int percentage) {
    return '$percentage% more';
  }

  @override
  String percentageFewer(int percentage) {
    return '$percentage% fewer';
  }

  @override
  String get comparedWithLastWeek => 'Compared with last week';

  @override
  String get historyDescription =>
      'Review your confirmed walking progress over time.';

  @override
  String get historyValidationExplanation =>
      'Today may include validating steps on Home. Completed days in History use confirmed steps.';

  @override
  String get sevenDays => '7 days';

  @override
  String get thirtyDays => '30 days';

  @override
  String get loadingWalkingHistory => 'Loading walking history';

  @override
  String get walkingHistoryUnavailable =>
      'Walking history is temporarily unavailable.';

  @override
  String get noConfirmedHistory => 'No confirmed step history yet';

  @override
  String get noConfirmedHistoryDescription =>
      'Start tracking your walks. Confirmed daily progress will appear here.';

  @override
  String get noRecordForDate => 'No local record for this date.';

  @override
  String get cityUpdated => 'City updated';

  @override
  String get clothing => 'Clothing';

  @override
  String get sports => 'Sports';

  @override
  String get food => 'Food';

  @override
  String get wellness => 'Wellness';

  @override
  String get noPreference => 'No preference';

  @override
  String get tehran => 'Tehran';

  @override
  String get karaj => 'Karaj';

  @override
  String get mashhad => 'Mashhad';

  @override
  String get isfahan => 'Isfahan';

  @override
  String get shiraz => 'Shiraz';

  @override
  String get tabriz => 'Tabriz';

  @override
  String get other => 'Other';

  @override
  String get preferNotToSay => 'Prefer not to say';

  @override
  String get previousSetupStep => 'Previous setup step';

  @override
  String get walkTowardHealthierHabits => 'Walk toward healthier habits';

  @override
  String get onboardingIntroDescription =>
      'WalkApp keeps personal health progress first. Campaigns are optional, and verified walking may unlock useful points or rewards.';

  @override
  String get trackDailyProgress => 'Track daily walking progress';

  @override
  String get buildHabitsWithGoal => 'Build habits with a personal goal';

  @override
  String get joinOptionalCampaigns => 'Join optional campaigns when you choose';

  @override
  String get chooseDailyGoal => 'Choose your daily goal';

  @override
  String get chooseDailyGoalDescription =>
      'Choose a goal that feels realistic for you. You can change it later.';

  @override
  String get comfortableStartingPoint => 'A comfortable starting point';

  @override
  String get balancedEverydayGoal => 'A balanced everyday goal';

  @override
  String get popularActiveTarget => 'A popular active target';

  @override
  String get activeWalkerGoal => 'For already active walkers';

  @override
  String get customGoal => 'Custom goal';

  @override
  String get whatInterestsYou => 'What interests you?';

  @override
  String get interestsDescription =>
      'Interests only help order local prototype content. Nothing is hidden.';

  @override
  String get chooseYourCity => 'Choose your city';

  @override
  String get citySelectionDescription =>
      'Your city may later help us highlight locally available campaigns. WalkApp does not use GPS for this choice.';

  @override
  String get physicalActivityAccess => 'Physical activity access';

  @override
  String get activityPermissionDescription =>
      'Activity access helps WalkApp detect walking and validate step progress. Background tracking lets active sessions continue with the screen off. Continuous GPS is not needed.';

  @override
  String get allowActivityAccess => 'Allow activity access';

  @override
  String get retryActivityAccess => 'Try activity access again';

  @override
  String get continueWithoutTracking => 'Continue without tracking';

  @override
  String get activityAccessGranted => 'Activity access granted';

  @override
  String get activityAccessNotGranted => 'Activity access not granted';

  @override
  String get enableAccessInSettings => 'Enable access in app settings';

  @override
  String get activitySensorUnavailable => 'Activity sensor unavailable';

  @override
  String get permissionBeforeRequest =>
      'Permission is requested only after you choose the action below.';

  @override
  String get trackingReadyDescription =>
      'You can start tracking from Home when you are ready.';

  @override
  String get trackingNeedsPermission =>
      'You can continue, but step tracking needs activity access.';

  @override
  String get enableActivityManually =>
      'Open this app’s system settings and enable activity access manually.';

  @override
  String get permissionUnsupported =>
      'This device does not support the prototype activity permission flow.';

  @override
  String get androidPermissionInstructions =>
      'Android: Settings → Apps → WalkApp → Permissions → Physical activity, then allow access.';

  @override
  String get youAreReady => 'You’re ready';

  @override
  String get completionDescription =>
      'Health tracking stays independent. Start it from Home whenever you choose.';

  @override
  String get interests => 'Interests';

  @override
  String get granted => 'Granted';

  @override
  String get notGranted => 'Not granted';

  @override
  String get decreaseGoal => 'Decrease goal by 1,000';

  @override
  String get goalInSteps => 'Goal in steps';

  @override
  String get increaseGoal => 'Increase goal by 1,000';

  @override
  String get quickOptions => 'Quick options';

  @override
  String get saveGoal => 'Save goal';

  @override
  String get dailyStepProgress => 'Daily step progress';

  @override
  String get currentActivity => 'Current activity';

  @override
  String get openNotifications => 'Open notifications';

  @override
  String get noUnreadNotifications => 'Notifications, none unread';

  @override
  String unreadNotificationsSemantics(int count) {
    return 'Notifications, $count unread';
  }

  @override
  String get todayHealthProgress => 'Today’s health progress';

  @override
  String todayHealthProgressSemantics(
    int steps,
    int goal,
    int percentage,
    int remaining,
  ) {
    return 'Today’s health progress, $steps of $goal steps, $percentage percent, $remaining remaining';
  }

  @override
  String progressOfGoal(int percentage, String goal, String remaining) {
    return '$percentage% of $goal • $remaining remaining';
  }

  @override
  String get loadingCampaignProgress => 'Loading campaign progress…';

  @override
  String get campaignProgressUnavailable =>
      'Campaign progress is temporarily unavailable.';

  @override
  String get activeCampaign => 'Active campaign';

  @override
  String campaignStepProgress(String current, String target) {
    return '$current / $target campaign steps';
  }

  @override
  String campaignGoalDayProgress(int current, int target) {
    return '$current of $target goal days completed';
  }

  @override
  String eligibleStepsToday(String current, String goal) {
    return '$current / $goal eligible steps today';
  }

  @override
  String get continueCampaign => 'Continue campaign';

  @override
  String get exploreMore => 'Explore more';

  @override
  String get campaignCompleted => 'Campaign completed';

  @override
  String get rewardReady => 'Reward ready';

  @override
  String pointsEarned(int count) {
    return '$count points earned';
  }

  @override
  String rewardReadyToClaim(String reward) {
    return '$reward is ready to claim';
  }

  @override
  String rewardUnlocked(String reward) {
    return '$reward unlocked';
  }

  @override
  String get viewRewards => 'View Rewards';

  @override
  String get claimReward => 'Claim reward';

  @override
  String get viewReward => 'View reward';

  @override
  String get viewAll => 'View all';

  @override
  String get featuredChallenge => 'Featured challenge';

  @override
  String get viewCampaign => 'View campaign';

  @override
  String get walkingChallengeQuestion => 'Ready for a walking challenge?';

  @override
  String get walkingChallengeDescription =>
      'Explore campaigns and unlock rewards from participating brands.';

  @override
  String get viewCampaigns => 'View campaigns';

  @override
  String get loadingRewards => 'Loading rewards…';

  @override
  String get rewardsUnavailable => 'Rewards are temporarily unavailable.';

  @override
  String rewardsReadyToClaim(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rewards ready to claim',
      one: '1 reward ready to claim',
    );
    return '$_temp0';
  }

  @override
  String availableCoupons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count available coupons',
      one: '1 available coupon',
    );
    return '$_temp0';
  }

  @override
  String get earnRewardsDescription =>
      'Complete eligible campaigns to start earning rewards.';

  @override
  String get openRewards => 'Open Rewards';

  @override
  String get localPrototypeContent => 'Local prototype content';

  @override
  String get loadingCampaigns => 'Loading campaigns';

  @override
  String get campaignsLoadError =>
      'Campaigns could not be loaded. Please try again.';

  @override
  String get noCampaignsAvailable => 'No campaigns available yet';

  @override
  String get noCampaignsDescription =>
      'New walking campaigns will appear here.';

  @override
  String get noMatchingCampaigns => 'No campaigns match your filters';

  @override
  String get tryAnotherCampaignFilter =>
      'Try another status or category filter.';

  @override
  String get active => 'Active';

  @override
  String get allCategories => 'All categories';

  @override
  String get done => 'Done';

  @override
  String get leaveCampaignQuestion => 'Leave this campaign?';

  @override
  String get leaveCampaign => 'Leave campaign';

  @override
  String get loadingCampaign => 'Loading campaign';

  @override
  String get noCampaignToShow => 'No campaign to show';

  @override
  String get returnToCampaigns => 'Return to Campaigns to discover a campaign.';

  @override
  String get startTracking => 'Start tracking';

  @override
  String get campaignRules => 'Campaign rules';

  @override
  String get activeCampaignExists => 'You already have an active campaign';

  @override
  String get keepCurrentCampaign => 'Keep current campaign';

  @override
  String get viewActiveCampaign => 'View active campaign';

  @override
  String get oneActiveCampaign => 'Only one campaign can be active at a time.';

  @override
  String get joinCampaign => 'Join campaign';

  @override
  String get campaignDetails => 'Campaign details';

  @override
  String get howItWorks => 'How it works';

  @override
  String get goalRules => 'Goal rules';

  @override
  String get rewardTerms => 'Reward terms';

  @override
  String get campaignDuration => 'Campaign duration';

  @override
  String get reward => 'Reward';

  @override
  String get minimumPurchase => 'Minimum purchase';

  @override
  String get whereToUse => 'Where to use';

  @override
  String get expiration => 'Expiration';

  @override
  String get availability => 'Availability';

  @override
  String get myRewards => 'My rewards';

  @override
  String get noClaimedRewards => 'No rewards claimed yet';

  @override
  String get viewCoupon => 'View coupon';

  @override
  String get walletActivity => 'Wallet activity';

  @override
  String get noPointTransactions => 'No point transactions yet';

  @override
  String get rewardDetails => 'Reward details';

  @override
  String get localRewardsPrototype => 'Local rewards prototype';

  @override
  String get noMatchingRewards => 'No matching rewards';

  @override
  String get viewWalletActivity => 'View wallet activity';

  @override
  String get viewDetails => 'View details';

  @override
  String get markCouponUsedQuestion => 'Mark coupon as used?';

  @override
  String get markAsUsed => 'Mark as used';

  @override
  String get couponDetails => 'Coupon details';

  @override
  String get savedRewardUnavailable =>
      'This saved reward is not available locally.';

  @override
  String get prototypeCoupon => 'Prototype coupon';

  @override
  String get copyCode => 'Copy code';

  @override
  String get status => 'Status';

  @override
  String get claimed => 'Claimed';

  @override
  String get source => 'Source';

  @override
  String get debugSimulation => 'Debug simulation';

  @override
  String get continueAction => 'Continue';

  @override
  String get continueToAccountSetup => 'Continue to account setup';

  @override
  String get chooseInterestError =>
      'Choose at least one interest or No preference.';

  @override
  String get goalRangeError => 'Enter a goal from 1,000 to 100,000 steps';

  @override
  String get dailyStepGoal => 'Daily step goal';

  @override
  String get goalSheetDescription =>
      'Choose a goal that feels achievable for your routine.';

  @override
  String get stepTrackingStarted => 'Step tracking started.';

  @override
  String get stepTrackingStopped => 'Step tracking stopped';

  @override
  String get trackingUpdateError =>
      'Tracking could not be updated. Please try again.';

  @override
  String get activityPermissionRequired =>
      'Activity permission is required to count steps.';

  @override
  String get stepSensorUnavailable =>
      'The step sensor is unavailable on this device.';

  @override
  String get trackingRefreshError =>
      'Tracking could not be updated. Pull down or try again.';

  @override
  String get stoppingTracking => 'Stopping…';

  @override
  String get startingTracking => 'Starting…';

  @override
  String get keepGoing => 'Keep going, you’re doing great!';

  @override
  String get readyToMove => 'Start tracking when you’re ready to move.';

  @override
  String get todayProgress => 'Today’s progress';

  @override
  String get sensorsReady => 'Sensors · Ready';

  @override
  String get sensorsPreparing => 'Sensors · Preparing';

  @override
  String get sensorsInactive => 'Sensors · Inactive';

  @override
  String get trackingActiveCompact => 'Tracking · Active';

  @override
  String get trackingStoppedCompact => 'Tracking · Stopped';

  @override
  String get validationValidating => 'Validation · Validating';

  @override
  String get validationIdle => 'Validation · Idle';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get dailyGoalCompletedNotification => 'Daily goal completed';

  @override
  String get dailyGoalCompletedMessage =>
      'You reached your walking goal for today.';

  @override
  String get dailyGoalReminderTitle =>
      'How many more steps will you take today?';

  @override
  String dailyGoalReminderMessage(int count) {
    return 'You have $count steps left to reach your daily goal.';
  }

  @override
  String get campaignEndingSoonNotification => 'Your campaign is ending soon';

  @override
  String campaignCompletedMessage(String campaign) {
    return 'You completed $campaign.';
  }

  @override
  String get campaignRewardReadyTitle => 'Reward ready to claim';

  @override
  String campaignRewardReadyMessage(String reward) {
    return 'Your $reward is ready.';
  }

  @override
  String get pointsAddedTitle => 'Points added';

  @override
  String pointsAddedMessage(int count) {
    return '$count points were added to your Rewards balance.';
  }

  @override
  String get rewardExpiringSoonTitle => 'Your reward is expiring soon';

  @override
  String rewardExpiringSoonMessage(String reward, String date) {
    return 'Use $reward before $date.';
  }

  @override
  String campaignStepsRemaining(int count) {
    return 'You need $count campaign steps before the deadline.';
  }

  @override
  String goalDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more goal days',
      one: '1 more goal day',
    );
    return 'You need $_temp0 before the deadline.';
  }

  @override
  String get campaignUnavailableShowingList =>
      'That campaign is no longer available. Showing Campaigns.';

  @override
  String get couponUnavailableShowingRewards =>
      'That coupon is no longer available. Showing Rewards.';

  @override
  String get rewardClaimError => 'The reward could not be claimed.';

  @override
  String get campaignRewardClaimed => 'Campaign reward claimed.';

  @override
  String get campaignEnrollmentLoadError =>
      'Enrollment state could not be loaded.';

  @override
  String get featuredCampaign => 'Featured campaign';

  @override
  String get endingSoon => 'Ending soon';

  @override
  String get completeOrLeaveCampaign =>
      'Complete or leave your current campaign before joining another one.';

  @override
  String get campaignNoLongerAvailable =>
      'This campaign is no longer available to join.';

  @override
  String get campaignAlreadyCompleted => 'You already completed this campaign.';

  @override
  String get campaignJoinError =>
      'The campaign could not be joined. Please try again.';

  @override
  String get joinCampaignStep => 'Join the campaign';

  @override
  String get walkCampaignPeriodStep => 'Walk during the campaign period';

  @override
  String get unlockRewardStep => 'Complete the goal and unlock the reward';

  @override
  String get targetSteps => 'Target steps';

  @override
  String get requiredGoalDays => 'Required goal days';

  @override
  String get eligibleActivityOnly => 'Only eligible verified activity counts.';

  @override
  String get personalDailyGoalUsed => 'Your personal daily goal is used.';

  @override
  String get campaignDayCountsOnce =>
      'Each campaign day can count at most once.';

  @override
  String get importantRestrictions => 'Important restrictions';

  @override
  String get campaignLeaveDescription =>
      'Your campaign progress will no longer remain active. Your normal health steps and daily goal history will not be deleted.';

  @override
  String get campaignLeaveError =>
      'The campaign could not be left. Please try again.';

  @override
  String get trackingStartError =>
      'Tracking could not be started. Please try again.';

  @override
  String get savedCampaignUnavailable =>
      'This saved campaign is unavailable. Your local record has been preserved.';

  @override
  String get requirementCompleted => 'Requirement completed';

  @override
  String get finalCampaignProgress => 'Final campaign progress';

  @override
  String get confirmedAfterEnrollmentOnly =>
      'Only confirmed steps recorded after enrollment count.';

  @override
  String get healthProgressIndependent =>
      'Health progress and the daily goal continue independently.';

  @override
  String get offlinePrototypeState =>
      'This is offline local prototype state. Device-local time is used.';

  @override
  String get rewardsDescription =>
      'Turn eligible activity and completed campaigns into useful offers.';

  @override
  String get rewardsLoadError => 'Rewards could not be loaded.';

  @override
  String get readyToClaim => 'Ready to claim';

  @override
  String get featuredReward => 'Featured reward';

  @override
  String get rewardCatalog => 'Reward catalog';

  @override
  String get rewardFilterHint => 'Try another category or earn more points.';

  @override
  String get availablePoints => 'Available points';

  @override
  String walletTotals(int earned, int spent) {
    return '$earned earned • $spent spent';
  }

  @override
  String get allFilter => 'All';

  @override
  String get affordableFilter => 'Affordable';

  @override
  String get clothingCategory => 'Clothing';

  @override
  String get sportsCategory => 'Sports';

  @override
  String get foodCategory => 'Food';

  @override
  String get wellnessCategory => 'Wellness';

  @override
  String get availableStatus => 'Available';

  @override
  String get insufficientPointsStatus => 'Not enough points';

  @override
  String get claimedStatus => 'Claimed';

  @override
  String get unavailableStatus => 'Unavailable';

  @override
  String get expiredStatus => 'Expired';

  @override
  String get used => 'Used';

  @override
  String get enoughPointsMessage =>
      'You have enough points to redeem this reward.';

  @override
  String morePointsNeeded(int count) {
    return '$count more points needed';
  }

  @override
  String get limitedRewardClaimed =>
      'This limited reward has already been claimed.';

  @override
  String get rewardCurrentlyUnavailable =>
      'This reward is not currently available.';

  @override
  String get rewardExpiredMessage => 'This reward has expired.';

  @override
  String balanceAfterRedemption(int count) {
    return 'Balance after redemption: $count';
  }

  @override
  String get localCouponDisclaimer =>
      'The resulting coupon is generated locally for MVP demonstration and cannot be validated by a real merchant.';

  @override
  String get insufficientBalanceMessage =>
      'Your point balance is no longer high enough.';

  @override
  String get rewardRedeemError => 'The reward could not be redeemed.';

  @override
  String pointsValue(int count) {
    return '$count points';
  }

  @override
  String afterRedemptionPoints(int count) {
    return 'After redemption: $count points';
  }

  @override
  String minimumPurchaseValue(String value) {
    return 'Minimum purchase: $value';
  }

  @override
  String whereToUseValue(String value) {
    return 'Where to use: $value';
  }

  @override
  String get terms => 'Terms';

  @override
  String get localRewardDisclaimer =>
      'Local prototype: points and coupons have no cash value and cannot be validated by a merchant.';

  @override
  String redeemForPoints(int count) {
    return 'Redeem for $count points';
  }

  @override
  String get viewClaimedReward => 'View reward';

  @override
  String get noClaimedRewardsDescription =>
      'Complete eligible campaigns or redeem a reward with points.';

  @override
  String noRewardsWithStatus(String status) {
    return 'There are no rewards with the status $status.';
  }

  @override
  String get campaignRewardSource => 'Campaign reward';

  @override
  String get pointsRedemptionSource => 'Points redemption';

  @override
  String get walletEmptyDescription =>
      'Point credits and reward redemptions will appear here.';

  @override
  String get onlineChannel => 'Online';

  @override
  String get inStoreChannel => 'In participating stores';

  @override
  String get onlineAndInStoreChannel => 'Online and in participating stores';

  @override
  String get dailyConfirmedSteps => 'Daily confirmed steps';

  @override
  String get totalConfirmed => 'Total confirmed';

  @override
  String get dailyAverageLabel => 'Daily average';

  @override
  String get goalDays => 'Goal days';

  @override
  String get activeDays => 'Active days';

  @override
  String confirmedStepsChartSemantics(int days, String steps) {
    return 'Confirmed steps chart for $days days. $steps total confirmed steps. The daily history list below provides complete details.';
  }

  @override
  String dayConfirmedStepsSemantics(String date, int steps) {
    return '$date, $steps confirmed steps';
  }

  @override
  String get today => 'Today';

  @override
  String get noRecord => 'No record';

  @override
  String get goalReached => 'Goal reached';

  @override
  String get completedDay => 'Completed day';

  @override
  String get campaignAvailableStatus => 'Available';

  @override
  String get campaignUpcomingStatus => 'Upcoming';

  @override
  String get campaignExpiredStatus => 'Expired';

  @override
  String get stepTargetType => 'Step target';

  @override
  String get goalConsistencyType => 'Goal consistency';

  @override
  String eligibleStepsCount(String count) {
    return '$count eligible steps';
  }

  @override
  String goalConsistencySummary(int required, int duration) {
    return 'Reach your goal on $required of $duration days';
  }

  @override
  String campaignStarts(String date) {
    return 'Starts $date';
  }

  @override
  String campaignEnded(String date) {
    return 'Ended $date';
  }

  @override
  String get endsToday => 'Ends today';

  @override
  String daysRemaining(int count) {
    return '$count days remaining';
  }

  @override
  String get viewProgress => 'View progress';

  @override
  String get completed => 'Completed';

  @override
  String get campaignFinished => 'Campaign ended';

  @override
  String get prototypeCouponCopied => 'Prototype coupon copied.';

  @override
  String get couponMarkedUsed => 'Coupon marked as used locally.';

  @override
  String get couponUpdateError => 'Coupon could not be updated.';

  @override
  String get couponUseLocalExplanation =>
      'This is only a local simulation and no merchant confirms this action.';

  @override
  String get activityAccessRequestError =>
      'Activity access could not be requested. Please try again.';

  @override
  String get setupSaveError =>
      'Your setup could not be saved locally. Please try again.';

  @override
  String get notificationsRefreshError =>
      'Notifications could not be refreshed. Your other WalkApp data is unaffected.';

  @override
  String get notificationUpdatesPending =>
      'Some notification updates are waiting to be saved locally.';

  @override
  String get notificationReadPending =>
      'This notification will be marked read when saving works.';

  @override
  String get readStatusSaveError => 'Read status could not be saved yet.';

  @override
  String get readNotificationsClearError =>
      'Read notifications could not be cleared yet.';

  @override
  String get campaignsDescription =>
      'Walk toward meaningful goals and unlock brand rewards.';

  @override
  String campaignStepsValue(String count) {
    return '$count campaign steps';
  }

  @override
  String goalDaysValue(int count) {
    return '$count goal days';
  }

  @override
  String confirmedCampaignStepsRequirement(String count) {
    return '$count confirmed campaign steps';
  }

  @override
  String separateGoalDaysRequirement(int days, String goal) {
    return '$days separate days reaching the captured $goal-step goal';
  }

  @override
  String get joinProgressExplanation =>
      'Progress starts from zero after joining. Only confirmed steps recorded after joining count. Normal health tracking continues.';

  @override
  String capturedGoalExplanation(String count) {
    return 'Your $count-step daily goal is captured now and will not change for this campaign.';
  }

  @override
  String leavingCampaignPointsOutcome(int count) {
    return 'Leaving removes this progress from active use. Completing this campaign awards $count points.';
  }

  @override
  String get leavingCampaignRewardOutcome =>
      'Leaving removes this progress from active use. Completing this campaign unlocks a reward you can claim.';

  @override
  String startsOn(String date) {
    return 'Starts on $date';
  }

  @override
  String daysValue(int count) {
    return '$count days';
  }

  @override
  String requiredVerifiedSteps(int count) {
    return '$count eligible verified steps are required.';
  }

  @override
  String walkBetweenDates(String start, String end) {
    return 'Walk between $start and $end.';
  }

  @override
  String requiredSeparateGoalDays(int count) {
    return '$count separate goal days are required.';
  }

  @override
  String get healthStepsContinueExplanation =>
      'Your health steps continue to be tracked normally.\n\nCampaign progress is calculated separately after joining.';

  @override
  String get pointsAddedToRewards => 'Added to your Rewards balance.';

  @override
  String get pointsBeingAdded => 'Your points are being added safely.';

  @override
  String get completedRewardReady =>
      'Your completed campaign reward is ready to claim.';

  @override
  String get couponAvailableInRewards =>
      'Your prototype coupon is available in My Rewards.';

  @override
  String joinedAndEnds(String joined, String ends) {
    return 'Joined $joined • Ends $ends';
  }

  @override
  String stepProgressSemantics(int percent, int current, int target) {
    return '$percent percent complete, $current of $target campaign steps';
  }

  @override
  String goalProgressSemantics(int completed, int required) {
    return '$completed of $required goal days complete';
  }

  @override
  String get campaignProgress => 'Campaign progress';

  @override
  String get campaignCompletedStatus => 'Campaign completed';

  @override
  String stepsRemainingPercent(String count, int percent) {
    return '$count steps remaining • $percent%';
  }

  @override
  String goalDaysCompleted(int completed, int required) {
    return '$completed / $required goal days completed';
  }

  @override
  String requiredDaysRemaining(int count) {
    return '$count required days remaining';
  }

  @override
  String capturedDailyGoal(String count) {
    return 'Captured daily goal: $count steps';
  }

  @override
  String earnedRewardPoints(int count) {
    return 'You earned $count reward points.';
  }

  @override
  String unlockedReward(String reward) {
    return 'You unlocked $reward.';
  }

  @override
  String get trackingActiveStatus => 'Tracking is active';

  @override
  String get trackingStoppedStatus => 'Tracking is stopped';

  @override
  String get trackingCampaignAutoUpdate =>
      'Eligible confirmed steps will update this campaign automatically.';

  @override
  String get trackingCampaignRequirement =>
      'Campaign progress changes only when eligible confirmed steps are recorded.';

  @override
  String deadlineValue(String date) {
    return 'Deadline: $date.';
  }

  @override
  String rewardPreviewSentence(String reward) {
    return 'Reward preview: $reward.';
  }

  @override
  String get campaignLeftHealthContinues =>
      'You left the campaign. Health tracking continues.';

  @override
  String capturedGoalPreserved(String count) {
    return 'This campaign keeps the captured $count-step goal even if your settings change.';
  }

  @override
  String get activeStatus => 'Active';

  @override
  String get leftStatus => 'Left';

  @override
  String get filterCampaigns => 'Filter campaigns';

  @override
  String unreadNotificationSemantics(String title, String message) {
    return 'Unread notification. $title. $message';
  }

  @override
  String notificationSemantics(String title, String message) {
    return '$title. $message';
  }

  @override
  String get newLabel => 'NEW';

  @override
  String dailyStepProgressValue(int steps, int goal, int percentage) {
    return '$steps of $goal steps, $percentage percent';
  }

  @override
  String get couponCodeDisclaimer =>
      'This locally generated code is for MVP demonstration only and cannot be validated by a real merchant.';

  @override
  String get rewardsLoadTryAgain =>
      'Rewards could not be loaded. Please try again.';

  @override
  String get campaignRewardClaimError =>
      'The campaign reward could not be claimed. Please try again.';

  @override
  String get rewardSafeRedeemError =>
      'The reward could not be redeemed safely. Your local wallet was restored when possible.';

  @override
  String get couponStatusUpdateError =>
      'The coupon status could not be updated.';

  @override
  String get campaignPointsPending =>
      'Campaign points could not be added yet. Rewards will retry safely.';

  @override
  String get campaignEnrollmentError =>
      'Campaign enrollment could not be loaded. Please try again.';

  @override
  String get campaignJoinLocalError =>
      'The campaign could not be joined locally. Please try again.';

  @override
  String get campaignLeaveLocalError =>
      'The campaign could not be left locally. Please try again.';

  @override
  String get campaignProgressSaveError =>
      'Campaign progress could not be saved. Tracking can continue while you retry.';

  @override
  String get savedCampaignDeviceUnavailable =>
      'This saved campaign is not available on this device. Its local progress is preserved.';

  @override
  String get campaignStatusUpdateError =>
      'The campaign status could not be updated locally. Please try again.';

  @override
  String get historyLoadControllerError =>
      'Local walking history could not be loaded. Step tracking can continue.';

  @override
  String get historySaveControllerError =>
      'Today’s confirmed history could not be saved yet. Tracking continues normally.';

  @override
  String get yesterday => 'Yesterday';

  @override
  String todayAtTime(String time) {
    return 'Today, $time';
  }

  @override
  String rewardMoveWearContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'Activewear starter offer',
      'short': 'A saving on selected everyday activewear.',
      'full': 'Redeem points for a saving on selected MoveWear activewear.',
      'discount': '10% off selected activewear',
      'minimum': 'Minimum purchase of €35',
      'expiration': 'Use within 14 days of redemption',
      'inventory': 'Eligible sizes and styles are subject to availability',
      'term1': 'Applies to campaign-marked products only.',
      'term2': 'Cannot be combined with another offer.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String rewardGreenBiteContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'Healthy meal offer',
      'short': 'Save on one eligible meal order.',
      'full': 'Redeem points for a saving on an eligible GreenBite meal order.',
      'discount': '20% off an eligible meal order',
      'minimum': 'Minimum purchase of €25',
      'expiration': 'Use within 10 days of redemption',
      'inventory': 'Available for eligible menu items',
      'term1': 'Delivery and service fees are excluded.',
      'term2': 'One prototype redemption per local user.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String rewardUrbanFitContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'Equipment saving',
      'short': 'A fixed saving on selected sports equipment.',
      'full': 'Use this prototype offer toward eligible UrbanFit equipment.',
      'discount': '€15 off selected sports equipment',
      'minimum': 'Minimum purchase of €70',
      'expiration': 'Use within 21 days of redemption',
      'inventory': 'Products are subject to availability',
      'term1': 'Selected equipment only.',
      'term2': 'Shipping does not count toward the minimum.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String rewardStepStyleContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'Walking essentials offer',
      'short': 'A low-point saving on walking essentials.',
      'full': 'Redeem a small points balance for selected walking essentials.',
      'discount': '12% off selected walking essentials',
      'minimum': 'Minimum purchase of €20',
      'expiration': 'Use within 7 days of redemption',
      'inventory': 'Participating locations only',
      'term1': 'Excludes clearance products.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String rewardFreshDayContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'Wellness bundle offer',
      'short': 'Save on one eligible wellness bundle.',
      'full': 'A higher-value prototype reward for a FreshDay wellness bundle.',
      'discount': '€20 off an eligible wellness bundle',
      'minimum': 'Minimum purchase of €80',
      'expiration': 'Use within 14 days of redemption',
      'inventory': 'Limited eligible bundle inventory',
      'term1': 'Applies to campaign-marked bundles only.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String rewardActiveLifeContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'Wellness session offer',
      'short': 'A saving on an eligible wellness session.',
      'full':
          'This prototype reward is temporarily unavailable while sessions are updated.',
      'discount': '25% off one wellness session',
      'minimum': 'No minimum purchase',
      'expiration': 'Use within 14 days of redemption',
      'inventory': 'Temporarily unavailable',
      'term1': 'Advance booking would be required.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String campaignMoveWearContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': '30,000-step week',
      'short': 'Build an active week with a clear verified-step target.',
      'full':
          'Walk 30,000 eligible verified steps during the seven-day campaign period to unlock a saving on selected sportswear.',
      'rewardTitle': 'Selected sportswear discount',
      'rewardDescription': 'Save on eligible MoveWear sportswear.',
      'discount': '20% off selected sportswear',
      'minimum': 'Minimum purchase of €50',
      'usage': 'Online and in participating stores',
      'expiration': 'Use within 14 days of unlocking',
      'inventory': 'Eligible items are subject to availability',
      'term1': 'Discount applies only to items marked as campaign eligible.',
      'term2': 'Cannot be combined with another promotional offer.',
      'term3': 'Each participant can receive only one reward.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String campaignGreenBiteContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'Five goal days',
      'short': 'Reach your personal walking goal on five campaign days.',
      'full':
          'Reach your current personal daily goal on five of the seven campaign days to unlock a healthy-meal saving.',
      'rewardTitle': '250 reward points',
      'rewardDescription': 'Earn points to use in the reward catalog.',
      'discount': '250 points',
      'minimum': 'Minimum purchase of €25',
      'usage': 'Online orders only',
      'expiration': 'Use within 10 days of unlocking',
      'inventory': 'While campaign rewards remain available',
      'term1': 'Applies to eligible meal items only.',
      'term2': 'Delivery and service fees are excluded.',
      'term3': 'Each participant can receive only one reward.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String campaignUrbanFitContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'City walking challenge',
      'short': 'A two-week walking target designed for everyday movement.',
      'full':
          'Walk 60,000 eligible verified steps over fourteen days to unlock a saving on selected training accessories.',
      'rewardTitle': '400 reward points',
      'rewardDescription': 'Earn points to use in the reward catalog.',
      'discount': '400 points',
      'minimum': 'Minimum purchase of €35',
      'usage': 'Online only',
      'expiration': 'Use within 21 days of unlocking',
      'inventory': 'Eligible products are subject to availability',
      'term1': 'Only accessories identified as eligible are included.',
      'term2': 'Cannot be exchanged for cash.',
      'term3': 'Each participant can receive only one reward.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String campaignStepStyleContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'Consistent steps',
      'short': 'Meet your personal daily goal on eight of ten days.',
      'full':
          'Build a consistent walking routine by reaching your personal daily goal on eight separate campaign days.',
      'rewardTitle': 'Walking apparel discount',
      'rewardDescription': 'Save on selected StepStyle walking apparel.',
      'discount': '18% off eligible walking apparel',
      'minimum': 'Minimum purchase of €60',
      'usage': 'Online and in participating stores',
      'expiration': 'Use within 14 days of unlocking',
      'inventory': 'Sizes and styles are subject to availability',
      'term1': 'Discount excludes clearance items.',
      'term2': 'Cannot be combined with membership pricing.',
      'term3': 'Each participant can receive only one reward.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String campaignFreshDayContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'Fresh-start walk',
      'short': 'Collect 20,000 verified steps during a five-day reset.',
      'full':
          'Walk 20,000 eligible verified steps during the campaign period and unlock a saving on an eligible wellness bundle.',
      'rewardTitle': 'Wellness bundle discount',
      'rewardDescription': 'Save on one eligible FreshDay wellness bundle.',
      'discount': '€10 off an eligible wellness bundle',
      'minimum': 'Minimum purchase of €40',
      'usage': 'Online only',
      'expiration': 'Use within 7 days of unlocking',
      'inventory': 'Limited to available eligible bundles',
      'term1': 'Applies to campaign-marked bundles only.',
      'term2': 'Shipping charges do not count toward the minimum purchase.',
      'term3': 'Each participant can receive only one reward.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String campaignActiveLifeContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'Active goal week',
      'short': 'A completed prototype campaign focused on daily goals.',
      'full':
          'This campaign asked participants to reach their personal daily goal on four of seven campaign days.',
      'rewardTitle': 'Wellness session discount',
      'rewardDescription': 'A saving on an eligible ActiveLife session.',
      'discount': '25% off one eligible wellness session',
      'minimum': 'No minimum purchase',
      'usage': 'At participating locations',
      'expiration': 'Reward availability period has ended',
      'inventory': 'Subject to available appointment times',
      'term1': 'Applied to selected sessions only.',
      'term2': 'Advance booking was required.',
      'term3': 'The campaign and its reward period have ended.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String rewardRedeemedTransaction(String brand, String reward) {
    return 'Redeemed $brand $reward';
  }

  @override
  String rewardRedemptionRestoredTransaction(String brand) {
    return 'Restored failed $brand redemption';
  }

  @override
  String campaignCompletedTransaction(String campaign) {
    return '$campaign completed';
  }

  @override
  String get prototypeRewardTerms => 'Prototype reward terms apply.';

  @override
  String get transitionBasedDetection => 'Transition-based detection';

  @override
  String get diagnosticReports => 'Diagnostic reports';

  @override
  String get diagnosticReportsDescription =>
      'Review and export controlled step-tracking sessions.';

  @override
  String get diagnosticNoReports => 'No diagnostic reports are available.';

  @override
  String get diagnosticTestMetadata => 'Test session details';

  @override
  String get diagnosticTestName => 'Test name';

  @override
  String get diagnosticManualSteps => 'Manually counted steps';

  @override
  String get diagnosticRouteDescription => 'Route description';

  @override
  String get diagnosticNotes => 'Test notes';

  @override
  String get diagnosticEditMetadata => 'Add or edit test details';

  @override
  String get diagnosticExportReport => 'Export report';

  @override
  String get diagnosticDeleteSession => 'Delete diagnostic session';

  @override
  String get diagnosticClearReports => 'Clear reports';

  @override
  String diagnosticSessionSummary(
    String mode,
    int candidates,
    int accepted,
    int rejected,
  ) {
    return '$mode · $candidates candidates · $accepted accepted · $rejected rejected';
  }

  @override
  String diagnosticSessionDetails(
    String mode,
    int durationSeconds,
    int candidates,
    int accepted,
    int rejected,
    int confirmedGained,
    String manualSteps,
  ) {
    return '$mode · ${durationSeconds}s · $candidates raw · $accepted accepted · $rejected rejected · +$confirmedGained confirmed · manual $manualSteps';
  }
}
