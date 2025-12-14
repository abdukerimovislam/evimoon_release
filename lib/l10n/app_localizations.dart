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
  /// **'Generated by EviMoon'**
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
  /// **'Sleep Quality'**
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
  /// **'Avg Cycle'**
  String get insightAvgCycle;

  /// No description provided for @insightAvgPeriod.
  ///
  /// In en, this message translates to:
  /// **'Avg Period'**
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
  /// **'Track Birth Control Pill'**
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
  /// **'Reminder Time'**
  String get settingsReminder;

  /// No description provided for @settingsPackSettings.
  ///
  /// In en, this message translates to:
  /// **'Pack Settings'**
  String get settingsPackSettings;

  /// No description provided for @settingsPlaceboCount.
  ///
  /// In en, this message translates to:
  /// **'Placebo Pills Count'**
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
  /// **'FaceID / TouchID'**
  String get settingsBiometrics;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export PDF Report'**
  String get settingsExport;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset & Delete All Data'**
  String get settingsReset;

  /// No description provided for @dialogResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset App?'**
  String get dialogResetTitle;

  /// No description provided for @dialogResetBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete all your logs and settings. This action cannot be undone.'**
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
  /// **'💊 Time for your pill'**
  String get notifPillTitle;

  /// No description provided for @notifPillBody.
  ///
  /// In en, this message translates to:
  /// **'Stay protected! Take your daily pill now.'**
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
  /// **'Anything else happened?'**
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
  /// **'Days'**
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
  /// **'Track Birth Control'**
  String get dialogCOCStartTitle;

  /// No description provided for @dialogCOCStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Are you starting a fresh pack today or continuing one?'**
  String get dialogCOCStartSubtitle;

  /// No description provided for @optionFreshPack.
  ///
  /// In en, this message translates to:
  /// **'Start Fresh Pack'**
  String get optionFreshPack;

  /// No description provided for @optionFreshPackSub.
  ///
  /// In en, this message translates to:
  /// **'Today is Day 1'**
  String get optionFreshPackSub;

  /// No description provided for @optionContinuePack.
  ///
  /// In en, this message translates to:
  /// **'Continue Pack'**
  String get optionContinuePack;

  /// No description provided for @optionContinuePackSub.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
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
  /// **'Delete Everything'**
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
  /// **'EviMoon Feedback (v1.0)'**
  String get emailSubject;

  /// No description provided for @emailBody.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue or suggestion here:\n\n\n\n--- Device Info ---\n(Please do not delete, it helps us fix bugs)\nPlatform: '**
  String get emailBody;
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
