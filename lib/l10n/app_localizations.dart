import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'WalkApp'**
  String get appTitle;

  /// No description provided for @startWalking.
  ///
  /// In en, this message translates to:
  /// **'Start Walking'**
  String get startWalking;

  /// No description provided for @stopTracking.
  ///
  /// In en, this message translates to:
  /// **'Stop Tracking'**
  String get stopTracking;

  /// No description provided for @todaySteps.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Steps'**
  String get todaySteps;

  /// No description provided for @confirmedSteps.
  ///
  /// In en, this message translates to:
  /// **'Confirmed Steps'**
  String get confirmedSteps;

  /// No description provided for @provisionalSteps.
  ///
  /// In en, this message translates to:
  /// **'Provisional Steps'**
  String get provisionalSteps;

  /// No description provided for @stepHistory.
  ///
  /// In en, this message translates to:
  /// **'Step History'**
  String get stepHistory;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @walking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get walking;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @still.
  ///
  /// In en, this message translates to:
  /// **'Still'**
  String get still;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @campaigns.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get campaigns;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoal;

  /// No description provided for @trackingActive.
  ///
  /// In en, this message translates to:
  /// **'Tracking active'**
  String get trackingActive;

  /// No description provided for @trackingStopped.
  ///
  /// In en, this message translates to:
  /// **'Tracking stopped'**
  String get trackingStopped;

  /// No description provided for @validating.
  ///
  /// In en, this message translates to:
  /// **'Validating'**
  String get validating;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @inVehicle.
  ///
  /// In en, this message translates to:
  /// **'In vehicle'**
  String get inVehicle;

  /// No description provided for @cycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get cycling;

  /// No description provided for @detectingActivity.
  ///
  /// In en, this message translates to:
  /// **'Detecting activity'**
  String get detectingActivity;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @persianLanguage.
  ///
  /// In en, this message translates to:
  /// **'فارسی'**
  String get persianLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @personalizeWalkingExperience.
  ///
  /// In en, this message translates to:
  /// **'Personalize your walking experience.'**
  String get personalizeWalkingExperience;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @dailyGoalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Daily goal updated'**
  String get dailyGoalUpdated;

  /// No description provided for @dailyGoalStepCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String dailyGoalStepCount(int count);

  /// No description provided for @persistedDailyTarget.
  ///
  /// In en, this message translates to:
  /// **'Your saved target for each day'**
  String get persistedDailyTarget;

  /// No description provided for @editDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit daily goal'**
  String get editDailyGoal;

  /// No description provided for @inAppNotifications.
  ///
  /// In en, this message translates to:
  /// **'In-app notifications'**
  String get inAppNotifications;

  /// No description provided for @reminderPrototypeDescription.
  ///
  /// In en, this message translates to:
  /// **'WalkApp checks these reminders while the app is open or when you return to it. System notifications are not enabled in this prototype.'**
  String get reminderPrototypeDescription;

  /// No description provided for @dailyGoalReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily goal reminder'**
  String get dailyGoalReminder;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @goalCompletionUpdates.
  ///
  /// In en, this message translates to:
  /// **'Goal completion updates'**
  String get goalCompletionUpdates;

  /// No description provided for @campaignUpdates.
  ///
  /// In en, this message translates to:
  /// **'Campaign updates'**
  String get campaignUpdates;

  /// No description provided for @rewardUpdates.
  ///
  /// In en, this message translates to:
  /// **'Reward updates'**
  String get rewardUpdates;

  /// No description provided for @trackingInformation.
  ///
  /// In en, this message translates to:
  /// **'Tracking information'**
  String get trackingInformation;

  /// No description provided for @backgroundTracking.
  ///
  /// In en, this message translates to:
  /// **'Background tracking'**
  String get backgroundTracking;

  /// No description provided for @backgroundTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'Steps continue to be processed while tracking is active.'**
  String get backgroundTrackingDescription;

  /// No description provided for @stepValidation.
  ///
  /// In en, this message translates to:
  /// **'Step validation'**
  String get stepValidation;

  /// No description provided for @stepValidationDescription.
  ///
  /// In en, this message translates to:
  /// **'Candidate steps are confirmed using activity information.'**
  String get stepValidationDescription;

  /// No description provided for @activityRecognition.
  ///
  /// In en, this message translates to:
  /// **'Activity recognition'**
  String get activityRecognition;

  /// No description provided for @activityRecognitionDescription.
  ///
  /// In en, this message translates to:
  /// **'Walking, running, cycling, and vehicle activity help validate steps.'**
  String get activityRecognitionDescription;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A focused step tracker for building a healthier daily routine.'**
  String get aboutDescription;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @prototypeAccount.
  ///
  /// In en, this message translates to:
  /// **'Prototype account'**
  String get prototypeAccount;

  /// No description provided for @logoutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutQuestion;

  /// No description provided for @logoutDescription.
  ///
  /// In en, this message translates to:
  /// **'You’ll return to Log in. Your step history and preferences will stay on this device.'**
  String get logoutDescription;

  /// No description provided for @trackingPaused.
  ///
  /// In en, this message translates to:
  /// **'Tracking paused'**
  String get trackingPaused;

  /// No description provided for @preparingSensor.
  ///
  /// In en, this message translates to:
  /// **'Preparing sensor'**
  String get preparingSensor;

  /// No description provided for @validatingRecentSteps.
  ///
  /// In en, this message translates to:
  /// **'Validating recent steps'**
  String get validatingRecentSteps;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get upToDate;

  /// No description provided for @sensorReady.
  ///
  /// In en, this message translates to:
  /// **'Step sensor ready'**
  String get sensorReady;

  /// No description provided for @sensorPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing step sensor'**
  String get sensorPreparing;

  /// No description provided for @sensorInactive.
  ///
  /// In en, this message translates to:
  /// **'Step sensor inactive'**
  String get sensorInactive;

  /// No description provided for @lowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Low confidence'**
  String get lowConfidence;

  /// No description provided for @mediumConfidence.
  ///
  /// In en, this message translates to:
  /// **'Medium confidence'**
  String get mediumConfidence;

  /// No description provided for @highConfidence.
  ///
  /// In en, this message translates to:
  /// **'High confidence'**
  String get highConfidence;

  /// No description provided for @currentActivityValue.
  ///
  /// In en, this message translates to:
  /// **'Current activity: {activity}'**
  String currentActivityValue(String activity);

  /// No description provided for @emailExample.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailExample;

  /// No description provided for @newToWalkApp.
  ///
  /// In en, this message translates to:
  /// **'New to WalkApp?'**
  String get newToWalkApp;

  /// No description provided for @setupStepProgress.
  ///
  /// In en, this message translates to:
  /// **'Setup step {current} of {total}'**
  String setupStepProgress(int current, int total);

  /// No description provided for @stepCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String stepCount(int count);

  /// No description provided for @goalValue.
  ///
  /// In en, this message translates to:
  /// **'Goal: {goal}'**
  String goalValue(String goal);

  /// No description provided for @percentageValue.
  ///
  /// In en, this message translates to:
  /// **'{percentage}%'**
  String percentageValue(int percentage);

  /// No description provided for @percentageComplete.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% complete'**
  String percentageComplete(int percentage);

  /// No description provided for @goalNumber.
  ///
  /// In en, this message translates to:
  /// **'Goal {goal}'**
  String goalNumber(int goal);

  /// No description provided for @campaignProgressPercent.
  ///
  /// In en, this message translates to:
  /// **'Campaign progress {percentage}%'**
  String campaignProgressPercent(int percentage);

  /// No description provided for @rewardValue.
  ///
  /// In en, this message translates to:
  /// **'Reward: {reward}'**
  String rewardValue(String reward);

  /// No description provided for @pointsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} points available'**
  String pointsAvailable(int count);

  /// No description provided for @pointsRequired.
  ///
  /// In en, this message translates to:
  /// **'{count} points required'**
  String pointsRequired(int count);

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance: {count}'**
  String currentBalance(int count);

  /// No description provided for @currentBalancePoints.
  ///
  /// In en, this message translates to:
  /// **'Current balance: {count} points'**
  String currentBalancePoints(int count);

  /// No description provided for @claimedOn.
  ///
  /// In en, this message translates to:
  /// **'Claimed on {date}'**
  String claimedOn(String date);

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on {date}'**
  String expiresOn(String date);

  /// No description provided for @redeemRewardQuestion.
  ///
  /// In en, this message translates to:
  /// **'Redeem {reward}?'**
  String redeemRewardQuestion(String reward);

  /// No description provided for @importantTerms.
  ///
  /// In en, this message translates to:
  /// **'Important terms: {terms}'**
  String importantTerms(String terms);

  /// No description provided for @joinCampaignQuestion.
  ///
  /// In en, this message translates to:
  /// **'Join {campaign}?'**
  String joinCampaignQuestion(String campaign);

  /// No description provided for @requirementValue.
  ///
  /// In en, this message translates to:
  /// **'Requirement: {requirement}'**
  String requirementValue(String requirement);

  /// No description provided for @endsOn.
  ///
  /// In en, this message translates to:
  /// **'Ends: {date}'**
  String endsOn(String date);

  /// No description provided for @rewardPreviewValue.
  ///
  /// In en, this message translates to:
  /// **'Reward preview: {reward}'**
  String rewardPreviewValue(String reward);

  /// No description provided for @openAccountMenu.
  ///
  /// In en, this message translates to:
  /// **'Open account menu'**
  String get openAccountMenu;

  /// No description provided for @discoverCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Discover campaigns'**
  String get discoverCampaigns;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Continue your journey and reach today’s goal.'**
  String get loginWelcomeMessage;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @passwordRecoveryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Password recovery will be available when authentication is connected.'**
  String get passwordRecoveryUnavailable;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @registerWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Start building a healthier daily routine.'**
  String get registerWelcomeMessage;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @minimumEightCharacters.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get minimumEightCharacters;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @acceptTermsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms of Use and Privacy Policy'**
  String get acceptTermsAndPrivacy;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose theme'**
  String get chooseTheme;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @localMvpAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Local MVP authentication'**
  String get localMvpAuthentication;

  /// No description provided for @localMvpAuthenticationDescription.
  ///
  /// In en, this message translates to:
  /// **'Credentials are not sent to or verified by a backend in this prototype.'**
  String get localMvpAuthenticationDescription;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterEmailAddress;

  /// No description provided for @enterValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmailAddress;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @useAtLeastEightCharacters.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get useAtLeastEightCharacters;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @acceptTermsToContinue.
  ///
  /// In en, this message translates to:
  /// **'Accept the terms and privacy policy to continue'**
  String get acceptTermsToContinue;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loadingLabel;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @clearReadNotificationsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Clear read notifications?'**
  String get clearReadNotificationsQuestion;

  /// No description provided for @readNotificationsRemoved.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 read notification will be removed from this device. Unread notifications will stay.} other{{count} read notifications will be removed from this device. Unread notifications will stay.}}'**
  String readNotificationsRemoved(int count);

  /// No description provided for @clearReadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear read notifications'**
  String get clearReadNotifications;

  /// No description provided for @loadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Loading notifications'**
  String get loadingNotifications;

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Notifications could not be loaded.'**
  String get notificationsLoadError;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @notificationEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Updates about goals, campaigns, and rewards will appear here.'**
  String get notificationEmptyDescription;

  /// No description provided for @notificationPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Updates about your health goals, campaigns, and rewards.'**
  String get notificationPageDescription;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @accountLogoutDescription.
  ///
  /// In en, this message translates to:
  /// **'You’ll return to Log in. Your steps, goals, theme, and profile will stay on this device.'**
  String get accountLogoutDescription;

  /// No description provided for @yourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get yourProfile;

  /// No description provided for @addNameAndEmail.
  ///
  /// In en, this message translates to:
  /// **'Add your name and email'**
  String get addNameAndEmail;

  /// No description provided for @aboutPageDescription.
  ///
  /// In en, this message translates to:
  /// **'A focused walking companion for tracking daily steps and building a healthier routine.'**
  String get aboutPageDescription;

  /// No description provided for @materialThreeDesign.
  ///
  /// In en, this message translates to:
  /// **'Material 3 design'**
  String get materialThreeDesign;

  /// No description provided for @materialThreeDescription.
  ///
  /// In en, this message translates to:
  /// **'Responsive light and dark themes use a modern health-focused Material 3 design system.'**
  String get materialThreeDescription;

  /// No description provided for @localPreferences.
  ///
  /// In en, this message translates to:
  /// **'Local preferences'**
  String get localPreferences;

  /// No description provided for @localPreferencesDescription.
  ///
  /// In en, this message translates to:
  /// **'Theme, daily goal, and profile details stay in the app’s local preferences.'**
  String get localPreferencesDescription;

  /// No description provided for @purposefulTracking.
  ///
  /// In en, this message translates to:
  /// **'Purposeful tracking'**
  String get purposefulTracking;

  /// No description provided for @purposefulTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'Step validation and activity information work together while tracking is active.'**
  String get purposefulTrackingDescription;

  /// No description provided for @progressPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Your health progress and account in one place.'**
  String get progressPageDescription;

  /// No description provided for @loadingProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'Loading progress summary'**
  String get loadingProgressSummary;

  /// No description provided for @progressHistoryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Progress history is temporarily unavailable.'**
  String get progressHistoryUnavailable;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get yourProgress;

  /// No description provided for @unreadNotificationCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread} other{{count} unread}}'**
  String unreadNotificationCount(int count);

  /// No description provided for @localDayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day recorded locally.} other{{count} days recorded locally.}}'**
  String localDayCount(int count);

  /// No description provided for @historyMetricsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'History metrics are currently unavailable.'**
  String get historyMetricsUnavailable;

  /// No description provided for @goalDaysThisWeek.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 goal day this week.} other{{count} goal days this week.}}'**
  String goalDaysThisWeek(int count);

  /// No description provided for @insightsHistoryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Insights will show when history is available.'**
  String get insightsHistoryUnavailable;

  /// No description provided for @achievementsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 achievement unlocked.} other{{count} achievements unlocked.}}'**
  String achievementsUnlocked(int count);

  /// No description provided for @yourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get yourAccount;

  /// No description provided for @manageProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your name and contact details.'**
  String get manageProfileDescription;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust your goal, theme, and preferences.'**
  String get settingsDescription;

  /// No description provided for @aboutDestinationDescription.
  ///
  /// In en, this message translates to:
  /// **'Learn more about WalkApp and tracking.'**
  String get aboutDestinationDescription;

  /// No description provided for @confirmedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Confirmed this week'**
  String get confirmedThisWeek;

  /// No description provided for @goalDaysThisWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal days this week'**
  String get goalDaysThisWeekLabel;

  /// No description provided for @currentGoalStreak.
  ///
  /// In en, this message translates to:
  /// **'Current goal streak'**
  String get currentGoalStreak;

  /// No description provided for @dayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String dayCount(int count);

  /// No description provided for @recordedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Recorded on this device'**
  String get recordedOnDevice;

  /// No description provided for @localProgressSummary.
  ///
  /// In en, this message translates to:
  /// **'Local progress summary'**
  String get localProgressSummary;

  /// No description provided for @yourAchievements.
  ///
  /// In en, this message translates to:
  /// **'Your achievements'**
  String get yourAchievements;

  /// No description provided for @achievementProgress.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} of {total} unlocked from real local activity.'**
  String achievementProgress(int unlocked, int total);

  /// No description provided for @firstStepsAchievement.
  ///
  /// In en, this message translates to:
  /// **'First Steps'**
  String get firstStepsAchievement;

  /// No description provided for @firstStepsAchievementDescription.
  ///
  /// In en, this message translates to:
  /// **'Record at least 1,000 confirmed steps in one day.'**
  String get firstStepsAchievementDescription;

  /// No description provided for @goalGetterAchievement.
  ///
  /// In en, this message translates to:
  /// **'Goal Getter'**
  String get goalGetterAchievement;

  /// No description provided for @goalGetterAchievementDescription.
  ///
  /// In en, this message translates to:
  /// **'Reach the recorded daily goal for the first time.'**
  String get goalGetterAchievementDescription;

  /// No description provided for @threeActiveDaysAchievement.
  ///
  /// In en, this message translates to:
  /// **'Three Active Days'**
  String get threeActiveDaysAchievement;

  /// No description provided for @threeActiveDaysAchievementDescription.
  ///
  /// In en, this message translates to:
  /// **'Record confirmed steps on three separate dates.'**
  String get threeActiveDaysAchievementDescription;

  /// No description provided for @consistentWalkerAchievement.
  ///
  /// In en, this message translates to:
  /// **'Consistent Walker'**
  String get consistentWalkerAchievement;

  /// No description provided for @consistentWalkerAchievementDescription.
  ///
  /// In en, this message translates to:
  /// **'Reach the daily goal on three consecutive dates.'**
  String get consistentWalkerAchievementDescription;

  /// No description provided for @weeklyExplorerAchievement.
  ///
  /// In en, this message translates to:
  /// **'Weekly Explorer'**
  String get weeklyExplorerAchievement;

  /// No description provided for @weeklyExplorerAchievementDescription.
  ///
  /// In en, this message translates to:
  /// **'Record 50,000 confirmed steps across seven consecutive days.'**
  String get weeklyExplorerAchievementDescription;

  /// No description provided for @campaignFinisherAchievement.
  ///
  /// In en, this message translates to:
  /// **'Campaign Finisher'**
  String get campaignFinisherAchievement;

  /// No description provided for @campaignFinisherAchievementDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete one walking campaign.'**
  String get campaignFinisherAchievementDescription;

  /// No description provided for @healthCategory.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthCategory;

  /// No description provided for @campaignCategory.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get campaignCategory;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @unlockedOn.
  ///
  /// In en, this message translates to:
  /// **'Unlocked {date}'**
  String unlockedOn(String date);

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Your account details'**
  String get profileDetails;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeProfile;

  /// No description provided for @profileStorageDescription.
  ///
  /// In en, this message translates to:
  /// **'Stored privately with your local app preferences.'**
  String get profileStorageDescription;

  /// No description provided for @personalization.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalization;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @rewardInterests.
  ///
  /// In en, this message translates to:
  /// **'Reward interests'**
  String get rewardInterests;

  /// No description provided for @dailyGoalWithSteps.
  ///
  /// In en, this message translates to:
  /// **'Daily goal: {count, plural, =1{1 step} other{{count} steps}}'**
  String dailyGoalWithSteps(int count);

  /// No description provided for @notAdded.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get notAdded;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @profileSaveError.
  ///
  /// In en, this message translates to:
  /// **'Profile could not be saved. Please try again.'**
  String get profileSaveError;

  /// No description provided for @rewardInterestsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Reward interests updated'**
  String get rewardInterestsUpdated;

  /// No description provided for @insightsDescription.
  ///
  /// In en, this message translates to:
  /// **'Real trends from confirmed steps recorded on this device.'**
  String get insightsDescription;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @confirmedStepCount.
  ///
  /// In en, this message translates to:
  /// **'{count} confirmed steps'**
  String confirmedStepCount(String count);

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'{count} daily average'**
  String dailyAverage(String count);

  /// No description provided for @activeDayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active day} other{{count} active days}}'**
  String activeDayCount(int count);

  /// No description provided for @goalDayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 goal day} other{{count} goal days}}'**
  String goalDayCount(int count);

  /// No description provided for @moreWeeklyComparisons.
  ///
  /// In en, this message translates to:
  /// **'More weekly comparisons are coming'**
  String get moreWeeklyComparisons;

  /// No description provided for @keepTrackingForTrend.
  ///
  /// In en, this message translates to:
  /// **'Keep tracking your walks to build a meaningful trend.'**
  String get keepTrackingForTrend;

  /// No description provided for @consistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get consistency;

  /// No description provided for @currentGoalDayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} current goal-day streak'**
  String currentGoalDayStreak(int count);

  /// No description provided for @longestLocalStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} longest local streak'**
  String longestLocalStreak(int count);

  /// No description provided for @goalCompletionThirtyDays.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% goal completion over 30 days'**
  String goalCompletionThirtyDays(int percentage);

  /// No description provided for @bestDay.
  ///
  /// In en, this message translates to:
  /// **'Best day'**
  String get bestDay;

  /// No description provided for @datedConfirmedSteps.
  ///
  /// In en, this message translates to:
  /// **'{date} — {count} confirmed steps'**
  String datedConfirmedSteps(String date, String count);

  /// No description provided for @recordedGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Recorded goal reached'**
  String get recordedGoalReached;

  /// No description provided for @recordedGoalNotReached.
  ///
  /// In en, this message translates to:
  /// **'Recorded goal not reached'**
  String get recordedGoalNotReached;

  /// No description provided for @liveDisplayedSteps.
  ///
  /// In en, this message translates to:
  /// **'{count} live displayed steps'**
  String liveDisplayedSteps(String count);

  /// No description provided for @confirmedValue.
  ///
  /// In en, this message translates to:
  /// **'{count} confirmed'**
  String confirmedValue(String count);

  /// No description provided for @validatingValue.
  ///
  /// In en, this message translates to:
  /// **'{count} validating'**
  String validatingValue(String count);

  /// No description provided for @dailyGoalFormatted.
  ///
  /// In en, this message translates to:
  /// **'Daily goal: {goal}'**
  String dailyGoalFormatted(String goal);

  /// No description provided for @liveStepsExplanation.
  ///
  /// In en, this message translates to:
  /// **'Live displayed steps may include activity still being validated. Historical totals use confirmed steps only.'**
  String get liveStepsExplanation;

  /// No description provided for @percentageMore.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% more'**
  String percentageMore(int percentage);

  /// No description provided for @percentageFewer.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% fewer'**
  String percentageFewer(int percentage);

  /// No description provided for @comparedWithLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Compared with last week'**
  String get comparedWithLastWeek;

  /// No description provided for @historyDescription.
  ///
  /// In en, this message translates to:
  /// **'Review your confirmed walking progress over time.'**
  String get historyDescription;

  /// No description provided for @historyValidationExplanation.
  ///
  /// In en, this message translates to:
  /// **'Today may include validating steps on Home. Completed days in History use confirmed steps.'**
  String get historyValidationExplanation;

  /// No description provided for @sevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get sevenDays;

  /// No description provided for @thirtyDays.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get thirtyDays;

  /// No description provided for @loadingWalkingHistory.
  ///
  /// In en, this message translates to:
  /// **'Loading walking history'**
  String get loadingWalkingHistory;

  /// No description provided for @walkingHistoryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Walking history is temporarily unavailable.'**
  String get walkingHistoryUnavailable;

  /// No description provided for @noConfirmedHistory.
  ///
  /// In en, this message translates to:
  /// **'No confirmed step history yet'**
  String get noConfirmedHistory;

  /// No description provided for @noConfirmedHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your walks. Confirmed daily progress will appear here.'**
  String get noConfirmedHistoryDescription;

  /// No description provided for @noRecordForDate.
  ///
  /// In en, this message translates to:
  /// **'No local record for this date.'**
  String get noRecordForDate;

  /// No description provided for @cityUpdated.
  ///
  /// In en, this message translates to:
  /// **'City updated'**
  String get cityUpdated;

  /// No description provided for @clothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get clothing;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @wellness.
  ///
  /// In en, this message translates to:
  /// **'Wellness'**
  String get wellness;

  /// No description provided for @noPreference.
  ///
  /// In en, this message translates to:
  /// **'No preference'**
  String get noPreference;

  /// No description provided for @tehran.
  ///
  /// In en, this message translates to:
  /// **'Tehran'**
  String get tehran;

  /// No description provided for @karaj.
  ///
  /// In en, this message translates to:
  /// **'Karaj'**
  String get karaj;

  /// No description provided for @mashhad.
  ///
  /// In en, this message translates to:
  /// **'Mashhad'**
  String get mashhad;

  /// No description provided for @isfahan.
  ///
  /// In en, this message translates to:
  /// **'Isfahan'**
  String get isfahan;

  /// No description provided for @shiraz.
  ///
  /// In en, this message translates to:
  /// **'Shiraz'**
  String get shiraz;

  /// No description provided for @tabriz.
  ///
  /// In en, this message translates to:
  /// **'Tabriz'**
  String get tabriz;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @preferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get preferNotToSay;

  /// No description provided for @previousSetupStep.
  ///
  /// In en, this message translates to:
  /// **'Previous setup step'**
  String get previousSetupStep;

  /// No description provided for @walkTowardHealthierHabits.
  ///
  /// In en, this message translates to:
  /// **'Walk toward healthier habits'**
  String get walkTowardHealthierHabits;

  /// No description provided for @onboardingIntroDescription.
  ///
  /// In en, this message translates to:
  /// **'WalkApp keeps personal health progress first. Campaigns are optional, and verified walking may unlock useful points or rewards.'**
  String get onboardingIntroDescription;

  /// No description provided for @trackDailyProgress.
  ///
  /// In en, this message translates to:
  /// **'Track daily walking progress'**
  String get trackDailyProgress;

  /// No description provided for @buildHabitsWithGoal.
  ///
  /// In en, this message translates to:
  /// **'Build habits with a personal goal'**
  String get buildHabitsWithGoal;

  /// No description provided for @joinOptionalCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Join optional campaigns when you choose'**
  String get joinOptionalCampaigns;

  /// No description provided for @chooseDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Choose your daily goal'**
  String get chooseDailyGoal;

  /// No description provided for @chooseDailyGoalDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a goal that feels realistic for you. You can change it later.'**
  String get chooseDailyGoalDescription;

  /// No description provided for @comfortableStartingPoint.
  ///
  /// In en, this message translates to:
  /// **'A comfortable starting point'**
  String get comfortableStartingPoint;

  /// No description provided for @balancedEverydayGoal.
  ///
  /// In en, this message translates to:
  /// **'A balanced everyday goal'**
  String get balancedEverydayGoal;

  /// No description provided for @popularActiveTarget.
  ///
  /// In en, this message translates to:
  /// **'A popular active target'**
  String get popularActiveTarget;

  /// No description provided for @activeWalkerGoal.
  ///
  /// In en, this message translates to:
  /// **'For already active walkers'**
  String get activeWalkerGoal;

  /// No description provided for @customGoal.
  ///
  /// In en, this message translates to:
  /// **'Custom goal'**
  String get customGoal;

  /// No description provided for @whatInterestsYou.
  ///
  /// In en, this message translates to:
  /// **'What interests you?'**
  String get whatInterestsYou;

  /// No description provided for @interestsDescription.
  ///
  /// In en, this message translates to:
  /// **'Interests only help order local prototype content. Nothing is hidden.'**
  String get interestsDescription;

  /// No description provided for @chooseYourCity.
  ///
  /// In en, this message translates to:
  /// **'Choose your city'**
  String get chooseYourCity;

  /// No description provided for @citySelectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Your city may later help us highlight locally available campaigns. WalkApp does not use GPS for this choice.'**
  String get citySelectionDescription;

  /// No description provided for @physicalActivityAccess.
  ///
  /// In en, this message translates to:
  /// **'Physical activity access'**
  String get physicalActivityAccess;

  /// No description provided for @activityPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Activity access helps WalkApp detect walking and validate step progress. Background tracking lets active sessions continue with the screen off. Continuous GPS is not needed.'**
  String get activityPermissionDescription;

  /// No description provided for @allowActivityAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow activity access'**
  String get allowActivityAccess;

  /// No description provided for @retryActivityAccess.
  ///
  /// In en, this message translates to:
  /// **'Try activity access again'**
  String get retryActivityAccess;

  /// No description provided for @continueWithoutTracking.
  ///
  /// In en, this message translates to:
  /// **'Continue without tracking'**
  String get continueWithoutTracking;

  /// No description provided for @activityAccessGranted.
  ///
  /// In en, this message translates to:
  /// **'Activity access granted'**
  String get activityAccessGranted;

  /// No description provided for @activityAccessNotGranted.
  ///
  /// In en, this message translates to:
  /// **'Activity access not granted'**
  String get activityAccessNotGranted;

  /// No description provided for @enableAccessInSettings.
  ///
  /// In en, this message translates to:
  /// **'Enable access in app settings'**
  String get enableAccessInSettings;

  /// No description provided for @activitySensorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Activity sensor unavailable'**
  String get activitySensorUnavailable;

  /// No description provided for @permissionBeforeRequest.
  ///
  /// In en, this message translates to:
  /// **'Permission is requested only after you choose the action below.'**
  String get permissionBeforeRequest;

  /// No description provided for @trackingReadyDescription.
  ///
  /// In en, this message translates to:
  /// **'You can start tracking from Home when you are ready.'**
  String get trackingReadyDescription;

  /// No description provided for @trackingNeedsPermission.
  ///
  /// In en, this message translates to:
  /// **'You can continue, but step tracking needs activity access.'**
  String get trackingNeedsPermission;

  /// No description provided for @enableActivityManually.
  ///
  /// In en, this message translates to:
  /// **'Open this app’s system settings and enable activity access manually.'**
  String get enableActivityManually;

  /// No description provided for @permissionUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This device does not support the prototype activity permission flow.'**
  String get permissionUnsupported;

  /// No description provided for @androidPermissionInstructions.
  ///
  /// In en, this message translates to:
  /// **'Android: Settings → Apps → WalkApp → Permissions → Physical activity, then allow access.'**
  String get androidPermissionInstructions;

  /// No description provided for @youAreReady.
  ///
  /// In en, this message translates to:
  /// **'You’re ready'**
  String get youAreReady;

  /// No description provided for @completionDescription.
  ///
  /// In en, this message translates to:
  /// **'Health tracking stays independent. Start it from Home whenever you choose.'**
  String get completionDescription;

  /// No description provided for @interests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interests;

  /// No description provided for @granted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// No description provided for @notGranted.
  ///
  /// In en, this message translates to:
  /// **'Not granted'**
  String get notGranted;

  /// No description provided for @decreaseGoal.
  ///
  /// In en, this message translates to:
  /// **'Decrease goal by 1,000'**
  String get decreaseGoal;

  /// No description provided for @goalInSteps.
  ///
  /// In en, this message translates to:
  /// **'Goal in steps'**
  String get goalInSteps;

  /// No description provided for @increaseGoal.
  ///
  /// In en, this message translates to:
  /// **'Increase goal by 1,000'**
  String get increaseGoal;

  /// No description provided for @quickOptions.
  ///
  /// In en, this message translates to:
  /// **'Quick options'**
  String get quickOptions;

  /// No description provided for @saveGoal.
  ///
  /// In en, this message translates to:
  /// **'Save goal'**
  String get saveGoal;

  /// No description provided for @dailyStepProgress.
  ///
  /// In en, this message translates to:
  /// **'Daily step progress'**
  String get dailyStepProgress;

  /// No description provided for @currentActivity.
  ///
  /// In en, this message translates to:
  /// **'Current activity'**
  String get currentActivity;

  /// No description provided for @openNotifications.
  ///
  /// In en, this message translates to:
  /// **'Open notifications'**
  String get openNotifications;

  /// No description provided for @noUnreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications, none unread'**
  String get noUnreadNotifications;

  /// No description provided for @unreadNotificationsSemantics.
  ///
  /// In en, this message translates to:
  /// **'Notifications, {count} unread'**
  String unreadNotificationsSemantics(int count);

  /// No description provided for @todayHealthProgress.
  ///
  /// In en, this message translates to:
  /// **'Today’s health progress'**
  String get todayHealthProgress;

  /// No description provided for @todayHealthProgressSemantics.
  ///
  /// In en, this message translates to:
  /// **'Today’s health progress, {steps} of {goal} steps, {percentage} percent, {remaining} remaining'**
  String todayHealthProgressSemantics(
    int steps,
    int goal,
    int percentage,
    int remaining,
  );

  /// No description provided for @progressOfGoal.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% of {goal} • {remaining} remaining'**
  String progressOfGoal(int percentage, String goal, String remaining);

  /// No description provided for @loadingCampaignProgress.
  ///
  /// In en, this message translates to:
  /// **'Loading campaign progress…'**
  String get loadingCampaignProgress;

  /// No description provided for @campaignProgressUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Campaign progress is temporarily unavailable.'**
  String get campaignProgressUnavailable;

  /// No description provided for @activeCampaign.
  ///
  /// In en, this message translates to:
  /// **'Active campaign'**
  String get activeCampaign;

  /// No description provided for @campaignStepProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target} campaign steps'**
  String campaignStepProgress(String current, String target);

  /// No description provided for @campaignGoalDayProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {target} goal days completed'**
  String campaignGoalDayProgress(int current, int target);

  /// No description provided for @eligibleStepsToday.
  ///
  /// In en, this message translates to:
  /// **'{current} / {goal} eligible steps today'**
  String eligibleStepsToday(String current, String goal);

  /// No description provided for @continueCampaign.
  ///
  /// In en, this message translates to:
  /// **'Continue campaign'**
  String get continueCampaign;

  /// No description provided for @exploreMore.
  ///
  /// In en, this message translates to:
  /// **'Explore more'**
  String get exploreMore;

  /// No description provided for @campaignCompleted.
  ///
  /// In en, this message translates to:
  /// **'Campaign completed'**
  String get campaignCompleted;

  /// No description provided for @rewardReady.
  ///
  /// In en, this message translates to:
  /// **'Reward ready'**
  String get rewardReady;

  /// No description provided for @pointsEarned.
  ///
  /// In en, this message translates to:
  /// **'{count} points earned'**
  String pointsEarned(int count);

  /// No description provided for @rewardReadyToClaim.
  ///
  /// In en, this message translates to:
  /// **'{reward} is ready to claim'**
  String rewardReadyToClaim(String reward);

  /// No description provided for @rewardUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{reward} unlocked'**
  String rewardUnlocked(String reward);

  /// No description provided for @viewRewards.
  ///
  /// In en, this message translates to:
  /// **'View Rewards'**
  String get viewRewards;

  /// No description provided for @claimReward.
  ///
  /// In en, this message translates to:
  /// **'Claim reward'**
  String get claimReward;

  /// No description provided for @viewReward.
  ///
  /// In en, this message translates to:
  /// **'View reward'**
  String get viewReward;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @featuredChallenge.
  ///
  /// In en, this message translates to:
  /// **'Featured challenge'**
  String get featuredChallenge;

  /// No description provided for @viewCampaign.
  ///
  /// In en, this message translates to:
  /// **'View campaign'**
  String get viewCampaign;

  /// No description provided for @walkingChallengeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ready for a walking challenge?'**
  String get walkingChallengeQuestion;

  /// No description provided for @walkingChallengeDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore campaigns and unlock rewards from participating brands.'**
  String get walkingChallengeDescription;

  /// No description provided for @viewCampaigns.
  ///
  /// In en, this message translates to:
  /// **'View campaigns'**
  String get viewCampaigns;

  /// No description provided for @loadingRewards.
  ///
  /// In en, this message translates to:
  /// **'Loading rewards…'**
  String get loadingRewards;

  /// No description provided for @rewardsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Rewards are temporarily unavailable.'**
  String get rewardsUnavailable;

  /// No description provided for @rewardsReadyToClaim.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reward ready to claim} other{{count} rewards ready to claim}}'**
  String rewardsReadyToClaim(int count);

  /// No description provided for @availableCoupons.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 available coupon} other{{count} available coupons}}'**
  String availableCoupons(int count);

  /// No description provided for @earnRewardsDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete eligible campaigns to start earning rewards.'**
  String get earnRewardsDescription;

  /// No description provided for @openRewards.
  ///
  /// In en, this message translates to:
  /// **'Open Rewards'**
  String get openRewards;

  /// No description provided for @localPrototypeContent.
  ///
  /// In en, this message translates to:
  /// **'Local prototype content'**
  String get localPrototypeContent;

  /// No description provided for @loadingCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Loading campaigns'**
  String get loadingCampaigns;

  /// No description provided for @campaignsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Campaigns could not be loaded. Please try again.'**
  String get campaignsLoadError;

  /// No description provided for @noCampaignsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No campaigns available yet'**
  String get noCampaignsAvailable;

  /// No description provided for @noCampaignsDescription.
  ///
  /// In en, this message translates to:
  /// **'New walking campaigns will appear here.'**
  String get noCampaignsDescription;

  /// No description provided for @noMatchingCampaigns.
  ///
  /// In en, this message translates to:
  /// **'No campaigns match your filters'**
  String get noMatchingCampaigns;

  /// No description provided for @tryAnotherCampaignFilter.
  ///
  /// In en, this message translates to:
  /// **'Try another status or category filter.'**
  String get tryAnotherCampaignFilter;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @leaveCampaignQuestion.
  ///
  /// In en, this message translates to:
  /// **'Leave this campaign?'**
  String get leaveCampaignQuestion;

  /// No description provided for @leaveCampaign.
  ///
  /// In en, this message translates to:
  /// **'Leave campaign'**
  String get leaveCampaign;

  /// No description provided for @loadingCampaign.
  ///
  /// In en, this message translates to:
  /// **'Loading campaign'**
  String get loadingCampaign;

  /// No description provided for @noCampaignToShow.
  ///
  /// In en, this message translates to:
  /// **'No campaign to show'**
  String get noCampaignToShow;

  /// No description provided for @returnToCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Return to Campaigns to discover a campaign.'**
  String get returnToCampaigns;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get startTracking;

  /// No description provided for @campaignRules.
  ///
  /// In en, this message translates to:
  /// **'Campaign rules'**
  String get campaignRules;

  /// No description provided for @activeCampaignExists.
  ///
  /// In en, this message translates to:
  /// **'You already have an active campaign'**
  String get activeCampaignExists;

  /// No description provided for @keepCurrentCampaign.
  ///
  /// In en, this message translates to:
  /// **'Keep current campaign'**
  String get keepCurrentCampaign;

  /// No description provided for @viewActiveCampaign.
  ///
  /// In en, this message translates to:
  /// **'View active campaign'**
  String get viewActiveCampaign;

  /// No description provided for @oneActiveCampaign.
  ///
  /// In en, this message translates to:
  /// **'Only one campaign can be active at a time.'**
  String get oneActiveCampaign;

  /// No description provided for @joinCampaign.
  ///
  /// In en, this message translates to:
  /// **'Join campaign'**
  String get joinCampaign;

  /// No description provided for @campaignDetails.
  ///
  /// In en, this message translates to:
  /// **'Campaign details'**
  String get campaignDetails;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @goalRules.
  ///
  /// In en, this message translates to:
  /// **'Goal rules'**
  String get goalRules;

  /// No description provided for @rewardTerms.
  ///
  /// In en, this message translates to:
  /// **'Reward terms'**
  String get rewardTerms;

  /// No description provided for @campaignDuration.
  ///
  /// In en, this message translates to:
  /// **'Campaign duration'**
  String get campaignDuration;

  /// No description provided for @reward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get reward;

  /// No description provided for @minimumPurchase.
  ///
  /// In en, this message translates to:
  /// **'Minimum purchase'**
  String get minimumPurchase;

  /// No description provided for @whereToUse.
  ///
  /// In en, this message translates to:
  /// **'Where to use'**
  String get whereToUse;

  /// No description provided for @expiration.
  ///
  /// In en, this message translates to:
  /// **'Expiration'**
  String get expiration;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @myRewards.
  ///
  /// In en, this message translates to:
  /// **'My rewards'**
  String get myRewards;

  /// No description provided for @noClaimedRewards.
  ///
  /// In en, this message translates to:
  /// **'No rewards claimed yet'**
  String get noClaimedRewards;

  /// No description provided for @viewCoupon.
  ///
  /// In en, this message translates to:
  /// **'View coupon'**
  String get viewCoupon;

  /// No description provided for @walletActivity.
  ///
  /// In en, this message translates to:
  /// **'Wallet activity'**
  String get walletActivity;

  /// No description provided for @noPointTransactions.
  ///
  /// In en, this message translates to:
  /// **'No point transactions yet'**
  String get noPointTransactions;

  /// No description provided for @rewardDetails.
  ///
  /// In en, this message translates to:
  /// **'Reward details'**
  String get rewardDetails;

  /// No description provided for @localRewardsPrototype.
  ///
  /// In en, this message translates to:
  /// **'Local rewards prototype'**
  String get localRewardsPrototype;

  /// No description provided for @noMatchingRewards.
  ///
  /// In en, this message translates to:
  /// **'No matching rewards'**
  String get noMatchingRewards;

  /// No description provided for @viewWalletActivity.
  ///
  /// In en, this message translates to:
  /// **'View wallet activity'**
  String get viewWalletActivity;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @markCouponUsedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Mark coupon as used?'**
  String get markCouponUsedQuestion;

  /// No description provided for @markAsUsed.
  ///
  /// In en, this message translates to:
  /// **'Mark as used'**
  String get markAsUsed;

  /// No description provided for @couponDetails.
  ///
  /// In en, this message translates to:
  /// **'Coupon details'**
  String get couponDetails;

  /// No description provided for @savedRewardUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This saved reward is not available locally.'**
  String get savedRewardUnavailable;

  /// No description provided for @prototypeCoupon.
  ///
  /// In en, this message translates to:
  /// **'Prototype coupon'**
  String get prototypeCoupon;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @claimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get claimed;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @debugSimulation.
  ///
  /// In en, this message translates to:
  /// **'Debug simulation'**
  String get debugSimulation;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @continueToAccountSetup.
  ///
  /// In en, this message translates to:
  /// **'Continue to account setup'**
  String get continueToAccountSetup;

  /// No description provided for @chooseInterestError.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one interest or No preference.'**
  String get chooseInterestError;

  /// No description provided for @goalRangeError.
  ///
  /// In en, this message translates to:
  /// **'Enter a goal from 1,000 to 100,000 steps'**
  String get goalRangeError;

  /// No description provided for @dailyStepGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily step goal'**
  String get dailyStepGoal;

  /// No description provided for @goalSheetDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a goal that feels achievable for your routine.'**
  String get goalSheetDescription;

  /// No description provided for @stepTrackingStarted.
  ///
  /// In en, this message translates to:
  /// **'Step tracking started.'**
  String get stepTrackingStarted;

  /// No description provided for @stepTrackingStopped.
  ///
  /// In en, this message translates to:
  /// **'Step tracking stopped'**
  String get stepTrackingStopped;

  /// No description provided for @trackingUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Tracking could not be updated. Please try again.'**
  String get trackingUpdateError;

  /// No description provided for @activityPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Activity permission is required to count steps.'**
  String get activityPermissionRequired;

  /// No description provided for @stepSensorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The step sensor is unavailable on this device.'**
  String get stepSensorUnavailable;

  /// No description provided for @trackingRefreshError.
  ///
  /// In en, this message translates to:
  /// **'Tracking could not be updated. Pull down or try again.'**
  String get trackingRefreshError;

  /// No description provided for @stoppingTracking.
  ///
  /// In en, this message translates to:
  /// **'Stopping…'**
  String get stoppingTracking;

  /// No description provided for @startingTracking.
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get startingTracking;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going, you’re doing great!'**
  String get keepGoing;

  /// No description provided for @readyToMove.
  ///
  /// In en, this message translates to:
  /// **'Start tracking when you’re ready to move.'**
  String get readyToMove;

  /// No description provided for @todayProgress.
  ///
  /// In en, this message translates to:
  /// **'Today’s progress'**
  String get todayProgress;

  /// No description provided for @sensorsReady.
  ///
  /// In en, this message translates to:
  /// **'Sensors · Ready'**
  String get sensorsReady;

  /// No description provided for @sensorsPreparing.
  ///
  /// In en, this message translates to:
  /// **'Sensors · Preparing'**
  String get sensorsPreparing;

  /// No description provided for @sensorsInactive.
  ///
  /// In en, this message translates to:
  /// **'Sensors · Inactive'**
  String get sensorsInactive;

  /// No description provided for @trackingActiveCompact.
  ///
  /// In en, this message translates to:
  /// **'Tracking · Active'**
  String get trackingActiveCompact;

  /// No description provided for @trackingStoppedCompact.
  ///
  /// In en, this message translates to:
  /// **'Tracking · Stopped'**
  String get trackingStoppedCompact;

  /// No description provided for @validationValidating.
  ///
  /// In en, this message translates to:
  /// **'Validation · Validating'**
  String get validationValidating;

  /// No description provided for @validationIdle.
  ///
  /// In en, this message translates to:
  /// **'Validation · Idle'**
  String get validationIdle;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @dailyGoalCompletedNotification.
  ///
  /// In en, this message translates to:
  /// **'Daily goal completed'**
  String get dailyGoalCompletedNotification;

  /// No description provided for @dailyGoalCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'You reached your walking goal for today.'**
  String get dailyGoalCompletedMessage;

  /// No description provided for @dailyGoalReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'How many more steps will you take today?'**
  String get dailyGoalReminderTitle;

  /// No description provided for @dailyGoalReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'You have {count} steps left to reach your daily goal.'**
  String dailyGoalReminderMessage(int count);

  /// No description provided for @campaignEndingSoonNotification.
  ///
  /// In en, this message translates to:
  /// **'Your campaign is ending soon'**
  String get campaignEndingSoonNotification;

  /// No description provided for @campaignCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'You completed {campaign}.'**
  String campaignCompletedMessage(String campaign);

  /// No description provided for @campaignRewardReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward ready to claim'**
  String get campaignRewardReadyTitle;

  /// No description provided for @campaignRewardReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your {reward} is ready.'**
  String campaignRewardReadyMessage(String reward);

  /// No description provided for @pointsAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Points added'**
  String get pointsAddedTitle;

  /// No description provided for @pointsAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} points were added to your Rewards balance.'**
  String pointsAddedMessage(int count);

  /// No description provided for @rewardExpiringSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Your reward is expiring soon'**
  String get rewardExpiringSoonTitle;

  /// No description provided for @rewardExpiringSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Use {reward} before {date}.'**
  String rewardExpiringSoonMessage(String reward, String date);

  /// No description provided for @campaignStepsRemaining.
  ///
  /// In en, this message translates to:
  /// **'You need {count} campaign steps before the deadline.'**
  String campaignStepsRemaining(int count);

  /// No description provided for @goalDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'You need {count, plural, =1{1 more goal day} other{{count} more goal days}} before the deadline.'**
  String goalDaysRemaining(int count);

  /// No description provided for @campaignUnavailableShowingList.
  ///
  /// In en, this message translates to:
  /// **'That campaign is no longer available. Showing Campaigns.'**
  String get campaignUnavailableShowingList;

  /// No description provided for @couponUnavailableShowingRewards.
  ///
  /// In en, this message translates to:
  /// **'That coupon is no longer available. Showing Rewards.'**
  String get couponUnavailableShowingRewards;

  /// No description provided for @rewardClaimError.
  ///
  /// In en, this message translates to:
  /// **'The reward could not be claimed.'**
  String get rewardClaimError;

  /// No description provided for @campaignRewardClaimed.
  ///
  /// In en, this message translates to:
  /// **'Campaign reward claimed.'**
  String get campaignRewardClaimed;

  /// No description provided for @campaignEnrollmentLoadError.
  ///
  /// In en, this message translates to:
  /// **'Enrollment state could not be loaded.'**
  String get campaignEnrollmentLoadError;

  /// No description provided for @featuredCampaign.
  ///
  /// In en, this message translates to:
  /// **'Featured campaign'**
  String get featuredCampaign;

  /// No description provided for @endingSoon.
  ///
  /// In en, this message translates to:
  /// **'Ending soon'**
  String get endingSoon;

  /// No description provided for @completeOrLeaveCampaign.
  ///
  /// In en, this message translates to:
  /// **'Complete or leave your current campaign before joining another one.'**
  String get completeOrLeaveCampaign;

  /// No description provided for @campaignNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This campaign is no longer available to join.'**
  String get campaignNoLongerAvailable;

  /// No description provided for @campaignAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'You already completed this campaign.'**
  String get campaignAlreadyCompleted;

  /// No description provided for @campaignJoinError.
  ///
  /// In en, this message translates to:
  /// **'The campaign could not be joined. Please try again.'**
  String get campaignJoinError;

  /// No description provided for @joinCampaignStep.
  ///
  /// In en, this message translates to:
  /// **'Join the campaign'**
  String get joinCampaignStep;

  /// No description provided for @walkCampaignPeriodStep.
  ///
  /// In en, this message translates to:
  /// **'Walk during the campaign period'**
  String get walkCampaignPeriodStep;

  /// No description provided for @unlockRewardStep.
  ///
  /// In en, this message translates to:
  /// **'Complete the goal and unlock the reward'**
  String get unlockRewardStep;

  /// No description provided for @targetSteps.
  ///
  /// In en, this message translates to:
  /// **'Target steps'**
  String get targetSteps;

  /// No description provided for @requiredGoalDays.
  ///
  /// In en, this message translates to:
  /// **'Required goal days'**
  String get requiredGoalDays;

  /// No description provided for @eligibleActivityOnly.
  ///
  /// In en, this message translates to:
  /// **'Only eligible verified activity counts.'**
  String get eligibleActivityOnly;

  /// No description provided for @personalDailyGoalUsed.
  ///
  /// In en, this message translates to:
  /// **'Your personal daily goal is used.'**
  String get personalDailyGoalUsed;

  /// No description provided for @campaignDayCountsOnce.
  ///
  /// In en, this message translates to:
  /// **'Each campaign day can count at most once.'**
  String get campaignDayCountsOnce;

  /// No description provided for @importantRestrictions.
  ///
  /// In en, this message translates to:
  /// **'Important restrictions'**
  String get importantRestrictions;

  /// No description provided for @campaignLeaveDescription.
  ///
  /// In en, this message translates to:
  /// **'Your campaign progress will no longer remain active. Your normal health steps and daily goal history will not be deleted.'**
  String get campaignLeaveDescription;

  /// No description provided for @campaignLeaveError.
  ///
  /// In en, this message translates to:
  /// **'The campaign could not be left. Please try again.'**
  String get campaignLeaveError;

  /// No description provided for @trackingStartError.
  ///
  /// In en, this message translates to:
  /// **'Tracking could not be started. Please try again.'**
  String get trackingStartError;

  /// No description provided for @savedCampaignUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This saved campaign is unavailable. Your local record has been preserved.'**
  String get savedCampaignUnavailable;

  /// No description provided for @requirementCompleted.
  ///
  /// In en, this message translates to:
  /// **'Requirement completed'**
  String get requirementCompleted;

  /// No description provided for @finalCampaignProgress.
  ///
  /// In en, this message translates to:
  /// **'Final campaign progress'**
  String get finalCampaignProgress;

  /// No description provided for @confirmedAfterEnrollmentOnly.
  ///
  /// In en, this message translates to:
  /// **'Only confirmed steps recorded after enrollment count.'**
  String get confirmedAfterEnrollmentOnly;

  /// No description provided for @healthProgressIndependent.
  ///
  /// In en, this message translates to:
  /// **'Health progress and the daily goal continue independently.'**
  String get healthProgressIndependent;

  /// No description provided for @offlinePrototypeState.
  ///
  /// In en, this message translates to:
  /// **'This is offline local prototype state. Device-local time is used.'**
  String get offlinePrototypeState;

  /// No description provided for @rewardsDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn eligible activity and completed campaigns into useful offers.'**
  String get rewardsDescription;

  /// No description provided for @rewardsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Rewards could not be loaded.'**
  String get rewardsLoadError;

  /// No description provided for @readyToClaim.
  ///
  /// In en, this message translates to:
  /// **'Ready to claim'**
  String get readyToClaim;

  /// No description provided for @featuredReward.
  ///
  /// In en, this message translates to:
  /// **'Featured reward'**
  String get featuredReward;

  /// No description provided for @rewardCatalog.
  ///
  /// In en, this message translates to:
  /// **'Reward catalog'**
  String get rewardCatalog;

  /// No description provided for @rewardFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Try another category or earn more points.'**
  String get rewardFilterHint;

  /// No description provided for @availablePoints.
  ///
  /// In en, this message translates to:
  /// **'Available points'**
  String get availablePoints;

  /// No description provided for @walletTotals.
  ///
  /// In en, this message translates to:
  /// **'{earned} earned • {spent} spent'**
  String walletTotals(int earned, int spent);

  /// No description provided for @allFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// No description provided for @affordableFilter.
  ///
  /// In en, this message translates to:
  /// **'Affordable'**
  String get affordableFilter;

  /// No description provided for @clothingCategory.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get clothingCategory;

  /// No description provided for @sportsCategory.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sportsCategory;

  /// No description provided for @foodCategory.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get foodCategory;

  /// No description provided for @wellnessCategory.
  ///
  /// In en, this message translates to:
  /// **'Wellness'**
  String get wellnessCategory;

  /// No description provided for @availableStatus.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableStatus;

  /// No description provided for @insufficientPointsStatus.
  ///
  /// In en, this message translates to:
  /// **'Not enough points'**
  String get insufficientPointsStatus;

  /// No description provided for @claimedStatus.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get claimedStatus;

  /// No description provided for @unavailableStatus.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailableStatus;

  /// No description provided for @expiredStatus.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expiredStatus;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @enoughPointsMessage.
  ///
  /// In en, this message translates to:
  /// **'You have enough points to redeem this reward.'**
  String get enoughPointsMessage;

  /// No description provided for @morePointsNeeded.
  ///
  /// In en, this message translates to:
  /// **'{count} more points needed'**
  String morePointsNeeded(int count);

  /// No description provided for @limitedRewardClaimed.
  ///
  /// In en, this message translates to:
  /// **'This limited reward has already been claimed.'**
  String get limitedRewardClaimed;

  /// No description provided for @rewardCurrentlyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This reward is not currently available.'**
  String get rewardCurrentlyUnavailable;

  /// No description provided for @rewardExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This reward has expired.'**
  String get rewardExpiredMessage;

  /// No description provided for @balanceAfterRedemption.
  ///
  /// In en, this message translates to:
  /// **'Balance after redemption: {count}'**
  String balanceAfterRedemption(int count);

  /// No description provided for @localCouponDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The resulting coupon is generated locally for MVP demonstration and cannot be validated by a real merchant.'**
  String get localCouponDisclaimer;

  /// No description provided for @insufficientBalanceMessage.
  ///
  /// In en, this message translates to:
  /// **'Your point balance is no longer high enough.'**
  String get insufficientBalanceMessage;

  /// No description provided for @rewardRedeemError.
  ///
  /// In en, this message translates to:
  /// **'The reward could not be redeemed.'**
  String get rewardRedeemError;

  /// No description provided for @pointsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} points'**
  String pointsValue(int count);

  /// No description provided for @afterRedemptionPoints.
  ///
  /// In en, this message translates to:
  /// **'After redemption: {count} points'**
  String afterRedemptionPoints(int count);

  /// No description provided for @minimumPurchaseValue.
  ///
  /// In en, this message translates to:
  /// **'Minimum purchase: {value}'**
  String minimumPurchaseValue(String value);

  /// No description provided for @whereToUseValue.
  ///
  /// In en, this message translates to:
  /// **'Where to use: {value}'**
  String whereToUseValue(String value);

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @localRewardDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Local prototype: points and coupons have no cash value and cannot be validated by a merchant.'**
  String get localRewardDisclaimer;

  /// No description provided for @redeemForPoints.
  ///
  /// In en, this message translates to:
  /// **'Redeem for {count} points'**
  String redeemForPoints(int count);

  /// No description provided for @viewClaimedReward.
  ///
  /// In en, this message translates to:
  /// **'View reward'**
  String get viewClaimedReward;

  /// No description provided for @noClaimedRewardsDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete eligible campaigns or redeem a reward with points.'**
  String get noClaimedRewardsDescription;

  /// No description provided for @noRewardsWithStatus.
  ///
  /// In en, this message translates to:
  /// **'There are no rewards with the status {status}.'**
  String noRewardsWithStatus(String status);

  /// No description provided for @campaignRewardSource.
  ///
  /// In en, this message translates to:
  /// **'Campaign reward'**
  String get campaignRewardSource;

  /// No description provided for @pointsRedemptionSource.
  ///
  /// In en, this message translates to:
  /// **'Points redemption'**
  String get pointsRedemptionSource;

  /// No description provided for @walletEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Point credits and reward redemptions will appear here.'**
  String get walletEmptyDescription;

  /// No description provided for @onlineChannel.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineChannel;

  /// No description provided for @inStoreChannel.
  ///
  /// In en, this message translates to:
  /// **'In participating stores'**
  String get inStoreChannel;

  /// No description provided for @onlineAndInStoreChannel.
  ///
  /// In en, this message translates to:
  /// **'Online and in participating stores'**
  String get onlineAndInStoreChannel;

  /// No description provided for @dailyConfirmedSteps.
  ///
  /// In en, this message translates to:
  /// **'Daily confirmed steps'**
  String get dailyConfirmedSteps;

  /// No description provided for @totalConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Total confirmed'**
  String get totalConfirmed;

  /// No description provided for @dailyAverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverageLabel;

  /// No description provided for @goalDays.
  ///
  /// In en, this message translates to:
  /// **'Goal days'**
  String get goalDays;

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDays;

  /// No description provided for @confirmedStepsChartSemantics.
  ///
  /// In en, this message translates to:
  /// **'Confirmed steps chart for {days} days. {steps} total confirmed steps. The daily history list below provides complete details.'**
  String confirmedStepsChartSemantics(int days, String steps);

  /// No description provided for @dayConfirmedStepsSemantics.
  ///
  /// In en, this message translates to:
  /// **'{date}, {steps} confirmed steps'**
  String dayConfirmedStepsSemantics(String date, int steps);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @noRecord.
  ///
  /// In en, this message translates to:
  /// **'No record'**
  String get noRecord;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get goalReached;

  /// No description provided for @completedDay.
  ///
  /// In en, this message translates to:
  /// **'Completed day'**
  String get completedDay;

  /// No description provided for @campaignAvailableStatus.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get campaignAvailableStatus;

  /// No description provided for @campaignUpcomingStatus.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get campaignUpcomingStatus;

  /// No description provided for @campaignExpiredStatus.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get campaignExpiredStatus;

  /// No description provided for @stepTargetType.
  ///
  /// In en, this message translates to:
  /// **'Step target'**
  String get stepTargetType;

  /// No description provided for @goalConsistencyType.
  ///
  /// In en, this message translates to:
  /// **'Goal consistency'**
  String get goalConsistencyType;

  /// No description provided for @eligibleStepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} eligible steps'**
  String eligibleStepsCount(String count);

  /// No description provided for @goalConsistencySummary.
  ///
  /// In en, this message translates to:
  /// **'Reach your goal on {required} of {duration} days'**
  String goalConsistencySummary(int required, int duration);

  /// No description provided for @campaignStarts.
  ///
  /// In en, this message translates to:
  /// **'Starts {date}'**
  String campaignStarts(String date);

  /// No description provided for @campaignEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended {date}'**
  String campaignEnded(String date);

  /// No description provided for @endsToday.
  ///
  /// In en, this message translates to:
  /// **'Ends today'**
  String get endsToday;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} days remaining'**
  String daysRemaining(int count);

  /// No description provided for @viewProgress.
  ///
  /// In en, this message translates to:
  /// **'View progress'**
  String get viewProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @campaignFinished.
  ///
  /// In en, this message translates to:
  /// **'Campaign ended'**
  String get campaignFinished;

  /// No description provided for @prototypeCouponCopied.
  ///
  /// In en, this message translates to:
  /// **'Prototype coupon copied.'**
  String get prototypeCouponCopied;

  /// No description provided for @couponMarkedUsed.
  ///
  /// In en, this message translates to:
  /// **'Coupon marked as used locally.'**
  String get couponMarkedUsed;

  /// No description provided for @couponUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Coupon could not be updated.'**
  String get couponUpdateError;

  /// No description provided for @couponUseLocalExplanation.
  ///
  /// In en, this message translates to:
  /// **'This is only a local simulation and no merchant confirms this action.'**
  String get couponUseLocalExplanation;

  /// No description provided for @activityAccessRequestError.
  ///
  /// In en, this message translates to:
  /// **'Activity access could not be requested. Please try again.'**
  String get activityAccessRequestError;

  /// No description provided for @setupSaveError.
  ///
  /// In en, this message translates to:
  /// **'Your setup could not be saved locally. Please try again.'**
  String get setupSaveError;

  /// No description provided for @notificationsRefreshError.
  ///
  /// In en, this message translates to:
  /// **'Notifications could not be refreshed. Your other WalkApp data is unaffected.'**
  String get notificationsRefreshError;

  /// No description provided for @notificationUpdatesPending.
  ///
  /// In en, this message translates to:
  /// **'Some notification updates are waiting to be saved locally.'**
  String get notificationUpdatesPending;

  /// No description provided for @notificationReadPending.
  ///
  /// In en, this message translates to:
  /// **'This notification will be marked read when saving works.'**
  String get notificationReadPending;

  /// No description provided for @readStatusSaveError.
  ///
  /// In en, this message translates to:
  /// **'Read status could not be saved yet.'**
  String get readStatusSaveError;

  /// No description provided for @readNotificationsClearError.
  ///
  /// In en, this message translates to:
  /// **'Read notifications could not be cleared yet.'**
  String get readNotificationsClearError;

  /// No description provided for @campaignsDescription.
  ///
  /// In en, this message translates to:
  /// **'Walk toward meaningful goals and unlock brand rewards.'**
  String get campaignsDescription;

  /// No description provided for @campaignStepsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} campaign steps'**
  String campaignStepsValue(String count);

  /// No description provided for @goalDaysValue.
  ///
  /// In en, this message translates to:
  /// **'{count} goal days'**
  String goalDaysValue(int count);

  /// No description provided for @confirmedCampaignStepsRequirement.
  ///
  /// In en, this message translates to:
  /// **'{count} confirmed campaign steps'**
  String confirmedCampaignStepsRequirement(String count);

  /// No description provided for @separateGoalDaysRequirement.
  ///
  /// In en, this message translates to:
  /// **'{days} separate days reaching the captured {goal}-step goal'**
  String separateGoalDaysRequirement(int days, String goal);

  /// No description provided for @joinProgressExplanation.
  ///
  /// In en, this message translates to:
  /// **'Progress starts from zero after joining. Only confirmed steps recorded after joining count. Normal health tracking continues.'**
  String get joinProgressExplanation;

  /// No description provided for @capturedGoalExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your {count}-step daily goal is captured now and will not change for this campaign.'**
  String capturedGoalExplanation(String count);

  /// No description provided for @leavingCampaignPointsOutcome.
  ///
  /// In en, this message translates to:
  /// **'Leaving removes this progress from active use. Completing this campaign awards {count} points.'**
  String leavingCampaignPointsOutcome(int count);

  /// No description provided for @leavingCampaignRewardOutcome.
  ///
  /// In en, this message translates to:
  /// **'Leaving removes this progress from active use. Completing this campaign unlocks a reward you can claim.'**
  String get leavingCampaignRewardOutcome;

  /// No description provided for @startsOn.
  ///
  /// In en, this message translates to:
  /// **'Starts on {date}'**
  String startsOn(String date);

  /// No description provided for @daysValue.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysValue(int count);

  /// No description provided for @requiredVerifiedSteps.
  ///
  /// In en, this message translates to:
  /// **'{count} eligible verified steps are required.'**
  String requiredVerifiedSteps(int count);

  /// No description provided for @walkBetweenDates.
  ///
  /// In en, this message translates to:
  /// **'Walk between {start} and {end}.'**
  String walkBetweenDates(String start, String end);

  /// No description provided for @requiredSeparateGoalDays.
  ///
  /// In en, this message translates to:
  /// **'{count} separate goal days are required.'**
  String requiredSeparateGoalDays(int count);

  /// No description provided for @healthStepsContinueExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your health steps continue to be tracked normally.\n\nCampaign progress is calculated separately after joining.'**
  String get healthStepsContinueExplanation;

  /// No description provided for @pointsAddedToRewards.
  ///
  /// In en, this message translates to:
  /// **'Added to your Rewards balance.'**
  String get pointsAddedToRewards;

  /// No description provided for @pointsBeingAdded.
  ///
  /// In en, this message translates to:
  /// **'Your points are being added safely.'**
  String get pointsBeingAdded;

  /// No description provided for @completedRewardReady.
  ///
  /// In en, this message translates to:
  /// **'Your completed campaign reward is ready to claim.'**
  String get completedRewardReady;

  /// No description provided for @couponAvailableInRewards.
  ///
  /// In en, this message translates to:
  /// **'Your prototype coupon is available in My Rewards.'**
  String get couponAvailableInRewards;

  /// No description provided for @joinedAndEnds.
  ///
  /// In en, this message translates to:
  /// **'Joined {joined} • Ends {ends}'**
  String joinedAndEnds(String joined, String ends);

  /// No description provided for @stepProgressSemantics.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent complete, {current} of {target} campaign steps'**
  String stepProgressSemantics(int percent, int current, int target);

  /// No description provided for @goalProgressSemantics.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {required} goal days complete'**
  String goalProgressSemantics(int completed, int required);

  /// No description provided for @campaignProgress.
  ///
  /// In en, this message translates to:
  /// **'Campaign progress'**
  String get campaignProgress;

  /// No description provided for @campaignCompletedStatus.
  ///
  /// In en, this message translates to:
  /// **'Campaign completed'**
  String get campaignCompletedStatus;

  /// No description provided for @stepsRemainingPercent.
  ///
  /// In en, this message translates to:
  /// **'{count} steps remaining • {percent}%'**
  String stepsRemainingPercent(String count, int percent);

  /// No description provided for @goalDaysCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {required} goal days completed'**
  String goalDaysCompleted(int completed, int required);

  /// No description provided for @requiredDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} required days remaining'**
  String requiredDaysRemaining(int count);

  /// No description provided for @capturedDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Captured daily goal: {count} steps'**
  String capturedDailyGoal(String count);

  /// No description provided for @earnedRewardPoints.
  ///
  /// In en, this message translates to:
  /// **'You earned {count} reward points.'**
  String earnedRewardPoints(int count);

  /// No description provided for @unlockedReward.
  ///
  /// In en, this message translates to:
  /// **'You unlocked {reward}.'**
  String unlockedReward(String reward);

  /// No description provided for @trackingActiveStatus.
  ///
  /// In en, this message translates to:
  /// **'Tracking is active'**
  String get trackingActiveStatus;

  /// No description provided for @trackingStoppedStatus.
  ///
  /// In en, this message translates to:
  /// **'Tracking is stopped'**
  String get trackingStoppedStatus;

  /// No description provided for @trackingCampaignAutoUpdate.
  ///
  /// In en, this message translates to:
  /// **'Eligible confirmed steps will update this campaign automatically.'**
  String get trackingCampaignAutoUpdate;

  /// No description provided for @trackingCampaignRequirement.
  ///
  /// In en, this message translates to:
  /// **'Campaign progress changes only when eligible confirmed steps are recorded.'**
  String get trackingCampaignRequirement;

  /// No description provided for @deadlineValue.
  ///
  /// In en, this message translates to:
  /// **'Deadline: {date}.'**
  String deadlineValue(String date);

  /// No description provided for @rewardPreviewSentence.
  ///
  /// In en, this message translates to:
  /// **'Reward preview: {reward}.'**
  String rewardPreviewSentence(String reward);

  /// No description provided for @campaignLeftHealthContinues.
  ///
  /// In en, this message translates to:
  /// **'You left the campaign. Health tracking continues.'**
  String get campaignLeftHealthContinues;

  /// No description provided for @capturedGoalPreserved.
  ///
  /// In en, this message translates to:
  /// **'This campaign keeps the captured {count}-step goal even if your settings change.'**
  String capturedGoalPreserved(String count);

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @leftStatus.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get leftStatus;

  /// No description provided for @filterCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Filter campaigns'**
  String get filterCampaigns;

  /// No description provided for @unreadNotificationSemantics.
  ///
  /// In en, this message translates to:
  /// **'Unread notification. {title}. {message}'**
  String unreadNotificationSemantics(String title, String message);

  /// No description provided for @notificationSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title}. {message}'**
  String notificationSemantics(String title, String message);

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newLabel;

  /// No description provided for @dailyStepProgressValue.
  ///
  /// In en, this message translates to:
  /// **'{steps} of {goal} steps, {percentage} percent'**
  String dailyStepProgressValue(int steps, int goal, int percentage);

  /// No description provided for @couponCodeDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This locally generated code is for MVP demonstration only and cannot be validated by a real merchant.'**
  String get couponCodeDisclaimer;

  /// No description provided for @rewardsLoadTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Rewards could not be loaded. Please try again.'**
  String get rewardsLoadTryAgain;

  /// No description provided for @campaignRewardClaimError.
  ///
  /// In en, this message translates to:
  /// **'The campaign reward could not be claimed. Please try again.'**
  String get campaignRewardClaimError;

  /// No description provided for @rewardSafeRedeemError.
  ///
  /// In en, this message translates to:
  /// **'The reward could not be redeemed safely. Your local wallet was restored when possible.'**
  String get rewardSafeRedeemError;

  /// No description provided for @couponStatusUpdateError.
  ///
  /// In en, this message translates to:
  /// **'The coupon status could not be updated.'**
  String get couponStatusUpdateError;

  /// No description provided for @campaignPointsPending.
  ///
  /// In en, this message translates to:
  /// **'Campaign points could not be added yet. Rewards will retry safely.'**
  String get campaignPointsPending;

  /// No description provided for @campaignEnrollmentError.
  ///
  /// In en, this message translates to:
  /// **'Campaign enrollment could not be loaded. Please try again.'**
  String get campaignEnrollmentError;

  /// No description provided for @campaignJoinLocalError.
  ///
  /// In en, this message translates to:
  /// **'The campaign could not be joined locally. Please try again.'**
  String get campaignJoinLocalError;

  /// No description provided for @campaignLeaveLocalError.
  ///
  /// In en, this message translates to:
  /// **'The campaign could not be left locally. Please try again.'**
  String get campaignLeaveLocalError;

  /// No description provided for @campaignProgressSaveError.
  ///
  /// In en, this message translates to:
  /// **'Campaign progress could not be saved. Tracking can continue while you retry.'**
  String get campaignProgressSaveError;

  /// No description provided for @savedCampaignDeviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This saved campaign is not available on this device. Its local progress is preserved.'**
  String get savedCampaignDeviceUnavailable;

  /// No description provided for @campaignStatusUpdateError.
  ///
  /// In en, this message translates to:
  /// **'The campaign status could not be updated locally. Please try again.'**
  String get campaignStatusUpdateError;

  /// No description provided for @historyLoadControllerError.
  ///
  /// In en, this message translates to:
  /// **'Local walking history could not be loaded. Step tracking can continue.'**
  String get historyLoadControllerError;

  /// No description provided for @historySaveControllerError.
  ///
  /// In en, this message translates to:
  /// **'Today’s confirmed history could not be saved yet. Tracking continues normally.'**
  String get historySaveControllerError;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @todayAtTime.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String todayAtTime(String time);

  /// No description provided for @rewardMoveWearContent.
  ///
  /// In en, this message translates to:
  /// **'{field, select, title{Activewear starter offer} short{A saving on selected everyday activewear.} full{Redeem points for a saving on selected MoveWear activewear.} discount{10% off selected activewear} minimum{Minimum purchase of €35} expiration{Use within 14 days of redemption} inventory{Eligible sizes and styles are subject to availability} term1{Applies to campaign-marked products only.} term2{Cannot be combined with another offer.} other{}}'**
  String rewardMoveWearContent(String field);

  /// No description provided for @rewardGreenBiteContent.
  ///
  /// In en, this message translates to:
  /// **'{field, select, title{Healthy meal offer} short{Save on one eligible meal order.} full{Redeem points for a saving on an eligible GreenBite meal order.} discount{20% off an eligible meal order} minimum{Minimum purchase of €25} expiration{Use within 10 days of redemption} inventory{Available for eligible menu items} term1{Delivery and service fees are excluded.} term2{One prototype redemption per local user.} other{}}'**
  String rewardGreenBiteContent(String field);

  /// No description provided for @rewardUrbanFitContent.
  ///
  /// In en, this message translates to:
  /// **'{field, select, title{Equipment saving} short{A fixed saving on selected sports equipment.} full{Use this prototype offer toward eligible UrbanFit equipment.} discount{€15 off selected sports equipment} minimum{Minimum purchase of €70} expiration{Use within 21 days of redemption} inventory{Products are subject to availability} term1{Selected equipment only.} term2{Shipping does not count toward the minimum.} other{}}'**
  String rewardUrbanFitContent(String field);

  /// No description provided for @rewardStepStyleContent.
  ///
  /// In en, this message translates to:
  /// **'{field, select, title{Walking essentials offer} short{A low-point saving on walking essentials.} full{Redeem a small points balance for selected walking essentials.} discount{12% off selected walking essentials} minimum{Minimum purchase of €20} expiration{Use within 7 days of redemption} inventory{Participating locations only} term1{Excludes clearance products.} other{}}'**
  String rewardStepStyleContent(String field);

  /// No description provided for @rewardFreshDayContent.
  ///
  /// In en, this message translates to:
  /// **'{field, select, title{Wellness bundle offer} short{Save on one eligible wellness bundle.} full{A higher-value prototype reward for a FreshDay wellness bundle.} discount{€20 off an eligible wellness bundle} minimum{Minimum purchase of €80} expiration{Use within 14 days of redemption} inventory{Limited eligible bundle inventory} term1{Applies to campaign-marked bundles only.} other{}}'**
  String rewardFreshDayContent(String field);

  /// No description provided for @rewardActiveLifeContent.
  ///
  /// In en, this message translates to:
  /// **'{field, select, title{Wellness session offer} short{A saving on an eligible wellness session.} full{This prototype reward is temporarily unavailable while sessions are updated.} discount{25% off one wellness session} minimum{No minimum purchase} expiration{Use within 14 days of redemption} inventory{Temporarily unavailable} term1{Advance booking would be required.} other{}}'**
  String rewardActiveLifeContent(String field);

  /// No description provided for @campaignMoveWearContent.
  ///
  /// In en, this message translates to:
  /// **'{field, select, title{30,000-step week} short{Build an active week with a clear verified-step target.} full{Walk 30,000 eligible verified steps during the seven-day campaign period to unlock a saving on selected sportswear.} rewardTitle{Selected sportswear discount} rewardDescription{Save on eligible MoveWear sportswear.} discount{20% off selected sportswear} minimum{Minimum purchase of €50} usage{Online and in participating stores} expiration{Use within 14 days of unlocking} inventory{Eligible items are subject to availability} term1{Discount applies only to items marked as campaign eligible.} term2{Cannot be combined with another promotional offer.} term3{Each participant can receive only one reward.} other{}}'**
  String campaignMoveWearContent(String field);

  /// No description provided for @campaignGreenBiteContent.
  ///
  /// In en, this message translates to:
  /// **'{field, select, title{Five goal days} short{Reach your personal walking goal on five campaign days.} full{Reach your current personal daily goal on five of the seven campaign days to unlock a healthy-meal saving.} rewardTitle{250 reward points} rewardDescription{Earn points to use in the reward catalog.} discount{250 points} minimum{Minimum purchase of €25} usage{Online orders only} expiration{Use within 10 days of unlocking} inventory{While campaign rewards remain available} term1{Applies to eligible meal items only.} term2{Delivery and service fees are excluded.} term3{Each participant can receive only one reward.} other{}}'**
  String campaignGreenBiteContent(String field);

  /// No description provided for @campaignUrbanFitContent.
  ///
  /// In en, this message translates to:
  /// **'{field, select, title{City walking challenge} short{A two-week walking target designed for everyday movement.} full{Walk 60,000 eligible verified steps over fourteen days to unlock a saving on selected training accessories.} rewardTitle{400 reward points} rewardDescription{Earn points to use in the reward catalog.} discount{400 points} minimum{Minimum purchase of €35} usage{Online only} expiration{Use within 21 days of unlocking} inventory{Eligible products are subject to availability} term1{Only accessories identified as eligible are included.} term2{Cannot be exchanged for cash.} term3{Each participant can receive only one reward.} other{}}'**
  String campaignUrbanFitContent(String field);

  /// No description provided for @campaignStepStyleContent.
  ///
  /// In en, this message translates to:
  /// **'{field, select, title{Consistent steps} short{Meet your personal daily goal on eight of ten days.} full{Build a consistent walking routine by reaching your personal daily goal on eight separate campaign days.} rewardTitle{Walking apparel discount} rewardDescription{Save on selected StepStyle walking apparel.} discount{18% off eligible walking apparel} minimum{Minimum purchase of €60} usage{Online and in participating stores} expiration{Use within 14 days of unlocking} inventory{Sizes and styles are subject to availability} term1{Discount excludes clearance items.} term2{Cannot be combined with membership pricing.} term3{Each participant can receive only one reward.} other{}}'**
  String campaignStepStyleContent(String field);

  /// No description provided for @campaignFreshDayContent.
  ///
  /// In en, this message translates to:
  /// **'{field, select, title{Fresh-start walk} short{Collect 20,000 verified steps during a five-day reset.} full{Walk 20,000 eligible verified steps during the campaign period and unlock a saving on an eligible wellness bundle.} rewardTitle{Wellness bundle discount} rewardDescription{Save on one eligible FreshDay wellness bundle.} discount{€10 off an eligible wellness bundle} minimum{Minimum purchase of €40} usage{Online only} expiration{Use within 7 days of unlocking} inventory{Limited to available eligible bundles} term1{Applies to campaign-marked bundles only.} term2{Shipping charges do not count toward the minimum purchase.} term3{Each participant can receive only one reward.} other{}}'**
  String campaignFreshDayContent(String field);

  /// No description provided for @campaignActiveLifeContent.
  ///
  /// In en, this message translates to:
  /// **'{field, select, title{Active goal week} short{A completed prototype campaign focused on daily goals.} full{This campaign asked participants to reach their personal daily goal on four of seven campaign days.} rewardTitle{Wellness session discount} rewardDescription{A saving on an eligible ActiveLife session.} discount{25% off one eligible wellness session} minimum{No minimum purchase} usage{At participating locations} expiration{Reward availability period has ended} inventory{Subject to available appointment times} term1{Applied to selected sessions only.} term2{Advance booking was required.} term3{The campaign and its reward period have ended.} other{}}'**
  String campaignActiveLifeContent(String field);

  /// No description provided for @rewardRedeemedTransaction.
  ///
  /// In en, this message translates to:
  /// **'Redeemed {brand} {reward}'**
  String rewardRedeemedTransaction(String brand, String reward);

  /// No description provided for @rewardRedemptionRestoredTransaction.
  ///
  /// In en, this message translates to:
  /// **'Restored failed {brand} redemption'**
  String rewardRedemptionRestoredTransaction(String brand);

  /// No description provided for @campaignCompletedTransaction.
  ///
  /// In en, this message translates to:
  /// **'{campaign} completed'**
  String campaignCompletedTransaction(String campaign);

  /// No description provided for @prototypeRewardTerms.
  ///
  /// In en, this message translates to:
  /// **'Prototype reward terms apply.'**
  String get prototypeRewardTerms;

  /// No description provided for @transitionBasedDetection.
  ///
  /// In en, this message translates to:
  /// **'Transition-based detection'**
  String get transitionBasedDetection;

  /// No description provided for @diagnosticReports.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic reports'**
  String get diagnosticReports;

  /// No description provided for @diagnosticReportsDescription.
  ///
  /// In en, this message translates to:
  /// **'Review and export controlled step-tracking sessions.'**
  String get diagnosticReportsDescription;

  /// No description provided for @diagnosticNoReports.
  ///
  /// In en, this message translates to:
  /// **'No diagnostic reports are available.'**
  String get diagnosticNoReports;

  /// No description provided for @diagnosticTestMetadata.
  ///
  /// In en, this message translates to:
  /// **'Test session details'**
  String get diagnosticTestMetadata;

  /// No description provided for @diagnosticTestName.
  ///
  /// In en, this message translates to:
  /// **'Test name'**
  String get diagnosticTestName;

  /// No description provided for @diagnosticManualSteps.
  ///
  /// In en, this message translates to:
  /// **'Manually counted steps'**
  String get diagnosticManualSteps;

  /// No description provided for @diagnosticRouteDescription.
  ///
  /// In en, this message translates to:
  /// **'Route description'**
  String get diagnosticRouteDescription;

  /// No description provided for @diagnosticNotes.
  ///
  /// In en, this message translates to:
  /// **'Test notes'**
  String get diagnosticNotes;

  /// No description provided for @diagnosticEditMetadata.
  ///
  /// In en, this message translates to:
  /// **'Add or edit test details'**
  String get diagnosticEditMetadata;

  /// No description provided for @diagnosticExportReport.
  ///
  /// In en, this message translates to:
  /// **'Export report'**
  String get diagnosticExportReport;

  /// No description provided for @diagnosticDeleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete diagnostic session'**
  String get diagnosticDeleteSession;

  /// No description provided for @diagnosticClearReports.
  ///
  /// In en, this message translates to:
  /// **'Clear reports'**
  String get diagnosticClearReports;

  /// No description provided for @diagnosticSessionSummary.
  ///
  /// In en, this message translates to:
  /// **'{mode} · {candidates} candidates · {accepted} accepted · {rejected} rejected'**
  String diagnosticSessionSummary(
    String mode,
    int candidates,
    int accepted,
    int rejected,
  );

  /// No description provided for @diagnosticSessionDetails.
  ///
  /// In en, this message translates to:
  /// **'{mode} · {durationSeconds}s · {candidates} raw · {accepted} accepted · {rejected} rejected · +{confirmedGained} confirmed · manual {manualSteps}'**
  String diagnosticSessionDetails(
    String mode,
    int durationSeconds,
    int candidates,
    int accepted,
    int rejected,
    int confirmedGained,
    String manualSteps,
  );
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
