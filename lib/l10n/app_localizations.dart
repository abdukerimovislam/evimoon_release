import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EviMoon'**
  String get appTitle;

  /// No description provided for @tabCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get tabCycle;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @tabInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get tabInsights;

  /// No description provided for @tabLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get tabLearn;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @phaseMenstruation.
  ///
  /// In en, this message translates to:
  /// **'Menstruation'**
  String get phaseMenstruation;

  /// No description provided for @phaseFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular Phase'**
  String get phaseFollicular;

  /// No description provided for @phaseOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get phaseOvulation;

  /// No description provided for @phaseLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal Phase'**
  String get phaseLuteal;

  /// No description provided for @dayOfCycle.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dayOfCycle(Object day);

  /// No description provided for @editPeriod.
  ///
  /// In en, this message translates to:
  /// **'Edit Period'**
  String get editPeriod;

  /// No description provided for @logSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Log Symptoms'**
  String get logSymptoms;

  /// No description provided for @predictionText.
  ///
  /// In en, this message translates to:
  /// **'Period in {days} days'**
  String predictionText(Object days);

  /// No description provided for @chanceOfPregnancy.
  ///
  /// In en, this message translates to:
  /// **'High chance of getting pregnant'**
  String get chanceOfPregnancy;

  /// No description provided for @lowChance.
  ///
  /// In en, this message translates to:
  /// **'Low chance of getting pregnant'**
  String get lowChance;

  /// No description provided for @wellnessHeader.
  ///
  /// In en, this message translates to:
  /// **'Wellness & Mood'**
  String get wellnessHeader;

  /// No description provided for @btnCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-in'**
  String get btnCheckIn;

  /// No description provided for @symptomHeader.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get symptomHeader;

  /// No description provided for @symptomSubHeader.
  ///
  /// In en, this message translates to:
  /// **'Log your symptoms for better insights.'**
  String get symptomSubHeader;

  /// No description provided for @catFlow.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get catFlow;

  /// No description provided for @catPain.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get catPain;

  /// No description provided for @catMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get catMood;

  /// No description provided for @catSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get catSleep;

  /// No description provided for @flowLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get flowLight;

  /// No description provided for @flowMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get flowMedium;

  /// No description provided for @flowHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get flowHeavy;

  /// No description provided for @painNone.
  ///
  /// In en, this message translates to:
  /// **'No Pain'**
  String get painNone;

  /// No description provided for @painCramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get painCramps;

  /// No description provided for @painHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get painHeadache;

  /// No description provided for @painBack.
  ///
  /// In en, this message translates to:
  /// **'Back Pain'**
  String get painBack;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodEnergetic.
  ///
  /// In en, this message translates to:
  /// **'Energetic'**
  String get moodEnergetic;

  /// No description provided for @moodIrritated.
  ///
  /// In en, this message translates to:
  /// **'Irritated'**
  String get moodIrritated;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @legendPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get legendPeriod;

  /// No description provided for @legendFertile.
  ///
  /// In en, this message translates to:
  /// **'Fertile'**
  String get legendFertile;

  /// No description provided for @legendOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get legendOvulation;

  /// No description provided for @calendarHeader.
  ///
  /// In en, this message translates to:
  /// **'Your History'**
  String get calendarHeader;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trends & Insights'**
  String get insightsTitle;

  /// No description provided for @chartCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Cycle Length'**
  String get chartCycleLength;

  /// No description provided for @chartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get chartSubtitle;

  /// No description provided for @insightTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Tip of the Day'**
  String get insightTipTitle;

  /// No description provided for @insightTipBody.
  ///
  /// In en, this message translates to:
  /// **'Energy levels drop during the luteal phase. It\'s a great time for yoga and sleeping in.'**
  String get insightTipBody;

  /// No description provided for @topSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Top Symptoms'**
  String get topSymptoms;

  /// No description provided for @patternDetected.
  ///
  /// In en, this message translates to:
  /// **'Pattern Detected'**
  String get patternDetected;

  /// No description provided for @patternBody.
  ///
  /// In en, this message translates to:
  /// **'You frequently log headaches before your period. Try hydrating more 2 days prior.'**
  String get patternBody;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileTitle;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @sectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get sectionSecurity;

  /// No description provided for @lblLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get lblLanguage;

  /// No description provided for @lblNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get lblNotifications;

  /// No description provided for @lblBiometrics.
  ///
  /// In en, this message translates to:
  /// **'FaceID / TouchID'**
  String get lblBiometrics;

  /// No description provided for @lblExport.
  ///
  /// In en, this message translates to:
  /// **'Export Data (PDF/CSV)'**
  String get lblExport;

  /// No description provided for @lblDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get lblDeleteAccount;

  /// No description provided for @descDelete.
  ///
  /// In en, this message translates to:
  /// **'This will permanently erase all your logs from this device.'**
  String get descDelete;

  /// No description provided for @alertDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get alertDeleteTitle;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// No description provided for @btnStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get btnStart;

  /// No description provided for @greetMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetMorning;

  /// No description provided for @greetAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetAfternoon;

  /// No description provided for @greetEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetEvening;

  /// No description provided for @phaseStatusMenstruation.
  ///
  /// In en, this message translates to:
  /// **'Time to rest & recharge'**
  String get phaseStatusMenstruation;

  /// No description provided for @phaseStatusFollicular.
  ///
  /// In en, this message translates to:
  /// **'Energy is rising'**
  String get phaseStatusFollicular;

  /// No description provided for @phaseStatusOvulation.
  ///
  /// In en, this message translates to:
  /// **'You are glowing today'**
  String get phaseStatusOvulation;

  /// No description provided for @phaseStatusLuteal.
  ///
  /// In en, this message translates to:
  /// **'Be gentle with yourself'**
  String get phaseStatusLuteal;

  /// No description provided for @notifPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Update'**
  String get notifPeriodTitle;

  /// No description provided for @notifPeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Your period is likely to start in 2 days. Get ready!'**
  String get notifPeriodBody;

  /// No description provided for @notifOvulationTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertility Window'**
  String get notifOvulationTitle;

  /// No description provided for @notifOvulationBody.
  ///
  /// In en, this message translates to:
  /// **'High chance of fertility today. You are glowing! 🌸'**
  String get notifOvulationBody;

  /// No description provided for @phaseLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get phaseLate;

  /// No description provided for @sectionCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Settings'**
  String get sectionCycle;

  /// No description provided for @lblCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Cycle Length'**
  String get lblCycleLength;

  /// No description provided for @lblPeriodLength.
  ///
  /// In en, this message translates to:
  /// **'Period Length'**
  String get lblPeriodLength;

  /// No description provided for @authLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'EviMoon Locked'**
  String get authLockedTitle;

  /// No description provided for @authUnlockBtn.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get authUnlockBtn;

  /// No description provided for @authReason.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to access EviMoon'**
  String get authReason;

  /// No description provided for @authNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not available on device'**
  String get authNotAvailable;

  /// No description provided for @pdfReportTitle.
  ///
  /// In en, this message translates to:
  /// **'EviMoon Health Report'**
  String get pdfReportTitle;

  /// No description provided for @pdfCycleHistory.
  ///
  /// In en, this message translates to:
  /// **'Cycle History Summary'**
  String get pdfCycleHistory;

  /// No description provided for @pdfHeaderStart.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get pdfHeaderStart;

  /// No description provided for @pdfHeaderEnd.
  ///
  /// In en, this message translates to:
  /// **'Predicted End'**
  String get pdfHeaderEnd;

  /// No description provided for @pdfHeaderLength.
  ///
  /// In en, this message translates to:
  /// **'Length (Days)'**
  String get pdfHeaderLength;

  /// No description provided for @pdfCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get pdfCurrent;

  /// No description provided for @pdfGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get pdfGenerated;

  /// No description provided for @pdfPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get pdfPage;

  /// No description provided for @dayTitle.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayTitle;

  /// No description provided for @insightMenstruationTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest & Reset'**
  String get insightMenstruationTitle;

  /// No description provided for @insightMenstruationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep warm, drink tea, skip heavy workouts.'**
  String get insightMenstruationSubtitle;

  /// No description provided for @insightFollicularTitle.
  ///
  /// In en, this message translates to:
  /// **'Creative Spark'**
  String get insightFollicularTitle;

  /// No description provided for @insightFollicularSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Energy is rising! Brain function is at peak.'**
  String get insightFollicularSubtitle;

  /// No description provided for @insightOvulationTitle.
  ///
  /// In en, this message translates to:
  /// **'Super Power'**
  String get insightOvulationTitle;

  /// No description provided for @insightOvulationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Magnetic energy. High libido & confidence.'**
  String get insightOvulationSubtitle;

  /// No description provided for @insightLutealTitle.
  ///
  /// In en, this message translates to:
  /// **'Inner Focus'**
  String get insightLutealTitle;

  /// No description provided for @insightLutealSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calm or irritable. Focus inward.'**
  String get insightLutealSubtitle;

  /// No description provided for @insightLateTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Calm'**
  String get insightLateTitle;

  /// No description provided for @insightLateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce stress and maintain healthy diet.'**
  String get insightLateSubtitle;

  /// No description provided for @lblEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get lblEnergy;

  /// No description provided for @lblMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get lblMood;

  /// No description provided for @tapToClose.
  ///
  /// In en, this message translates to:
  /// **'Tap to close'**
  String get tapToClose;

  /// No description provided for @btnPeriodStart.
  ///
  /// In en, this message translates to:
  /// **'STARTED'**
  String get btnPeriodStart;

  /// No description provided for @btnPeriodEnd.
  ///
  /// In en, this message translates to:
  /// **'ENDED'**
  String get btnPeriodEnd;

  /// No description provided for @dialogStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start New Cycle?'**
  String get dialogStartTitle;

  /// No description provided for @dialogStartBody.
  ///
  /// In en, this message translates to:
  /// **'Today will be marked as Day 1 of your period.'**
  String get dialogStartBody;

  /// No description provided for @dialogEndTitle.
  ///
  /// In en, this message translates to:
  /// **'End Period?'**
  String get dialogEndTitle;

  /// No description provided for @dialogEndBody.
  ///
  /// In en, this message translates to:
  /// **'Your cycle phase will switch to follicular.'**
  String get dialogEndBody;

  /// No description provided for @btnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btnConfirm;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @logFlow.
  ///
  /// In en, this message translates to:
  /// **'Flow Intensity'**
  String get logFlow;

  /// No description provided for @logPain.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get logPain;

  /// No description provided for @logMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get logMood;

  /// No description provided for @logSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get logSleep;

  /// No description provided for @logNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get logNotes;

  /// No description provided for @insightPhasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Phases'**
  String get insightPhasesTitle;

  /// No description provided for @insightPhasesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Typical duration breakdown'**
  String get insightPhasesSubtitle;

  /// No description provided for @insightMoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood by Phase'**
  String get insightMoodTitle;

  /// No description provided for @insightMoodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Average mood intensity'**
  String get insightMoodSubtitle;

  /// No description provided for @insightAvgCycle.
  ///
  /// In en, this message translates to:
  /// **'Average Cycle Length'**
  String get insightAvgCycle;

  /// No description provided for @insightAvgPeriod.
  ///
  /// In en, this message translates to:
  /// **'Average Period Length'**
  String get insightAvgPeriod;

  /// No description provided for @phaseShortMens.
  ///
  /// In en, this message translates to:
  /// **'MENS'**
  String get phaseShortMens;

  /// No description provided for @phaseShortFoll.
  ///
  /// In en, this message translates to:
  /// **'FOLL'**
  String get phaseShortFoll;

  /// No description provided for @phaseShortOvul.
  ///
  /// In en, this message translates to:
  /// **'OVUL'**
  String get phaseShortOvul;

  /// No description provided for @phaseShortLut.
  ///
  /// In en, this message translates to:
  /// **'LUT'**
  String get phaseShortLut;

  /// No description provided for @unitDaysShort.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get unitDaysShort;

  /// No description provided for @insightBodyBalance.
  ///
  /// In en, this message translates to:
  /// **'Body Balance'**
  String get insightBodyBalance;

  /// No description provided for @insightBodyBalanceSub.
  ///
  /// In en, this message translates to:
  /// **'Follicular (Purple) vs Luteal (Orange)'**
  String get insightBodyBalanceSub;

  /// No description provided for @insightMoodFlow.
  ///
  /// In en, this message translates to:
  /// **'Mood Flow'**
  String get insightMoodFlow;

  /// No description provided for @insightMoodFlowSub.
  ///
  /// In en, this message translates to:
  /// **'Recent 30 days trend'**
  String get insightMoodFlowSub;

  /// No description provided for @paramEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get paramEnergy;

  /// No description provided for @paramLibido.
  ///
  /// In en, this message translates to:
  /// **'Libido'**
  String get paramLibido;

  /// No description provided for @paramSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get paramSkin;

  /// No description provided for @predTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Forecast'**
  String get predTitle;

  /// No description provided for @predSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on your cycle & sleep patterns'**
  String get predSubtitle;

  /// No description provided for @recHighEnergy.
  ///
  /// In en, this message translates to:
  /// **'Great day for heavy tasks or workouts!'**
  String get recHighEnergy;

  /// No description provided for @recLowEnergy.
  ///
  /// In en, this message translates to:
  /// **'Take it easy. Prioritize rest today.'**
  String get recLowEnergy;

  /// No description provided for @recNormalEnergy.
  ///
  /// In en, this message translates to:
  /// **'Maintain a steady pace.'**
  String get recNormalEnergy;

  /// No description provided for @btnWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get btnWrong;

  /// No description provided for @msgFeedback.
  ///
  /// In en, this message translates to:
  /// **'Is {metric} really {status} today?'**
  String msgFeedback(Object metric, Object status);

  /// No description provided for @paramFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get paramFocus;

  /// No description provided for @statusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get statusLow;

  /// No description provided for @statusHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get statusHigh;

  /// No description provided for @statusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get statusNormal;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackTitle;

  /// No description provided for @feedbackQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is your {metric} really {status} today?'**
  String feedbackQuestion(Object metric, Object status);

  /// No description provided for @btnYesCorrect.
  ///
  /// In en, this message translates to:
  /// **'Yes, correct'**
  String get btnYesCorrect;

  /// No description provided for @btnNoWrong.
  ///
  /// In en, this message translates to:
  /// **'No, it\'s wrong'**
  String get btnNoWrong;

  /// No description provided for @cocActivePhase.
  ///
  /// In en, this message translates to:
  /// **'Active Pill Phase'**
  String get cocActivePhase;

  /// No description provided for @cocBreakPhase.
  ///
  /// In en, this message translates to:
  /// **'Break Week'**
  String get cocBreakPhase;

  /// No description provided for @cocPredictionActive.
  ///
  /// In en, this message translates to:
  /// **'{days} active pills remaining'**
  String cocPredictionActive(Object days);

  /// No description provided for @cocPredictionBreak.
  ///
  /// In en, this message translates to:
  /// **'Start new pack in {days} days'**
  String cocPredictionBreak(Object days);

  /// No description provided for @btnStartNewPack.
  ///
  /// In en, this message translates to:
  /// **'Start New Pack'**
  String get btnStartNewPack;

  /// No description provided for @btnRestartPack.
  ///
  /// In en, this message translates to:
  /// **'Restart Pack'**
  String get btnRestartPack;

  /// No description provided for @dialogStartPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Start New Pack?'**
  String get dialogStartPackTitle;

  /// No description provided for @dialogStartPackBody.
  ///
  /// In en, this message translates to:
  /// **'This will reset your cycle to Day 1. Use this when you open a fresh pack.'**
  String get dialogStartPackBody;

  /// No description provided for @pillTaken.
  ///
  /// In en, this message translates to:
  /// **'Pill Taken'**
  String get pillTaken;

  /// No description provided for @pillTake.
  ///
  /// In en, this message translates to:
  /// **'Take Your Pill'**
  String get pillTake;

  /// No description provided for @pillScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {time}'**
  String pillScheduled(String time);

  /// No description provided for @blisterMyPack.
  ///
  /// In en, this message translates to:
  /// **'My Pack'**
  String get blisterMyPack;

  /// No description provided for @blisterDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day} / {total}'**
  String blisterDay(Object day, Object total);

  /// No description provided for @blisterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Day {day} (Overdue)'**
  String blisterOverdue(Object day);

  /// No description provided for @blister21.
  ///
  /// In en, this message translates to:
  /// **'21-Day Pack'**
  String get blister21;

  /// No description provided for @blister28.
  ///
  /// In en, this message translates to:
  /// **'28-Day Pack'**
  String get blister28;

  /// No description provided for @legendTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get legendTaken;

  /// No description provided for @legendActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get legendActive;

  /// No description provided for @legendPlacebo.
  ///
  /// In en, this message translates to:
  /// **'Placebo'**
  String get legendPlacebo;

  /// No description provided for @legendBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get legendBreak;

  /// No description provided for @insightCOCActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get insightCOCActiveTitle;

  /// No description provided for @insightCOCActiveBody.
  ///
  /// In en, this message translates to:
  /// **'Active pill phase. Make sure to take your pill at the same time daily.'**
  String get insightCOCActiveBody;

  /// No description provided for @insightCOCBreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Bleed'**
  String get insightCOCBreakTitle;

  /// No description provided for @insightCOCBreakBody.
  ///
  /// In en, this message translates to:
  /// **'This is the break week. Bleeding is expected due to hormone drop.'**
  String get insightCOCBreakBody;

  /// No description provided for @settingsContraception.
  ///
  /// In en, this message translates to:
  /// **'Contraception'**
  String get settingsContraception;

  /// No description provided for @settingsTrackPill.
  ///
  /// In en, this message translates to:
  /// **'Track Contraceptive Pill'**
  String get settingsTrackPill;

  /// No description provided for @settingsPackType.
  ///
  /// In en, this message translates to:
  /// **'Pack Type'**
  String get settingsPackType;

  /// No description provided for @settingsPills.
  ///
  /// In en, this message translates to:
  /// **'{count} Pills'**
  String settingsPills(Object count);

  /// No description provided for @settingsReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get settingsReminder;

  /// No description provided for @settingsPackSettings.
  ///
  /// In en, this message translates to:
  /// **'Pack Settings'**
  String get settingsPackSettings;

  /// No description provided for @settingsPlaceboCount.
  ///
  /// In en, this message translates to:
  /// **'Placebo Days'**
  String get settingsPlaceboCount;

  /// No description provided for @settingsBreakDuration.
  ///
  /// In en, this message translates to:
  /// **'Break Duration'**
  String get settingsBreakDuration;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifs.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifs;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data & Security'**
  String get settingsData;

  /// No description provided for @settingsBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get settingsBiometrics;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Download PDF Report'**
  String get settingsExport;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get settingsReset;

  /// No description provided for @dialogResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Everything?'**
  String get dialogResetTitle;

  /// No description provided for @dialogResetBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete all your data permanently. This action cannot be undone.'**
  String get dialogResetBody;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// No description provided for @logSymptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Symptoms'**
  String get logSymptomsTitle;

  /// No description provided for @msgSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get msgSaved;

  /// No description provided for @logSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin Condition'**
  String get logSkin;

  /// No description provided for @logLibido.
  ///
  /// In en, this message translates to:
  /// **'Libido'**
  String get logLibido;

  /// No description provided for @symptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get symptomNausea;

  /// No description provided for @symptomBloating.
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get symptomBloating;

  /// No description provided for @lblNoData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get lblNoData;

  /// No description provided for @lblNoSymptoms.
  ///
  /// In en, this message translates to:
  /// **'No symptoms logged.'**
  String get lblNoSymptoms;

  /// No description provided for @notifPillTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to take your pill!'**
  String get notifPillTitle;

  /// No description provided for @notifPillBody.
  ///
  /// In en, this message translates to:
  /// **'Stay protected and track your cycle.'**
  String get notifPillBody;

  /// No description provided for @logVitals.
  ///
  /// In en, this message translates to:
  /// **'Vitals'**
  String get logVitals;

  /// No description provided for @lblTemp.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get lblTemp;

  /// No description provided for @lblWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get lblWeight;

  /// No description provided for @lblLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle Factors'**
  String get lblLifestyle;

  /// No description provided for @factorStress.
  ///
  /// In en, this message translates to:
  /// **'High Stress'**
  String get factorStress;

  /// No description provided for @factorAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get factorAlcohol;

  /// No description provided for @factorTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get factorTravel;

  /// No description provided for @factorSport.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get factorSport;

  /// No description provided for @hintNotes.
  ///
  /// In en, this message translates to:
  /// **'Add a note...'**
  String get hintNotes;

  /// No description provided for @symptomAcne.
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get symptomAcne;

  /// No description provided for @lblLifestyleHeader.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get lblLifestyleHeader;

  /// No description provided for @predInsightHormones.
  ///
  /// In en, this message translates to:
  /// **'Hormones: {hormone} is rising.'**
  String predInsightHormones(Object hormone);

  /// No description provided for @predMismatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Feeling different?'**
  String get predMismatchTitle;

  /// No description provided for @predMismatchBody.
  ///
  /// In en, this message translates to:
  /// **'Tap an icon to adjust the advice.'**
  String get predMismatchBody;

  /// No description provided for @btnAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get btnAdjust;

  /// No description provided for @stateLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get stateLow;

  /// No description provided for @stateMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get stateMedium;

  /// No description provided for @stateHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get stateHigh;

  /// No description provided for @tipLowEnergy.
  ///
  /// In en, this message translates to:
  /// **'Rest day valid. Try gentle yoga or a nap.'**
  String get tipLowEnergy;

  /// No description provided for @tipHighEnergy.
  ///
  /// In en, this message translates to:
  /// **'Great time for cardio or tackling complex tasks!'**
  String get tipHighEnergy;

  /// No description provided for @tipLowMood.
  ///
  /// In en, this message translates to:
  /// **'Be gentle with yourself. Chocolate helps.'**
  String get tipLowMood;

  /// No description provided for @tipHighMood.
  ///
  /// In en, this message translates to:
  /// **'Share your vibes! Socialize or create something.'**
  String get tipHighMood;

  /// No description provided for @tipLowFocus.
  ///
  /// In en, this message translates to:
  /// **'Avoid multitasking. Pick one small goal.'**
  String get tipLowFocus;

  /// No description provided for @tipHighFocus.
  ///
  /// In en, this message translates to:
  /// **'Deep work mode. Tackle the hardest project.'**
  String get tipHighFocus;

  /// No description provided for @hormoneEstrogen.
  ///
  /// In en, this message translates to:
  /// **'Estrogen'**
  String get hormoneEstrogen;

  /// No description provided for @hormoneProgesterone.
  ///
  /// In en, this message translates to:
  /// **'Progesterone'**
  String get hormoneProgesterone;

  /// No description provided for @hormoneReset.
  ///
  /// In en, this message translates to:
  /// **'Hormonal Reset'**
  String get hormoneReset;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to EviMoon'**
  String get onboardTitle1;

  /// No description provided for @onboardBody1.
  ///
  /// In en, this message translates to:
  /// **'Track your cycle, understand your body, and live in harmony with your natural rhythm.'**
  String get onboardBody1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Last Period Start'**
  String get onboardTitle2;

  /// No description provided for @onboardBody2.
  ///
  /// In en, this message translates to:
  /// **'Please select the first day of your last menstruation to help us calibrate.'**
  String get onboardBody2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Cycle Length'**
  String get onboardTitle3;

  /// No description provided for @onboardBody3.
  ///
  /// In en, this message translates to:
  /// **'How many days usually pass between periods? The average is 28 days.'**
  String get onboardBody3;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysUnit;

  /// No description provided for @insightVitals.
  ///
  /// In en, this message translates to:
  /// **'Body Vitals'**
  String get insightVitals;

  /// No description provided for @hadSex.
  ///
  /// In en, this message translates to:
  /// **'Had Sex'**
  String get hadSex;

  /// No description provided for @protectedSex.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get protectedSex;

  /// No description provided for @lblIntimacy.
  ///
  /// In en, this message translates to:
  /// **'Intimacy'**
  String get lblIntimacy;

  /// No description provided for @lblWellness.
  ///
  /// In en, this message translates to:
  /// **'Wellness'**
  String get lblWellness;

  /// No description provided for @insightVitalsSub.
  ///
  /// In en, this message translates to:
  /// **'Temperature & Weight tracking'**
  String get insightVitalsSub;

  /// No description provided for @cocDayInfo.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of 28'**
  String cocDayInfo(int day);

  /// No description provided for @dialogPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Pack Type'**
  String get dialogPackTitle;

  /// No description provided for @dialogPackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the pill pack format you use.'**
  String get dialogPackSubtitle;

  /// No description provided for @pack21Title.
  ///
  /// In en, this message translates to:
  /// **'21 Pills'**
  String get pack21Title;

  /// No description provided for @pack21Subtitle.
  ///
  /// In en, this message translates to:
  /// **'21 Active + 7 Days Break'**
  String get pack21Subtitle;

  /// No description provided for @pack28Title.
  ///
  /// In en, this message translates to:
  /// **'28 Pills'**
  String get pack28Title;

  /// No description provided for @pack28Subtitle.
  ///
  /// In en, this message translates to:
  /// **'21 Active + 7 Placebo'**
  String get pack28Subtitle;

  /// No description provided for @btnSaveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get btnSaveSettings;

  /// No description provided for @dialogCOCStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Contraception?'**
  String get dialogCOCStartTitle;

  /// No description provided for @dialogCOCStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to start tracking your pill pack.'**
  String get dialogCOCStartSubtitle;

  /// No description provided for @optionFreshPack.
  ///
  /// In en, this message translates to:
  /// **'Start Fresh Pack'**
  String get optionFreshPack;

  /// No description provided for @optionFreshPackSub.
  ///
  /// In en, this message translates to:
  /// **'I\'m starting a new pack today'**
  String get optionFreshPackSub;

  /// No description provided for @optionContinuePack.
  ///
  /// In en, this message translates to:
  /// **'Continue Current'**
  String get optionContinuePack;

  /// No description provided for @optionContinuePackSub.
  ///
  /// In en, this message translates to:
  /// **'I\'m in the middle of a pack'**
  String get optionContinuePackSub;

  /// No description provided for @labelOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get labelOr;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get dialogResetConfirm;

  /// No description provided for @insightsOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get insightsOverview;

  /// No description provided for @insightsHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get insightsHealth;

  /// No description provided for @insightsPatterns.
  ///
  /// In en, this message translates to:
  /// **'Patterns'**
  String get insightsPatterns;

  /// No description provided for @insightsVitals.
  ///
  /// In en, this message translates to:
  /// **'Body Vitals'**
  String get insightsVitals;

  /// No description provided for @insightsVitalsSub.
  ///
  /// In en, this message translates to:
  /// **'Temperature & Weight tracking'**
  String get insightsVitalsSub;

  /// No description provided for @currentCycle.
  ///
  /// In en, this message translates to:
  /// **'Current cycle'**
  String get currentCycle;

  /// No description provided for @regularity.
  ///
  /// In en, this message translates to:
  /// **'Regularity'**
  String get regularity;

  /// No description provided for @ovulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get ovulation;

  /// No description provided for @averageMood.
  ///
  /// In en, this message translates to:
  /// **'Average mood'**
  String get averageMood;

  /// No description provided for @sleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Sleep quality'**
  String get sleepQuality;

  /// No description provided for @nextPhases.
  ///
  /// In en, this message translates to:
  /// **'Next phases'**
  String get nextPhases;

  /// No description provided for @prediction.
  ///
  /// In en, this message translates to:
  /// **'Prediction'**
  String get prediction;

  /// No description provided for @sleepAndEnergy.
  ///
  /// In en, this message translates to:
  /// **'Sleep and energy by phase'**
  String get sleepAndEnergy;

  /// No description provided for @bodyTemperature.
  ///
  /// In en, this message translates to:
  /// **'Body temperature'**
  String get bodyTemperature;

  /// No description provided for @basalTemperature.
  ///
  /// In en, this message translates to:
  /// **'Basal temperature for 14 days'**
  String get basalTemperature;

  /// No description provided for @positiveTrend.
  ///
  /// In en, this message translates to:
  /// **'Positive trend'**
  String get positiveTrend;

  /// No description provided for @recommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get recommendation;

  /// No description provided for @cycleRegularity.
  ///
  /// In en, this message translates to:
  /// **'Cycle regularity'**
  String get cycleRegularity;

  /// No description provided for @fertilityWindow.
  ///
  /// In en, this message translates to:
  /// **'Fertility window'**
  String get fertilityWindow;

  /// No description provided for @symptomPatterns.
  ///
  /// In en, this message translates to:
  /// **'Symptom patterns'**
  String get symptomPatterns;

  /// No description provided for @correlationAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Correlation analysis'**
  String get correlationAnalysis;

  /// No description provided for @historicalComparison.
  ///
  /// In en, this message translates to:
  /// **'Historical comparison'**
  String get historicalComparison;

  /// No description provided for @dailyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Daily metrics'**
  String get dailyMetrics;

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// No description provided for @phaseComparison.
  ///
  /// In en, this message translates to:
  /// **'Phase comparison'**
  String get phaseComparison;

  /// No description provided for @energyEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Energy efficiency'**
  String get energyEfficiency;

  /// No description provided for @sleepEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Sleep efficiency'**
  String get sleepEfficiency;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @improvement.
  ///
  /// In en, this message translates to:
  /// **'Improvement'**
  String get improvement;

  /// No description provided for @insightsNoData.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get insightsNoData;

  /// No description provided for @insightsNoDataSub.
  ///
  /// In en, this message translates to:
  /// **'Add daily measurements to see insights'**
  String get insightsNoDataSub;

  /// No description provided for @insightsPredictedOvulation.
  ///
  /// In en, this message translates to:
  /// **'Predicted ovulation in {days} days'**
  String insightsPredictedOvulation(Object days);

  /// No description provided for @insightsPredictedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Predicted period in {days} days'**
  String insightsPredictedPeriod(Object days);

  /// No description provided for @insightsPredictedFertile.
  ///
  /// In en, this message translates to:
  /// **'Fertile window in {days} days'**
  String insightsPredictedFertile(Object days);

  /// No description provided for @insightsCycleDay.
  ///
  /// In en, this message translates to:
  /// **'Cycle day {day}'**
  String insightsCycleDay(Object day);

  /// No description provided for @insightsAvgValues.
  ///
  /// In en, this message translates to:
  /// **'Average values over last 3 cycles'**
  String get insightsAvgValues;

  /// No description provided for @insightsPersonalizedTips.
  ///
  /// In en, this message translates to:
  /// **'Personalized tips for you'**
  String get insightsPersonalizedTips;

  /// No description provided for @insightsBasedOnPatterns.
  ///
  /// In en, this message translates to:
  /// **'Based on your patterns'**
  String get insightsBasedOnPatterns;

  /// No description provided for @insightsSeeMore.
  ///
  /// In en, this message translates to:
  /// **'See more insights'**
  String get insightsSeeMore;

  /// No description provided for @insightsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get insightsExportData;

  /// No description provided for @insightsShareInsights.
  ///
  /// In en, this message translates to:
  /// **'Share insights'**
  String get insightsShareInsights;

  /// No description provided for @insightsSetReminder.
  ///
  /// In en, this message translates to:
  /// **'Set reminder'**
  String get insightsSetReminder;

  /// No description provided for @insightsCompareCycles.
  ///
  /// In en, this message translates to:
  /// **'Compare cycles'**
  String get insightsCompareCycles;

  /// No description provided for @insightsGenerateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate report'**
  String get insightsGenerateReport;

  /// No description provided for @insightTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get insightTitle;

  /// No description provided for @insightRadarTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Balance'**
  String get insightRadarTitle;

  /// No description provided for @insightRadarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follicular (Blue) vs Luteal (Orange)'**
  String get insightRadarSubtitle;

  /// No description provided for @insightSymptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Symptoms'**
  String get insightSymptomsTitle;

  /// No description provided for @insightSymptomsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Most frequent occurrences'**
  String get insightSymptomsSubtitle;

  /// No description provided for @radarEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get radarEnergy;

  /// No description provided for @radarMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get radarMood;

  /// No description provided for @radarSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get radarSleep;

  /// No description provided for @radarSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get radarSkin;

  /// No description provided for @radarLibido.
  ///
  /// In en, this message translates to:
  /// **'Libido'**
  String get radarLibido;

  /// No description provided for @phaseFollicularLabel.
  ///
  /// In en, this message translates to:
  /// **'Follicular'**
  String get phaseFollicularLabel;

  /// No description provided for @phaseLutealLabel.
  ///
  /// In en, this message translates to:
  /// **'Luteal'**
  String get phaseLutealLabel;

  /// No description provided for @lblOccurrences.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String lblOccurrences(int count);

  /// No description provided for @lblNoDataChart.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet. Keep logging!'**
  String get lblNoDataChart;

  /// No description provided for @insightCorrelationTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Patterns'**
  String get insightCorrelationTitle;

  /// No description provided for @insightCorrelationSub.
  ///
  /// In en, this message translates to:
  /// **'How your lifestyle affects your body'**
  String get insightCorrelationSub;

  /// No description provided for @insightPatternText.
  ///
  /// In en, this message translates to:
  /// **'When you log {factor}, you experience {symptom} in {percent}% of cases.'**
  String insightPatternText(String factor, String symptom, int percent);

  /// No description provided for @insightCycleDNA.
  ///
  /// In en, this message translates to:
  /// **'Your Cycle DNA'**
  String get insightCycleDNA;

  /// No description provided for @insightDNASub.
  ///
  /// In en, this message translates to:
  /// **'Follicular vs Luteal Persona'**
  String get insightDNASub;

  /// No description provided for @lblFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular'**
  String get lblFollicular;

  /// No description provided for @lblLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal'**
  String get lblLuteal;

  /// No description provided for @dialogPeriodStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Period Started?'**
  String get dialogPeriodStartTitle;

  /// No description provided for @dialogPeriodStartBody.
  ///
  /// In en, this message translates to:
  /// **'Did your period start today or did you forget to log it?'**
  String get dialogPeriodStartBody;

  /// No description provided for @btnToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get btnToday;

  /// No description provided for @btnAnotherDay.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get btnAnotherDay;

  /// No description provided for @splashSlogan.
  ///
  /// In en, this message translates to:
  /// **'Your cycle. Your rhythm.'**
  String get splashSlogan;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support & Feedback'**
  String get settingsSupport;

  /// No description provided for @emailSubject.
  ///
  /// In en, this message translates to:
  /// **'EviMoon Feedback'**
  String get emailSubject;

  /// No description provided for @emailBody.
  ///
  /// In en, this message translates to:
  /// **'Hello EviMoon Team,\n\nI have a question/suggestion regarding the app on'**
  String get emailBody;

  /// No description provided for @insightProstaglandinsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prostaglandins at work'**
  String get insightProstaglandinsTitle;

  /// No description provided for @insightProstaglandinsBody.
  ///
  /// In en, this message translates to:
  /// **'Uterine contractions help shed the lining. Warmth and magnesium usually help.'**
  String get insightProstaglandinsBody;

  /// No description provided for @insightWinterPhaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest & Restore'**
  String get insightWinterPhaseTitle;

  /// No description provided for @insightWinterPhaseBody.
  ///
  /// In en, this message translates to:
  /// **'Hormones are at their lowest. It\'s okay to slow down and recharge.'**
  String get insightWinterPhaseBody;

  /// No description provided for @insightEstrogenTitle.
  ///
  /// In en, this message translates to:
  /// **'Estrogen Rising'**
  String get insightEstrogenTitle;

  /// No description provided for @insightEstrogenBody.
  ///
  /// In en, this message translates to:
  /// **'Estrogen boosts serotonin. Great time for creative tasks and planning!'**
  String get insightEstrogenBody;

  /// No description provided for @insightMittelschmerzTitle.
  ///
  /// In en, this message translates to:
  /// **'Mittelschmerz'**
  String get insightMittelschmerzTitle;

  /// No description provided for @insightMittelschmerzBody.
  ///
  /// In en, this message translates to:
  /// **'You might be feeling the exact moment of ovulation. It is usually brief.'**
  String get insightMittelschmerzBody;

  /// No description provided for @insightFertilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Fertility Signals'**
  String get insightFertilityTitle;

  /// No description provided for @insightFertilityBody.
  ///
  /// In en, this message translates to:
  /// **'Nature encourages social connection now. You are magnetic!'**
  String get insightFertilityBody;

  /// No description provided for @insightWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Water Retention'**
  String get insightWaterTitle;

  /// No description provided for @insightWaterBody.
  ///
  /// In en, this message translates to:
  /// **'Body holds water preparing for potential pregnancy. It will pass soon.'**
  String get insightWaterBody;

  /// No description provided for @insightProgesteroneTitle.
  ///
  /// In en, this message translates to:
  /// **'Progesterone Drop'**
  String get insightProgesteroneTitle;

  /// No description provided for @insightProgesteroneBody.
  ///
  /// In en, this message translates to:
  /// **'Brain chemicals dip before period. Be gentle with yourself today.'**
  String get insightProgesteroneBody;

  /// No description provided for @insightSkinTitle.
  ///
  /// In en, this message translates to:
  /// **'Hormonal Skin'**
  String get insightSkinTitle;

  /// No description provided for @insightSkinBody.
  ///
  /// In en, this message translates to:
  /// **'Progesterone stimulates oil glands. Keep skincare simple.'**
  String get insightSkinBody;

  /// No description provided for @insightMetabolismTitle.
  ///
  /// In en, this message translates to:
  /// **'Energy Demands'**
  String get insightMetabolismTitle;

  /// No description provided for @insightMetabolismBody.
  ///
  /// In en, this message translates to:
  /// **'Metabolism speeds up. Choose complex carbs instead of sugar.'**
  String get insightMetabolismBody;

  /// No description provided for @insightSpottingTitle.
  ///
  /// In en, this message translates to:
  /// **'Spotting Detected'**
  String get insightSpottingTitle;

  /// No description provided for @insightSpottingBody.
  ///
  /// In en, this message translates to:
  /// **'Light bleeding can happen during ovulation or due to stress.'**
  String get insightSpottingBody;

  /// No description provided for @premiumInsightLabel.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM INSIGHT'**
  String get premiumInsightLabel;

  /// No description provided for @calendarForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'CALENDAR & FORECAST'**
  String get calendarForecastTitle;

  /// No description provided for @aiForecastHigh.
  ///
  /// In en, this message translates to:
  /// **'Forecast is Accurate'**
  String get aiForecastHigh;

  /// No description provided for @aiForecastHighSub.
  ///
  /// In en, this message translates to:
  /// **'Based on your stable history'**
  String get aiForecastHighSub;

  /// No description provided for @aiForecastMedium.
  ///
  /// In en, this message translates to:
  /// **'Moderate Confidence'**
  String get aiForecastMedium;

  /// No description provided for @aiForecastMediumSub.
  ///
  /// In en, this message translates to:
  /// **'Some cycle variations detected'**
  String get aiForecastMediumSub;

  /// No description provided for @aiForecastLow.
  ///
  /// In en, this message translates to:
  /// **'Low Accuracy'**
  String get aiForecastLow;

  /// No description provided for @aiForecastLowSub.
  ///
  /// In en, this message translates to:
  /// **'Cycle length varies significantly'**
  String get aiForecastLowSub;

  /// No description provided for @aiLearning.
  ///
  /// In en, this message translates to:
  /// **'AI Learning...'**
  String get aiLearning;

  /// No description provided for @aiLearningSub.
  ///
  /// In en, this message translates to:
  /// **'Log 3 cycles to unlock forecast'**
  String get aiLearningSub;

  /// No description provided for @confidenceHighDesc.
  ///
  /// In en, this message translates to:
  /// **'Cycle is predictable and regular.'**
  String get confidenceHighDesc;

  /// No description provided for @confidenceMedDesc.
  ///
  /// In en, this message translates to:
  /// **'Forecast based on average data.'**
  String get confidenceMedDesc;

  /// No description provided for @confidenceLowDesc.
  ///
  /// In en, this message translates to:
  /// **'Predictions may vary due to irregular history.'**
  String get confidenceLowDesc;

  /// No description provided for @confidenceCalcDesc.
  ///
  /// In en, this message translates to:
  /// **'Gathering more data for better accuracy.'**
  String get confidenceCalcDesc;

  /// No description provided for @confidenceNoData.
  ///
  /// In en, this message translates to:
  /// **'Not enough history yet.'**
  String get confidenceNoData;

  /// No description provided for @factorDataNeeded.
  ///
  /// In en, this message translates to:
  /// **'Need at least 3 cycles'**
  String get factorDataNeeded;

  /// No description provided for @factorHighVar.
  ///
  /// In en, this message translates to:
  /// **'High irregularity detected'**
  String get factorHighVar;

  /// No description provided for @factorSlightVar.
  ///
  /// In en, this message translates to:
  /// **'Slight irregularity'**
  String get factorSlightVar;

  /// No description provided for @factorStable.
  ///
  /// In en, this message translates to:
  /// **'Cycle is stable'**
  String get factorStable;

  /// No description provided for @factorAnomaly.
  ///
  /// In en, this message translates to:
  /// **'Recent anomaly detected'**
  String get factorAnomaly;

  /// No description provided for @aiDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Forecast Analysis'**
  String get aiDialogTitle;

  /// No description provided for @aiDialogScore.
  ///
  /// In en, this message translates to:
  /// **'Your cycle forecast confidence score is {score}%.'**
  String aiDialogScore(int score);

  /// No description provided for @aiDialogExplanation.
  ///
  /// In en, this message translates to:
  /// **'This score is calculated locally based on your cycle history variance.'**
  String get aiDialogExplanation;

  /// No description provided for @aiDialogFactors.
  ///
  /// In en, this message translates to:
  /// **'Factors:'**
  String get aiDialogFactors;

  /// No description provided for @btnGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get btnGotIt;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navHome;

  /// No description provided for @navSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get navSymptoms;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @msgSavedNoPop.
  ///
  /// In en, this message translates to:
  /// **'Symptoms updated successfully'**
  String get msgSavedNoPop;

  /// No description provided for @lblFlowAndLove.
  ///
  /// In en, this message translates to:
  /// **'Flow & Intimacy'**
  String get lblFlowAndLove;

  /// No description provided for @sectionBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get sectionBackup;

  /// No description provided for @btnSaveBackup.
  ///
  /// In en, this message translates to:
  /// **'Save Backup'**
  String get btnSaveBackup;

  /// No description provided for @btnRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from File'**
  String get btnRestoreBackup;

  /// No description provided for @dialogRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Data?'**
  String get dialogRestoreTitle;

  /// No description provided for @dialogRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'This will overwrite your current data with the backup file. Are you sure?'**
  String get dialogRestoreBody;

  /// No description provided for @btnRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get btnRestore;

  /// No description provided for @msgRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully!'**
  String get msgRestoreSuccess;

  /// No description provided for @msgEmailError.
  ///
  /// In en, this message translates to:
  /// **'Could not open email client. Write to: {email}'**
  String msgEmailError(Object email);

  /// No description provided for @msgExportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data to export yet.'**
  String get msgExportEmpty;

  /// No description provided for @msgExportError.
  ///
  /// In en, this message translates to:
  /// **'Could not generate PDF'**
  String get msgExportError;

  /// No description provided for @msgBiometricsError.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not available on this device'**
  String get msgBiometricsError;

  /// No description provided for @authBiometricsReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm to enable biometrics'**
  String get authBiometricsReason;

  /// No description provided for @lblUser.
  ///
  /// In en, this message translates to:
  /// **'EviMoon User'**
  String get lblUser;

  /// No description provided for @modeTTC.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Planning'**
  String get modeTTC;

  /// No description provided for @modeTTCDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable fertility tracking and ovulation focus'**
  String get modeTTCDesc;

  /// No description provided for @modeTTCActive.
  ///
  /// In en, this message translates to:
  /// **'Fertility Mode Activated'**
  String get modeTTCActive;

  /// No description provided for @dialogTTCConflict.
  ///
  /// In en, this message translates to:
  /// **'Disable Contraception?'**
  String get dialogTTCConflict;

  /// No description provided for @dialogTTCConflictBody.
  ///
  /// In en, this message translates to:
  /// **'To enable Pregnancy Planning mode, contraceptive tracking must be disabled.'**
  String get dialogTTCConflictBody;

  /// No description provided for @btnDisableAndSwitch.
  ///
  /// In en, this message translates to:
  /// **'Disable & Switch'**
  String get btnDisableAndSwitch;

  /// No description provided for @ttcStatusLow.
  ///
  /// In en, this message translates to:
  /// **'Low Chance'**
  String get ttcStatusLow;

  /// No description provided for @ttcStatusHigh.
  ///
  /// In en, this message translates to:
  /// **'High Fertility'**
  String get ttcStatusHigh;

  /// No description provided for @ttcStatusPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak Fertility'**
  String get ttcStatusPeak;

  /// No description provided for @ttcStatusOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation Day'**
  String get ttcStatusOvulation;

  /// No description provided for @ttcDPO.
  ///
  /// In en, this message translates to:
  /// **'{days} DPO'**
  String ttcDPO(Object days);

  /// No description provided for @ttcChance.
  ///
  /// In en, this message translates to:
  /// **'Conception Chance'**
  String get ttcChance;

  /// No description provided for @ttcTestWait.
  ///
  /// In en, this message translates to:
  /// **'Too early to test'**
  String get ttcTestWait;

  /// No description provided for @ttcTestReady.
  ///
  /// In en, this message translates to:
  /// **'You can test today'**
  String get ttcTestReady;

  /// No description provided for @lblCycleDay.
  ///
  /// In en, this message translates to:
  /// **'Cycle Day {day}'**
  String lblCycleDay(Object day);

  /// No description provided for @ttcBtnBBT.
  ///
  /// In en, this message translates to:
  /// **'Log BBT'**
  String get ttcBtnBBT;

  /// No description provided for @ttcBtnTest.
  ///
  /// In en, this message translates to:
  /// **'LH Test'**
  String get ttcBtnTest;

  /// No description provided for @ttcBtnSex.
  ///
  /// In en, this message translates to:
  /// **'Intimacy'**
  String get ttcBtnSex;

  /// No description provided for @ttcLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Log'**
  String get ttcLogTitle;

  /// No description provided for @ttcSectionBBT.
  ///
  /// In en, this message translates to:
  /// **'Basal Body Temperature'**
  String get ttcSectionBBT;

  /// No description provided for @ttcSectionTest.
  ///
  /// In en, this message translates to:
  /// **'Ovulation Test (LH)'**
  String get ttcSectionTest;

  /// No description provided for @ttcSectionSex.
  ///
  /// In en, this message translates to:
  /// **'Intimacy'**
  String get ttcSectionSex;

  /// No description provided for @lblNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative (-)'**
  String get lblNegative;

  /// No description provided for @lblPositive.
  ///
  /// In en, this message translates to:
  /// **'Positive (+)'**
  String get lblPositive;

  /// No description provided for @lblPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get lblPeak;

  /// No description provided for @lblSexYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, we did!'**
  String get lblSexYes;

  /// No description provided for @lblSexNo.
  ///
  /// In en, this message translates to:
  /// **'Not today'**
  String get lblSexNo;

  /// No description provided for @ttcTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Tip'**
  String get ttcTipTitle;

  /// No description provided for @ttcTipDefault.
  ///
  /// In en, this message translates to:
  /// **'Stress affects ovulation. Try 5 min meditation today.'**
  String get ttcTipDefault;

  /// No description provided for @dialogHighTempTitle.
  ///
  /// In en, this message translates to:
  /// **'High Temperature'**
  String get dialogHighTempTitle;

  /// No description provided for @dialogHighTempBody.
  ///
  /// In en, this message translates to:
  /// **'Temperature above 37.5°C usually indicates fever, not ovulation.'**
  String get dialogHighTempBody;

  /// No description provided for @dialogLowTempTitle.
  ///
  /// In en, this message translates to:
  /// **'Low Temperature'**
  String get dialogLowTempTitle;

  /// No description provided for @dialogLowTempBody.
  ///
  /// In en, this message translates to:
  /// **'Temperature below 35.5°C is unusually low. Is this a typo?'**
  String get dialogLowTempBody;

  /// No description provided for @dialogPeriodLHTitle.
  ///
  /// In en, this message translates to:
  /// **'Unusual Reading'**
  String get dialogPeriodLHTitle;

  /// No description provided for @dialogPeriodLHBody.
  ///
  /// In en, this message translates to:
  /// **'Positive LH test during menstruation is rare. It might be an error.'**
  String get dialogPeriodLHBody;

  /// No description provided for @btnLogAnyway.
  ///
  /// In en, this message translates to:
  /// **'Log Anyway'**
  String get btnLogAnyway;

  /// No description provided for @insightFertilitySub.
  ///
  /// In en, this message translates to:
  /// **'How your body signals ovulation'**
  String get insightFertilitySub;

  /// No description provided for @insightLibidoHigh.
  ///
  /// In en, this message translates to:
  /// **'High Libido during fertile window'**
  String get insightLibidoHigh;

  /// No description provided for @insightPainOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation pain (Mittelschmerz) detected'**
  String get insightPainOvulation;

  /// No description provided for @insightTempShift.
  ///
  /// In en, this message translates to:
  /// **'Temperature shift detected after ovulation'**
  String get insightTempShift;

  /// No description provided for @lblDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get lblDetected;

  /// No description provided for @transitionTTC.
  ///
  /// In en, this message translates to:
  /// **'The journey begins... ✨'**
  String get transitionTTC;

  /// No description provided for @transitionCOC.
  ///
  /// In en, this message translates to:
  /// **'Protection activated 🛡️'**
  String get transitionCOC;

  /// No description provided for @transitionTrack.
  ///
  /// In en, this message translates to:
  /// **'Listening to your body 🌿'**
  String get transitionTrack;

  /// No description provided for @legendFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular'**
  String get legendFollicular;

  /// No description provided for @legendLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal'**
  String get legendLuteal;

  /// No description provided for @lblBodyMind.
  ///
  /// In en, this message translates to:
  /// **'Body & Mind'**
  String get lblBodyMind;

  /// No description provided for @pdfReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gynecological & Cycle History'**
  String get pdfReportSubtitle;

  /// No description provided for @pdfPatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get pdfPatient;

  /// No description provided for @pdfClinicalSummary.
  ///
  /// In en, this message translates to:
  /// **'Clinical Summary'**
  String get pdfClinicalSummary;

  /// No description provided for @pdfDetailedLogs.
  ///
  /// In en, this message translates to:
  /// **'Detailed Logs'**
  String get pdfDetailedLogs;

  /// No description provided for @pdfAvgCycle.
  ///
  /// In en, this message translates to:
  /// **'Avg Cycle Length'**
  String get pdfAvgCycle;

  /// No description provided for @pdfAvgPeriod.
  ///
  /// In en, this message translates to:
  /// **'Avg Period'**
  String get pdfAvgPeriod;

  /// No description provided for @pdfPainReported.
  ///
  /// In en, this message translates to:
  /// **'Pain Reported'**
  String get pdfPainReported;

  /// No description provided for @pdfTableDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get pdfTableDate;

  /// No description provided for @pdfTableCD.
  ///
  /// In en, this message translates to:
  /// **'CD'**
  String get pdfTableCD;

  /// No description provided for @pdfTableSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get pdfTableSymptoms;

  /// No description provided for @pdfTableBBT.
  ///
  /// In en, this message translates to:
  /// **'BBT'**
  String get pdfTableBBT;

  /// No description provided for @pdfTableNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get pdfTableNotes;

  /// No description provided for @pdfFlowShort.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get pdfFlowShort;

  /// No description provided for @unitDays.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get unitDays;

  /// No description provided for @pdfDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'DISCLAIMER: This report is generated by EviMoon based on user-inputted data. It does not constitute a medical diagnosis. Please consult a healthcare professional for interpretation.'**
  String get pdfDisclaimer;

  /// No description provided for @dialogDataInsufficientTitle.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Data'**
  String get dialogDataInsufficientTitle;

  /// No description provided for @dialogDataInsufficientBody.
  ///
  /// In en, this message translates to:
  /// **'To generate a clinical report, we need at least 7 days of logs or one complete cycle. This ensures clinical accuracy for your doctor.'**
  String get dialogDataInsufficientBody;

  /// No description provided for @btnOk.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get btnOk;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'EviMoon'**
  String get splashTitle;

  /// No description provided for @notifPhaseFollicularTitle.
  ///
  /// In en, this message translates to:
  /// **'Energy Rising ⚡'**
  String get notifPhaseFollicularTitle;

  /// No description provided for @notifPhaseFollicularBody.
  ///
  /// In en, this message translates to:
  /// **'Estrogen is up! Your brain is sharp and your body is ready for action.'**
  String get notifPhaseFollicularBody;

  /// No description provided for @notifPhaseOvulationTitle.
  ///
  /// In en, this message translates to:
  /// **'You are glowing 🌸'**
  String get notifPhaseOvulationTitle;

  /// No description provided for @notifPhaseOvulationBody.
  ///
  /// In en, this message translates to:
  /// **'Peak fertility and confidence. Perfect for big meetings (or dates).'**
  String get notifPhaseOvulationBody;

  /// No description provided for @notifPhaseLutealTitle.
  ///
  /// In en, this message translates to:
  /// **'Be Gentle 🌙'**
  String get notifPhaseLutealTitle;

  /// No description provided for @notifPhaseLutealBody.
  ///
  /// In en, this message translates to:
  /// **'Progesterone is rising. Feeling tired is okay. Take it slow.'**
  String get notifPhaseLutealBody;

  /// No description provided for @notifPhasePeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'New Cycle 🩸'**
  String get notifPhasePeriodTitle;

  /// No description provided for @notifPhasePeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to log the start of your period.'**
  String get notifPhasePeriodBody;

  /// No description provided for @notifLatePeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Late Period?'**
  String get notifLatePeriodTitle;

  /// No description provided for @notifLatePeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Cycle is longer than usual. Log symptoms or take a test.'**
  String get notifLatePeriodBody;

  /// No description provided for @notifLogCheckinTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you feel?'**
  String get notifLogCheckinTitle;

  /// No description provided for @notifLogCheckinBody.
  ///
  /// In en, this message translates to:
  /// **'Take a second to log your symptoms for better predictions.'**
  String get notifLogCheckinBody;

  /// No description provided for @settingsDailyLog.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-in (20:00)'**
  String get settingsDailyLog;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'EviMoon Premium'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock the full potential of your cycle.'**
  String get paywallSubtitle;

  /// No description provided for @featureTimersTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Timer Designs'**
  String get featureTimersTitle;

  /// No description provided for @featureTimersDesc.
  ///
  /// In en, this message translates to:
  /// **'Unique styles for your home screen'**
  String get featureTimersDesc;

  /// No description provided for @featurePdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical PDF Report'**
  String get featurePdfTitle;

  /// No description provided for @featurePdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Share symptom history with your doctor'**
  String get featurePdfDesc;

  /// No description provided for @featureAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Cycle Confidence'**
  String get featureAiTitle;

  /// No description provided for @featureAiDesc.
  ///
  /// In en, this message translates to:
  /// **'Know how accurate your forecast is'**
  String get featureAiDesc;

  /// No description provided for @featureTtcTitle.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Planning Mode'**
  String get featureTtcTitle;

  /// No description provided for @featureTtcDesc.
  ///
  /// In en, this message translates to:
  /// **'Specialized tools for conception'**
  String get featureTtcDesc;

  /// No description provided for @paywallNoOffers.
  ///
  /// In en, this message translates to:
  /// **'No offers available'**
  String get paywallNoOffers;

  /// No description provided for @paywallSelectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select Plan'**
  String get paywallSelectPlan;

  /// No description provided for @paywallSubscribeFor.
  ///
  /// In en, this message translates to:
  /// **'Subscribe for {price}'**
  String paywallSubscribeFor(String price);

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get paywallRestore;

  /// No description provided for @paywallTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get paywallTerms;

  /// No description provided for @paywallBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get paywallBestValue;

  /// No description provided for @msgNoSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No active subscriptions found'**
  String get msgNoSubscriptions;

  /// No description provided for @proStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Status'**
  String get proStatusTitle;

  /// No description provided for @proStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active'**
  String get proStatusActive;

  /// No description provided for @proStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'You have full access to all features.'**
  String get proStatusDesc;

  /// No description provided for @btnManageSub.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get btnManageSub;

  /// No description provided for @btnManageSubDesc.
  ///
  /// In en, this message translates to:
  /// **'Change plan or cancel in iOS Settings'**
  String get btnManageSubDesc;

  /// No description provided for @msgLinkError.
  ///
  /// In en, this message translates to:
  /// **'Could not open settings'**
  String get msgLinkError;

  /// No description provided for @tipPeriod.
  ///
  /// In en, this message translates to:
  /// **'Rest up and eat iron-rich foods.'**
  String get tipPeriod;

  /// No description provided for @tipOvulation.
  ///
  /// In en, this message translates to:
  /// **'Peak fertility! Ideal time to conceive.'**
  String get tipOvulation;

  /// No description provided for @tipLutealEarly.
  ///
  /// In en, this message translates to:
  /// **'Progesterone is rising. Stay hydrated.'**
  String get tipLutealEarly;

  /// No description provided for @tipLutealLate.
  ///
  /// In en, this message translates to:
  /// **'Implantation window. Avoid high stress.'**
  String get tipLutealLate;

  /// No description provided for @tipFollicular.
  ///
  /// In en, this message translates to:
  /// **'Energy is rising. Good for exercise.'**
  String get tipFollicular;

  /// No description provided for @msgLhPeakRecorded.
  ///
  /// In en, this message translates to:
  /// **'LH Peak recorded! High fertility window active.'**
  String get msgLhPeakRecorded;

  /// No description provided for @phaseNewMoon.
  ///
  /// In en, this message translates to:
  /// **'New Moon'**
  String get phaseNewMoon;

  /// No description provided for @phaseWaxingCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waxing Crescent'**
  String get phaseWaxingCrescent;

  /// No description provided for @phaseFirstQuarter.
  ///
  /// In en, this message translates to:
  /// **'First Quarter'**
  String get phaseFirstQuarter;

  /// No description provided for @phaseFullMoon.
  ///
  /// In en, this message translates to:
  /// **'Full Moon'**
  String get phaseFullMoon;

  /// No description provided for @phaseWaningGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waning Gibbous'**
  String get phaseWaningGibbous;

  /// No description provided for @phaseWaningCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waning Crescent'**
  String get phaseWaningCrescent;

  /// No description provided for @ttcChanceHigh.
  ///
  /// In en, this message translates to:
  /// **'High Chance'**
  String get ttcChanceHigh;

  /// No description provided for @ttcChancePeak.
  ///
  /// In en, this message translates to:
  /// **'Peak Fertility'**
  String get ttcChancePeak;

  /// No description provided for @ttcChanceLow.
  ///
  /// In en, this message translates to:
  /// **'Low Chance'**
  String get ttcChanceLow;

  /// No description provided for @ttcCycleDay.
  ///
  /// In en, this message translates to:
  /// **'CYCLE DAY {day}'**
  String ttcCycleDay(int day);

  /// No description provided for @lblTest.
  ///
  /// In en, this message translates to:
  /// **'LH Test'**
  String get lblTest;

  /// No description provided for @lblSex.
  ///
  /// In en, this message translates to:
  /// **'Intimacy'**
  String get lblSex;

  /// No description provided for @lblMucus.
  ///
  /// In en, this message translates to:
  /// **'Mucus'**
  String get lblMucus;

  /// No description provided for @valMeasured.
  ///
  /// In en, this message translates to:
  /// **'{temp}°'**
  String valMeasured(double temp);

  /// No description provided for @valPositive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get valPositive;

  /// No description provided for @valPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get valPeak;

  /// No description provided for @valNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get valNegative;

  /// No description provided for @valSexYes.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get valSexYes;

  /// No description provided for @valMucusLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get valMucusLogged;

  /// No description provided for @titleInputBBT.
  ///
  /// In en, this message translates to:
  /// **'Log Temperature'**
  String get titleInputBBT;

  /// No description provided for @titleInputTest.
  ///
  /// In en, this message translates to:
  /// **'LH Test Result'**
  String get titleInputTest;

  /// No description provided for @titleInputSex.
  ///
  /// In en, this message translates to:
  /// **'Intimacy details'**
  String get titleInputSex;

  /// No description provided for @titleInputMucus.
  ///
  /// In en, this message translates to:
  /// **'Cervical Mucus'**
  String get titleInputMucus;

  /// No description provided for @chipNegative.
  ///
  /// In en, this message translates to:
  /// **'Negative'**
  String get chipNegative;

  /// No description provided for @chipPositive.
  ///
  /// In en, this message translates to:
  /// **'Positive'**
  String get chipPositive;

  /// No description provided for @chipPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get chipPeak;

  /// No description provided for @labelSexNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get labelSexNo;

  /// No description provided for @labelSexYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get labelSexYes;

  /// No description provided for @mucusDry.
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get mucusDry;

  /// No description provided for @mucusSticky.
  ///
  /// In en, this message translates to:
  /// **'Sticky'**
  String get mucusSticky;

  /// No description provided for @mucusCreamy.
  ///
  /// In en, this message translates to:
  /// **'Creamy'**
  String get mucusCreamy;

  /// No description provided for @mucusWatery.
  ///
  /// In en, this message translates to:
  /// **'Watery'**
  String get mucusWatery;

  /// No description provided for @mucusEggWhite.
  ///
  /// In en, this message translates to:
  /// **'Egg White'**
  String get mucusEggWhite;

  /// No description provided for @ttcChartTitle.
  ///
  /// In en, this message translates to:
  /// **'BBT CHART (14 DAYS)'**
  String get ttcChartTitle;

  /// No description provided for @ttcChartPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Log temperature to see chart'**
  String get ttcChartPlaceholder;

  /// No description provided for @hintTemp.
  ///
  /// In en, this message translates to:
  /// **'36.6'**
  String get hintTemp;

  /// No description provided for @prefNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get prefNotifications;

  /// No description provided for @prefBiometrics.
  ///
  /// In en, this message translates to:
  /// **'FaceID / TouchID'**
  String get prefBiometrics;

  /// No description provided for @prefCOC.
  ///
  /// In en, this message translates to:
  /// **'Contraceptive Pill Mode'**
  String get prefCOC;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get sectionData;

  /// No description provided for @btnExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF Report'**
  String get btnExportPdf;

  /// No description provided for @btnBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get btnBackup;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @btnContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get btnContactSupport;

  /// No description provided for @btnRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate EviMoon'**
  String get btnRateApp;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
