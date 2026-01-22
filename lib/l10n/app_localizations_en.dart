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
  String get pdfGenerated => 'Generated';

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
  String get logSleep => 'Sleep';

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
  String get insightAvgCycle => 'Average Cycle Length';

  @override
  String get insightAvgPeriod => 'Average Period Length';

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
  String get settingsTrackPill => 'Track Contraceptive Pill';

  @override
  String get settingsPackType => 'Pack Type';

  @override
  String settingsPills(Object count) {
    return '$count Pills';
  }

  @override
  String get settingsReminder => 'Reminder';

  @override
  String get settingsPackSettings => 'Pack Settings';

  @override
  String get settingsPlaceboCount => 'Placebo Days';

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
  String get settingsBiometrics => 'Biometric Login';

  @override
  String get settingsExport => 'Download PDF Report';

  @override
  String get settingsReset => 'Reset All Data';

  @override
  String get dialogResetTitle => 'Reset Everything?';

  @override
  String get dialogResetBody => 'This will delete all your data permanently. This action cannot be undone.';

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
  String get notifPillTitle => 'Time to take your pill!';

  @override
  String get notifPillBody => 'Stay protected and track your cycle.';

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
  String get hintNotes => 'Add a note...';

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
  String get daysUnit => 'days';

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
  String get dialogCOCStartTitle => 'Track Contraception?';

  @override
  String get dialogCOCStartSubtitle => 'Choose how you want to start tracking your pill pack.';

  @override
  String get optionFreshPack => 'Start Fresh Pack';

  @override
  String get optionFreshPackSub => 'I\'m starting a new pack today';

  @override
  String get optionContinuePack => 'Continue Current';

  @override
  String get optionContinuePackSub => 'I\'m in the middle of a pack';

  @override
  String get labelOr => 'OR';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogResetConfirm => 'Reset';

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
  String get emailSubject => 'EviMoon Feedback';

  @override
  String get emailBody => 'Hello EviMoon Team,\n\nI have a question/suggestion regarding the app on';

  @override
  String get insightProstaglandinsTitle => 'Prostaglandins at work';

  @override
  String get insightProstaglandinsBody => 'Uterine contractions help shed the lining. Warmth and magnesium usually help.';

  @override
  String get insightWinterPhaseTitle => 'Rest & Restore';

  @override
  String get insightWinterPhaseBody => 'Hormones are at their lowest. It\'s okay to slow down and recharge.';

  @override
  String get insightEstrogenTitle => 'Estrogen Rising';

  @override
  String get insightEstrogenBody => 'Estrogen boosts serotonin. Great time for creative tasks and planning!';

  @override
  String get insightMittelschmerzTitle => 'Mittelschmerz';

  @override
  String get insightMittelschmerzBody => 'You might be feeling the exact moment of ovulation. It is usually brief.';

  @override
  String get insightFertilityTitle => 'Fertility Signals';

  @override
  String get insightFertilityBody => 'Nature encourages social connection now. You are magnetic!';

  @override
  String get insightWaterTitle => 'Water Retention';

  @override
  String get insightWaterBody => 'Body holds water preparing for potential pregnancy. It will pass soon.';

  @override
  String get insightProgesteroneTitle => 'Progesterone Drop';

  @override
  String get insightProgesteroneBody => 'Brain chemicals dip before period. Be gentle with yourself today.';

  @override
  String get insightSkinTitle => 'Hormonal Skin';

  @override
  String get insightSkinBody => 'Progesterone stimulates oil glands. Keep skincare simple.';

  @override
  String get insightMetabolismTitle => 'Energy Demands';

  @override
  String get insightMetabolismBody => 'Metabolism speeds up. Choose complex carbs instead of sugar.';

  @override
  String get insightSpottingTitle => 'Spotting Detected';

  @override
  String get insightSpottingBody => 'Light bleeding can happen during ovulation or due to stress.';

  @override
  String get premiumInsightLabel => 'PREMIUM INSIGHT';

  @override
  String get calendarForecastTitle => 'CALENDAR & FORECAST';

  @override
  String get aiForecastHigh => 'Forecast is Accurate';

  @override
  String get aiForecastHighSub => 'Based on your stable history';

  @override
  String get aiForecastMedium => 'Moderate Confidence';

  @override
  String get aiForecastMediumSub => 'Some cycle variations detected';

  @override
  String get aiForecastLow => 'Low Accuracy';

  @override
  String get aiForecastLowSub => 'Cycle length varies significantly';

  @override
  String get aiLearning => 'AI Learning...';

  @override
  String get aiLearningSub => 'Log 3 cycles to unlock forecast';

  @override
  String get confidenceHighDesc => 'Cycle is predictable and regular.';

  @override
  String get confidenceMedDesc => 'Forecast based on average data.';

  @override
  String get confidenceLowDesc => 'Predictions may vary due to irregular history.';

  @override
  String get confidenceCalcDesc => 'Gathering more data for better accuracy.';

  @override
  String get confidenceNoData => 'Not enough history yet.';

  @override
  String get factorDataNeeded => 'Need at least 3 cycles';

  @override
  String get factorHighVar => 'High irregularity detected';

  @override
  String get factorSlightVar => 'Slight irregularity';

  @override
  String get factorStable => 'Cycle is stable';

  @override
  String get factorAnomaly => 'Recent anomaly detected';

  @override
  String get aiDialogTitle => 'AI Forecast Analysis';

  @override
  String aiDialogScore(int score) {
    return 'Your cycle forecast confidence score is $score%.';
  }

  @override
  String get aiDialogExplanation => 'This score is calculated locally based on your cycle history variance.';

  @override
  String get aiDialogFactors => 'Factors:';

  @override
  String get btnGotIt => 'Got it';

  @override
  String get navHome => 'Today';

  @override
  String get navSymptoms => 'Symptoms';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navProfile => 'Profile';

  @override
  String get msgSavedNoPop => 'Symptoms updated successfully';

  @override
  String get lblFlowAndLove => 'Flow & Intimacy';

  @override
  String get sectionBackup => 'Backup & Restore';

  @override
  String get btnSaveBackup => 'Save Backup';

  @override
  String get btnRestoreBackup => 'Restore from File';

  @override
  String get dialogRestoreTitle => 'Restore Data?';

  @override
  String get dialogRestoreBody => 'This will overwrite your current data with the backup file. Are you sure?';

  @override
  String get btnRestore => 'Restore';

  @override
  String get msgRestoreSuccess => 'Data restored successfully!';

  @override
  String msgEmailError(Object email) {
    return 'Could not open email client. Write to: $email';
  }

  @override
  String get msgExportEmpty => 'No data to export yet.';

  @override
  String get msgExportError => 'Could not generate PDF';

  @override
  String get msgBiometricsError => 'Biometrics not available on this device';

  @override
  String get authBiometricsReason => 'Confirm to enable biometrics';

  @override
  String get lblUser => 'EviMoon User';

  @override
  String get modeTTC => 'Pregnancy Planning';

  @override
  String get modeTTCDesc => 'Enable fertility tracking and ovulation focus';

  @override
  String get modeTTCActive => 'Fertility Mode Activated';

  @override
  String get dialogTTCConflict => 'Disable Contraception?';

  @override
  String get dialogTTCConflictBody => 'To enable Pregnancy Planning mode, contraceptive tracking must be disabled.';

  @override
  String get btnDisableAndSwitch => 'Disable & Switch';

  @override
  String get ttcStatusLow => 'Low Chance';

  @override
  String get ttcStatusHigh => 'High Fertility';

  @override
  String get ttcStatusPeak => 'Peak Fertility';

  @override
  String get ttcStatusOvulation => 'Ovulation Day';

  @override
  String ttcDPO(Object days) {
    return '$days DPO';
  }

  @override
  String get ttcChance => 'Conception Chance';

  @override
  String get ttcTestWait => 'Too early to test';

  @override
  String get ttcTestReady => 'You can test today';

  @override
  String lblCycleDay(Object day) {
    return 'Cycle Day $day';
  }

  @override
  String get ttcBtnBBT => 'Log BBT';

  @override
  String get ttcBtnTest => 'LH Test';

  @override
  String get ttcBtnSex => 'Intimacy';

  @override
  String get ttcLogTitle => 'Today\'s Log';

  @override
  String get ttcSectionBBT => 'Basal Body Temperature';

  @override
  String get ttcSectionTest => 'Ovulation Test (LH)';

  @override
  String get ttcSectionSex => 'Intimacy';

  @override
  String get lblNegative => 'Negative (-)';

  @override
  String get lblPositive => 'Positive (+)';

  @override
  String get lblPeak => 'Peak';

  @override
  String get lblSexYes => 'Yes, we did!';

  @override
  String get lblSexNo => 'Not today';

  @override
  String get ttcTipTitle => 'Daily Tip';

  @override
  String get ttcTipDefault => 'Stress affects ovulation. Try 5 min meditation today.';

  @override
  String get dialogHighTempTitle => 'High Temperature';

  @override
  String get dialogHighTempBody => 'Temperature above 37.5°C usually indicates fever, not ovulation.';

  @override
  String get dialogLowTempTitle => 'Low Temperature';

  @override
  String get dialogLowTempBody => 'Temperature below 35.5°C is unusually low. Is this a typo?';

  @override
  String get dialogPeriodLHTitle => 'Unusual Reading';

  @override
  String get dialogPeriodLHBody => 'Positive LH test during menstruation is rare. It might be an error.';

  @override
  String get btnLogAnyway => 'Log Anyway';

  @override
  String get insightFertilitySub => 'How your body signals ovulation';

  @override
  String get insightLibidoHigh => 'High Libido during fertile window';

  @override
  String get insightPainOvulation => 'Ovulation pain (Mittelschmerz) detected';

  @override
  String get insightTempShift => 'Temperature shift detected after ovulation';

  @override
  String get lblDetected => 'Detected';

  @override
  String get transitionTTC => 'The journey begins... ✨';

  @override
  String get transitionCOC => 'Protection activated 🛡️';

  @override
  String get transitionTrack => 'Listening to your body 🌿';

  @override
  String get legendFollicular => 'Follicular';

  @override
  String get legendLuteal => 'Luteal';

  @override
  String get lblBodyMind => 'Body & Mind';

  @override
  String get pdfReportSubtitle => 'Gynecological & Cycle History';

  @override
  String get pdfPatient => 'Patient';

  @override
  String get pdfClinicalSummary => 'Clinical Summary';

  @override
  String get pdfDetailedLogs => 'Detailed Logs';

  @override
  String get pdfAvgCycle => 'Avg Cycle Length';

  @override
  String get pdfAvgPeriod => 'Avg Period';

  @override
  String get pdfPainReported => 'Pain Reported';

  @override
  String get pdfTableDate => 'Date';

  @override
  String get pdfTableCD => 'CD';

  @override
  String get pdfTableSymptoms => 'Symptoms';

  @override
  String get pdfTableBBT => 'BBT';

  @override
  String get pdfTableNotes => 'Notes';

  @override
  String get pdfFlowShort => 'Flow';

  @override
  String get unitDays => 'days';

  @override
  String get pdfDisclaimer => 'DISCLAIMER: This report is generated by EviMoon based on user-inputted data. It does not constitute a medical diagnosis. Please consult a healthcare professional for interpretation.';

  @override
  String get dialogDataInsufficientTitle => 'Insufficient Data';

  @override
  String get dialogDataInsufficientBody => 'To generate a clinical report, we need at least 7 days of logs or one complete cycle. This ensures clinical accuracy for your doctor.';

  @override
  String get btnOk => 'Understood';

  @override
  String get splashTitle => 'EviMoon';

  @override
  String get notifPhaseFollicularTitle => 'Energy Rising ⚡';

  @override
  String get notifPhaseFollicularBody => 'Estrogen is up! Your brain is sharp and your body is ready for action.';

  @override
  String get notifPhaseOvulationTitle => 'You are glowing 🌸';

  @override
  String get notifPhaseOvulationBody => 'Peak fertility and confidence. Perfect for big meetings (or dates).';

  @override
  String get notifPhaseLutealTitle => 'Be Gentle 🌙';

  @override
  String get notifPhaseLutealBody => 'Progesterone is rising. Feeling tired is okay. Take it slow.';

  @override
  String get notifPhasePeriodTitle => 'New Cycle 🩸';

  @override
  String get notifPhasePeriodBody => 'Don\'t forget to log the start of your period.';

  @override
  String get notifLatePeriodTitle => 'Late Period?';

  @override
  String get notifLatePeriodBody => 'Cycle is longer than usual. Log symptoms or take a test.';

  @override
  String get notifLogCheckinTitle => 'How do you feel?';

  @override
  String get notifLogCheckinBody => 'Take a second to log your symptoms for better predictions.';

  @override
  String get settingsDailyLog => 'Daily Check-in (20:00)';

  @override
  String get paywallTitle => 'EviMoon Premium';

  @override
  String get paywallSubtitle => 'Unlock the full potential of your cycle.';

  @override
  String get featureTimersTitle => 'Premium Timer Designs';

  @override
  String get featureTimersDesc => 'Unique styles for your home screen';

  @override
  String get featurePdfTitle => 'Medical PDF Report';

  @override
  String get featurePdfDesc => 'Share symptom history with your doctor';

  @override
  String get featureAiTitle => 'AI Cycle Confidence';

  @override
  String get featureAiDesc => 'Know how accurate your forecast is';

  @override
  String get featureTtcTitle => 'Pregnancy Planning Mode';

  @override
  String get featureTtcDesc => 'Specialized tools for conception';

  @override
  String get paywallNoOffers => 'No offers available';

  @override
  String get paywallSelectPlan => 'Select Plan';

  @override
  String paywallSubscribeFor(String price) {
    return 'Subscribe for $price';
  }

  @override
  String get paywallRestore => 'Restore Purchases';

  @override
  String get paywallTerms => 'Terms & Privacy';

  @override
  String get paywallBestValue => 'BEST VALUE';

  @override
  String get msgNoSubscriptions => 'No active subscriptions found';

  @override
  String get proStatusTitle => 'Subscription Status';

  @override
  String get proStatusActive => 'Premium Active';

  @override
  String get proStatusDesc => 'You have full access to all features.';

  @override
  String get btnManageSub => 'Manage Subscription';

  @override
  String get btnManageSubDesc => 'Change plan or cancel in iOS Settings';

  @override
  String get msgLinkError => 'Could not open settings';

  @override
  String get tipPeriod => 'Rest up and eat iron-rich foods.';

  @override
  String get tipOvulation => 'Peak fertility! Ideal time to conceive.';

  @override
  String get tipLutealEarly => 'Progesterone is rising. Stay hydrated.';

  @override
  String get tipLutealLate => 'Implantation window. Avoid high stress.';

  @override
  String get tipFollicular => 'Energy is rising. Good for exercise.';

  @override
  String get msgLhPeakRecorded => 'LH Peak recorded! High fertility window active.';

  @override
  String get phaseNewMoon => 'New Moon';

  @override
  String get phaseWaxingCrescent => 'Waxing Crescent';

  @override
  String get phaseFirstQuarter => 'First Quarter';

  @override
  String get phaseFullMoon => 'Full Moon';

  @override
  String get phaseWaningGibbous => 'Waning Gibbous';

  @override
  String get phaseWaningCrescent => 'Waning Crescent';

  @override
  String get ttcChanceHigh => 'High Chance';

  @override
  String get ttcChancePeak => 'Peak Fertility';

  @override
  String get ttcChanceLow => 'Low Chance';

  @override
  String ttcCycleDay(int day) {
    return 'CYCLE DAY $day';
  }

  @override
  String get lblTest => 'LH Test';

  @override
  String get lblSex => 'Intimacy';

  @override
  String get lblMucus => 'Mucus';

  @override
  String valMeasured(double temp) {
    return '$temp°';
  }

  @override
  String get valPositive => 'Positive';

  @override
  String get valPeak => 'Peak';

  @override
  String get valNegative => 'Negative';

  @override
  String get valSexYes => 'Logged';

  @override
  String get valMucusLogged => 'Logged';

  @override
  String get titleInputBBT => 'Log Temperature';

  @override
  String get titleInputTest => 'LH Test Result';

  @override
  String get titleInputSex => 'Intimacy details';

  @override
  String get titleInputMucus => 'Cervical Mucus';

  @override
  String get chipNegative => 'Negative';

  @override
  String get chipPositive => 'Positive';

  @override
  String get chipPeak => 'Peak';

  @override
  String get labelSexNo => 'No';

  @override
  String get labelSexYes => 'Yes';

  @override
  String get mucusDry => 'Dry';

  @override
  String get mucusSticky => 'Sticky';

  @override
  String get mucusCreamy => 'Creamy';

  @override
  String get mucusWatery => 'Watery';

  @override
  String get mucusEggWhite => 'Egg White';

  @override
  String get ttcChartTitle => 'BBT CHART (14 DAYS)';

  @override
  String get ttcChartPlaceholder => 'Log temperature to see chart';

  @override
  String get hintTemp => '36.6';

  @override
  String get prefNotifications => 'Notifications';

  @override
  String get prefBiometrics => 'FaceID / TouchID';

  @override
  String get prefCOC => 'Contraceptive Pill Mode';

  @override
  String get sectionData => 'Data Management';

  @override
  String get btnExportPdf => 'Export PDF Report';

  @override
  String get btnBackup => 'Backup Data';

  @override
  String get sectionAbout => 'About';

  @override
  String get btnContactSupport => 'Contact Support';

  @override
  String get btnRateApp => 'Rate EviMoon';
}
