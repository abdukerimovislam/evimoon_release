// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'EviMoon';

  @override
  String get tabCycle => 'Цикл';

  @override
  String get tabCalendar => 'Календарь';

  @override
  String get tabInsights => 'Аналитика';

  @override
  String get tabLearn => 'Советы';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get phaseMenstruation => 'Менструация';

  @override
  String get phaseFollicular => 'Фолликулярная фаза';

  @override
  String get phaseOvulation => 'Овуляция';

  @override
  String get phaseLuteal => 'Лютеиновая фаза';

  @override
  String dayOfCycle(Object day) {
    return 'День $day';
  }

  @override
  String get editPeriod => 'Отметить';

  @override
  String get logSymptoms => 'Симптомы';

  @override
  String predictionText(Object days) {
    return 'Месячные через $days дн.';
  }

  @override
  String get chanceOfPregnancy => 'Высокая вероятность беременности';

  @override
  String get lowChance => 'Низкая вероятность беременности';

  @override
  String get wellnessHeader => 'Самочувствие и настроение';

  @override
  String get btnCheckIn => 'Отметить состояние';

  @override
  String get symptomHeader => 'Как самочувствие?';

  @override
  String get symptomSubHeader => 'Отметьте симптомы для точного прогноза.';

  @override
  String get catFlow => 'Выделения';

  @override
  String get catPain => 'Болевые ощущения';

  @override
  String get catMood => 'Настроение';

  @override
  String get catSleep => 'Сон';

  @override
  String get flowLight => 'Легкие';

  @override
  String get flowMedium => 'Средние';

  @override
  String get flowHeavy => 'Обильные';

  @override
  String get painNone => 'Нет боли';

  @override
  String get painCramps => 'Спазмы';

  @override
  String get painHeadache => 'Голова';

  @override
  String get painBack => 'Спина';

  @override
  String get moodHappy => 'Счастье';

  @override
  String get moodSad => 'Грусть';

  @override
  String get moodAnxious => 'Тревога';

  @override
  String get moodEnergetic => 'Энергия';

  @override
  String get moodIrritated => 'Раздражение';

  @override
  String get btnSave => 'Сохранить';

  @override
  String get legendPeriod => 'Месячные';

  @override
  String get legendFertile => 'Фертильность';

  @override
  String get legendOvulation => 'Овуляция';

  @override
  String get calendarHeader => 'История циклов';

  @override
  String get insightsTitle => 'Тренды и Анализ';

  @override
  String get chartCycleLength => 'Длина цикла';

  @override
  String get chartSubtitle => 'Последние 6 месяцев';

  @override
  String get insightTipTitle => 'Совет дня';

  @override
  String get insightTipBody => 'В лютеиновой фазе уровень энергии падает. Это отличное время для йоги и раннего отхода ко сну.';

  @override
  String get topSymptoms => 'Топ симптомов';

  @override
  String get patternDetected => 'Найден паттерн';

  @override
  String get patternBody => 'У вас часто болит голова перед началом цикла. Попробуйте пить больше воды за 2 дня до начала.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get sectionGeneral => 'Основное';

  @override
  String get sectionSecurity => 'Безопасность';

  @override
  String get lblLanguage => 'Язык приложения';

  @override
  String get lblNotifications => 'Уведомления';

  @override
  String get lblBiometrics => 'Вход по биометрии';

  @override
  String get lblExport => 'Экспорт данных (PDF)';

  @override
  String get lblDeleteAccount => 'Удалить все данные';

  @override
  String get descDelete => 'Это действие необратимо удалит все записи с устройства.';

  @override
  String get alertDeleteTitle => 'Вы уверены?';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get btnNext => 'Далее';

  @override
  String get btnStart => 'Начать';

  @override
  String get greetMorning => 'Доброе утро';

  @override
  String get greetAfternoon => 'Добрый день';

  @override
  String get greetEvening => 'Добрый вечер';

  @override
  String get phaseStatusMenstruation => 'Время для отдыха и заботы';

  @override
  String get phaseStatusFollicular => 'Энергия растет';

  @override
  String get phaseStatusOvulation => 'Вы сегодня сияете';

  @override
  String get phaseStatusLuteal => 'Будьте бережны к себе';

  @override
  String get notifPeriodTitle => 'Скоро новый цикл';

  @override
  String get notifPeriodBody => 'Месячные могут начаться через 2 дня. Не забудьте подготовиться!';

  @override
  String get notifOvulationTitle => 'Окно фертильности';

  @override
  String get notifOvulationBody => 'Сегодня высокая вероятность овуляции. Вы сияете! 🌸';

  @override
  String get phaseLate => 'Задержка';

  @override
  String get sectionCycle => 'Настройки цикла';

  @override
  String get lblCycleLength => 'Длина цикла';

  @override
  String get lblPeriodLength => 'Длительность месячных';

  @override
  String get authLockedTitle => 'EviMoon заблокирован';

  @override
  String get authUnlockBtn => 'Разблокировать';

  @override
  String get authReason => 'Подтвердите личность для входа';

  @override
  String get authNotAvailable => 'Биометрия недоступна на устройстве';

  @override
  String get pdfReportTitle => 'Отчет о здоровье EviMoon';

  @override
  String get pdfCycleHistory => 'История циклов';

  @override
  String get pdfHeaderStart => 'Начало';

  @override
  String get pdfHeaderEnd => 'Конец (Прогноз)';

  @override
  String get pdfHeaderLength => 'Длительность (дн.)';

  @override
  String get pdfCurrent => 'Текущий';

  @override
  String get pdfGenerated => 'Сгенерировано в EviMoon';

  @override
  String get pdfPage => 'Страница';

  @override
  String get dayTitle => 'День';

  @override
  String get insightMenstruationTitle => 'Отдых и Перезагрузка';

  @override
  String get insightMenstruationSubtitle => 'Держитесь в тепле, пейте чай, избегайте нагрузок.';

  @override
  String get insightFollicularTitle => 'Творческая Искра';

  @override
  String get insightFollicularSubtitle => 'Энергия растет! Мозг работает на пике.';

  @override
  String get insightOvulationTitle => 'Суперсила';

  @override
  String get insightOvulationSubtitle => 'Вы магнит для окружающих. Высокое либидо.';

  @override
  String get insightLutealTitle => 'Внутренний Фокус';

  @override
  String get insightLutealSubtitle => 'Спокойствие или раздражение. Фокус внутрь себя.';

  @override
  String get insightLateTitle => 'Сохраняйте спокойствие';

  @override
  String get insightLateSubtitle => 'Снизьте стресс и следите за питанием.';

  @override
  String get lblEnergy => 'Энергия';

  @override
  String get lblMood => 'Настр.';

  @override
  String get tapToClose => 'Нажмите, чтобы закрыть';

  @override
  String get btnPeriodStart => 'НАЧАЛИСЬ';

  @override
  String get btnPeriodEnd => 'ЗАКОНЧИЛИСЬ';

  @override
  String get dialogStartTitle => 'Начать новый цикл?';

  @override
  String get dialogStartBody => 'Сегодняшний день будет отмечен как 1-й день месячных.';

  @override
  String get dialogEndTitle => 'Месячные закончились?';

  @override
  String get dialogEndBody => 'Текущая фаза сменится на фолликулярную.';

  @override
  String get btnConfirm => 'Да, подтвердить';

  @override
  String get btnCancel => 'Отмена';

  @override
  String get logFlow => 'Выделения';

  @override
  String get logPain => 'Боль';

  @override
  String get logMood => 'Настроение';

  @override
  String get logSleep => 'Качество сна';

  @override
  String get logNotes => 'Заметки';

  @override
  String get insightPhasesTitle => 'Фазы цикла';

  @override
  String get insightPhasesSubtitle => 'Распределение по длительности';

  @override
  String get insightMoodTitle => 'Эмоции по фазам';

  @override
  String get insightMoodSubtitle => 'Средний уровень настроения';

  @override
  String get insightAvgCycle => 'Ср. цикл';

  @override
  String get insightAvgPeriod => 'Ср. месячные';

  @override
  String get phaseShortMens => 'МЕНС';

  @override
  String get phaseShortFoll => 'ФОЛЛ';

  @override
  String get phaseShortOvul => 'ОВУЛ';

  @override
  String get phaseShortLut => 'ЛЮТ';

  @override
  String get unitDaysShort => 'д';

  @override
  String get insightBodyBalance => 'Баланс Тела';

  @override
  String get insightBodyBalanceSub => 'Фолликулярная (Фиол.) vs Лютеиновая (Оранж.)';

  @override
  String get insightMoodFlow => 'Поток Настроения';

  @override
  String get insightMoodFlowSub => 'Тренд за последние 30 дней';

  @override
  String get paramEnergy => 'Энергия';

  @override
  String get paramLibido => 'Либидо';

  @override
  String get paramSkin => 'Кожа';

  @override
  String get predTitle => 'Прогноз на день';

  @override
  String get predSubtitle => 'На основе цикла и качества сна';

  @override
  String get recHighEnergy => 'Отличный день для спорта и задач!';

  @override
  String get recLowEnergy => 'Не перегружайся. Сегодня нужен отдых.';

  @override
  String get recNormalEnergy => 'Держи привычный темп.';

  @override
  String get btnWrong => 'Не так';

  @override
  String msgFeedback(Object metric, Object status) {
    return 'Правда ли $metric сегодня $status?';
  }

  @override
  String get paramFocus => 'Фокус';

  @override
  String get statusLow => 'Низкий';

  @override
  String get statusHigh => 'Высокий';

  @override
  String get statusNormal => 'Норма';

  @override
  String get feedbackTitle => 'Уточнение прогноза';

  @override
  String feedbackQuestion(Object metric, Object status) {
    return 'Твой показатель «$metric» сегодня действительно «$status»?';
  }

  @override
  String get btnYesCorrect => 'Да, всё верно';

  @override
  String get btnNoWrong => 'Нет, ошибка';

  @override
  String get cocActivePhase => 'Активные таблетки';

  @override
  String get cocBreakPhase => 'Неделя перерыва';

  @override
  String cocPredictionActive(Object days) {
    return 'Осталось $days активных';
  }

  @override
  String cocPredictionBreak(Object days) {
    return 'Новая пачка через $days дн.';
  }

  @override
  String get btnStartNewPack => 'Начать новую пачку';

  @override
  String get btnRestartPack => 'Перезапуск';

  @override
  String get dialogStartPackTitle => 'Начать новую пачку?';

  @override
  String get dialogStartPackBody => 'Это сбросит цикл на День 1. Используйте, когда открываете новую упаковку.';

  @override
  String get pillTaken => 'Принята';

  @override
  String get pillTake => 'Принять таблетку';

  @override
  String pillScheduled(String time) {
    return 'По расписанию в $time';
  }

  @override
  String get blisterMyPack => 'Моя упаковка';

  @override
  String blisterDay(Object day, Object total) {
    return 'День $day из $total';
  }

  @override
  String blisterOverdue(Object day) {
    return 'День $day (Просрочено)';
  }

  @override
  String get blister21 => 'Пачка 21 день';

  @override
  String get blister28 => 'Пачка 28 дней';

  @override
  String get legendTaken => 'Принято';

  @override
  String get legendActive => 'Актив';

  @override
  String get legendPlacebo => 'Плацебо';

  @override
  String get legendBreak => 'Перерыв';

  @override
  String get insightCOCActiveTitle => 'Вы защищены';

  @override
  String get insightCOCActiveBody => 'Фаза активных таблеток. Старайтесь принимать их в одно и то же время.';

  @override
  String get insightCOCBreakTitle => 'Кровотечение отмены';

  @override
  String get insightCOCBreakBody => 'Неделя перерыва. Ожидается кровотечение из-за снижения уровня гормонов.';

  @override
  String get settingsContraception => 'Контрацепция';

  @override
  String get settingsTrackPill => 'Трекер таблеток (КОК)';

  @override
  String get settingsPackType => 'Тип упаковки';

  @override
  String settingsPills(Object count) {
    return '$count шт.';
  }

  @override
  String get settingsReminder => 'Напоминание';

  @override
  String get settingsPackSettings => 'Настройки пачки';

  @override
  String get settingsPlaceboCount => 'Кол-во плацебо';

  @override
  String get settingsBreakDuration => 'Длительность перерыва';

  @override
  String get settingsGeneral => 'Общие';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsNotifs => 'Уведомления';

  @override
  String get settingsData => 'Данные и Безопасность';

  @override
  String get settingsBiometrics => 'Вход по биометрии';

  @override
  String get settingsExport => 'Скачать PDF отчет';

  @override
  String get settingsReset => 'Сброс и удаление данных';

  @override
  String get dialogResetTitle => 'Сбросить приложение?';

  @override
  String get dialogResetBody => 'Это удалит все ваши записи и настройки. Действие нельзя отменить.';

  @override
  String get btnDelete => 'Удалить';

  @override
  String get logSymptomsTitle => 'Отметить симптомы';

  @override
  String get msgSaved => 'Сохранено!';

  @override
  String get logSkin => 'Состояние кожи';

  @override
  String get logLibido => 'Либидо';

  @override
  String get symptomNausea => 'Тошнота';

  @override
  String get symptomBloating => 'Вздутие';

  @override
  String get lblNoData => 'Нет данных';

  @override
  String get lblNoSymptoms => 'Симптомы не отмечены.';

  @override
  String get notifPillTitle => '💊 Время таблетки';

  @override
  String get notifPillBody => 'Оставайтесь под защитой! Примите таблетку сейчас.';

  @override
  String get logVitals => 'Показатели';

  @override
  String get lblTemp => 'Температура (БТ)';

  @override
  String get lblWeight => 'Вес (кг)';

  @override
  String get lblLifestyle => 'Образ жизни';

  @override
  String get factorStress => 'Стресс';

  @override
  String get factorAlcohol => 'Алкоголь';

  @override
  String get factorTravel => 'Поездки';

  @override
  String get factorSport => 'Спорт';

  @override
  String get hintNotes => 'Что-то еще произошло?';

  @override
  String get symptomAcne => 'Акне';

  @override
  String get lblLifestyleHeader => 'Образ жизни';

  @override
  String predInsightHormones(Object hormone) {
    return 'Гормоны: $hormone повышается.';
  }

  @override
  String get predMismatchTitle => 'Чувствуете себя иначе?';

  @override
  String get predMismatchBody => 'Нажмите на иконку, чтобы изменить совет.';

  @override
  String get btnAdjust => 'Изменить';

  @override
  String get stateLow => 'Низкий';

  @override
  String get stateMedium => 'Средний';

  @override
  String get stateHigh => 'Высокий';

  @override
  String get tipLowEnergy => 'День отдыха. Попробуйте йогу или короткий сон.';

  @override
  String get tipHighEnergy => 'Отличное время для кардио или сложных задач!';

  @override
  String get tipLowMood => 'Будьте бережны к себе. Шоколад помогает.';

  @override
  String get tipHighMood => 'Делитесь настроением! Творите и общайтесь.';

  @override
  String get tipLowFocus => 'Избегайте многозадачности. Выберите одну мелкую цель.';

  @override
  String get tipHighFocus => 'Режим глубокой работы. Беритесь за сложное.';

  @override
  String get hormoneEstrogen => 'Эстроген';

  @override
  String get hormoneProgesterone => 'Прогестерон';

  @override
  String get hormoneReset => 'Гормональная перезагрузка';

  @override
  String get onboardTitle1 => 'Добро пожаловать';

  @override
  String get onboardBody1 => 'Отслеживайте цикл, понимайте своё тело и живите в гармонии с собой.';

  @override
  String get onboardTitle2 => 'Начало менструации';

  @override
  String get onboardBody2 => 'Выберите первый день последних месячных для точного прогноза.';

  @override
  String get onboardTitle3 => 'Длина цикла';

  @override
  String get onboardBody3 => 'Сколько дней обычно проходит между менструациями? В среднем это 28 дней.';

  @override
  String get daysUnit => 'Дн.';

  @override
  String get insightVitals => 'Динамика тела';

  @override
  String get hadSex => 'Секс';

  @override
  String get protectedSex => 'Защищенный';

  @override
  String get lblIntimacy => 'Интим';

  @override
  String get lblWellness => 'Самочувствие';

  @override
  String get insightVitalsSub => 'График температуры и веса';

  @override
  String cocDayInfo(int day) {
    return 'День $day из 28';
  }

  @override
  String get dialogPackTitle => 'Выберите тип упаковки';

  @override
  String get dialogPackSubtitle => 'Укажите формат упаковки, который вы используете.';

  @override
  String get pack21Title => '21 Таблетка';

  @override
  String get pack21Subtitle => '21 Активная + 7 Дней перерыва';

  @override
  String get pack28Title => '28 Таблеток';

  @override
  String get pack28Subtitle => '21 Активная + 7 Плацебо';

  @override
  String get btnSaveSettings => 'Сохранить настройки';

  @override
  String get dialogCOCStartTitle => 'Трекер Таблеток';

  @override
  String get dialogCOCStartSubtitle => 'Вы начинаете новую пачку сегодня или продолжаете текущую?';

  @override
  String get optionFreshPack => 'Новая пачка';

  @override
  String get optionFreshPackSub => 'Сегодня День 1';

  @override
  String get optionContinuePack => 'Продолжить пачку';

  @override
  String get optionContinuePackSub => 'Выбрать дату начала';

  @override
  String get labelOr => 'ИЛИ';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogResetConfirm => 'Delete Everything';

  @override
  String get insightsOverview => 'Обзор';

  @override
  String get insightsHealth => 'Здоровье';

  @override
  String get insightsPatterns => 'Паттерны';

  @override
  String get insightsVitals => 'Показатели тела';

  @override
  String get insightsVitalsSub => 'Температура и вес';

  @override
  String get currentCycle => 'Текущий цикл';

  @override
  String get regularity => 'Регулярность';

  @override
  String get ovulation => 'Овуляция';

  @override
  String get averageMood => 'Среднее настроение';

  @override
  String get sleepQuality => 'Качество сна';

  @override
  String get nextPhases => 'Следующие фазы';

  @override
  String get prediction => 'Прогноз';

  @override
  String get sleepAndEnergy => 'Сон и энергия по фазам';

  @override
  String get bodyTemperature => 'Температура тела';

  @override
  String get basalTemperature => 'Базальная температура за 14 дней';

  @override
  String get positiveTrend => 'Позитивная тенденция';

  @override
  String get recommendation => 'Рекомендация';

  @override
  String get cycleRegularity => 'Регулярность цикла';

  @override
  String get fertilityWindow => 'Окно фертильности';

  @override
  String get symptomPatterns => 'Шаблоны симптомов';

  @override
  String get correlationAnalysis => 'Анализ корреляций';

  @override
  String get historicalComparison => 'Историческое сравнение';

  @override
  String get dailyMetrics => 'Ежедневные показатели';

  @override
  String get trends => 'Тренды';

  @override
  String get phaseComparison => 'Сравнение фаз';

  @override
  String get energyEfficiency => 'Эффективность энергии';

  @override
  String get sleepEfficiency => 'Эффективность сна';

  @override
  String get start => 'Начало';

  @override
  String get end => 'Конец';

  @override
  String get today => 'Сегодня';

  @override
  String get improvement => 'Улучшение';

  @override
  String get insightsNoData => 'Данных пока нет';

  @override
  String get insightsNoDataSub => 'Добавляйте ежедневные измерения, чтобы увидеть аналитику';

  @override
  String insightsPredictedOvulation(Object days) {
    return 'Прогнозируемая овуляция через $days дней';
  }

  @override
  String insightsPredictedPeriod(Object days) {
    return 'Прогнозируемые месячные через $days дней';
  }

  @override
  String insightsPredictedFertile(Object days) {
    return 'Фертильное окно через $days дней';
  }

  @override
  String insightsCycleDay(Object day) {
    return '$day день цикла';
  }

  @override
  String get insightsAvgValues => 'Средние значения за последние 3 цикла';

  @override
  String get insightsPersonalizedTips => 'Персонализированные рекомендации';

  @override
  String get insightsBasedOnPatterns => 'На основе ваших паттернов';

  @override
  String get insightsSeeMore => 'Посмотреть больше аналитики';

  @override
  String get insightsExportData => 'Экспортировать данные';

  @override
  String get insightsShareInsights => 'Поделиться аналитикой';

  @override
  String get insightsSetReminder => 'Установить напоминание';

  @override
  String get insightsCompareCycles => 'Сравнить циклы';

  @override
  String get insightsGenerateReport => 'Создать отчет';

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
  String get insightCorrelationTitle => 'Умные паттерны';

  @override
  String get insightCorrelationSub => 'Влияние образа жизни на тело';

  @override
  String insightPatternText(String factor, String symptom, int percent) {
    return 'При факторе $factor, симптом $symptom возникает в $percent% случаев.';
  }

  @override
  String get insightCycleDNA => 'ДНК Цикла';

  @override
  String get insightDNASub => 'Портрет фаз';

  @override
  String get lblFollicular => 'Фолликулярная';

  @override
  String get lblLuteal => 'Лютеиновая';

  @override
  String get dialogPeriodStartTitle => 'Начались месячные?';

  @override
  String get dialogPeriodStartBody => 'Они начались сегодня или вы забыли отметить раньше?';

  @override
  String get btnToday => 'Сегодня';

  @override
  String get btnAnotherDay => 'Выбрать дату';

  @override
  String get splashSlogan => 'Твой цикл. Твой ритм.';

  @override
  String get settingsSupport => 'Поддержка и Отзывы';

  @override
  String get emailSubject => 'EviMoon Отзыв (v1.0)';

  @override
  String get emailBody => 'Опишите проблему или предложение здесь:\n\n\n\n--- Инфо об устройстве ---\n(Пожалуйста, не удаляйте, это поможет исправить баги)\nПлатформа: ';
}
