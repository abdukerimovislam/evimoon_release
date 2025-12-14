// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EviMoon';

  @override
  String get tabCycle => 'Cycle';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabInsights => 'Insights';

  @override
  String get tabLearn => 'Learn';

  @override
  String get tabProfile => 'Profile';

  @override
  String get phaseMenstruation => 'Menstruation';

  @override
  String get phaseFollicular => 'Follicular Phase';

  @override
  String get phaseOvulation => 'Ovulation';

  @override
  String get phaseLuteal => 'Luteal Phase';

  @override
  String dayOfCycle(Object day) {
    return 'Day $day';
  }

  @override
  String get editPeriod => 'Edit Period';

  @override
  String get logSymptoms => 'Log Symptoms';

  @override
  String predictionText(Object days) {
    return 'Period in $days days';
  }

  @override
  String get chanceOfPregnancy => 'High chance of getting pregnant';

  @override
  String get lowChance => 'Low chance of getting pregnant';

  @override
  String get wellnessHeader => 'Wellness & Mood';

  @override
  String get btnCheckIn => 'Daily Check-in';

  @override
  String get symptomHeader => 'How are you feeling?';

  @override
  String get symptomSubHeader => 'Log your symptoms for better insights.';

  @override
  String get catFlow => 'Flow';

  @override
  String get catPain => 'Pain';

  @override
  String get catMood => 'Mood';

  @override
  String get catSleep => 'Sleep';

  @override
  String get flowLight => 'Light';

  @override
  String get flowMedium => 'Medium';

  @override
  String get flowHeavy => 'Heavy';

  @override
  String get painNone => 'No Pain';

  @override
  String get painCramps => 'Cramps';

  @override
  String get painHeadache => 'Headache';

  @override
  String get painBack => 'Back Pain';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodEnergetic => 'Energetic';

  @override
  String get moodIrritated => 'Irritated';

  @override
  String get btnSave => 'Save';

  @override
  String get legendPeriod => 'Period';

  @override
  String get legendFertile => 'Fertile';

  @override
  String get legendOvulation => 'Ovulation';

  @override
  String get calendarHeader => 'Your History';

  @override
  String get insightsTitle => 'Trends & Insights';

  @override
  String get chartCycleLength => 'Cycle Length';

  @override
  String get chartSubtitle => 'Last 6 months';

  @override
  String get insightTipTitle => 'Tip of the Day';

  @override
  String get insightTipBody => 'Energy levels drop during the luteal phase. It\'s a great time for yoga and sleeping in.';

  @override
  String get topSymptoms => 'Top Symptoms';

  @override
  String get patternDetected => 'Pattern Detected';

  @override
  String get patternBody => 'You frequently log headaches before your period. Try hydrating more 2 days prior.';

  @override
  String get profileTitle => 'Profile & Settings';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionSecurity => 'Security & Privacy';

  @override
  String get lblLanguage => 'Language';

  @override
  String get lblNotifications => 'Notifications';

  @override
  String get lblBiometrics => 'FaceID / TouchID';

  @override
  String get lblExport => 'Export Data (PDF/CSV)';

  @override
  String get lblDeleteAccount => 'Delete All Data';

  @override
  String get descDelete => 'This will permanently erase all your logs from this device.';

  @override
  String get alertDeleteTitle => 'Are you sure?';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get btnNext => 'Next';

  @override
  String get btnStart => 'Get Started';

  @override
  String get greetMorning => 'Good morning';

  @override
  String get greetAfternoon => 'Good afternoon';

  @override
  String get greetEvening => 'Good evening';

  @override
  String get phaseStatusMenstruation => 'Time to rest & recharge';

  @override
  String get phaseStatusFollicular => 'Energy is rising';

  @override
  String get phaseStatusOvulation => 'You are glowing today';

  @override
  String get phaseStatusLuteal => 'Be gentle with yourself';

  @override
  String get notifPeriodTitle => 'Cycle Update';

  @override
  String get notifPeriodBody => 'Your period is likely to start in 2 days. Get ready!';

  @override
  String get notifOvulationTitle => 'Fertility Window';

  @override
  String get notifOvulationBody => 'High chance of fertility today. You are glowing! 🌸';

  @override
  String get phaseLate => 'Late';

  @override
  String get sectionCycle => 'Cycle Settings';

  @override
  String get lblCycleLength => 'Cycle Length';

  @override
  String get lblPeriodLength => 'Period Length';

  @override
  String get authLockedTitle => 'EviMoon Locked';

  @override
  String get authUnlockBtn => 'Unlock';

  @override
  String get authReason => 'Please authenticate to access EviMoon';

  @override
  String get authNotAvailable => 'Biometrics not available on device';

  @override
  String get pdfReportTitle => 'EviMoon Health Report';

  @override
  String get pdfCycleHistory => 'Cycle History Summary';

  @override
  String get pdfHeaderStart => 'Start Date';

  @override
  String get pdfHeaderEnd => 'Predicted End';

  @override
  String get pdfHeaderLength => 'Length (Days)';

  @override
  String get pdfCurrent => 'Current';

  @override
  String get pdfGenerated => 'Generated by EviMoon';

  @override
  String get pdfPage => 'Page';

  @override
  String get dayTitle => 'Day';

  @override
  String get insightMenstruationTitle => 'Rest & Reset';

  @override
  String get insightMenstruationSubtitle => 'Keep warm, drink tea, skip heavy workouts.';

  @override
  String get insightFollicularTitle => 'Creative Spark';

  @override
  String get insightFollicularSubtitle => 'Energy is rising! Brain function is at peak.';

  @override
  String get insightOvulationTitle => 'Super Power';

  @override
  String get insightOvulationSubtitle => 'Magnetic energy. High libido & confidence.';

  @override
  String get insightLutealTitle => 'Inner Focus';

  @override
  String get insightLutealSubtitle => 'Calm or irritable. Focus inward.';

  @override
  String get insightLateTitle => 'Stay Calm';

  @override
  String get insightLateSubtitle => 'Reduce stress and maintain healthy diet.';

  @override
  String get lblEnergy => 'Energy';

  @override
  String get lblMood => 'Mood';

  @override
  String get tapToClose => 'Tap to close';

  @override
  String get btnPeriodStart => 'STARTED';

  @override
  String get btnPeriodEnd => 'ENDED';

  @override
  String get dialogStartTitle => 'Start New Cycle?';

  @override
  String get dialogStartBody => 'Today will be marked as Day 1 of your period.';

  @override
  String get dialogEndTitle => 'End Period?';

  @override
  String get dialogEndBody => 'Your cycle phase will switch to follicular.';

  @override
  String get btnConfirm => 'Confirm';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get logFlow => 'Flow Intensity';

  @override
  String get logPain => 'Pain';

  @override
  String get logMood => 'Mood';

  @override
  String get logSleep => 'Sleep Quality';

  @override
  String get logNotes => 'Notes';

  @override
  String get insightPhasesTitle => 'Cycle Phases';

  @override
  String get insightPhasesSubtitle => 'Typical duration breakdown';

  @override
  String get insightMoodTitle => 'Mood by Phase';

  @override
  String get insightMoodSubtitle => 'Average mood intensity';

  @override
  String get insightAvgCycle => 'Avg Cycle';

  @override
  String get insightAvgPeriod => 'Avg Period';

  @override
  String get phaseShortMens => 'MENS';

  @override
  String get phaseShortFoll => 'FOLL';

  @override
  String get phaseShortOvul => 'OVUL';

  @override
  String get phaseShortLut => 'LUT';

  @override
  String get unitDaysShort => 'd';

  @override
  String get insightBodyBalance => 'Body Balance';

  @override
  String get insightBodyBalanceSub => 'Follicular (Purple) vs Luteal (Orange)';

  @override
  String get insightMoodFlow => 'Mood Flow';

  @override
  String get insightMoodFlowSub => 'Recent 30 days trend';

  @override
  String get paramEnergy => 'Energy';

  @override
  String get paramLibido => 'Libido';

  @override
  String get paramSkin => 'Skin';

  @override
  String get predTitle => 'Daily Forecast';

  @override
  String get predSubtitle => 'Based on your cycle & sleep patterns';

  @override
  String get recHighEnergy => 'Great day for heavy tasks or workouts!';

  @override
  String get recLowEnergy => 'Take it easy. Prioritize rest today.';

  @override
  String get recNormalEnergy => 'Maintain a steady pace.';

  @override
  String get btnWrong => 'Wrong';

  @override
  String msgFeedback(Object metric, Object status) {
    return 'Is $metric really $status today?';
  }

  @override
  String get paramFocus => 'Focus';

  @override
  String get statusLow => 'Low';

  @override
  String get statusHigh => 'High';

  @override
  String get statusNormal => 'Normal';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String feedbackQuestion(Object metric, Object status) {
    return 'Is your $metric really $status today?';
  }

  @override
  String get btnYesCorrect => 'Yes, correct';

  @override
  String get btnNoWrong => 'No, it\'s wrong';

  @override
  String get cocActivePhase => 'Active Pill Phase';

  @override
  String get cocBreakPhase => 'Break Week';

  @override
  String cocPredictionActive(Object days) {
    return '$days active pills remaining';
  }

  @override
  String cocPredictionBreak(Object days) {
    return 'Start new pack in $days days';
  }

  @override
  String get btnStartNewPack => 'Start New Pack';

  @override
  String get btnRestartPack => 'Restart Pack';

  @override
  String get dialogStartPackTitle => 'Start New Pack?';

  @override
  String get dialogStartPackBody => 'This will reset your cycle to Day 1. Use this when you open a fresh pack.';

  @override
  String get pillTaken => 'Pill Taken';

  @override
  String get pillTake => 'Take Your Pill';

  @override
  String pillScheduled(String time) {
    return 'Scheduled for $time';
  }

  @override
  String get blisterMyPack => 'My Pack';

  @override
  String blisterDay(Object day, Object total) {
    return 'Day $day / $total';
  }

  @override
  String blisterOverdue(Object day) {
    return 'Day $day (Overdue)';
  }

  @override
  String get blister21 => '21-Day Pack';

  @override
  String get blister28 => '28-Day Pack';

  @override
  String get legendTaken => 'Taken';

  @override
  String get legendActive => 'Active';

  @override
  String get legendPlacebo => 'Placebo';

  @override
  String get legendBreak => 'Break';

  @override
  String get insightCOCActiveTitle => 'Protected';

  @override
  String get insightCOCActiveBody => 'Active pill phase. Make sure to take your pill at the same time daily.';

  @override
  String get insightCOCBreakTitle => 'Withdrawal Bleed';

  @override
  String get insightCOCBreakBody => 'This is the break week. Bleeding is expected due to hormone drop.';

  @override
  String get settingsContraception => 'Contraception';

  @override
  String get settingsTrackPill => 'Track Birth Control Pill';

  @override
  String get settingsPackType => 'Pack Type';

  @override
  String settingsPills(Object count) {
    return '$count Pills';
  }

  @override
  String get settingsReminder => 'Reminder Time';

  @override
  String get settingsPackSettings => 'Pack Settings';

  @override
  String get settingsPlaceboCount => 'Placebo Pills Count';

  @override
  String get settingsBreakDuration => 'Break Duration';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotifs => 'Notifications';

  @override
  String get settingsData => 'Data & Security';

  @override
  String get settingsBiometrics => 'FaceID / TouchID';

  @override
  String get settingsExport => 'Export PDF Report';

  @override
  String get settingsReset => 'Reset & Delete All Data';

  @override
  String get dialogResetTitle => 'Reset App?';

  @override
  String get dialogResetBody => 'This will delete all your logs and settings. This action cannot be undone.';

  @override
  String get btnDelete => 'Delete';

  @override
  String get logSymptomsTitle => 'Log Symptoms';

  @override
  String get msgSaved => 'Saved!';

  @override
  String get logSkin => 'Skin Condition';

  @override
  String get logLibido => 'Libido';

  @override
  String get symptomNausea => 'Nausea';

  @override
  String get symptomBloating => 'Bloating';

  @override
  String get lblNoData => 'No Data';

  @override
  String get lblNoSymptoms => 'No symptoms logged.';

  @override
  String get notifPillTitle => '💊 Time for your pill';

  @override
  String get notifPillBody => 'Stay protected! Take your daily pill now.';

  @override
  String get logVitals => 'Vitals';

  @override
  String get lblTemp => 'Temperature';

  @override
  String get lblWeight => 'Weight';

  @override
  String get lblLifestyle => 'Lifestyle Factors';

  @override
  String get factorStress => 'High Stress';

  @override
  String get factorAlcohol => 'Alcohol';

  @override
  String get factorTravel => 'Travel';

  @override
  String get factorSport => 'Exercise';

  @override
  String get hintNotes => 'Anything else happened?';

  @override
  String get symptomAcne => 'Acne';

  @override
  String get lblLifestyleHeader => 'Lifestyle';

  @override
  String predInsightHormones(Object hormone) {
    return 'Hormones: $hormone is rising.';
  }

  @override
  String get predMismatchTitle => 'Feeling different?';

  @override
  String get predMismatchBody => 'Tap an icon to adjust the advice.';

  @override
  String get btnAdjust => 'Adjust';

  @override
  String get stateLow => 'Low';

  @override
  String get stateMedium => 'Medium';

  @override
  String get stateHigh => 'High';

  @override
  String get tipLowEnergy => 'Rest day valid. Try gentle yoga or a nap.';

  @override
  String get tipHighEnergy => 'Great time for cardio or tackling complex tasks!';

  @override
  String get tipLowMood => 'Be gentle with yourself. Chocolate helps.';

  @override
  String get tipHighMood => 'Share your vibes! Socialize or create something.';

  @override
  String get tipLowFocus => 'Avoid multitasking. Pick one small goal.';

  @override
  String get tipHighFocus => 'Deep work mode. Tackle the hardest project.';

  @override
  String get hormoneEstrogen => 'Estrogen';

  @override
  String get hormoneProgesterone => 'Progesterone';

  @override
  String get hormoneReset => 'Hormonal Reset';

  @override
  String get onboardTitle1 => 'Welcome to EviMoon';

  @override
  String get onboardBody1 => 'Track your cycle, understand your body, and live in harmony with your natural rhythm.';

  @override
  String get onboardTitle2 => 'Last Period Start';

  @override
  String get onboardBody2 => 'Please select the first day of your last menstruation to help us calibrate.';

  @override
  String get onboardTitle3 => 'Cycle Length';

  @override
  String get onboardBody3 => 'How many days usually pass between periods? The average is 28 days.';

  @override
  String get daysUnit => 'Days';

  @override
  String get insightVitals => 'Body Vitals';

  @override
  String get hadSex => 'Had Sex';

  @override
  String get protectedSex => 'Protected';

  @override
  String get lblIntimacy => 'Intimacy';

  @override
  String get lblWellness => 'Wellness';

  @override
  String get insightVitalsSub => 'Temperature & Weight tracking';

  @override
  String cocDayInfo(int day) {
    return 'Day $day of 28';
  }

  @override
  String get dialogPackTitle => 'Choose Pack Type';

  @override
  String get dialogPackSubtitle => 'Select the pill pack format you use.';

  @override
  String get pack21Title => '21 Pills';

  @override
  String get pack21Subtitle => '21 Active + 7 Days Break';

  @override
  String get pack28Title => '28 Pills';

  @override
  String get pack28Subtitle => '21 Active + 7 Placebo';

  @override
  String get btnSaveSettings => 'Save Settings';

  @override
  String get dialogCOCStartTitle => 'Track Birth Control';

  @override
  String get dialogCOCStartSubtitle => 'Are you starting a fresh pack today or continuing one?';

  @override
  String get optionFreshPack => 'Start Fresh Pack';

  @override
  String get optionFreshPackSub => 'Today is Day 1';

  @override
  String get optionContinuePack => 'Continue Pack';

  @override
  String get optionContinuePackSub => 'Select start date';

  @override
  String get labelOr => 'OR';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogResetConfirm => 'Delete Everything';

  @override
  String get insightsOverview => 'Overview';

  @override
  String get insightsHealth => 'Health';

  @override
  String get insightsPatterns => 'Patterns';

  @override
  String get insightsVitals => 'Body Vitals';

  @override
  String get insightsVitalsSub => 'Temperature & Weight tracking';

  @override
  String get currentCycle => 'Current cycle';

  @override
  String get regularity => 'Regularity';

  @override
  String get ovulation => 'Ovulation';

  @override
  String get averageMood => 'Average mood';

  @override
  String get sleepQuality => 'Sleep quality';

  @override
  String get nextPhases => 'Next phases';

  @override
  String get prediction => 'Prediction';

  @override
  String get sleepAndEnergy => 'Sleep and energy by phase';

  @override
  String get bodyTemperature => 'Body temperature';

  @override
  String get basalTemperature => 'Basal temperature for 14 days';

  @override
  String get positiveTrend => 'Positive trend';

  @override
  String get recommendation => 'Recommendation';

  @override
  String get cycleRegularity => 'Cycle regularity';

  @override
  String get fertilityWindow => 'Fertility window';

  @override
  String get symptomPatterns => 'Symptom patterns';

  @override
  String get correlationAnalysis => 'Correlation analysis';

  @override
  String get historicalComparison => 'Historical comparison';

  @override
  String get dailyMetrics => 'Daily metrics';

  @override
  String get trends => 'Trends';

  @override
  String get phaseComparison => 'Phase comparison';

  @override
  String get energyEfficiency => 'Energy efficiency';

  @override
  String get sleepEfficiency => 'Sleep efficiency';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get today => 'Today';

  @override
  String get improvement => 'Improvement';

  @override
  String get insightsNoData => 'No data yet';

  @override
  String get insightsNoDataSub => 'Add daily measurements to see insights';

  @override
  String insightsPredictedOvulation(Object days) {
    return 'Predicted ovulation in $days days';
  }

  @override
  String insightsPredictedPeriod(Object days) {
    return 'Predicted period in $days days';
  }

  @override
  String insightsPredictedFertile(Object days) {
    return 'Fertile window in $days days';
  }

  @override
  String insightsCycleDay(Object day) {
    return 'Cycle day $day';
  }

  @override
  String get insightsAvgValues => 'Average values over last 3 cycles';

  @override
  String get insightsPersonalizedTips => 'Personalized tips for you';

  @override
  String get insightsBasedOnPatterns => 'Based on your patterns';

  @override
  String get insightsSeeMore => 'See more insights';

  @override
  String get insightsExportData => 'Export data';

  @override
  String get insightsShareInsights => 'Share insights';

  @override
  String get insightsSetReminder => 'Set reminder';

  @override
  String get insightsCompareCycles => 'Compare cycles';

  @override
  String get insightsGenerateReport => 'Generate report';

  @override
  String get insightTitle => 'Analytics';

  @override
  String get insightRadarTitle => 'Cycle Balance';

  @override
  String get insightRadarSubtitle => 'Follicular (Blue) vs Luteal (Orange)';

  @override
  String get insightSymptomsTitle => 'Top Symptoms';

  @override
  String get insightSymptomsSubtitle => 'Most frequent occurrences';

  @override
  String get radarEnergy => 'Energy';

  @override
  String get radarMood => 'Mood';

  @override
  String get radarSleep => 'Sleep';

  @override
  String get radarSkin => 'Skin';

  @override
  String get radarLibido => 'Libido';

  @override
  String get phaseFollicularLabel => 'Follicular';

  @override
  String get phaseLutealLabel => 'Luteal';

  @override
  String lblOccurrences(int count) {
    return '$count times';
  }

  @override
  String get lblNoDataChart => 'Not enough data yet. Keep logging!';

  @override
  String get insightCorrelationTitle => 'Smart Patterns';

  @override
  String get insightCorrelationSub => 'How your lifestyle affects your body';

  @override
  String insightPatternText(String factor, String symptom, int percent) {
    return 'When you log $factor, you experience $symptom in $percent% of cases.';
  }

  @override
  String get insightCycleDNA => 'Your Cycle DNA';

  @override
  String get insightDNASub => 'Follicular vs Luteal Persona';

  @override
  String get lblFollicular => 'Follicular';

  @override
  String get lblLuteal => 'Luteal';

  @override
  String get dialogPeriodStartTitle => 'Period Started?';

  @override
  String get dialogPeriodStartBody => 'Did your period start today or did you forget to log it?';

  @override
  String get btnToday => 'Today';

  @override
  String get btnAnotherDay => 'Select Date';

  @override
  String get splashSlogan => 'Your cycle. Your rhythm.';

  @override
  String get settingsSupport => 'Support & Feedback';

  @override
  String get emailSubject => 'EviMoon Feedback (v1.0)';

  @override
  String get emailBody => 'Describe your issue or suggestion here:\n\n\n\n--- Device Info ---\n(Please do not delete, it helps us fix bugs)\nPlatform: ';
}
