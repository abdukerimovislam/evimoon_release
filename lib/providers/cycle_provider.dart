import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/cycle_model.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

class CycleProvider with ChangeNotifier {
  // 📦 Хранилища данных
  // ⚠️ Убрали 'final', чтобы можно было переоткрыть коробку, если она закрылась
  Box _cycleBox;
  Box _settingsBox;
  final NotificationService? _notificationService;

  // 🧠 Текущее состояние (кэш)
  CycleData _currentData = CycleData.empty();
  List<CycleModel> _history = [];

  // ⚙️ Настройки
  bool _isCOCEnabled = false;
  int _avgCycleLength = 28;
  int _avgPeriodDuration = 5;

  bool _isLoaded = false;

  CycleProvider(this._cycleBox, this._settingsBox, [this._notificationService]) {
    _init();
  }

  // --- Геттеры ---
  CycleData get currentData => _currentData;
  List<CycleModel> get history => _history;

  int get cycleLength => _isCOCEnabled ? 28 : _avgCycleLength;
  int get avgPeriodDuration => _avgPeriodDuration;
  int get periodDuration => _avgPeriodDuration;

  bool get isCOCEnabled => _isCOCEnabled;
  bool get isLoaded => _isLoaded;

  // --- 🛡️ ЗАЩИТА ОТ ЗАКРЫТЫХ КОРОБОК ---
  Future<void> _ensureBoxOpen() async {
    if (!_settingsBox.isOpen) {
      debugPrint("⚠️ Settings Box was closed. Re-opening...");
      _settingsBox = await Hive.openBox(_settingsBox.name);
    }
    if (!_cycleBox.isOpen) {
      debugPrint("⚠️ Cycle Box was closed. Re-opening...");
      _cycleBox = await Hive.openBox(_cycleBox.name);
    }
  }

  // --- 🚀 Инициализация ---
  Future<void> _init() async {
    try {
      await _ensureBoxOpen(); // Проверка перед чтением

      // 1. Загрузка настроек
      _isCOCEnabled = _settingsBox.get('coc_enabled', defaultValue: false);
      _avgCycleLength = _settingsBox.get('avg_cycle_len', defaultValue: 28);
      _avgPeriodDuration = _settingsBox.get('avg_period_len', defaultValue: 5);

      // 2. Загрузка истории
      if (_cycleBox.isNotEmpty) {
        _history = _cycleBox.values.cast<CycleModel>().toList();
        _history.sort((a, b) => b.startDate.compareTo(a.startDate));
      }

      // 3. Определение даты старта
      DateTime start;
      final savedStartTimestamp = _settingsBox.get('current_cycle_start');

      if (savedStartTimestamp != null) {
        start = DateTime.fromMillisecondsSinceEpoch(savedStartTimestamp);
      } else if (_history.isNotEmpty) {
        start = _history.first.startDate;
      } else {
        start = DateTime.now();
      }

      _recalculateAverages();
      _updateCurrentData(start, _avgCycleLength, _avgPeriodDuration);

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint("🛑 CycleProvider Init Critical Error: $e");
    }
  }

  // --- 🧮 Ядро расчетов ---

  void _updateCurrentData(DateTime startDate, int cycleLen, int periodLen) {
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);

    final diff = normalizedNow.difference(normalizedStart).inDays;

    int currentDay = diff + 1;
    if (currentDay <= 0) currentDay = 1;

    final effectiveCycleLen = _isCOCEnabled ? 28 : cycleLen;

    CyclePhase phase = _calculatePhase(currentDay, effectiveCycleLen, periodLen, isCOC: _isCOCEnabled);
    bool isFertile = !_isCOCEnabled && (phase == CyclePhase.ovulation);

    int daysUntilNext = effectiveCycleLen - currentDay;
    if (daysUntilNext < 0) daysUntilNext = 0;

    _currentData = CycleData(
      cycleStartDate: startDate,
      totalCycleLength: effectiveCycleLen,
      periodDuration: periodLen,
      currentDay: currentDay,
      phase: phase,
      daysUntilNextPeriod: daysUntilNext,
      isFertile: isFertile,
      lastPeriodDate: startDate,
    );
    notifyListeners();
  }

  CyclePhase _calculatePhase(int day, int length, int period, {required bool isCOC}) {
    if (isCOC) {
      if (day <= 21) return CyclePhase.follicular;
      else if (day <= 28) return CyclePhase.menstruation;
      else return CyclePhase.late;
    }

    if (day <= period) return CyclePhase.menstruation;

    final ovulationDay = length - 14;
    if (day < ovulationDay - 5) return CyclePhase.follicular;
    if (day >= ovulationDay - 5 && day <= ovulationDay + 1) return CyclePhase.ovulation;
    if (day > length) return CyclePhase.late;

    return CyclePhase.luteal;
  }

  // --- 🎮 Действия пользователя (С ЗАЩИТОЙ) ---

  Future<void> startNewCycle() async {
    await _ensureBoxOpen(); // 🔥 Защита

    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);

    if (_currentData.cycleStartDate.isAfter(now)) return;

    if (normalizedNow.isAtSameMomentAs(DateTime(
        _currentData.cycleStartDate.year,
        _currentData.cycleStartDate.month,
        _currentData.cycleStartDate.day))) {

      // Логика восстановления случайно отмененных месячных
      if (_avgPeriodDuration < 2) {
        int defaultPeriod = 5;
        await _settingsBox.put('avg_period_len', defaultPeriod);
        _avgPeriodDuration = defaultPeriod;
        _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, defaultPeriod);
        _rescheduleNotifications();
        return;
      }
      return;
    }

    final prevEnd = normalizedNow.subtract(const Duration(days: 1));
    final length = prevEnd.difference(_currentData.cycleStartDate).inDays + 1;

    if (length > 10 && !_isCOCEnabled) {
      final historyItem = CycleModel(
        startDate: _currentData.cycleStartDate,
        endDate: prevEnd,
      );
      await _cycleBox.add(historyItem);
      _history.insert(0, historyItem);

      if (_cycleBox.length > 36) await _cycleBox.deleteAt(0);
      _recalculateAverages();
    }

    int defaultPeriod = 5;
    await _settingsBox.put('avg_period_len', defaultPeriod);
    _avgPeriodDuration = defaultPeriod;

    await setSpecificCycleStartDate(normalizedNow);
  }

  Future<void> endCurrentPeriod() async {
    await _ensureBoxOpen(); // 🔥 Защита

    final now = DateTime.now();
    final start = _currentData.cycleStartDate;

    int newDuration = now.difference(start).inDays;
    if (newDuration < 0) newDuration = 0;

    await setAveragePeriodDuration(newDuration);
  }

  Future<void> setSpecificCycleStartDate(DateTime date) async {
    await _ensureBoxOpen(); // 🔥 Защита

    final normalizedDate = DateTime(date.year, date.month, date.day);
    await _settingsBox.put('current_cycle_start', normalizedDate.millisecondsSinceEpoch);
    _updateCurrentData(normalizedDate, _avgCycleLength, _avgPeriodDuration);
    _rescheduleNotifications();
  }

  Future<void> setCOCMode(bool enabled, {int currentPillNumber = 1}) async {
    await _ensureBoxOpen(); // 🔥 Защита

    _isCOCEnabled = enabled;
    await _settingsBox.put('coc_enabled', enabled);

    if (enabled) {
      if (currentPillNumber > 1) {
        final daysToSubtract = currentPillNumber - 1;
        final correctedStart = DateTime.now().subtract(Duration(days: daysToSubtract));
        await setSpecificCycleStartDate(correctedStart);
      } else {
        await setSpecificCycleStartDate(DateTime.now());
      }
    } else {
      _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
      _rescheduleNotifications();
    }
    notifyListeners();
  }

  Future<void> setAveragePeriodDuration(int days) async {
    await _ensureBoxOpen(); // 🔥 Защита

    await _settingsBox.put('avg_period_len', days);
    _avgPeriodDuration = days;
    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, days);
    _rescheduleNotifications();
  }

  Future<void> setCycleLength(int length) async {
    await _ensureBoxOpen(); // 🔥 Защита от краша при онбординге

    await _settingsBox.put('avg_cycle_len', length);
    _avgCycleLength = length;
    _updateCurrentData(_currentData.cycleStartDate, length, _avgPeriodDuration);
    _rescheduleNotifications();
  }

  // --- 📈 Аналитика ---

  void _recalculateAverages() {
    if (_history.isEmpty || _isCOCEnabled) return;

    int total = 0;
    int count = 0;
    final recent = _history.take(6);

    for (var h in recent) {
      if (h.endDate != null) {
        final len = h.endDate!.difference(h.startDate).inDays + 1;
        if (len >= 21 && len <= 40) {
          total += len;
          count++;
        }
      }
    }

    if (count > 0) {
      _avgCycleLength = (total / count).round();
      _settingsBox.put('avg_cycle_len', _avgCycleLength);
    }
  }

  // --- 📅 Календарь ---

  CyclePhase? getPhaseForDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);

    for (var h in _history) {
      if (h.endDate == null) continue;
      if (!normalized.isBefore(h.startDate) && !normalized.isAfter(h.endDate!)) {
        final day = normalized.difference(h.startDate).inDays + 1;
        final len = h.endDate!.difference(h.startDate).inDays + 1;
        return _calculatePhase(day, len, _avgPeriodDuration, isCOC: false);
      }
    }

    final start = _currentData.cycleStartDate;
    if (!normalized.isBefore(start)) {
      final daysDiff = normalized.difference(start).inDays;
      final len = cycleLength;
      final dayInCycle = (daysDiff % len) + 1;
      return _calculatePhase(dayInCycle, len, _avgPeriodDuration, isCOC: _isCOCEnabled);
    }

    return null;
  }

  Color getColorForPhase(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation: return AppColors.menstruation;
      case CyclePhase.follicular: return AppColors.follicular;
      case CyclePhase.ovulation: return AppColors.ovulation;
      case CyclePhase.luteal: return AppColors.luteal;
      default: return Colors.grey;
    }
  }

  // --- 🔔 Уведомления ---
  static final Map<String, Map<String, String>> _notifTranslations = {
    'en': {'periodTitle': 'Cycle Update', 'periodBody': 'Period likely starting soon.', 'follicularTitle': 'Energy Rising ⚡', 'follicularBody': 'Follicular phase started.', 'ovulationTitle': 'Fertility Window 🌸', 'ovulationBody': 'High fertility chance.', 'lutealTitle': 'Be Gentle 🌙', 'lutealBody': 'Luteal phase here.', 'pillActive': 'Active Pill Phase', 'pillBody': 'Remember to take your pill!'},
    'ru': {'periodTitle': 'Скоро цикл', 'periodBody': 'Скоро месячные.', 'follicularTitle': 'Энергия растет ⚡', 'follicularBody': 'Фолликулярная фаза.', 'ovulationTitle': 'Фертильность 🌸', 'ovulationBody': 'Высокая вероятность.', 'lutealTitle': 'Забота 🌙', 'lutealBody': 'Лютеиновая фаза.', 'pillActive': 'Активные таблетки', 'pillBody': 'Не забудьте принять таблетку!'}
  };

  Future<void> _rescheduleNotifications() async {
    if (_notificationService == null) return;
    await _notificationService!.cancelAll();

    String langCode = 'en';
    try {
      if (Intl.defaultLocale != null) langCode = Intl.defaultLocale!.split('_')[0];
    } catch (_) {}

    final Map<String, String> strings = _notifTranslations[langCode] ?? _notifTranslations['en']!;
    final lastStart = _currentData.cycleStartDate;
    final len = cycleLength;
    final nextStart = lastStart.add(Duration(days: len));

    if (_isCOCEnabled) {
      final newPackDate = nextStart;
      await _scheduleIfFuture(10, newPackDate, "New Pack 💊", "Time to start a new pack!");
      final breakDate = lastStart.add(const Duration(days: 21));
      await _scheduleIfFuture(11, breakDate, "Break Week 🩸", "Active pills finished. Break week starts.");
    } else {
      final follicularDate = lastStart.add(Duration(days: _avgPeriodDuration));
      await _scheduleIfFuture(10, follicularDate, strings['follicularTitle']!, strings['follicularBody']!);
      final ovulationDate = lastStart.add(Duration(days: len - 16));
      await _scheduleIfFuture(20, ovulationDate, strings['ovulationTitle']!, strings['ovulationBody']!);
      final lutealDate = lastStart.add(Duration(days: len - 10));
      await _scheduleIfFuture(30, lutealDate, strings['lutealTitle']!, strings['lutealBody']!);
      final periodReminderDate = nextStart.subtract(const Duration(days: 2));
      await _scheduleIfFuture(40, periodReminderDate, strings['periodTitle']!, strings['periodBody']!);
    }
  }

  Future<void> _scheduleIfFuture(int id, DateTime date, String title, String body) async {
    if (_notificationService == null) return;
    if (date.isAfter(DateTime.now())) {
      await _notificationService!.scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: DateTime(date.year, date.month, date.day, 9, 0)
      );
    }
  }

  void setPeriodDate(DateTime date) => setSpecificCycleStartDate(date);
  Future<void> reload() async => await _init();
}