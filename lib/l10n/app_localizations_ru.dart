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
  String get navHome => 'Сегодня';

  @override
  String get navSymptoms => 'Симптомы';

  @override
  String get navCalendar => 'Календарь';

  @override
  String get navProfile => 'Профиль';

  @override
  String get phaseMenstruation => 'Менструация';

  @override
  String get phaseFollicular => 'Фолликулярная фаза';

  @override
  String get phaseOvulation => 'Овуляция';

  @override
  String get phaseLuteal => 'Лютеиновая фаза';

  @override
  String get phaseLate => 'Задержка';

  @override
  String get phaseShortMens => 'МЕНС';

  @override
  String get phaseShortFoll => 'ФОЛЛ';

  @override
  String get phaseShortOvul => 'ОВУЛ';

  @override
  String get phaseShortLut => 'ЛЮТ';

  @override
  String get phaseStatusMenstruation => 'Время для отдыха и заботы';

  @override
  String get phaseStatusFollicular => 'Энергия растет';

  @override
  String get phaseStatusOvulation => 'Вы сегодня сияете';

  @override
  String get phaseStatusLuteal => 'Будьте бережны к себе';

  @override
  String dayOfCycle(int day) {
    return 'День $day';
  }

  @override
  String get editPeriod => 'Отметить';

  @override
  String get logSymptoms => 'Симптомы';

  @override
  String get logSymptomsTitle => 'Отметить симптомы';

  @override
  String predictionText(int days) {
    return 'Месячные через $days дн.';
  }

  @override
  String get chanceOfPregnancy => 'Высокая вероятность';

  @override
  String get lowChance => 'Низкая вероятность';

  @override
  String get wellnessHeader => 'Самочувствие и настроение';

  @override
  String get lblFlowAndLove => 'Выделения и Близость';

  @override
  String get lblBodyMind => 'Тело и Разум';

  @override
  String get btnCheckIn => 'Отметить состояние';

  @override
  String get symptomHeader => 'Как самочувствие?';

  @override
  String get symptomSubHeader => 'Отметьте симптомы для точного прогноза.';

  @override
  String get msgSaved => 'Сохранено!';

  @override
  String get msgSavedNoPop => 'Симптомы обновлены';

  @override
  String get catFlow => 'Выделения';

  @override
  String get logFlow => 'Выделения';

  @override
  String get flowLight => 'Лёгкие';

  @override
  String get flowMedium => 'Умеренные';

  @override
  String get flowHeavy => 'Обильные';

  @override
  String get catPain => 'Болевые ощущения';

  @override
  String get logPain => 'Боль';

  @override
  String get painNone => 'Нет боли';

  @override
  String get painCramps => 'Спазмы';

  @override
  String get painHeadache => 'Голова';

  @override
  String get painBack => 'Спина';

  @override
  String get catMood => 'Настроение';

  @override
  String get logMood => 'Настроение';

  @override
  String get moodHappy => 'Радость';

  @override
  String get moodSad => 'Грусть';

  @override
  String get moodAnxious => 'Тревога';

  @override
  String get moodEnergetic => 'Энергия';

  @override
  String get moodIrritated => 'Раздражение';

  @override
  String get catSleep => 'Сон';

  @override
  String get logSleep => 'Сон';

  @override
  String get logNotes => 'Заметки';

  @override
  String get hintNotes => 'Что-то еще произошло?';

  @override
  String get logVitals => 'Показатели';

  @override
  String get lblTemp => 'Температура';

  @override
  String get lblWeight => 'Вес (кг)';

  @override
  String get logSkin => 'Кожа';

  @override
  String get symptomAcne => 'Акне';

  @override
  String get symptomNausea => 'Тошнота';

  @override
  String get symptomBloating => 'Вздутие';

  @override
  String get logLibido => 'Либидо';

  @override
  String get lblIntimacy => 'Интим';

  @override
  String get hadSex => 'Секс';

  @override
  String get protectedSex => 'Защищенный';

  @override
  String get lblLifestyle => 'Образ жизни';

  @override
  String get lblLifestyleHeader => 'Образ жизни';

  @override
  String get factorStress => 'Стресс';

  @override
  String get factorAlcohol => 'Алкоголь';

  @override
  String get factorTravel => 'Поездки';

  @override
  String get factorSport => 'Спорт';

  @override
  String get lblEnergy => 'Энергия';

  @override
  String get lblMood => 'Настроение';

  @override
  String get btnSave => 'Сохранить';

  @override
  String get btnCancel => 'Отмена';

  @override
  String get btnConfirm => 'Подтвердить';

  @override
  String get btnNext => 'Далее';

  @override
  String get btnStart => 'Начать';

  @override
  String get btnDelete => 'Удалить';

  @override
  String get btnOk => 'Понятно';

  @override
  String get tapToClose => 'Нажмите, чтобы закрыть';

  @override
  String get btnSaveSettings => 'Сохранить настройки';

  @override
  String get dialogCancel => 'Отмена';

  @override
  String get legendPeriod => 'Месячные';

  @override
  String get legendFertile => 'Фертильность';

  @override
  String get legendOvulation => 'Овуляция';

  @override
  String get legendFollicular => 'Фолликул.';

  @override
  String get legendLuteal => 'Лютеин.';

  @override
  String get legendPredictedPeriod => 'Прогноз';

  @override
  String get calendarHeader => 'История циклов';

  @override
  String get lblPreviousCycle => 'Прошлый цикл';

  @override
  String get lblNoData => 'Нет данных';

  @override
  String get lblNoSymptoms => 'Симптомы не отмечены.';

  @override
  String get insightsTitle => 'Тренды и Анализ';

  @override
  String get insightsOverview => 'Обзор';

  @override
  String get insightsHealth => 'Здоровье';

  @override
  String get insightsPatterns => 'Паттерны';

  @override
  String get chartCycleLength => 'Длина цикла';

  @override
  String get chartSubtitle => 'Последние 6 месяцев';

  @override
  String get topSymptoms => 'Топ симптомов';

  @override
  String get patternDetected => 'Найден паттерн';

  @override
  String get patternBody => 'У вас часто болит голова перед началом цикла. Попробуйте пить больше воды за 2 дня до начала.';

  @override
  String get insightPhasesTitle => 'Фазы цикла';

  @override
  String get insightPhasesSubtitle => 'Распределение по длительности';

  @override
  String get insightMoodTitle => 'Эмоции по фазам';

  @override
  String get insightMoodSubtitle => 'Средний уровень настроения';

  @override
  String get insightVitals => 'Динамика тела';

  @override
  String get insightVitalsSub => 'График температуры и веса';

  @override
  String get insightBodyBalance => 'Баланс Тела';

  @override
  String get insightBodyBalanceSub => 'Фолликулярная (Фиол.) vs Лютеиновая (Оранж.)';

  @override
  String get insightMoodFlow => 'Поток Настроения';

  @override
  String get insightMoodFlowSub => 'Тренд за последние 30 дней';

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
  String get insightAvgCycle => 'Длина цикла';

  @override
  String get insightAvgPeriod => 'Длина месячных';

  @override
  String get unitDaysShort => 'д';

  @override
  String get daysUnit => 'дн.';

  @override
  String get paramEnergy => 'Энергия';

  @override
  String get paramLibido => 'Либидо';

  @override
  String get paramSkin => 'Кожа';

  @override
  String get paramFocus => 'Фокус';

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
  String msgFeedback(String metric, String status) {
    return 'Правда ли $metric сегодня $status?';
  }

  @override
  String get statusLow => 'Низкий';

  @override
  String get statusHigh => 'Высокий';

  @override
  String get statusNormal => 'Норма';

  @override
  String get stateLow => 'Низкий';

  @override
  String get stateMedium => 'Средний';

  @override
  String get stateHigh => 'Высокий';

  @override
  String get feedbackTitle => 'Уточнение прогноза';

  @override
  String feedbackQuestion(String metric, String status) {
    return 'Твой показатель «$metric» сегодня действительно «$status»?';
  }

  @override
  String get btnYesCorrect => 'Да, всё верно';

  @override
  String get btnNoWrong => 'Нет, ошибка';

  @override
  String get btnWrong => 'Не так';

  @override
  String get btnAdjust => 'Изменить';

  @override
  String get predMismatchTitle => 'Чувствуете себя иначе?';

  @override
  String get predMismatchBody => 'Нажмите на иконку, чтобы изменить совет.';

  @override
  String predInsightHormones(String hormone) {
    return 'Гормоны: $hormone повышается.';
  }

  @override
  String get hormoneEstrogen => 'Эстроген';

  @override
  String get hormoneProgesterone => 'Прогестерон';

  @override
  String get hormoneReset => 'Гормональная перезагрузка';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get lblUser => 'Пользователь';

  @override
  String get sectionGeneral => 'ОСНОВНЫЕ';

  @override
  String get settingsGeneral => 'Общие';

  @override
  String get sectionSecurity => 'Безопасность';

  @override
  String get sectionData => 'УПРАВЛЕНИЕ ДАННЫМИ';

  @override
  String get settingsData => 'Управление данными';

  @override
  String get sectionBackup => 'Резервное копирование';

  @override
  String get sectionAbout => 'О ПРИЛОЖЕНИИ';

  @override
  String get lblLanguage => 'Язык приложения';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get lblNotifications => 'Уведомления';

  @override
  String get settingsNotifs => 'Уведомления';

  @override
  String get lblBiometrics => 'Вход по биометрии';

  @override
  String get settingsBiometrics => 'Вход по FaceID';

  @override
  String get lblExport => 'Экспорт данных (PDF)';

  @override
  String get settingsExport => 'Скачать отчет (PDF)';

  @override
  String get lblDeleteAccount => 'Удалить все данные';

  @override
  String get settingsReset => 'Сбросить все данные';

  @override
  String get settingsTheme => 'Оформление';

  @override
  String get settingsDailyLog => 'Вечерний отчет (20:00)';

  @override
  String get settingsSupport => 'Поддержка и Отзывы';

  @override
  String get btnExportPdf => 'Скачать отчет (PDF)';

  @override
  String get btnBackup => 'Резервная копия';

  @override
  String get btnSaveBackup => 'Сохранить бекап';

  @override
  String get btnRestoreBackup => 'Восстановить из файла';

  @override
  String get btnContactSupport => 'Написать в поддержку';

  @override
  String get btnRateApp => 'Оценить приложение';

  @override
  String get themeOceanic => 'Океан';

  @override
  String get themeNature => 'Природа';

  @override
  String get themeVelvet => 'Бархат';

  @override
  String get themeDigital => 'Диджитал';

  @override
  String get themeActive => 'Активна';

  @override
  String get selectThemeTitle => 'Выберите тему';

  @override
  String get prefNotifications => 'Уведомления';

  @override
  String get prefBiometrics => 'Вход по FaceID';

  @override
  String get prefCOC => 'Режим КОК (Таблетки)';

  @override
  String get descDelete => 'Это действие необратимо удалит все записи с устройства.';

  @override
  String get alertDeleteTitle => 'Вы уверены?';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get dialogResetTitle => 'Сбросить всё?';

  @override
  String get dialogResetBody => 'Это действие удалит все ваши данные безвозвратно.';

  @override
  String get dialogResetConfirm => 'Сбросить';

  @override
  String get dialogRestoreTitle => 'Восстановить данные?';

  @override
  String get dialogRestoreBody => 'Это действие перезапишет ваши текущие данные данными из файла. Вы уверены?';

  @override
  String get btnRestore => 'Восстановить';

  @override
  String get msgRestoreSuccess => 'Данные успешно восстановлены!';

  @override
  String get backupSubject => 'Резервная копия EviMoon';

  @override
  String backupBody(String date) {
    return 'Резервная копия данных EviMoon от $date';
  }

  @override
  String get greetMorning => 'Доброе утро';

  @override
  String get greetAfternoon => 'Добрый день';

  @override
  String get greetEvening => 'Добрый вечер';

  @override
  String get authLockedTitle => 'EviMoon Заблокирован';

  @override
  String get authUnlockBtn => 'Разблокировать';

  @override
  String get authReason => 'Подтвердите личность для входа';

  @override
  String get authNotAvailable => 'Биометрия недоступна на устройстве';

  @override
  String get authBiometricsReason => 'Подтвердите включение биометрии';

  @override
  String get msgBiometricsError => 'Биометрия недоступна на этом устройстве';

  @override
  String get pdfReportTitle => 'Медицинский Отчет EviMoon';

  @override
  String get pdfReportSubtitle => 'Гинекологический анамнез и история циклов';

  @override
  String get pdfCycleHistory => 'История циклов';

  @override
  String get pdfHeaderStart => 'Начало';

  @override
  String get pdfHeaderEnd => 'Конец';

  @override
  String get pdfHeaderLength => 'Длительность';

  @override
  String get pdfCurrent => 'Текущий';

  @override
  String get pdfGenerated => 'Дата';

  @override
  String get pdfPage => 'Страница';

  @override
  String get pdfPatient => 'Пациент';

  @override
  String get pdfClinicalSummary => 'Клиническая Сводка';

  @override
  String get pdfDetailedLogs => 'Детальный Журнал';

  @override
  String get pdfAvgCycle => 'Ср. Цикл';

  @override
  String get pdfAvgPeriod => 'Ср. Менструация';

  @override
  String get pdfPainReported => 'Дни с болью';

  @override
  String get pdfTableDate => 'Дата';

  @override
  String get pdfTableCD => 'ДЦ';

  @override
  String get pdfTableSymptoms => 'Симптомы';

  @override
  String get pdfTableBBT => 'ББТ';

  @override
  String get pdfTableNotes => 'Заметки';

  @override
  String get pdfFlowShort => 'Выд.';

  @override
  String get unitDays => 'дн.';

  @override
  String get pdfDisclaimer => 'ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ: Этот отчет сгенерирован приложением на основе данных пользователя. Он не является медицинским диагнозом.';

  @override
  String get msgExportError => 'Не удалось создать PDF';

  @override
  String get msgExportEmpty => 'Нет данных для экспорта.';

  @override
  String get dialogDataInsufficientTitle => 'Недостаточно данных';

  @override
  String get dialogDataInsufficientBody => 'Для формирования отчета необходимо минимум 2 дня наблюдений.';

  @override
  String get dayTitle => 'День';

  @override
  String get insightTipTitle => 'Совет дня';

  @override
  String get insightTipBody => 'В лютеиновой фазе уровень энергии падает. Это отличное время для йоги.';

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
  String get insightProstaglandinsTitle => 'Работают простагландины';

  @override
  String get insightProstaglandinsBody => 'Сокращения матки помогают обновлению. Тепло и магний облегчат состояние.';

  @override
  String get insightWinterPhaseTitle => 'Время восстановления';

  @override
  String get insightWinterPhaseBody => 'Уровень гормонов минимален. Это нормально — замедлиться и отдохнуть.';

  @override
  String get insightEstrogenTitle => 'Рост эстрогена';

  @override
  String get insightEstrogenBody => 'Эстроген повышает серотонин. Отличное время для креатива и планов!';

  @override
  String get insightMittelschmerzTitle => 'Овуляторный синдром';

  @override
  String get insightMittelschmerzBody => 'Возможно, вы чувствуете сам момент овуляции. Обычно это быстро проходит.';

  @override
  String get insightFertilityTitle => 'Пик фертильности';

  @override
  String get insightFertilityBody => 'Природа подталкивает к общению. Сейчас вы особенно притягательны!';

  @override
  String get insightWaterTitle => 'Задержка воды';

  @override
  String get insightWaterBody => 'Организм запасает воду перед возможной беременностью. Это скоро пройдет.';

  @override
  String get insightProgesteroneTitle => 'Спад прогестерона';

  @override
  String get insightProgesteroneBody => 'Химия мозга меняется перед циклом. Будьте бережны к себе сегодня.';

  @override
  String get insightSkinTitle => 'Гормональная кожа';

  @override
  String get insightSkinBody => 'Прогестерон активирует сальные железы. Используйте мягкий уход.';

  @override
  String get insightMetabolismTitle => 'Тяга к сладкому';

  @override
  String get insightMetabolismBody => 'Метаболизм ускоряется. Лучше выбрать сложные углеводы вместо сахара.';

  @override
  String get insightSpottingTitle => 'Замечены выделения';

  @override
  String get insightSpottingBody => 'Небольшие выделения бывают при овуляции или стрессе.';

  @override
  String get tipPeriod => 'Больше отдыхайте, ешьте продукты с железом.';

  @override
  String get tipOvulation => 'Пик фертильности! Идеальное время.';

  @override
  String get tipLutealEarly => 'Прогестерон растет. Пейте больше воды.';

  @override
  String get tipLutealLate => 'Окно имплантации. Избегайте стресса.';

  @override
  String get tipFollicular => 'Энергия растет. Хорошее время для спорта.';

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
  String get dialogStartTitle => 'Начать новый цикл?';

  @override
  String get dialogStartBody => 'Сегодняшний день будет отмечен как 1-й день месячных.';

  @override
  String get dialogEndTitle => 'Месячные закончились?';

  @override
  String get dialogEndBody => 'Текущая фаза сменится на фолликулярную.';

  @override
  String get btnPeriodStart => 'НАЧАЛИСЬ';

  @override
  String get btnPeriodEnd => 'ЗАКОНЧИЛИСЬ';

  @override
  String get dialogPeriodStartTitle => 'Когда начались месячные?';

  @override
  String get dialogPeriodStartBody => 'Они начались сегодня или вы забыли отметить раньше?';

  @override
  String get btnToday => 'Сегодня';

  @override
  String get btnYesterday => 'Вчера';

  @override
  String get btnPickDate => 'Выбрать дату';

  @override
  String get btnAnotherDay => 'Выбрать дату';

  @override
  String get cocActivePhase => 'Активные таблетки';

  @override
  String get cocBreakPhase => 'Неделя перерыва';

  @override
  String cocPredictionActive(int days) {
    return 'Осталось $days активных';
  }

  @override
  String cocPredictionBreak(int days) {
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
  String get dialogCOCStartTitle => 'Режим КОК';

  @override
  String get dialogCOCStartSubtitle => 'Как вы хотите начать отслеживание таблеток?';

  @override
  String get optionFreshPack => 'Новая пачка';

  @override
  String get optionFreshPackSub => 'Я начинаю новую упаковку сегодня';

  @override
  String get optionContinuePack => 'Продолжить текущую';

  @override
  String get optionContinuePackSub => 'Я уже начала пачку ранее';

  @override
  String get labelOr => 'ИЛИ';

  @override
  String cocDayInfo(int day) {
    return 'День $day из 28';
  }

  @override
  String get settingsContraception => 'Контрацепция';

  @override
  String get settingsTrackPill => 'Отслеживать таблетки';

  @override
  String get settingsPackType => 'Тип упаковки';

  @override
  String settingsPills(int count) {
    return '$count таблеток';
  }

  @override
  String get settingsReminder => 'Напоминание';

  @override
  String get settingsPackSettings => 'Настройки упаковки';

  @override
  String get settingsPlaceboCount => 'Дни плацебо';

  @override
  String get settingsBreakDuration => 'Длительность перерыва';

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
  String get pack21 => '21 Активная + 7 Перерыв';

  @override
  String get pack28 => '28 Активных (Без перерыва)';

  @override
  String get pack24 => '24 Активные + 4 Пустышки';

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
  String blisterDay(int day, int total) {
    return 'День $day из $total';
  }

  @override
  String blisterOverdue(int day) {
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
  String get sectionCycle => 'Настройки цикла';

  @override
  String get lblCycleLength => 'Длина цикла';

  @override
  String get lblPeriodLength => 'Длительность месячных';

  @override
  String get lblAverage => 'В среднем';

  @override
  String get lblNormalRange => 'Норма: 21-35 дней';

  @override
  String get emailSubject => 'Отзыв о EviMoon';

  @override
  String get emailBody => 'Здравствуйте, команда EviMoon,\n\nУ меня есть вопрос/предложение:';

  @override
  String msgEmailError(String email) {
    return 'Не удалось открыть почту. Напишите на: $email';
  }

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
  String get onboardModeTitle => 'Какая у вас цель?';

  @override
  String get onboardModeCycle => 'Отслеживать цикл';

  @override
  String get onboardModeCycleDesc => 'Прогноз месячных и фертильности';

  @override
  String get onboardModePill => 'Пить таблетки (КОК)';

  @override
  String get onboardModePillDesc => 'Напоминания и учет пачек';

  @override
  String get onboardDateTitleCycle => 'Когда начались последние месячные?';

  @override
  String get onboardDateTitlePill => 'Когда вы начали эту пачку?';

  @override
  String get onboardLengthTitle => 'Длина цикла';

  @override
  String get onboardPackTitle => 'Тип упаковки';

  @override
  String get splashTitle => 'EVIMOON';

  @override
  String get splashSlogan => 'Твой цикл. Твой ритм.';

  @override
  String get premiumInsightLabel => 'PREMIUM INSIGHT';

  @override
  String get calendarForecastTitle => 'КАЛЕНДАРЬ И ПРОГНОЗ';

  @override
  String get aiForecastHigh => 'Прогноз точен';

  @override
  String get aiForecastHighSub => 'На основе стабильной истории';

  @override
  String get aiForecastMedium => 'Средняя точность';

  @override
  String get aiForecastMediumSub => 'Есть колебания цикла';

  @override
  String get aiForecastLow => 'Низкая точность';

  @override
  String get aiForecastLowSub => 'Длина цикла сильно меняется';

  @override
  String get aiLearning => 'ИИ обучается...';

  @override
  String get aiLearningSub => 'Отметьте 3 цикла для прогноза';

  @override
  String get confidenceHighDesc => 'Цикл предсказуем и регулярен.';

  @override
  String get confidenceMedDesc => 'Прогноз на основе средних данных.';

  @override
  String get confidenceLowDesc => 'Прогноз может меняться из-за нерегулярности.';

  @override
  String get confidenceCalcDesc => 'Собираем данные для точности.';

  @override
  String get confidenceNoData => 'Пока недостаточно истории.';

  @override
  String get factorDataNeeded => 'Нужно минимум 3 цикла';

  @override
  String get factorHighVar => 'Высокая нерегулярность';

  @override
  String get factorSlightVar => 'Небольшая нерегулярность';

  @override
  String get factorStable => 'Цикл стабилен';

  @override
  String get factorAnomaly => 'Обнаружена аномалия';

  @override
  String get aiDialogTitle => 'Анализ прогноза AI';

  @override
  String aiDialogScore(int score) {
    return 'Уверенность прогноза цикла: $score%.';
  }

  @override
  String get aiDialogExplanation => 'Оценка рассчитана локально на основе истории вашего цикла.';

  @override
  String get aiDialogFactors => 'Факторы:';

  @override
  String get btnGotIt => 'Понятно';

  @override
  String get aiStatusHigh => 'Высокая точность';

  @override
  String get aiStatusMedium => 'Средняя точность';

  @override
  String get aiStatusLow => 'Низкая точность';

  @override
  String get aiDescHigh => 'Ваш цикл очень регулярный. Прогноз ИИ, скорее всего, точен до ±1 дня.';

  @override
  String get aiDescMedium => 'В последних циклах есть вариативность. Прогноз может отклоняться на ±2-3 дня.';

  @override
  String get aiDescLow => 'История циклов нерегулярна или слишком коротка. ИИ нужно больше данных.';

  @override
  String get aiConfidenceScore => 'Уровень доверия';

  @override
  String get aiLabelHistory => 'Длина истории';

  @override
  String get aiLabelVariation => 'Вариация цикла';

  @override
  String get aiSuffixCycles => 'циклов';

  @override
  String get aiSuffixDays => 'дней';

  @override
  String get modeTTC => 'Планирование беременности';

  @override
  String get modeTTCDesc => 'Фокус на фертильности и овуляции';

  @override
  String get modeTTCActive => 'Режим планирования включен';

  @override
  String get modeCycle => 'Трекер цикла';

  @override
  String get modeTrackCycle => 'Отслеживать цикл';

  @override
  String get modeGetPregnant => 'Хочу забеременеть';

  @override
  String get dialogTTCConflict => 'Отключить контрацепцию?';

  @override
  String get dialogTTCConflictBody => 'Чтобы включить режим планирования, необходимо отключить отслеживание таблеток.';

  @override
  String get btnDisableAndSwitch => 'Отключить и переключить';

  @override
  String get ttcStatusLow => 'Низкий шанс';

  @override
  String get ttcStatusHigh => 'Высокая фертильность';

  @override
  String get ttcStatusPeak => 'Пик фертильности';

  @override
  String get ttcStatusOvulation => 'День Овуляции';

  @override
  String ttcDPO(int days) {
    return '$days ДПО';
  }

  @override
  String get ttcChance => 'Вероятность зачатия';

  @override
  String get ttcChanceHigh => 'Высокий шанс';

  @override
  String get ttcChancePeak => 'Пик фертильности';

  @override
  String get ttcChanceLow => 'Низкий шанс';

  @override
  String get ttcTestWait => 'Рано для теста';

  @override
  String get ttcTestReady => 'Можно делать тест';

  @override
  String lblCycleDay(int day) {
    return 'День цикла $day';
  }

  @override
  String ttcCycleDay(int day) {
    return 'ДЕНЬ ЦИКЛА $day';
  }

  @override
  String get ttcBtnBBT => 'БТ График';

  @override
  String get ttcBtnTest => 'ЛГ Тест';

  @override
  String get ttcBtnSex => 'Близость';

  @override
  String get ttcBtnReset => 'Сбросить';

  @override
  String get ttcLogTitle => 'Отчет за сегодня';

  @override
  String get ttcSectionBBT => 'Базальная температура';

  @override
  String get ttcSectionTest => 'Тест на овуляцию (ЛГ)';

  @override
  String get ttcSectionSex => 'Близость';

  @override
  String get lblNegative => 'Отриц. (-)';

  @override
  String get lblPositive => 'Положит. (+)';

  @override
  String get lblPeak => 'Пик';

  @override
  String get chipNegative => 'Отриц.';

  @override
  String get chipPositive => 'Полож.';

  @override
  String get chipPeak => 'Пик';

  @override
  String get valNegative => 'Отриц.';

  @override
  String get valPositive => 'Полож.';

  @override
  String get valPeak => 'Пик';

  @override
  String get lblSexYes => 'Да, был!';

  @override
  String get lblSexNo => 'Не сегодня';

  @override
  String get labelSexNo => 'Нет';

  @override
  String get labelSexYes => 'Да';

  @override
  String get valSexYes => 'Да';

  @override
  String get ttcTipTitle => 'Совет дня';

  @override
  String get ttcTipDefault => 'Стресс влияет на овуляцию. Попробуйте 5-минутную медитацию.';

  @override
  String get ttcStrategyTitle => 'Стратегия';

  @override
  String get ttcStrategyMinimal => 'Минимум усилий';

  @override
  String get ttcStrategyMaximal => 'Максимум шансов';

  @override
  String get ttcPlanTitle => 'План';

  @override
  String get ttcPlanMinimalBody => 'В фертильное окно: близость через день, ЛГ-тесты 2–3 дня, ББТ по желанию.';

  @override
  String get ttcPlanMaximalBody => 'В фертильное окно: близость каждый день, ЛГ-тест ежедневно, ББТ каждое утро.';

  @override
  String get ttcOvulationBadgeTitle => 'Овуляция';

  @override
  String get ttcOvulationEstimatedCalendar => 'Оценка (календарь)';

  @override
  String get ttcOvulationConfirmedLH => 'Подтверждено по ЛГ';

  @override
  String get ttcOvulationConfirmedBBT => 'Подтверждено по ББТ';

  @override
  String get ttcOvulationConfirmedManual => 'Подтверждено';

  @override
  String get dialogHighTempTitle => 'Высокая температура';

  @override
  String get dialogHighTempBody => 'Температура выше 37.5°C обычно указывает на жар, а не овуляцию.';

  @override
  String get dialogLowTempTitle => 'Низкая температура';

  @override
  String get dialogLowTempBody => 'Температура ниже 35.5°C необычно низкая. Это опечатка?';

  @override
  String get dialogPeriodLHTitle => 'Необычное значение';

  @override
  String get dialogPeriodLHBody => 'Положительный ЛГ-тест во время менструации — редкость. Возможна ошибка.';

  @override
  String get btnLogAnyway => 'Все равно записать';

  @override
  String get insightFertilitySub => 'Как тело сообщает об овуляции';

  @override
  String get insightLibidoHigh => 'Высокое либидо в фертильное окно';

  @override
  String get insightPainOvulation => 'Замечена овуляторная боль';

  @override
  String get insightTempShift => 'Сдвиг температуры после овуляции';

  @override
  String get lblDetected => 'Обнаружено';

  @override
  String get msgLhPeakRecorded => 'LH пик записан! Окно высокой фертильности.';

  @override
  String get transitionTTC => 'Вперед за малышом... ✨';

  @override
  String get transitionCOC => 'Защита активирована 🛡️';

  @override
  String get transitionTrack => 'В гармонии с телом 🌿';

  @override
  String get notifPhaseFollicularTitle => 'Прилив сил ⚡';

  @override
  String get notifPhaseFollicularBody => 'Энергия растет! Отличное время для спорта.';

  @override
  String get notifFollTitle => 'Прилив сил ⚡';

  @override
  String get notifFollBody => 'Энергия растет! Отличное время для спорта.';

  @override
  String get notifPhaseOvulationTitle => 'Ты сияешь 🌸';

  @override
  String get notifPhaseOvulationBody => 'Пик женственности и фертильности сегодня.';

  @override
  String get notifOvulationTitle => 'Ты сияешь 🌸';

  @override
  String get notifOvulationBody => 'Пик женственности и фертильности сегодня.';

  @override
  String get notifPhaseLutealTitle => 'Время заботы 🌙';

  @override
  String get notifPhaseLutealBody => 'Организм просит отдыха, не перегружай себя.';

  @override
  String get notifLutealTitle => 'Время заботы 🌙';

  @override
  String get notifLutealBody => 'Организм просит отдыха, не перегружай себя.';

  @override
  String get notifPhasePeriodTitle => 'Новый цикл начался 🩸';

  @override
  String get notifPhasePeriodBody => 'Не забудь отметить начало менструации в календаре.';

  @override
  String get notifPeriodSoonTitle => 'Скоро цикл 🩸';

  @override
  String get notifPeriodSoonBody => 'Ожидается завтра. Всё готово?';

  @override
  String get notifPeriodTitle => 'Скоро новый цикл';

  @override
  String get notifPeriodBody => 'Месячные могут начаться через 2 дня. Не забудьте подготовиться!';

  @override
  String get notifLatePeriodTitle => 'Задержка?';

  @override
  String get notifLatePeriodBody => 'Цикл длится дольше обычного. Отметь симптомы или сделай тест.';

  @override
  String get notifLateTitle => 'Задержка?';

  @override
  String get notifLateBody => 'Цикл длиннее обычного. Не волнуйся, так бывает.';

  @override
  String get notifLogCheckinTitle => 'Как самочувствие?';

  @override
  String get notifLogCheckinBody => 'Пара секунд на отметку симптомов помогут нам лучше понимать твое тело.';

  @override
  String get notifCheckinTitle => 'Как самочувствие? 📝';

  @override
  String get notifCheckinBody => 'Отметь симптомы в дневнике.';

  @override
  String get notifPillTitle => 'Таблетка 💊';

  @override
  String get notifPillBody => 'Время принять контрацептив.';

  @override
  String get notifNewPackTitle => 'Новая пачка 💊';

  @override
  String get notifNewPackBody => 'Пора начинать новый блистер!';

  @override
  String get notifBreakTitle => 'Перерыв 🩸';

  @override
  String get notifBreakBody => 'Активные таблетки закончились. Неделя перерыва.';

  @override
  String get paywallTitle => 'EviMoon Premium';

  @override
  String get paywallSubtitle => 'Раскройте полный потенциал своего цикла.';

  @override
  String get featureTimersTitle => 'Премиум дизайны';

  @override
  String get featureTimersDesc => 'Уникальные стили таймера';

  @override
  String get featurePdfTitle => 'Медицинский PDF-отчет';

  @override
  String get featurePdfDesc => 'История симптомов для врача';

  @override
  String get featureAiTitle => 'Точность прогноза (AI)';

  @override
  String get featureAiDesc => 'Оценка уверенности алгоритма';

  @override
  String get featureTtcTitle => 'Режим планирования';

  @override
  String get featureTtcDesc => 'Инструменты для зачатия';

  @override
  String get paywallNoOffers => 'Нет доступных предложений';

  @override
  String get paywallSelectPlan => 'Выберите план';

  @override
  String paywallSubscribeFor(String price) {
    return 'Подписаться за $price';
  }

  @override
  String get paywallRestore => 'Восстановить покупки';

  @override
  String get paywallTerms => 'Условия и Политика';

  @override
  String get paywallBestValue => 'ВЫГОДНО';

  @override
  String get msgNoSubscriptions => 'Активные подписки не найдены';

  @override
  String get proStatusTitle => 'Статус подписки';

  @override
  String get proStatusActive => 'Premium Активен';

  @override
  String get proStatusDesc => 'У вас есть полный доступ ко всем функциям.';

  @override
  String get btnManageSub => 'Управление подпиской';

  @override
  String get btnManageSubDesc => 'Сменить план или отменить в настройках iOS';

  @override
  String get msgLinkError => 'Не удалось открыть настройки';

  @override
  String get badgePro => 'PRO';

  @override
  String get badgeGoPro => 'GO PRO';

  @override
  String get badgePremium => 'ПРЕМИУМ';

  @override
  String get debugPremiumOn => 'ОТЛАДКА: Премиум ВКЛ';

  @override
  String get debugPremiumOff => 'ОТЛАДКА: Премиум ВЫКЛ';

  @override
  String get phaseNewMoon => 'Новолуние';

  @override
  String get phaseWaxingCrescent => 'Растущая Луна';

  @override
  String get phaseFirstQuarter => 'Первая четверть';

  @override
  String get phaseFullMoon => 'Полнолуние';

  @override
  String get phaseWaningGibbous => 'Убывающая Луна';

  @override
  String get phaseWaningCrescent => 'Старая Луна';

  @override
  String get lblTest => 'Тест ЛГ';

  @override
  String get lblSex => 'Близость';

  @override
  String get lblMucus => 'Выделения';

  @override
  String valMeasured(double temp) {
    return '$temp°';
  }

  @override
  String get valMucusLogged => 'Отмечено';

  @override
  String get titleInputBBT => 'Ввод температуры';

  @override
  String get titleInputTest => 'Результат теста ЛГ';

  @override
  String get titleInputSex => 'Детали близости';

  @override
  String get titleInputMucus => 'Цервикальная слизь';

  @override
  String get mucusDry => 'Сухо';

  @override
  String get mucusSticky => 'Липкая';

  @override
  String get mucusCreamy => 'Крем';

  @override
  String get mucusWatery => 'Вода';

  @override
  String get mucusEggWhite => 'Белок';

  @override
  String get ttcChartTitle => 'ГРАФИК БТ (14 ДНЕЙ)';

  @override
  String get ttcChartPlaceholder => 'Введите БТ для графика';

  @override
  String get hintTemp => '36.6';

  @override
  String get designSelectorTitle => 'Стиль таймера';

  @override
  String get designClassic => 'Классика';

  @override
  String get designMinimal => 'Минимализм';

  @override
  String get designLunar => 'Луна';

  @override
  String get designBloom => 'Цветение';

  @override
  String get designLiquid => 'Жидкость';

  @override
  String get designOrbit => 'Орбита';

  @override
  String get designZen => 'Дзен';

  @override
  String get ttcHintToday => 'Сегодня';

  @override
  String get ttcTimelineTitle => 'Лента';

  @override
  String ttcTimelineOvulationEquals(int day) {
    return 'Овуляция = $day';
  }

  @override
  String get ttcDockBBT => 'БТТ';

  @override
  String get ttcDockLH => 'ЛГ';

  @override
  String get ttcDockSex => 'Секс';

  @override
  String get ttcDockMucus => 'Слизь';

  @override
  String get ttcShortBBT => 'БТТ';

  @override
  String get ttcShortLH => 'ЛГ';

  @override
  String get ttcShortSex => 'Секс';

  @override
  String get ttcShortMucus => 'Слизь';

  @override
  String get ttcMarkDone => '✓';

  @override
  String get ttcMarkMissing => '?';

  @override
  String get ttcAllDone => 'Всё заполнено ✓';

  @override
  String ttcMissingList(String items) {
    return 'Осталось: $items';
  }

  @override
  String ttcRemainingLeft(String items) {
    return 'Осталось: $items';
  }

  @override
  String ttcCtaTestReadyBody(int dpo, String bbt, String lh) {
    return 'DPO $dpo • БТТ $bbt • ЛГ $lh';
  }

  @override
  String ttcCtaTestWaitBody(int dpo, int days) {
    return 'DPO $dpo • осталось ~$days дн. до надёжного теста';
  }

  @override
  String get ttcCtaPeakBody => 'Сегодня/завтра — максимум. Отметь секс и тест, чтобы улучшить точность.';

  @override
  String ttcCtaHighBody(int days) {
    return 'Окно фертильности открыто • пик через ~$days дн.';
  }

  @override
  String get ttcCtaMenstruationBody => 'Мягкий режим: сон, вода, тепло. Лог необязателен — но БТТ полезна.';

  @override
  String ttcCtaLowBody(String status) {
    return 'День подготовки • $status';
  }

  @override
  String get ttcDash => '—';

  @override
  String get eduTitleBBT => 'Зачем измерять БТ?';

  @override
  String get eduBodyBBT => 'Базальная температура (БТ) немного повышается после овуляции из-за выработки прогестерона. График температуры помогает подтвердить, что овуляция действительно произошла.';

  @override
  String get eduTitleLH => 'Тесты на овуляцию';

  @override
  String get eduBodyLH => 'Уровень лютеинизирующего гормона (ЛГ) резко возрастает за 24–48 часов до овуляции. Положительный тест предсказывает самые благоприятные дни для зачатия перед выходом яйцеклетки.';

  @override
  String get eduTitleSex => 'Отметка близости';

  @override
  String get eduBodySex => 'Сперматозоиды могут жить в организме до 5 дней. Отметки помогают убедиться, что близость совпала с окном фертильности, что значительно повышает шансы на зачатие.';

  @override
  String get eduTitleMucus => 'Цервикальная слизь';

  @override
  String get eduBodyMucus => 'При приближении овуляции эстроген делает выделения прозрачными и тягучими (как яичный белок). Это создает идеальную среду для выживания и передвижения сперматозоидов.';
}
