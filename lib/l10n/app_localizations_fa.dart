// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'WalkApp';

  @override
  String get startWalking => 'شروع پیاده‌روی';

  @override
  String get stopTracking => 'توقف ردیابی';

  @override
  String get todaySteps => 'قدم‌های امروز';

  @override
  String get confirmedSteps => 'قدم‌های تأییدشده';

  @override
  String get provisionalSteps => 'قدم‌های در انتظار بررسی';

  @override
  String get stepHistory => 'تاریخچه قدم‌ها';

  @override
  String get reset => 'بازنشانی';

  @override
  String get walking => 'در حال پیاده‌روی';

  @override
  String get running => 'در حال دویدن';

  @override
  String get still => 'بدون حرکت';

  @override
  String get unknown => 'نامشخص';

  @override
  String get retry => 'تلاش دوباره';

  @override
  String get cancel => 'انصراف';

  @override
  String get confirm => 'تأیید';

  @override
  String get home => 'خانه';

  @override
  String get campaigns => 'چالش‌ها';

  @override
  String get rewards => 'پاداش‌ها';

  @override
  String get progress => 'پیشرفت';

  @override
  String get notifications => 'اعلان‌ها';

  @override
  String get profile => 'پروفایل';

  @override
  String get settings => 'تنظیمات';

  @override
  String get history => 'تاریخچه';

  @override
  String get insights => 'بینش‌ها';

  @override
  String get achievements => 'دستاوردها';

  @override
  String get about => 'درباره برنامه';

  @override
  String get login => 'ورود';

  @override
  String get register => 'ایجاد حساب';

  @override
  String get loading => 'در حال بارگذاری';

  @override
  String get save => 'ذخیره';

  @override
  String get close => 'بستن';

  @override
  String get logout => 'خروج';

  @override
  String get dailyGoal => 'هدف روزانه';

  @override
  String get trackingActive => 'ردیابی فعال است';

  @override
  String get trackingStopped => 'ردیابی متوقف است';

  @override
  String get validating => 'در حال بررسی';

  @override
  String get remaining => 'باقی‌مانده';

  @override
  String get inVehicle => 'داخل وسیله نقلیه';

  @override
  String get cycling => 'دوچرخه‌سواری';

  @override
  String get detectingActivity => 'در حال تشخیص فعالیت';

  @override
  String get appLanguage => 'زبان برنامه';

  @override
  String get persianLanguage => 'فارسی';

  @override
  String get englishLanguage => 'English';

  @override
  String get personalizeWalkingExperience =>
      'تجربه پیاده‌روی خود را شخصی‌سازی کنید.';

  @override
  String get appearance => 'ظاهر';

  @override
  String get systemTheme => 'سیستم';

  @override
  String get lightTheme => 'روشن';

  @override
  String get darkTheme => 'تیره';

  @override
  String get dailyGoalUpdated => 'هدف روزانه به‌روز شد';

  @override
  String dailyGoalStepCount(int count) {
    return '$count قدم';
  }

  @override
  String get persistedDailyTarget => 'هدف ذخیره‌شده شما برای هر روز';

  @override
  String get editDailyGoal => 'ویرایش هدف روزانه';

  @override
  String get inAppNotifications => 'اعلان‌های درون‌برنامه‌ای';

  @override
  String get reminderPrototypeDescription =>
      'WalkApp این یادآورها را هنگام بازبودن برنامه یا بازگشت شما به آن بررسی می‌کند. اعلان‌های سیستمی در این نمونه فعال نیستند.';

  @override
  String get dailyGoalReminder => 'یادآوری هدف روزانه';

  @override
  String get reminderTime => 'زمان یادآوری';

  @override
  String get goalCompletionUpdates => 'اعلان تکمیل هدف';

  @override
  String get campaignUpdates => 'به‌روزرسانی چالش‌ها';

  @override
  String get rewardUpdates => 'به‌روزرسانی پاداش‌ها';

  @override
  String get trackingInformation => 'اطلاعات ردیابی';

  @override
  String get backgroundTracking => 'ردیابی پس‌زمینه';

  @override
  String get backgroundTrackingDescription =>
      'تا زمانی که ردیابی فعال است، پردازش قدم‌ها ادامه دارد.';

  @override
  String get stepValidation => 'اعتبارسنجی قدم‌ها';

  @override
  String get stepValidationDescription =>
      'قدم‌های نامزد با استفاده از اطلاعات فعالیت تأیید می‌شوند.';

  @override
  String get activityRecognition => 'تشخیص فعالیت';

  @override
  String get activityRecognitionDescription =>
      'پیاده‌روی، دویدن، دوچرخه‌سواری و حرکت با خودرو به اعتبارسنجی قدم‌ها کمک می‌کنند.';

  @override
  String get aboutDescription =>
      'قدم‌شماری متمرکز برای ساختن یک برنامه روزانه سالم‌تر.';

  @override
  String get account => 'حساب کاربری';

  @override
  String get prototypeAccount => 'حساب نمایشی';

  @override
  String get logoutQuestion => 'خارج می‌شوید؟';

  @override
  String get logoutDescription =>
      'به صفحه ورود بازمی‌گردید. تاریخچه قدم‌ها و تنظیمات شما روی این دستگاه باقی می‌ماند.';

  @override
  String get trackingPaused => 'ردیابی متوقف است';

  @override
  String get preparingSensor => 'در حال آماده‌سازی حسگر';

  @override
  String get validatingRecentSteps => 'در حال بررسی قدم‌های اخیر';

  @override
  String get upToDate => 'به‌روز';

  @override
  String get sensorReady => 'حسگر قدم‌شمار آماده است';

  @override
  String get sensorPreparing => 'حسگر قدم‌شمار در حال آماده‌سازی است';

  @override
  String get sensorInactive => 'حسگر قدم‌شمار غیرفعال است';

  @override
  String get lowConfidence => 'اطمینان کم';

  @override
  String get mediumConfidence => 'اطمینان متوسط';

  @override
  String get highConfidence => 'اطمینان زیاد';

  @override
  String currentActivityValue(String activity) {
    return 'فعالیت فعلی: $activity';
  }

  @override
  String get emailExample => 'you@example.com';

  @override
  String get newToWalkApp => 'تازه به WalkApp پیوسته‌اید؟';

  @override
  String setupStepProgress(int current, int total) {
    return 'مرحله $current از $total';
  }

  @override
  String stepCount(int count) {
    return '$count قدم';
  }

  @override
  String goalValue(String goal) {
    return 'هدف: $goal';
  }

  @override
  String percentageValue(int percentage) {
    return '$percentage٪';
  }

  @override
  String percentageComplete(int percentage) {
    return '$percentage٪ تکمیل‌شده';
  }

  @override
  String goalNumber(int goal) {
    return 'هدف $goal';
  }

  @override
  String campaignProgressPercent(int percentage) {
    return 'پیشرفت چالش $percentage٪';
  }

  @override
  String rewardValue(String reward) {
    return 'پاداش: $reward';
  }

  @override
  String pointsAvailable(int count) {
    return '$count امتیاز در دسترس';
  }

  @override
  String pointsRequired(int count) {
    return '$count امتیاز موردنیاز';
  }

  @override
  String currentBalance(int count) {
    return 'موجودی فعلی: $count';
  }

  @override
  String currentBalancePoints(int count) {
    return 'موجودی فعلی: $count امتیاز';
  }

  @override
  String claimedOn(String date) {
    return 'دریافت‌شده در $date';
  }

  @override
  String expiresOn(String date) {
    return 'انقضا در $date';
  }

  @override
  String redeemRewardQuestion(String reward) {
    return 'پاداش $reward دریافت شود؟';
  }

  @override
  String importantTerms(String terms) {
    return 'شرایط مهم: $terms';
  }

  @override
  String joinCampaignQuestion(String campaign) {
    return 'به $campaign می‌پیوندید؟';
  }

  @override
  String requirementValue(String requirement) {
    return 'شرط: $requirement';
  }

  @override
  String endsOn(String date) {
    return 'پایان: $date';
  }

  @override
  String rewardPreviewValue(String reward) {
    return 'پیش‌نمایش پاداش: $reward';
  }

  @override
  String get openAccountMenu => 'بازکردن منوی حساب';

  @override
  String get discoverCampaigns => 'کشف چالش‌ها';

  @override
  String get back => 'بازگشت';

  @override
  String get welcomeBack => 'خوش آمدید';

  @override
  String get loginWelcomeMessage =>
      'مسیر سلامتی خود را ادامه دهید و به هدف امروز برسید.';

  @override
  String get emailAddress => 'نشانی ایمیل';

  @override
  String get password => 'رمز عبور';

  @override
  String get forgotPassword => 'رمز عبور را فراموش کرده‌اید؟';

  @override
  String get passwordRecoveryUnavailable =>
      'بازیابی رمز عبور پس از اتصال سامانه احراز هویت در دسترس خواهد بود.';

  @override
  String get createYourAccount => 'حساب خود را بسازید';

  @override
  String get registerWelcomeMessage =>
      'ساخت یک برنامه روزانه سالم‌تر را آغاز کنید.';

  @override
  String get fullName => 'نام و نام خانوادگی';

  @override
  String get yourName => 'نام شما';

  @override
  String get minimumEightCharacters => 'حداقل ۸ نویسه';

  @override
  String get confirmPassword => 'تکرار رمز عبور';

  @override
  String get acceptTermsAndPrivacy =>
      'شرایط استفاده و سیاست حریم خصوصی را می‌پذیرم';

  @override
  String get alreadyHaveAccount => 'از قبل حساب دارید؟';

  @override
  String get chooseTheme => 'انتخاب پوسته';

  @override
  String get showPassword => 'نمایش رمز عبور';

  @override
  String get hidePassword => 'پنهان‌کردن رمز عبور';

  @override
  String get localMvpAuthentication => 'احراز هویت محلی نسخه اولیه';

  @override
  String get localMvpAuthenticationDescription =>
      'در این نسخه آزمایشی، اطلاعات ورود به سرور ارسال یا توسط آن تأیید نمی‌شوند.';

  @override
  String get enterFullName => 'نام و نام خانوادگی خود را وارد کنید';

  @override
  String get enterEmailAddress => 'نشانی ایمیل خود را وارد کنید';

  @override
  String get enterValidEmailAddress => 'یک نشانی ایمیل معتبر وارد کنید';

  @override
  String get enterPassword => 'رمز عبور خود را وارد کنید';

  @override
  String get useAtLeastEightCharacters => 'حداقل از ۸ نویسه استفاده کنید';

  @override
  String get passwordsDoNotMatch => 'رمزهای عبور یکسان نیستند';

  @override
  String get acceptTermsToContinue =>
      'برای ادامه، شرایط و سیاست حریم خصوصی را بپذیرید';

  @override
  String get loadingLabel => 'در حال بارگذاری';

  @override
  String get somethingWentWrong => 'مشکلی پیش آمد';

  @override
  String get clearReadNotificationsQuestion => 'اعلان‌های خوانده‌شده پاک شوند؟';

  @override
  String readNotificationsRemoved(int count) {
    return '$count اعلان خوانده‌شده از این دستگاه حذف می‌شود. اعلان‌های خوانده‌نشده باقی می‌مانند.';
  }

  @override
  String get clearReadNotifications => 'پاک‌کردن اعلان‌های خوانده‌شده';

  @override
  String get loadingNotifications => 'در حال بارگیری اعلان‌ها';

  @override
  String get notificationsLoadError => 'اعلان‌ها بارگیری نشدند.';

  @override
  String get noNotifications => 'هنوز اعلانی ندارید';

  @override
  String get notificationEmptyDescription =>
      'به‌روزرسانی هدف‌ها، چالش‌ها و پاداش‌ها اینجا نمایش داده می‌شود.';

  @override
  String get notificationPageDescription =>
      'به‌روزرسانی هدف‌های سلامتی، چالش‌ها و پاداش‌های شما.';

  @override
  String get markAllRead => 'علامت‌گذاری همه به‌عنوان خوانده‌شده';

  @override
  String get unread => 'خوانده‌نشده';

  @override
  String get earlier => 'قدیمی‌تر';

  @override
  String get accountLogoutDescription =>
      'به صفحه ورود بازمی‌گردید. قدم‌ها، هدف‌ها، پوسته و نمایه شما روی این دستگاه باقی می‌ماند.';

  @override
  String get yourProfile => 'نمایه شما';

  @override
  String get addNameAndEmail => 'نام و ایمیل خود را اضافه کنید';

  @override
  String get aboutPageDescription =>
      'همراهی متمرکز برای ثبت قدم‌های روزانه و ساختن برنامه‌ای سالم‌تر.';

  @override
  String get materialThreeDesign => 'طراحی متریال ۳';

  @override
  String get materialThreeDescription =>
      'پوسته‌های روشن و تیره واکنش‌گرا از سامانه طراحی مدرن و سلامت‌محور متریال ۳ استفاده می‌کنند.';

  @override
  String get localPreferences => 'تنظیمات محلی';

  @override
  String get localPreferencesDescription =>
      'پوسته، هدف روزانه و اطلاعات نمایه در تنظیمات محلی برنامه باقی می‌مانند.';

  @override
  String get purposefulTracking => 'ردیابی هدفمند';

  @override
  String get purposefulTrackingDescription =>
      'اعتبارسنجی قدم‌ها و اطلاعات فعالیت هنگام ردیابی با هم کار می‌کنند.';

  @override
  String get progressPageDescription => 'پیشرفت سلامتی و حساب شما در یک مکان.';

  @override
  String get loadingProgressSummary => 'در حال بارگیری خلاصه پیشرفت';

  @override
  String get progressHistoryUnavailable =>
      'تاریخچه پیشرفت موقتاً در دسترس نیست.';

  @override
  String get yourProgress => 'پیشرفت شما';

  @override
  String unreadNotificationCount(int count) {
    return '$count خوانده‌نشده';
  }

  @override
  String localDayCount(int count) {
    return '$count روز به‌صورت محلی ثبت شده است.';
  }

  @override
  String get historyMetricsUnavailable =>
      'شاخص‌های تاریخچه اکنون در دسترس نیستند.';

  @override
  String goalDaysThisWeek(int count) {
    return '$count روز رسیدن به هدف در این هفته.';
  }

  @override
  String get insightsHistoryUnavailable =>
      'بینش‌ها پس از دردسترس‌بودن تاریخچه نمایش داده می‌شوند.';

  @override
  String achievementsUnlocked(int count) {
    return '$count دستاورد باز شده است.';
  }

  @override
  String get yourAccount => 'حساب شما';

  @override
  String get manageProfileDescription =>
      'نام و اطلاعات تماس خود را مدیریت کنید.';

  @override
  String get settingsDescription => 'هدف، پوسته و تنظیمات خود را تغییر دهید.';

  @override
  String get aboutDestinationDescription =>
      'درباره WalkApp و ردیابی بیشتر بدانید.';

  @override
  String get confirmedThisWeek => 'تأییدشده این هفته';

  @override
  String get goalDaysThisWeekLabel => 'روزهای رسیدن به هدف در این هفته';

  @override
  String get currentGoalStreak => 'روند فعلی هدف';

  @override
  String dayCount(int count) {
    return '$count روز';
  }

  @override
  String get recordedOnDevice => 'ثبت‌شده روی این دستگاه';

  @override
  String get localProgressSummary => 'خلاصه پیشرفت محلی';

  @override
  String get yourAchievements => 'دستاوردهای شما';

  @override
  String achievementProgress(int unlocked, int total) {
    return '$unlocked مورد از $total دستاورد با فعالیت واقعی محلی باز شده است.';
  }

  @override
  String get firstStepsAchievement => 'نخستین قدم‌ها';

  @override
  String get firstStepsAchievementDescription =>
      'در یک روز حداقل ۱٬۰۰۰ قدم تأییدشده ثبت کنید.';

  @override
  String get goalGetterAchievement => 'رسیدن به هدف';

  @override
  String get goalGetterAchievementDescription =>
      'برای نخستین بار به هدف روزانه ثبت‌شده برسید.';

  @override
  String get threeActiveDaysAchievement => 'سه روز فعال';

  @override
  String get threeActiveDaysAchievementDescription =>
      'در سه تاریخ جداگانه قدم تأییدشده ثبت کنید.';

  @override
  String get consistentWalkerAchievement => 'پیاده‌روی پیوسته';

  @override
  String get consistentWalkerAchievementDescription =>
      'در سه روز پیاپی به هدف روزانه برسید.';

  @override
  String get weeklyExplorerAchievement => 'کاوشگر هفتگی';

  @override
  String get weeklyExplorerAchievementDescription =>
      'در هفت روز پیاپی ۵۰٬۰۰۰ قدم تأییدشده ثبت کنید.';

  @override
  String get campaignFinisherAchievement => 'پایان‌دهنده چالش';

  @override
  String get campaignFinisherAchievementDescription =>
      'یک چالش پیاده‌روی را تکمیل کنید.';

  @override
  String get healthCategory => 'سلامتی';

  @override
  String get campaignCategory => 'چالش';

  @override
  String get unlocked => 'بازشده';

  @override
  String get locked => 'قفل‌شده';

  @override
  String unlockedOn(String date) {
    return 'بازشده در $date';
  }

  @override
  String get profileDetails => 'جزئیات حساب شما';

  @override
  String get completeProfile => 'نمایه خود را تکمیل کنید';

  @override
  String get profileStorageDescription =>
      'به‌صورت خصوصی در تنظیمات محلی برنامه ذخیره می‌شود.';

  @override
  String get personalization => 'شخصی‌سازی';

  @override
  String get city => 'شهر';

  @override
  String get rewardInterests => 'علاقه‌مندی‌های پاداش';

  @override
  String dailyGoalWithSteps(int count) {
    return 'هدف روزانه: $count قدم';
  }

  @override
  String get notAdded => 'اضافه نشده';

  @override
  String get editProfile => 'ویرایش نمایه';

  @override
  String get profileSaved => 'نمایه ذخیره شد';

  @override
  String get profileSaveError => 'نمایه ذخیره نشد. دوباره تلاش کنید.';

  @override
  String get rewardInterestsUpdated => 'علاقه‌مندی‌های پاداش به‌روز شد';

  @override
  String get insightsDescription =>
      'روندهای واقعی بر پایه قدم‌های تأییدشده ثبت‌شده روی این دستگاه.';

  @override
  String get thisWeek => 'این هفته';

  @override
  String confirmedStepCount(String count) {
    return '$count قدم تأییدشده';
  }

  @override
  String dailyAverage(String count) {
    return 'میانگین روزانه $count';
  }

  @override
  String activeDayCount(int count) {
    return '$count روز فعال';
  }

  @override
  String goalDayCount(int count) {
    return '$count روز رسیدن به هدف';
  }

  @override
  String get moreWeeklyComparisons => 'مقایسه‌های هفتگی بیشتری در راه است';

  @override
  String get keepTrackingForTrend =>
      'برای ساختن روندی معنادار، پیاده‌روی‌های خود را ثبت کنید.';

  @override
  String get consistency => 'پیوستگی';

  @override
  String currentGoalDayStreak(int count) {
    return 'روند فعلی رسیدن به هدف: $count روز';
  }

  @override
  String longestLocalStreak(int count) {
    return 'طولانی‌ترین روند محلی: $count روز';
  }

  @override
  String goalCompletionThirtyDays(int percentage) {
    return '$percentage٪ تکمیل هدف در ۳۰ روز';
  }

  @override
  String get bestDay => 'بهترین روز';

  @override
  String datedConfirmedSteps(String date, String count) {
    return '$date — $count قدم تأییدشده';
  }

  @override
  String get recordedGoalReached => 'رسیدن به هدف ثبت شده است';

  @override
  String get recordedGoalNotReached => 'رسیدن به هدف ثبت نشده است';

  @override
  String liveDisplayedSteps(String count) {
    return '$count قدم زنده نمایش‌داده‌شده';
  }

  @override
  String confirmedValue(String count) {
    return '$count تأییدشده';
  }

  @override
  String validatingValue(String count) {
    return '$count در حال بررسی';
  }

  @override
  String dailyGoalFormatted(String goal) {
    return 'هدف روزانه: $goal';
  }

  @override
  String get liveStepsExplanation =>
      'قدم‌های زنده نمایش‌داده‌شده ممکن است شامل قدم‌های در حال اعتبارسنجی باشند. آمار تاریخچه فقط از قدم‌های تأییدشده استفاده می‌کند.';

  @override
  String percentageMore(int percentage) {
    return '$percentage٪ بیشتر';
  }

  @override
  String percentageFewer(int percentage) {
    return '$percentage٪ کمتر';
  }

  @override
  String get comparedWithLastWeek => 'مقایسه با هفته گذشته';

  @override
  String get historyDescription =>
      'پیشرفت قدم‌های تأییدشده خود را در گذر زمان مرور کنید.';

  @override
  String get historyValidationExplanation =>
      'آمار امروز ممکن است شامل قدم‌های در حال بررسی صفحه خانه باشد. روزهای تکمیل‌شده در تاریخچه فقط از قدم‌های تأییدشده استفاده می‌کنند.';

  @override
  String get sevenDays => '۷ روز';

  @override
  String get thirtyDays => '۳۰ روز';

  @override
  String get loadingWalkingHistory => 'در حال بارگیری تاریخچه پیاده‌روی';

  @override
  String get walkingHistoryUnavailable =>
      'تاریخچه پیاده‌روی موقتاً در دسترس نیست.';

  @override
  String get noConfirmedHistory => 'هنوز سابقه قدم تأییدشده‌ای ندارید';

  @override
  String get noConfirmedHistoryDescription =>
      'ردیابی پیاده‌روی را آغاز کنید. پیشرفت روزانه تأییدشده اینجا نمایش داده می‌شود.';

  @override
  String get noRecordForDate => 'برای این تاریخ سابقه محلی وجود ندارد.';

  @override
  String get cityUpdated => 'شهر به‌روز شد';

  @override
  String get clothing => 'پوشاک';

  @override
  String get sports => 'ورزش';

  @override
  String get food => 'غذا';

  @override
  String get wellness => 'تندرستی';

  @override
  String get noPreference => 'بدون ترجیح';

  @override
  String get tehran => 'تهران';

  @override
  String get karaj => 'کرج';

  @override
  String get mashhad => 'مشهد';

  @override
  String get isfahan => 'اصفهان';

  @override
  String get shiraz => 'شیراز';

  @override
  String get tabriz => 'تبریز';

  @override
  String get other => 'سایر';

  @override
  String get preferNotToSay => 'ترجیح می‌دهم نگویم';

  @override
  String get previousSetupStep => 'مرحله قبلی راه‌اندازی';

  @override
  String get walkTowardHealthierHabits => 'به‌سوی عادت‌های سالم‌تر قدم بردارید';

  @override
  String get onboardingIntroDescription =>
      'WalkApp پیشرفت سلامتی شخصی را در اولویت می‌گذارد. چالش‌ها اختیاری‌اند و پیاده‌روی تأییدشده ممکن است امتیاز یا پاداش مفیدی فراهم کند.';

  @override
  String get trackDailyProgress => 'پیشرفت پیاده‌روی روزانه را ثبت کنید';

  @override
  String get buildHabitsWithGoal => 'با هدف شخصی عادت بسازید';

  @override
  String get joinOptionalCampaigns =>
      'هر زمان خواستید به چالش‌های اختیاری بپیوندید';

  @override
  String get chooseDailyGoal => 'هدف روزانه خود را انتخاب کنید';

  @override
  String get chooseDailyGoalDescription =>
      'هدفی انتخاب کنید که برایتان واقع‌بینانه باشد. بعداً می‌توانید آن را تغییر دهید.';

  @override
  String get comfortableStartingPoint => 'نقطه شروعی راحت';

  @override
  String get balancedEverydayGoal => 'هدف روزانه متعادل';

  @override
  String get popularActiveTarget => 'هدف فعال و محبوب';

  @override
  String get activeWalkerGoal => 'برای افراد از قبل فعال';

  @override
  String get customGoal => 'هدف دلخواه';

  @override
  String get whatInterestsYou => 'به چه چیزهایی علاقه دارید؟';

  @override
  String get interestsDescription =>
      'علاقه‌مندی‌ها فقط ترتیب محتوای نمونه محلی را تعیین می‌کنند و چیزی پنهان نمی‌شود.';

  @override
  String get chooseYourCity => 'شهر خود را انتخاب کنید';

  @override
  String get citySelectionDescription =>
      'شهر شما ممکن است بعداً برای نمایش چالش‌های محلی استفاده شود. WalkApp برای این انتخاب از GPS استفاده نمی‌کند.';

  @override
  String get physicalActivityAccess => 'دسترسی به فعالیت بدنی';

  @override
  String get activityPermissionDescription =>
      'دسترسی فعالیت به WalkApp کمک می‌کند پیاده‌روی را تشخیص دهد و پیشرفت قدم‌ها را اعتبارسنجی کند. ردیابی پس‌زمینه اجازه می‌دهد نشست فعال با صفحه خاموش ادامه یابد. GPS پیوسته لازم نیست.';

  @override
  String get allowActivityAccess => 'اجازه دسترسی به فعالیت';

  @override
  String get retryActivityAccess => 'تلاش دوباره برای دسترسی';

  @override
  String get continueWithoutTracking => 'ادامه بدون ردیابی';

  @override
  String get activityAccessGranted => 'دسترسی فعالیت داده شده است';

  @override
  String get activityAccessNotGranted => 'دسترسی فعالیت داده نشده است';

  @override
  String get enableAccessInSettings => 'دسترسی را در تنظیمات برنامه فعال کنید';

  @override
  String get activitySensorUnavailable => 'حسگر فعالیت در دسترس نیست';

  @override
  String get permissionBeforeRequest =>
      'مجوز فقط پس از انتخاب اقدام زیر درخواست می‌شود.';

  @override
  String get trackingReadyDescription =>
      'هر زمان آماده بودید می‌توانید ردیابی را از صفحه خانه آغاز کنید.';

  @override
  String get trackingNeedsPermission =>
      'می‌توانید ادامه دهید، اما ردیابی قدم‌ها به دسترسی فعالیت نیاز دارد.';

  @override
  String get enableActivityManually =>
      'تنظیمات سیستمی این برنامه را باز کنید و دسترسی فعالیت را دستی فعال کنید.';

  @override
  String get permissionUnsupported =>
      'این دستگاه از فرایند آزمایشی مجوز فعالیت پشتیبانی نمی‌کند.';

  @override
  String get androidPermissionInstructions =>
      'اندروید: تنظیمات ← برنامه‌ها ← WalkApp ← مجوزها ← فعالیت بدنی، سپس دسترسی را مجاز کنید.';

  @override
  String get youAreReady => 'همه‌چیز آماده است';

  @override
  String get completionDescription =>
      'ردیابی سلامتی مستقل باقی می‌ماند و هر زمان بخواهید از صفحه خانه آغاز می‌شود.';

  @override
  String get interests => 'علایق';

  @override
  String get granted => 'داده‌شده';

  @override
  String get notGranted => 'داده‌نشده';

  @override
  String get decreaseGoal => 'کاهش هدف به‌اندازه ۱٬۰۰۰';

  @override
  String get goalInSteps => 'هدف برحسب قدم';

  @override
  String get increaseGoal => 'افزایش هدف به‌اندازه ۱٬۰۰۰';

  @override
  String get quickOptions => 'گزینه‌های سریع';

  @override
  String get saveGoal => 'ذخیره هدف';

  @override
  String get dailyStepProgress => 'پیشرفت قدم‌های روزانه';

  @override
  String get currentActivity => 'فعالیت فعلی';

  @override
  String get openNotifications => 'بازکردن اعلان‌ها';

  @override
  String get noUnreadNotifications => 'اعلان‌ها، بدون مورد خوانده‌نشده';

  @override
  String unreadNotificationsSemantics(int count) {
    return 'اعلان‌ها، $count مورد خوانده‌نشده';
  }

  @override
  String get todayHealthProgress => 'پیشرفت سلامتی امروز';

  @override
  String todayHealthProgressSemantics(
    int steps,
    int goal,
    int percentage,
    int remaining,
  ) {
    return 'پیشرفت سلامتی امروز، $steps از $goal قدم، $percentage درصد، $remaining باقی‌مانده';
  }

  @override
  String progressOfGoal(int percentage, String goal, String remaining) {
    return '$percentage٪ از $goal • $remaining باقی‌مانده';
  }

  @override
  String get loadingCampaignProgress => 'در حال بارگیری پیشرفت چالش…';

  @override
  String get campaignProgressUnavailable => 'پیشرفت چالش موقتاً در دسترس نیست.';

  @override
  String get activeCampaign => 'چالش فعال';

  @override
  String campaignStepProgress(String current, String target) {
    return '$current / $target قدم چالش';
  }

  @override
  String campaignGoalDayProgress(int current, int target) {
    return '$current روز از $target روز هدف تکمیل شده';
  }

  @override
  String eligibleStepsToday(String current, String goal) {
    return '$current / $goal قدم واجد شرایط امروز';
  }

  @override
  String get continueCampaign => 'ادامه چالش';

  @override
  String get exploreMore => 'مشاهده بیشتر';

  @override
  String get campaignCompleted => 'چالش تکمیل شد';

  @override
  String get rewardReady => 'پاداش آماده است';

  @override
  String pointsEarned(int count) {
    return '$count امتیاز کسب شد';
  }

  @override
  String rewardReadyToClaim(String reward) {
    return '$reward آماده دریافت است';
  }

  @override
  String rewardUnlocked(String reward) {
    return '$reward باز شد';
  }

  @override
  String get viewRewards => 'مشاهده پاداش‌ها';

  @override
  String get claimReward => 'دریافت پاداش';

  @override
  String get viewReward => 'مشاهده پاداش';

  @override
  String get viewAll => 'مشاهده همه';

  @override
  String get featuredChallenge => 'چالش ویژه';

  @override
  String get viewCampaign => 'مشاهده چالش';

  @override
  String get walkingChallengeQuestion => 'برای یک چالش پیاده‌روی آماده‌اید؟';

  @override
  String get walkingChallengeDescription =>
      'چالش‌ها را بررسی کنید و از برندهای شرکت‌کننده پاداش بگیرید.';

  @override
  String get viewCampaigns => 'مشاهده چالش‌ها';

  @override
  String get loadingRewards => 'در حال بارگیری پاداش‌ها…';

  @override
  String get rewardsUnavailable => 'پاداش‌ها موقتاً در دسترس نیستند.';

  @override
  String rewardsReadyToClaim(int count) {
    return '$count پاداش آماده دریافت';
  }

  @override
  String availableCoupons(int count) {
    return '$count کد تخفیف در دسترس';
  }

  @override
  String get earnRewardsDescription =>
      'برای شروع دریافت پاداش، چالش‌های واجد شرایط را تکمیل کنید.';

  @override
  String get openRewards => 'بازکردن پاداش‌ها';

  @override
  String get localPrototypeContent => 'محتوای نمونه محلی';

  @override
  String get loadingCampaigns => 'در حال بارگیری چالش‌ها';

  @override
  String get campaignsLoadError => 'چالش‌ها بارگیری نشدند. دوباره تلاش کنید.';

  @override
  String get noCampaignsAvailable => 'هنوز چالشی در دسترس نیست';

  @override
  String get noCampaignsDescription =>
      'چالش‌های جدید پیاده‌روی اینجا نمایش داده می‌شوند.';

  @override
  String get noMatchingCampaigns => 'چالشی مطابق فیلتر پیدا نشد';

  @override
  String get tryAnotherCampaignFilter => 'وضعیت یا دسته دیگری را امتحان کنید.';

  @override
  String get active => 'فعال';

  @override
  String get allCategories => 'همه دسته‌ها';

  @override
  String get done => 'انجام شد';

  @override
  String get leaveCampaignQuestion => 'از این چالش خارج می‌شوید؟';

  @override
  String get leaveCampaign => 'ترک چالش';

  @override
  String get loadingCampaign => 'در حال بارگیری چالش';

  @override
  String get noCampaignToShow => 'چالشی برای نمایش وجود ندارد';

  @override
  String get returnToCampaigns => 'برای یافتن چالش به صفحه چالش‌ها بازگردید.';

  @override
  String get startTracking => 'شروع ردیابی';

  @override
  String get campaignRules => 'قوانین چالش';

  @override
  String get activeCampaignExists => 'یک چالش فعال دارید';

  @override
  String get keepCurrentCampaign => 'حفظ چالش فعلی';

  @override
  String get viewActiveCampaign => 'مشاهده چالش فعال';

  @override
  String get oneActiveCampaign => 'در هر زمان فقط یک چالش می‌تواند فعال باشد.';

  @override
  String get joinCampaign => 'پیوستن به چالش';

  @override
  String get campaignDetails => 'جزئیات چالش';

  @override
  String get howItWorks => 'نحوه کار';

  @override
  String get goalRules => 'قوانین هدف';

  @override
  String get rewardTerms => 'شرایط پاداش';

  @override
  String get campaignDuration => 'مدت چالش';

  @override
  String get reward => 'پاداش';

  @override
  String get minimumPurchase => 'حداقل خرید';

  @override
  String get whereToUse => 'محل استفاده';

  @override
  String get expiration => 'انقضا';

  @override
  String get availability => 'موجودی';

  @override
  String get myRewards => 'پاداش‌های من';

  @override
  String get noClaimedRewards => 'هنوز پاداشی دریافت نکرده‌اید';

  @override
  String get viewCoupon => 'مشاهده کد تخفیف';

  @override
  String get walletActivity => 'گردش کیف پول';

  @override
  String get noPointTransactions => 'هنوز تراکنش امتیازی ندارید';

  @override
  String get rewardDetails => 'جزئیات پاداش';

  @override
  String get localRewardsPrototype => 'نمونه محلی پاداش‌ها';

  @override
  String get noMatchingRewards => 'پاداشی مطابق فیلتر پیدا نشد';

  @override
  String get viewWalletActivity => 'مشاهده گردش کیف پول';

  @override
  String get viewDetails => 'مشاهده جزئیات';

  @override
  String get markCouponUsedQuestion => 'کد تخفیف استفاده‌شده علامت‌گذاری شود؟';

  @override
  String get markAsUsed => 'علامت‌گذاری به‌عنوان استفاده‌شده';

  @override
  String get couponDetails => 'جزئیات کد تخفیف';

  @override
  String get savedRewardUnavailable =>
      'این پاداش ذخیره‌شده به‌صورت محلی در دسترس نیست.';

  @override
  String get prototypeCoupon => 'کد تخفیف نمونه';

  @override
  String get copyCode => 'کپی کد';

  @override
  String get status => 'وضعیت';

  @override
  String get claimed => 'دریافت‌شده';

  @override
  String get source => 'منبع';

  @override
  String get debugSimulation => 'شبیه‌سازی آزمایشی';

  @override
  String get continueAction => 'ادامه';

  @override
  String get continueToAccountSetup => 'ادامه به راه‌اندازی حساب';

  @override
  String get chooseInterestError =>
      'حداقل یک علاقه‌مندی یا «بدون ترجیح» را انتخاب کنید.';

  @override
  String get goalRangeError => 'هدفی بین ۱٬۰۰۰ تا ۱۰۰٬۰۰۰ قدم وارد کنید';

  @override
  String get dailyStepGoal => 'هدف قدم‌های روزانه';

  @override
  String get goalSheetDescription =>
      'هدفی انتخاب کنید که برای برنامه روزانه شما دست‌یافتنی باشد.';

  @override
  String get stepTrackingStarted => 'ردیابی قدم آغاز شد.';

  @override
  String get stepTrackingStopped => 'ردیابی قدم‌ها متوقف شد';

  @override
  String get trackingUpdateError => 'ردیابی به‌روز نشد. دوباره تلاش کنید.';

  @override
  String get activityPermissionRequired =>
      'برای شمارش قدم‌ها مجوز فعالیت لازم است.';

  @override
  String get stepSensorUnavailable =>
      'حسگر قدم‌شمار در این دستگاه در دسترس نیست.';

  @override
  String get trackingRefreshError =>
      'ردیابی به‌روز نشد. صفحه را تازه کنید یا دوباره تلاش کنید.';

  @override
  String get stoppingTracking => 'در حال توقف…';

  @override
  String get startingTracking => 'در حال شروع…';

  @override
  String get keepGoing => 'ادامه دهید، عالی پیش می‌روید!';

  @override
  String get readyToMove => 'هر زمان آماده حرکت بودید، ردیابی را آغاز کنید.';

  @override
  String get todayProgress => 'پیشرفت امروز';

  @override
  String get sensorsReady => 'حسگرها · آماده';

  @override
  String get sensorsPreparing => 'حسگرها · در حال آماده‌سازی';

  @override
  String get sensorsInactive => 'حسگرها · غیرفعال';

  @override
  String get trackingActiveCompact => 'ردیابی · فعال';

  @override
  String get trackingStoppedCompact => 'ردیابی · متوقف';

  @override
  String get validationValidating => 'اعتبارسنجی · در حال بررسی';

  @override
  String get validationIdle => 'اعتبارسنجی · بی‌کار';

  @override
  String get goodMorning => 'صبح بخیر';

  @override
  String get goodAfternoon => 'ظهر بخیر';

  @override
  String get goodEvening => 'عصر بخیر';

  @override
  String get dailyGoalCompletedNotification => 'هدف روزانه تکمیل شد';

  @override
  String get dailyGoalCompletedMessage => 'به هدف پیاده‌روی امروز خود رسیدید.';

  @override
  String get dailyGoalReminderTitle => 'امروز چند قدم دیگر برمی‌دارید؟';

  @override
  String dailyGoalReminderMessage(int count) {
    return '$count قدم تا رسیدن به هدف روزانه باقی مانده است.';
  }

  @override
  String get campaignEndingSoonNotification => 'چالش شما به‌زودی پایان می‌یابد';

  @override
  String campaignCompletedMessage(String campaign) {
    return 'چالش $campaign را تکمیل کردید.';
  }

  @override
  String get campaignRewardReadyTitle => 'پاداش آماده دریافت است';

  @override
  String campaignRewardReadyMessage(String reward) {
    return 'پاداش $reward آماده است.';
  }

  @override
  String get pointsAddedTitle => 'امتیازها اضافه شدند';

  @override
  String pointsAddedMessage(int count) {
    return '$count امتیاز به موجودی پاداش‌های شما اضافه شد.';
  }

  @override
  String get rewardExpiringSoonTitle => 'پاداش شما به‌زودی منقضی می‌شود';

  @override
  String rewardExpiringSoonMessage(String reward, String date) {
    return 'پاداش $reward را پیش از $date استفاده کنید.';
  }

  @override
  String campaignStepsRemaining(int count) {
    return 'تا مهلت پایان به $count قدم چالش دیگر نیاز دارید.';
  }

  @override
  String goalDaysRemaining(int count) {
    return 'تا مهلت پایان به $count روز هدف دیگر نیاز دارید.';
  }

  @override
  String get campaignUnavailableShowingList =>
      'این چالش دیگر در دسترس نیست. فهرست چالش‌ها نمایش داده می‌شود.';

  @override
  String get couponUnavailableShowingRewards =>
      'این کد تخفیف دیگر در دسترس نیست. پاداش‌ها نمایش داده می‌شوند.';

  @override
  String get rewardClaimError => 'پاداش دریافت نشد.';

  @override
  String get campaignRewardClaimed => 'پاداش چالش دریافت شد.';

  @override
  String get campaignEnrollmentLoadError => 'وضعیت عضویت بارگیری نشد.';

  @override
  String get featuredCampaign => 'چالش ویژه';

  @override
  String get endingSoon => 'رو به پایان';

  @override
  String get completeOrLeaveCampaign =>
      'پیش از پیوستن به چالشی دیگر، چالش فعلی را تکمیل یا ترک کنید.';

  @override
  String get campaignNoLongerAvailable =>
      'این چالش دیگر برای عضویت در دسترس نیست.';

  @override
  String get campaignAlreadyCompleted => 'این چالش را قبلاً تکمیل کرده‌اید.';

  @override
  String get campaignJoinError => 'عضویت در چالش انجام نشد. دوباره تلاش کنید.';

  @override
  String get joinCampaignStep => 'به چالش بپیوندید';

  @override
  String get walkCampaignPeriodStep => 'در بازه چالش پیاده‌روی کنید';

  @override
  String get unlockRewardStep => 'هدف را تکمیل و پاداش را باز کنید';

  @override
  String get targetSteps => 'قدم‌های هدف';

  @override
  String get requiredGoalDays => 'روزهای هدف موردنیاز';

  @override
  String get eligibleActivityOnly =>
      'فقط فعالیت تأییدشده واجد شرایط محاسبه می‌شود.';

  @override
  String get personalDailyGoalUsed => 'هدف روزانه شخصی شما استفاده می‌شود.';

  @override
  String get campaignDayCountsOnce =>
      'هر روز چالش حداکثر یک‌بار محاسبه می‌شود.';

  @override
  String get importantRestrictions => 'محدودیت‌های مهم';

  @override
  String get campaignLeaveDescription =>
      'پیشرفت چالش دیگر فعال نخواهد بود. قدم‌های سلامتی و تاریخچه هدف روزانه حذف نمی‌شوند.';

  @override
  String get campaignLeaveError => 'ترک چالش انجام نشد. دوباره تلاش کنید.';

  @override
  String get trackingStartError => 'ردیابی آغاز نشد. دوباره تلاش کنید.';

  @override
  String get savedCampaignUnavailable =>
      'این چالش ذخیره‌شده در دسترس نیست. سابقه محلی شما حفظ شده است.';

  @override
  String get requirementCompleted => 'شرط تکمیل شده';

  @override
  String get finalCampaignProgress => 'پیشرفت نهایی چالش';

  @override
  String get confirmedAfterEnrollmentOnly =>
      'فقط قدم‌های تأییدشده پس از عضویت محاسبه می‌شوند.';

  @override
  String get healthProgressIndependent =>
      'پیشرفت سلامتی و هدف روزانه مستقل ادامه پیدا می‌کنند.';

  @override
  String get offlinePrototypeState =>
      'این وضعیت نمونه به‌صورت محلی و آفلاین است و از زمان دستگاه استفاده می‌کند.';

  @override
  String get rewardsDescription =>
      'فعالیت‌های واجد شرایط و چالش‌های تکمیل‌شده را به پیشنهادهای کاربردی تبدیل کنید.';

  @override
  String get rewardsLoadError => 'پاداش‌ها بارگیری نشدند.';

  @override
  String get readyToClaim => 'آماده دریافت';

  @override
  String get featuredReward => 'پاداش ویژه';

  @override
  String get rewardCatalog => 'فهرست پاداش‌ها';

  @override
  String get rewardFilterHint =>
      'دسته دیگری را انتخاب کنید یا امتیاز بیشتری به دست آورید.';

  @override
  String get availablePoints => 'امتیازهای در دسترس';

  @override
  String walletTotals(int earned, int spent) {
    return '$earned دریافت‌شده • $spent مصرف‌شده';
  }

  @override
  String get allFilter => 'همه';

  @override
  String get affordableFilter => 'قابل دریافت';

  @override
  String get clothingCategory => 'پوشاک';

  @override
  String get sportsCategory => 'ورزشی';

  @override
  String get foodCategory => 'خوراکی';

  @override
  String get wellnessCategory => 'سلامت';

  @override
  String get availableStatus => 'موجود';

  @override
  String get insufficientPointsStatus => 'امتیاز کافی نیست';

  @override
  String get claimedStatus => 'دریافت‌شده';

  @override
  String get unavailableStatus => 'ناموجود';

  @override
  String get expiredStatus => 'منقضی‌شده';

  @override
  String get used => 'استفاده‌شده';

  @override
  String get enoughPointsMessage => 'برای دریافت این پاداش امتیاز کافی دارید.';

  @override
  String morePointsNeeded(int count) {
    return '$count امتیاز دیگر لازم است';
  }

  @override
  String get limitedRewardClaimed => 'این پاداش محدود قبلاً دریافت شده است.';

  @override
  String get rewardCurrentlyUnavailable => 'این پاداش اکنون در دسترس نیست.';

  @override
  String get rewardExpiredMessage => 'این پاداش منقضی شده است.';

  @override
  String balanceAfterRedemption(int count) {
    return 'موجودی پس از دریافت: $count';
  }

  @override
  String get localCouponDisclaimer =>
      'کوپن حاصل فقط به‌صورت محلی برای نمایش نمونه اولیه ساخته می‌شود و فروشگاه واقعی نمی‌تواند آن را اعتبارسنجی کند.';

  @override
  String get insufficientBalanceMessage => 'موجودی امتیاز شما دیگر کافی نیست.';

  @override
  String get rewardRedeemError => 'دریافت پاداش انجام نشد.';

  @override
  String pointsValue(int count) {
    return '$count امتیاز';
  }

  @override
  String afterRedemptionPoints(int count) {
    return 'پس از دریافت: $count امتیاز';
  }

  @override
  String minimumPurchaseValue(String value) {
    return 'حداقل خرید: $value';
  }

  @override
  String whereToUseValue(String value) {
    return 'محل استفاده: $value';
  }

  @override
  String get terms => 'شرایط';

  @override
  String get localRewardDisclaimer =>
      'نمونه اولیه محلی: امتیازها و کوپن‌ها ارزش نقدی ندارند و فروشگاه نمی‌تواند آن‌ها را اعتبارسنجی کند.';

  @override
  String redeemForPoints(int count) {
    return 'دریافت با $count امتیاز';
  }

  @override
  String get viewClaimedReward => 'مشاهده پاداش';

  @override
  String get noClaimedRewardsDescription =>
      'چالش‌های واجد شرایط را تکمیل کنید یا با امتیازها پاداش بگیرید.';

  @override
  String noRewardsWithStatus(String status) {
    return 'پاداشی با وضعیت «$status» وجود ندارد.';
  }

  @override
  String get campaignRewardSource => 'پاداش چالش';

  @override
  String get pointsRedemptionSource => 'استفاده از امتیازها';

  @override
  String get walletEmptyDescription =>
      'افزایش امتیازها و دریافت پاداش‌ها در اینجا نمایش داده می‌شود.';

  @override
  String get onlineChannel => 'آنلاین';

  @override
  String get inStoreChannel => 'در فروشگاه‌های منتخب';

  @override
  String get onlineAndInStoreChannel => 'آنلاین و در فروشگاه‌های منتخب';

  @override
  String get dailyConfirmedSteps => 'قدم‌های تأییدشده روزانه';

  @override
  String get totalConfirmed => 'مجموع تأییدشده';

  @override
  String get dailyAverageLabel => 'میانگین روزانه';

  @override
  String get goalDays => 'روزهای رسیدن به هدف';

  @override
  String get activeDays => 'روزهای فعال';

  @override
  String confirmedStepsChartSemantics(int days, String steps) {
    return 'نمودار قدم‌های تأییدشده برای $days روز؛ در مجموع $steps قدم تأییدشده. فهرست روزانه پایین، جزئیات کامل را نشان می‌دهد.';
  }

  @override
  String dayConfirmedStepsSemantics(String date, int steps) {
    return '$date، $steps قدم تأییدشده';
  }

  @override
  String get today => 'امروز';

  @override
  String get noRecord => 'بدون سابقه';

  @override
  String get goalReached => 'هدف محقق شد';

  @override
  String get completedDay => 'روز تکمیل‌شده';

  @override
  String get campaignAvailableStatus => 'موجود';

  @override
  String get campaignUpcomingStatus => 'پیش‌رو';

  @override
  String get campaignExpiredStatus => 'منقضی‌شده';

  @override
  String get stepTargetType => 'هدف قدم';

  @override
  String get goalConsistencyType => 'تداوم هدف';

  @override
  String eligibleStepsCount(String count) {
    return '$count قدم واجد شرایط';
  }

  @override
  String goalConsistencySummary(int required, int duration) {
    return 'در $required روز از $duration روز به هدف برسید';
  }

  @override
  String campaignStarts(String date) {
    return 'شروع در $date';
  }

  @override
  String campaignEnded(String date) {
    return 'پایان در $date';
  }

  @override
  String get endsToday => 'امروز به پایان می‌رسد';

  @override
  String daysRemaining(int count) {
    return '$count روز باقی مانده';
  }

  @override
  String get viewProgress => 'مشاهده پیشرفت';

  @override
  String get completed => 'تکمیل‌شده';

  @override
  String get campaignFinished => 'چالش پایان یافته';

  @override
  String get prototypeCouponCopied => 'کوپن نمونه کپی شد.';

  @override
  String get couponMarkedUsed => 'کوپن به‌صورت محلی استفاده‌شده علامت خورد.';

  @override
  String get couponUpdateError => 'کوپن به‌روزرسانی نشد.';

  @override
  String get couponUseLocalExplanation =>
      'این فقط یک شبیه‌سازی محلی است و هیچ فروشنده‌ای این اقدام را تأیید نمی‌کند.';

  @override
  String get activityAccessRequestError =>
      'درخواست دسترسی به فعالیت انجام نشد. دوباره تلاش کنید.';

  @override
  String get setupSaveError =>
      'تنظیمات شما به‌صورت محلی ذخیره نشد. دوباره تلاش کنید.';

  @override
  String get notificationsRefreshError =>
      'اعلان‌ها تازه‌سازی نشدند. سایر داده‌های WalkApp بدون تغییر مانده‌اند.';

  @override
  String get notificationUpdatesPending =>
      'برخی به‌روزرسانی‌های اعلان‌ها در انتظار ذخیره محلی هستند.';

  @override
  String get notificationReadPending =>
      'این اعلان پس از امکان ذخیره، خوانده‌شده علامت می‌خورد.';

  @override
  String get readStatusSaveError => 'وضعیت خوانده‌شدن هنوز ذخیره نشده است.';

  @override
  String get readNotificationsClearError =>
      'اعلان‌های خوانده‌شده هنوز پاک نشده‌اند.';

  @override
  String get campaignsDescription =>
      'برای هدف‌های ارزشمند قدم بردارید و پاداش برندها را دریافت کنید.';

  @override
  String campaignStepsValue(String count) {
    return '$count قدم چالش';
  }

  @override
  String goalDaysValue(int count) {
    return '$count روز هدف';
  }

  @override
  String confirmedCampaignStepsRequirement(String count) {
    return '$count قدم تأییدشده چالش';
  }

  @override
  String separateGoalDaysRequirement(int days, String goal) {
    return '$days روز جداگانه با رسیدن به هدف ثبت‌شده $goal قدمی';
  }

  @override
  String get joinProgressExplanation =>
      'پیشرفت پس از عضویت از صفر آغاز می‌شود. فقط قدم‌های تأییدشده پس از عضویت محاسبه می‌شوند و ردیابی عادی سلامتی ادامه دارد.';

  @override
  String capturedGoalExplanation(String count) {
    return 'هدف روزانه $count قدمی شما اکنون ثبت می‌شود و برای این چالش تغییر نمی‌کند.';
  }

  @override
  String leavingCampaignPointsOutcome(int count) {
    return 'با ترک چالش، این پیشرفت دیگر فعال نیست. تکمیل چالش $count امتیاز می‌دهد.';
  }

  @override
  String get leavingCampaignRewardOutcome =>
      'با ترک چالش، این پیشرفت دیگر فعال نیست. تکمیل چالش پاداشی قابل دریافت آزاد می‌کند.';

  @override
  String startsOn(String date) {
    return 'شروع در $date';
  }

  @override
  String daysValue(int count) {
    return '$count روز';
  }

  @override
  String requiredVerifiedSteps(int count) {
    return '$count قدم تأییدشده واجد شرایط لازم است.';
  }

  @override
  String walkBetweenDates(String start, String end) {
    return 'از $start تا $end پیاده‌روی کنید.';
  }

  @override
  String requiredSeparateGoalDays(int count) {
    return '$count روز جداگانه رسیدن به هدف لازم است.';
  }

  @override
  String get healthStepsContinueExplanation =>
      'قدم‌های سلامتی شما به‌طور عادی ردیابی می‌شوند.\n\nپیشرفت چالش پس از عضویت به‌صورت جداگانه محاسبه می‌شود.';

  @override
  String get pointsAddedToRewards => 'به موجودی پاداش‌های شما افزوده شد.';

  @override
  String get pointsBeingAdded =>
      'امتیازهای شما با اطمینان در حال افزوده‌شدن هستند.';

  @override
  String get completedRewardReady => 'پاداش چالش تکمیل‌شده آماده دریافت است.';

  @override
  String get couponAvailableInRewards =>
      'کوپن نمونه شما در «پاداش‌های من» در دسترس است.';

  @override
  String joinedAndEnds(String joined, String ends) {
    return 'عضویت در $joined • پایان در $ends';
  }

  @override
  String stepProgressSemantics(int percent, int current, int target) {
    return '$percent درصد تکمیل؛ $current از $target قدم چالش';
  }

  @override
  String goalProgressSemantics(int completed, int required) {
    return '$completed روز از $required روز هدف تکمیل شده';
  }

  @override
  String get campaignProgress => 'پیشرفت چالش';

  @override
  String get campaignCompletedStatus => 'چالش تکمیل شده';

  @override
  String stepsRemainingPercent(String count, int percent) {
    return '$count قدم باقی مانده • $percent٪';
  }

  @override
  String goalDaysCompleted(int completed, int required) {
    return '$completed / $required روز هدف تکمیل شده';
  }

  @override
  String requiredDaysRemaining(int count) {
    return '$count روز لازم باقی مانده';
  }

  @override
  String capturedDailyGoal(String count) {
    return 'هدف روزانه ثبت‌شده: $count قدم';
  }

  @override
  String earnedRewardPoints(int count) {
    return '$count امتیاز پاداش دریافت کردید.';
  }

  @override
  String unlockedReward(String reward) {
    return 'پاداش $reward را آزاد کردید.';
  }

  @override
  String get trackingActiveStatus => 'ردیابی فعال است';

  @override
  String get trackingStoppedStatus => 'ردیابی متوقف است';

  @override
  String get trackingCampaignAutoUpdate =>
      'قدم‌های تأییدشده واجد شرایط، این چالش را خودکار به‌روزرسانی می‌کنند.';

  @override
  String get trackingCampaignRequirement =>
      'پیشرفت چالش فقط با ثبت قدم‌های تأییدشده واجد شرایط تغییر می‌کند.';

  @override
  String deadlineValue(String date) {
    return 'مهلت: $date.';
  }

  @override
  String rewardPreviewSentence(String reward) {
    return 'پیش‌نمایش پاداش: $reward.';
  }

  @override
  String get campaignLeftHealthContinues =>
      'از چالش خارج شدید. ردیابی سلامتی ادامه دارد.';

  @override
  String capturedGoalPreserved(String count) {
    return 'این چالش هدف ثبت‌شده $count قدمی را حتی با تغییر تنظیمات حفظ می‌کند.';
  }

  @override
  String get activeStatus => 'فعال';

  @override
  String get leftStatus => 'ترک‌شده';

  @override
  String get filterCampaigns => 'فیلتر چالش‌ها';

  @override
  String unreadNotificationSemantics(String title, String message) {
    return 'اعلان خوانده‌نشده. $title. $message';
  }

  @override
  String notificationSemantics(String title, String message) {
    return '$title. $message';
  }

  @override
  String get newLabel => 'جدید';

  @override
  String dailyStepProgressValue(int steps, int goal, int percentage) {
    return '$steps قدم از $goal قدم، $percentage درصد';
  }

  @override
  String get couponCodeDisclaimer =>
      'این کد محلی فقط برای نمایش نمونه اولیه ساخته شده است و فروشگاه واقعی نمی‌تواند آن را اعتبارسنجی کند.';

  @override
  String get rewardsLoadTryAgain => 'پاداش‌ها بارگیری نشدند. دوباره تلاش کنید.';

  @override
  String get campaignRewardClaimError =>
      'پاداش چالش دریافت نشد. دوباره تلاش کنید.';

  @override
  String get rewardSafeRedeemError =>
      'دریافت امن پاداش انجام نشد. در صورت امکان، کیف پول محلی بازیابی شد.';

  @override
  String get couponStatusUpdateError => 'وضعیت کوپن به‌روزرسانی نشد.';

  @override
  String get campaignPointsPending =>
      'امتیازهای چالش هنوز افزوده نشده‌اند. پاداش‌ها دوباره با اطمینان تلاش می‌کنند.';

  @override
  String get campaignEnrollmentError =>
      'وضعیت عضویت در چالش بارگیری نشد. دوباره تلاش کنید.';

  @override
  String get campaignJoinLocalError =>
      'عضویت محلی در چالش انجام نشد. دوباره تلاش کنید.';

  @override
  String get campaignLeaveLocalError =>
      'ترک محلی چالش انجام نشد. دوباره تلاش کنید.';

  @override
  String get campaignProgressSaveError =>
      'پیشرفت چالش ذخیره نشد. هنگام تلاش دوباره، ردیابی می‌تواند ادامه پیدا کند.';

  @override
  String get savedCampaignDeviceUnavailable =>
      'این چالش ذخیره‌شده در این دستگاه در دسترس نیست. پیشرفت محلی آن حفظ شده است.';

  @override
  String get campaignStatusUpdateError =>
      'وضعیت چالش به‌صورت محلی به‌روزرسانی نشد. دوباره تلاش کنید.';

  @override
  String get historyLoadControllerError =>
      'تاریخچه محلی پیاده‌روی بارگیری نشد. ردیابی قدم می‌تواند ادامه پیدا کند.';

  @override
  String get historySaveControllerError =>
      'تاریخچه تأییدشده امروز هنوز ذخیره نشده است. ردیابی به‌طور عادی ادامه دارد.';

  @override
  String get yesterday => 'دیروز';

  @override
  String todayAtTime(String time) {
    return 'امروز، $time';
  }

  @override
  String rewardMoveWearContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'پیشنهاد آغاز پوشاک ورزشی',
      'short': 'تخفیف برای پوشاک ورزشی روزمره منتخب.',
      'full': 'با امتیازهای خود از پوشاک ورزشی منتخب MoveWear تخفیف بگیرید.',
      'discount': '۱۰٪ تخفیف پوشاک ورزشی منتخب',
      'minimum': 'حداقل خرید ۳۵ یورو',
      'expiration': 'تا ۱۴ روز پس از دریافت استفاده شود',
      'inventory': 'اندازه‌ها و مدل‌های واجد شرایط بسته به موجودی هستند',
      'term1': 'فقط برای محصولات دارای نشان چالش معتبر است.',
      'term2': 'با پیشنهاد دیگری قابل ترکیب نیست.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String rewardGreenBiteContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'پیشنهاد غذای سالم',
      'short': 'برای یک سفارش غذای واجد شرایط تخفیف بگیرید.',
      'full':
          'با امتیازهای خود برای یک سفارش غذای واجد شرایط GreenBite تخفیف بگیرید.',
      'discount': '۲۰٪ تخفیف یک سفارش غذای واجد شرایط',
      'minimum': 'حداقل خرید ۲۵ یورو',
      'expiration': 'تا ۱۰ روز پس از دریافت استفاده شود',
      'inventory': 'برای اقلام واجد شرایط منو در دسترس است',
      'term1': 'هزینه ارسال و خدمات شامل تخفیف نیست.',
      'term2':
          'هر کاربر محلی فقط یک‌بار می‌تواند این پاداش نمونه را دریافت کند.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String rewardUrbanFitContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'تخفیف تجهیزات',
      'short': 'تخفیف ثابت برای تجهیزات ورزشی منتخب.',
      'full':
          'از این پیشنهاد نمونه برای تجهیزات واجد شرایط UrbanFit استفاده کنید.',
      'discount': '۱۵ یورو تخفیف تجهیزات ورزشی منتخب',
      'minimum': 'حداقل خرید ۷۰ یورو',
      'expiration': 'تا ۲۱ روز پس از دریافت استفاده شود',
      'inventory': 'محصولات بسته به موجودی هستند',
      'term1': 'فقط تجهیزات منتخب.',
      'term2': 'هزینه ارسال در حداقل خرید محاسبه نمی‌شود.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String rewardStepStyleContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'پیشنهاد لوازم ضروری پیاده‌روی',
      'short': 'تخفیفی با امتیاز کم برای لوازم ضروری پیاده‌روی.',
      'full':
          'با مقدار کمی امتیاز، لوازم ضروری پیاده‌روی منتخب را با تخفیف بگیرید.',
      'discount': '۱۲٪ تخفیف لوازم ضروری پیاده‌روی منتخب',
      'minimum': 'حداقل خرید ۲۰ یورو',
      'expiration': 'تا ۷ روز پس از دریافت استفاده شود',
      'inventory': 'فقط در شعبه‌های منتخب',
      'term1': 'محصولات حراجی شامل نمی‌شوند.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String rewardFreshDayContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'پیشنهاد بسته تندرستی',
      'short': 'برای یک بسته تندرستی واجد شرایط تخفیف بگیرید.',
      'full': 'پاداش نمونه با ارزش بیشتر برای یک بسته تندرستی FreshDay.',
      'discount': '۲۰ یورو تخفیف یک بسته تندرستی واجد شرایط',
      'minimum': 'حداقل خرید ۸۰ یورو',
      'expiration': 'تا ۱۴ روز پس از دریافت استفاده شود',
      'inventory': 'موجودی بسته‌های واجد شرایط محدود است',
      'term1': 'فقط برای بسته‌های دارای نشان چالش معتبر است.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String rewardActiveLifeContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'پیشنهاد جلسه تندرستی',
      'short': 'تخفیف برای یک جلسه تندرستی واجد شرایط.',
      'full': 'این پاداش نمونه هنگام به‌روزرسانی جلسه‌ها موقتاً در دسترس نیست.',
      'discount': '۲۵٪ تخفیف یک جلسه تندرستی',
      'minimum': 'بدون حداقل خرید',
      'expiration': 'تا ۱۴ روز پس از دریافت استفاده شود',
      'inventory': 'موقتاً ناموجود',
      'term1': 'رزرو قبلی لازم است.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String campaignMoveWearContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'هفته ۳۰٬۰۰۰ قدمی',
      'short': 'یک هفته فعال با هدف روشن قدم‌های تأییدشده بسازید.',
      'full':
          'در دوره هفت‌روزه چالش، ۳۰٬۰۰۰ قدم تأییدشده واجد شرایط بردارید تا تخفیف پوشاک ورزشی منتخب آزاد شود.',
      'rewardTitle': 'تخفیف پوشاک ورزشی منتخب',
      'rewardDescription': 'برای پوشاک ورزشی واجد شرایط MoveWear تخفیف بگیرید.',
      'discount': '۲۰٪ تخفیف پوشاک ورزشی منتخب',
      'minimum': 'حداقل خرید ۵۰ یورو',
      'usage': 'آنلاین و در فروشگاه‌های منتخب',
      'expiration': 'تا ۱۴ روز پس از آزادشدن استفاده شود',
      'inventory': 'اقلام واجد شرایط بسته به موجودی هستند',
      'term1': 'تخفیف فقط برای اقلام دارای نشان واجد شرایط چالش است.',
      'term2': 'با پیشنهاد تبلیغاتی دیگری قابل ترکیب نیست.',
      'term3': 'هر شرکت‌کننده فقط می‌تواند یک پاداش دریافت کند.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String campaignGreenBiteContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'پنج روز رسیدن به هدف',
      'short': 'در پنج روز چالش به هدف شخصی پیاده‌روی خود برسید.',
      'full':
          'در پنج روز از هفت روز چالش به هدف روزانه شخصی خود برسید تا تخفیف غذای سالم آزاد شود.',
      'rewardTitle': '۲۵۰ امتیاز پاداش',
      'rewardDescription': 'برای استفاده در فهرست پاداش‌ها امتیاز کسب کنید.',
      'discount': '۲۵۰ امتیاز',
      'minimum': 'حداقل خرید ۲۵ یورو',
      'usage': 'فقط سفارش آنلاین',
      'expiration': 'تا ۱۰ روز پس از آزادشدن استفاده شود',
      'inventory': 'تا زمان موجودبودن پاداش چالش',
      'term1': 'فقط برای اقلام غذایی واجد شرایط معتبر است.',
      'term2': 'هزینه ارسال و خدمات شامل نمی‌شود.',
      'term3': 'هر شرکت‌کننده فقط می‌تواند یک پاداش دریافت کند.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String campaignUrbanFitContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'چالش پیاده‌روی شهری',
      'short': 'هدف پیاده‌روی دوهفته‌ای برای تحرک روزمره.',
      'full':
          'در چهارده روز، ۶۰٬۰۰۰ قدم تأییدشده واجد شرایط بردارید تا تخفیف لوازم تمرینی منتخب آزاد شود.',
      'rewardTitle': '۴۰۰ امتیاز پاداش',
      'rewardDescription': 'برای استفاده در فهرست پاداش‌ها امتیاز کسب کنید.',
      'discount': '۴۰۰ امتیاز',
      'minimum': 'حداقل خرید ۳۵ یورو',
      'usage': 'فقط آنلاین',
      'expiration': 'تا ۲۱ روز پس از آزادشدن استفاده شود',
      'inventory': 'محصولات واجد شرایط بسته به موجودی هستند',
      'term1': 'فقط لوازمی که واجد شرایط مشخص شده‌اند شامل می‌شوند.',
      'term2': 'قابل تبدیل به وجه نقد نیست.',
      'term3': 'هر شرکت‌کننده فقط می‌تواند یک پاداش دریافت کند.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String campaignStepStyleContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'قدم‌های پیوسته',
      'short': 'در هشت روز از ده روز به هدف روزانه شخصی خود برسید.',
      'full':
          'با رسیدن به هدف روزانه شخصی در هشت روز جداگانه چالش، برنامه پیاده‌روی پیوسته بسازید.',
      'rewardTitle': 'تخفیف پوشاک پیاده‌روی',
      'rewardDescription': 'برای پوشاک پیاده‌روی منتخب StepStyle تخفیف بگیرید.',
      'discount': '۱۸٪ تخفیف پوشاک پیاده‌روی واجد شرایط',
      'minimum': 'حداقل خرید ۶۰ یورو',
      'usage': 'آنلاین و در فروشگاه‌های منتخب',
      'expiration': 'تا ۱۴ روز پس از آزادشدن استفاده شود',
      'inventory': 'اندازه‌ها و مدل‌ها بسته به موجودی هستند',
      'term1': 'محصولات حراجی شامل تخفیف نیستند.',
      'term2': 'با قیمت‌گذاری عضویت قابل ترکیب نیست.',
      'term3': 'هر شرکت‌کننده فقط می‌تواند یک پاداش دریافت کند.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String campaignFreshDayContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'پیاده‌روی شروع تازه',
      'short': 'در یک دوره پنج‌روزه، ۲۰٬۰۰۰ قدم تأییدشده جمع کنید.',
      'full':
          'در دوره چالش ۲۰٬۰۰۰ قدم تأییدشده واجد شرایط بردارید و تخفیف یک بسته تندرستی واجد شرایط را آزاد کنید.',
      'rewardTitle': 'تخفیف بسته تندرستی',
      'rewardDescription':
          'برای یک بسته تندرستی واجد شرایط FreshDay تخفیف بگیرید.',
      'discount': '۱۰ یورو تخفیف یک بسته تندرستی واجد شرایط',
      'minimum': 'حداقل خرید ۴۰ یورو',
      'usage': 'فقط آنلاین',
      'expiration': 'تا ۷ روز پس از آزادشدن استفاده شود',
      'inventory': 'محدود به بسته‌های واجد شرایط موجود',
      'term1': 'فقط برای بسته‌های دارای نشان چالش معتبر است.',
      'term2': 'هزینه ارسال در حداقل خرید محاسبه نمی‌شود.',
      'term3': 'هر شرکت‌کننده فقط می‌تواند یک پاداش دریافت کند.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String campaignActiveLifeContent(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'title': 'هفته هدف فعال',
      'short': 'چالش نمونه تکمیل‌شده با تمرکز بر هدف‌های روزانه.',
      'full':
          'در این چالش، شرکت‌کنندگان باید در چهار روز از هفت روز به هدف روزانه شخصی خود می‌رسیدند.',
      'rewardTitle': 'تخفیف جلسه تندرستی',
      'rewardDescription': 'تخفیف برای یک جلسه واجد شرایط ActiveLife.',
      'discount': '۲۵٪ تخفیف یک جلسه تندرستی واجد شرایط',
      'minimum': 'بدون حداقل خرید',
      'usage': 'در مکان‌های منتخب',
      'expiration': 'دوره دسترسی پاداش پایان یافته است',
      'inventory': 'تابع زمان‌های نوبت موجود',
      'term1': 'فقط برای جلسه‌های منتخب معتبر بود.',
      'term2': 'رزرو قبلی لازم بود.',
      'term3': 'دوره چالش و پاداش آن پایان یافته است.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String rewardRedeemedTransaction(String brand, String reward) {
    return 'دریافت $reward از $brand';
  }

  @override
  String rewardRedemptionRestoredTransaction(String brand) {
    return 'بازگرداندن دریافت ناموفق از $brand';
  }

  @override
  String campaignCompletedTransaction(String campaign) {
    return 'چالش $campaign تکمیل شد';
  }

  @override
  String get prototypeRewardTerms => 'شرایط پاداش نمونه اعمال می‌شود.';
}
