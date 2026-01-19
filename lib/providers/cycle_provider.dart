import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/cycle_model.dart';
import '../services/notification_service.dart';
import '../logic/cycle_ai_engine.dart';

// Enum для вероятности зачатия
enum FertilityChance { low, high, peak }

class CycleProvider with ChangeNotifier {
  // 📦 Хранилища данных
  Box _cycleBox;
  Box _settingsBox;
  final NotificationService? _notificationService;

  // 🧠 Текущее состояние (кэш)
  CycleData _currentData = CycleData.empty();
  List<CycleModel> _history = [];

  // 🔥 Результат AI анализа
  CycleConfidenceResult? _aiConfidence;

  // ⚙️ Настройки
  bool _isCOCEnabled = false;
  bool _isTTCMode = false;
  int _avgCycleLength = 28;
  int _avgPeriodDuration = 5;

  // ✅ OVERRIDE: пользователь нажал “Закончить месячные”
  // Сохраняем для текущего цикла: startMs + day
  int? _periodEndCycleStartMs;
  int? _periodEndedAtDay;

  bool _isLoaded = false;

  CycleProvider(this._cycleBox, this._settingsBox, [this._notificationService]) {
    _init();
  }

  // --- Геттеры ---
  CycleData get currentData => _currentData;
  List<CycleModel> get history => List.unmodifiable(_history);
  CycleConfidenceResult? get aiConfidence => _aiConfidence;

  int get cycleLength => _isCOCEnabled ? 28 : _avgCycleLength;
  int get avgPeriodDuration => _avgPeriodDuration;
  int get periodDuration => _avgPeriodDuration;

  bool get isCOCEnabled => _isCOCEnabled;
  bool get isTTCMode => _isTTCMode;
  bool get isLoaded => _isLoaded;

  // --- 🤰 TTC (ПЛАНИРОВАНИЕ) ---

  int get ovulationDay => cycleLength - 14;

  int? get currentDPO {
    if (!_isTTCMode || _isCOCEnabled) return null;
    final current = _currentData.currentDay;
    if (current > ovulationDay) return current - ovulationDay;
    return null;
  }

  FertilityChance get conceptionChance {
    if (!_isTTCMode || _isCOCEnabled) return FertilityChance.low;

    final current = _currentData.currentDay;

    if (current == ovulationDay || current == ovulationDay - 1) {
      return FertilityChance.peak;
    }
    if (current >= ovulationDay - 5 && current < ovulationDay - 1) {
      return FertilityChance.high;
    }
    return FertilityChance.low;
  }

  bool get isFertileWindow {
    if (!_isTTCMode || _isCOCEnabled) return false;
    final current = _currentData.currentDay;
    return current >= (ovulationDay - 5) && current <= ovulationDay;
  }

  // --- 🛡️ ЗАЩИТА ОТ ЗАКРЫТЫХ КОРОБОК ---
  Future<void> _ensureBoxOpen() async {
    if (!_settingsBox.isOpen) {
      _settingsBox = await Hive.openBox(_settingsBox.name);
    }
    if (!_cycleBox.isOpen) {
      _cycleBox = await Hive.openBox(_cycleBox.name);
    }
  }

  // --- Helpers ---
  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  void _loadPeriodEndOverride() {
    try {
      _periodEndCycleStartMs = _settingsBox.get('period_end_cycle_start') as int?;
      _periodEndedAtDay = _settingsBox.get('period_end_day') as int?;
    } catch (_) {
      _periodEndCycleStartMs = null;
      _periodEndedAtDay = null;
    }
  }

  Future<void> _clearPeriodEndOverride() async {
    _periodEndCycleStartMs = null;
    _periodEndedAtDay = null;
    try {
      await _settingsBox.delete('period_end_cycle_start');
      await _settingsBox.delete('period_end_day');
    } catch (_) {}
  }

  bool _overrideApplies(DateTime cycleStart) {
    if (_periodEndCycleStartMs == null || _periodEndedAtDay == null) return false;
    final startMs = _normalizeDate(cycleStart).millisecondsSinceEpoch;
    return _periodEndCycleStartMs == startMs;
  }

  // --- 🚀 Инициализация ---
  Future<void> _init() async {
    _isLoaded = false;
    try {
      await _ensureBoxOpen();

      _isCOCEnabled = _settingsBox.get('coc_enabled', defaultValue: false);
      _isTTCMode = _settingsBox.get('ttc_mode_enabled', defaultValue: false);
      _avgCycleLength = _settingsBox.get('avg_cycle_len', defaultValue: 28);
      _avgPeriodDuration = _settingsBox.get('avg_period_len', defaultValue: 5);

      _loadPeriodEndOverride();

      // История
      _history = [];
      if (_cycleBox.isNotEmpty) {
        _history = _cycleBox.values.cast<CycleModel>().toList();
        _history.sort((a, b) => b.startDate.compareTo(a.startDate)); // newest first
      }

      // Текущий старт цикла
      DateTime start;
      final savedStartTimestamp = _settingsBox.get('current_cycle_start');

      if (savedStartTimestamp != null) {
        start = DateTime.fromMillisecondsSinceEpoch(savedStartTimestamp);
      } else if (_history.isNotEmpty) {
        start = _normalizeDate(_history.first.startDate);
      } else {
        start = _normalizeDate(DateTime.now());
      }

      _recalculateAverages();
      _calculateAIConfidence();
      _updateCurrentData(start, _avgCycleLength, _avgPeriodDuration, notify: false);

      _isLoaded = true;
      notifyListeners();

      // Ставим уведомления после первого построения UI
      _rescheduleNotifications();
    } catch (e) {
      debugPrint("CycleProvider Init Error: $e");
    }
  }

  // --- 🧮 Ядро расчетов ---

  void _updateCurrentData(
      DateTime startDate,
      int cycleLen,
      int periodLen, {
        bool notify = true,
      }) {
    final now = DateTime.now();
    final normalizedNow = _normalizeDate(now);
    final normalizedStart = _normalizeDate(startDate);

    // если старт в будущем — фиксируем на сегодня
    final safeStart = normalizedStart.isAfter(normalizedNow) ? normalizedNow : normalizedStart;

    final diff = normalizedNow.difference(safeStart).inDays;
    int currentDay = diff + 1;
    if (currentDay <= 0) currentDay = 1;

    final effectiveCycleLen = _isCOCEnabled ? 28 : cycleLen.clamp(21, 45);

    // ✅ если ушли за длину цикла — нормализуем день (чтобы не ломать UI)
    // так Late будет отображаться корректно через _calculatePhase(day > length)
    // но currentDay станет "день в цикле" для предиктов/окна фертильности
    // Late мы всё равно поймаем фазой и daysUntilNext = 0.
    int dayForWindow = currentDay;
    if (dayForWindow > effectiveCycleLen && effectiveCycleLen > 0) {
      dayForWindow = ((dayForWindow - 1) % effectiveCycleLen) + 1;
    }

    final phase = _calculatePhase(
      day: currentDay,
      length: effectiveCycleLen,
      period: periodLen,
      isCOC: _isCOCEnabled,
      cycleStart: safeStart,
    );

    final int ovDay = effectiveCycleLen - 14;
    final bool isFertile = !_isCOCEnabled && (dayForWindow >= (ovDay - 5) && dayForWindow <= ovDay);

    int daysUntilNext = effectiveCycleLen - dayForWindow;
    if (phase == CyclePhase.late) daysUntilNext = 0;
    if (daysUntilNext < 0) daysUntilNext = 0;

    _currentData = CycleData(
      cycleStartDate: safeStart,
      totalCycleLength: effectiveCycleLen,
      periodDuration: periodLen.clamp(1, 14),
      currentDay: currentDay,
      phase: phase,
      daysUntilNextPeriod: daysUntilNext,
      isFertile: isFertile,
      lastPeriodDate: safeStart,
    );

    if (notify) notifyListeners();
  }

  CyclePhase _calculatePhase({
    required int day,
    required int length,
    required int period,
    required bool isCOC,
    required DateTime cycleStart,
  }) {
    if (isCOC) {
      if (day <= 21) return CyclePhase.follicular;
      if (day <= 28) return CyclePhase.menstruation;
      return CyclePhase.late;
    }

    // ✅ OVERRIDE: если “закончено” в этом цикле, то начиная с day >= endedAtDay
    // мы НЕ показываем menstruation, даже если day <= period
    final bool endedForThisCycle = _overrideApplies(cycleStart);
    final int? endedAtDay = endedForThisCycle ? _periodEndedAtDay : null;

    if (period > 0 && day <= period) {
      if (endedAtDay != null && day >= endedAtDay) {
        // пропускаем menstruation
      } else {
        return CyclePhase.menstruation;
      }
    }

    final ovDay = length - 14;
    if (day >= ovDay - 5 && day <= ovDay + 1) return CyclePhase.ovulation;

    if (day < ovDay - 5) return CyclePhase.follicular;
    if (day > length) return CyclePhase.late;

    return CyclePhase.luteal;
  }

  // --- 🎮 Действия пользователя ---

  Future<void> setTTCMode(bool enabled) async {
    await _ensureBoxOpen();

    if (enabled && _isCOCEnabled) {
      debugPrint("Cannot enable TTC while COC is active");
      return;
    }

    _isTTCMode = enabled;
    await _settingsBox.put('ttc_mode_enabled', enabled);
    notifyListeners();
  }

  Future<void> startNewCycle() async {
    await _ensureBoxOpen();

    // ✅ Новый цикл = месячные снова начались, override “закончено” сбрасываем
    await _clearPeriodEndOverride();

    final now = DateTime.now();
    final normalizedNow = _normalizeDate(now);
    final normalizedStart = _normalizeDate(_currentData.cycleStartDate);

    if (normalizedStart.isAfter(normalizedNow)) return;

    // если уже сегодня — просто обновляем старт
    if (normalizedNow.isAtSameMomentAs(normalizedStart)) {
      await setSpecificCycleStartDate(normalizedNow);
      return;
    }

    final prevEnd = normalizedNow.subtract(const Duration(days: 1));
    final length = prevEnd.difference(normalizedStart).inDays + 1;

    // сохраняем историю только если похоже на валидный цикл
    if (length >= 11 && length <= 120 && !_isCOCEnabled) {
      final historyItem = CycleModel(
        startDate: normalizedStart,
        endDate: prevEnd,
        length: length,
      );

      await _cycleBox.add(historyItem);

      _history = _cycleBox.values.cast<CycleModel>().toList();
      _history.sort((a, b) => b.startDate.compareTo(a.startDate));

      _recalculateAverages();
      _calculateAIConfidence();
    }

    await setSpecificCycleStartDate(normalizedNow);
  }

  Future<void> endCurrentPeriod() async {
    await _ensureBoxOpen();

    final now = DateTime.now();
    final today = _normalizeDate(now);
    final start = _normalizeDate(_currentData.cycleStartDate);

    int newDuration = today.difference(start).inDays + 1;
    if (newDuration < 1) newDuration = 1;
    if (newDuration > 14) newDuration = 14;

    // ✅ сохраняем “закончено сегодня” (чтобы UI сразу сменил фазу)
    final startMs = start.millisecondsSinceEpoch;
    _periodEndCycleStartMs = startMs;
    _periodEndedAtDay = _currentData.currentDay;

    await _settingsBox.put('period_end_cycle_start', startMs);
    await _settingsBox.put('period_end_day', _periodEndedAtDay);

    await setAveragePeriodDuration(newDuration);

    // форс-обновление (на всякий)
    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
  }

  Future<void> setSpecificCycleStartDate(DateTime date) async {
    await _ensureBoxOpen();
    final normalizedDate = _normalizeDate(date);

    // ✅ смена старта = новая логика -> сбрасываем override
    await _clearPeriodEndOverride();

    if (_avgPeriodDuration < 2) {
      _avgPeriodDuration = 5;
      await _settingsBox.put('avg_period_len', 5);
    }

    await _settingsBox.put('current_cycle_start', normalizedDate.millisecondsSinceEpoch);

    _updateCurrentData(normalizedDate, _avgCycleLength, _avgPeriodDuration);
    await _rescheduleNotifications();
  }

  Future<void> setCOCMode(bool enabled, {int currentPillNumber = 1}) async {
    await _ensureBoxOpen();

    _isCOCEnabled = enabled;
    await _settingsBox.put('coc_enabled', enabled);

    if (enabled) {
      _aiConfidence = null;

      if (_isTTCMode) {
        _isTTCMode = false;
        await _settingsBox.put('ttc_mode_enabled', false);
      }

      await _clearPeriodEndOverride();

      if (currentPillNumber > 1) {
        final daysToSubtract = currentPillNumber - 1;
        final correctedStart = DateTime.now().subtract(Duration(days: daysToSubtract));
        await setSpecificCycleStartDate(correctedStart);
      } else {
        await setSpecificCycleStartDate(DateTime.now());
      }
    } else {
      _calculateAIConfidence();
      _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
      await _rescheduleNotifications();
    }

    notifyListeners();
  }

  Future<void> setAveragePeriodDuration(int days) async {
    await _ensureBoxOpen();

    days = days.clamp(1, 14);

    await _settingsBox.put('avg_period_len', days);
    _avgPeriodDuration = days;

    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, days);
    await _rescheduleNotifications();
  }

  Future<void> setCycleLength(int length) async {
    await _ensureBoxOpen();

    length = length.clamp(21, 45);

    await _settingsBox.put('avg_cycle_len', length);
    _avgCycleLength = length;

    _updateCurrentData(_currentData.cycleStartDate, length, _avgPeriodDuration);
    await _rescheduleNotifications();
  }

  // --- 📈 Аналитика ---
  int _cycleLenFromModel(CycleModel m) {
    if (m.length != null && m.length! > 0) return m.length!;
    if (m.endDate == null) return 0;
    final s = _normalizeDate(m.startDate);
    final e = _normalizeDate(m.endDate!);
    return e.difference(s).inDays + 1;
  }

  void _recalculateAverages() {
    if (_history.isEmpty || _isCOCEnabled) return;

    int total = 0;
    int count = 0;

    final recent = _history.take(6);
    for (final h in recent) {
      final len = _cycleLenFromModel(h);
      if (len >= 21 && len <= 45) {
        total += len;
        count++;
      }
    }

    if (count > 0) {
      _avgCycleLength = (total / count).round().clamp(21, 45);
      _settingsBox.put('avg_cycle_len', _avgCycleLength);
    }
  }

  void _calculateAIConfidence() {
    if (_isCOCEnabled) {
      _aiConfidence = null;
      return;
    }
    try {
      // newest first already; ensure we pass the same ordering
      _aiConfidence = CycleAIEngine.calculateConfidence(_history);
    } catch (e) {
      debugPrint("AI Engine error: $e");
      _aiConfidence = null;
    }
  }

  // --- 📅 Календарь ---
  CyclePhase? getPhaseForDate(DateTime date) {
    final normalized = _normalizeDate(date);

    // История
    for (final h in _history) {
      if (h.endDate == null) continue;

      final hs = _normalizeDate(h.startDate);
      final he = _normalizeDate(h.endDate!);

      if (!normalized.isBefore(hs) && !normalized.isAfter(he)) {
        final day = normalized.difference(hs).inDays + 1;
        final len = _cycleLenFromModel(h);
        if (len <= 0) return null;

        return _calculatePhase(
          day: day,
          length: len,
          period: _avgPeriodDuration,
          isCOC: false,
          cycleStart: hs,
        );
      }
    }

    // Текущий цикл
    final start = _normalizeDate(_currentData.cycleStartDate);
    if (!normalized.isBefore(start)) {
      final daysDiff = normalized.difference(start).inDays;
      final len = cycleLength;
      final dayInCycle = (daysDiff % len) + 1;

      return _calculatePhase(
        day: dayInCycle,
        length: len,
        period: _avgPeriodDuration,
        isCOC: _isCOCEnabled,
        cycleStart: start,
      );
    }

    return null;
  }

  // --- 🔔 УВЕДОМЛЕНИЯ ---
  Map<String, String> _getLabelsSafe(String key, String lang) {
    final bool isRu = lang == 'ru';
    if (key == 'follicular') {
      return {
        't': isRu ? 'Прилив сил ⚡' : 'Energy Rising ⚡',
        'b': isRu ? 'Энергия растет! Время для спорта.' : 'Great time for workouts!'
      };
    } else if (key == 'ovulation') {
      return {
        't': isRu ? 'Ты сияешь 🌸' : 'You are glowing 🌸',
        'b': isRu ? 'Пик женственности и энергии.' : 'Peak confidence today.'
      };
    } else if (key == 'luteal') {
      return {
        't': isRu ? 'Время заботы 🌙' : 'Be Gentle 🌙',
        'b': isRu ? 'Организм просит отдыха.' : 'Take it slow today.'
      };
    } else if (key == 'checkin') {
      return {
        't': isRu ? 'Как самочувствие?' : 'Daily Log 📝',
        'b': isRu ? 'Отметь симптомы.' : 'How do you feel today?'
      };
    } else if (key == 'late') {
      return {
        't': isRu ? 'Задержка?' : 'Late Period?',
        'b': isRu ? 'Цикл длиннее обычного.' : 'Cycle is longer than usual.'
      };
    } else if (key == 'periodSoon') {
      return {
        't': isRu ? 'Скоро цикл 🩸' : 'Period Soon 🩸',
        'b': isRu ? 'Ожидается завтра.' : 'Expect your period tomorrow.'
      };
    }
    return {'t': 'Update', 'b': 'Check the app'};
  }

  Future<void> _rescheduleNotifications() async {
    if (_notificationService == null) return;

    try {
      await _notificationService!.cancelAll();

      String lang = 'en';
      try {
        lang = Intl.defaultLocale?.split('_')[0] ?? 'en';
      } catch (_) {}

      final lastStart = _normalizeDate(_currentData.cycleStartDate);
      final len = cycleLength;
      final nextPeriodStart = lastStart.add(Duration(days: len));

      if (_isCOCEnabled) {
        await _scheduleIfFuture(100, nextPeriodStart, "New Pack 💊", "Time to start a new pack!", payload: "screen_coc");
        final breakDate = lastStart.add(const Duration(days: 21));
        await _scheduleIfFuture(101, breakDate, "Break Week 🩸", "Active pills finished.", payload: "screen_coc");
        return;
      }

      final day7 = lastStart.add(const Duration(days: 6));
      final tFoll = _getLabelsSafe('follicular', lang);
      await _scheduleIfFuture(201, day7, tFoll['t']!, tFoll['b']!, payload: "screen_calendar");

      final ovDay = len - 14;
      if (ovDay > 1) {
        final ovDate = lastStart.add(Duration(days: ovDay - 1));
        final tOv = _getLabelsSafe('ovulation', lang);
        await _scheduleIfFuture(202, ovDate, tOv['t']!, tOv['b']!, payload: "screen_calendar");
      }

      final pmsDay = len - 5;
      if (pmsDay > 10) {
        final pmsDate = lastStart.add(Duration(days: pmsDay - 1));
        final tLut = _getLabelsSafe('luteal', lang);
        await _scheduleIfFuture(203, pmsDate, tLut['t']!, tLut['b']!, payload: "screen_calendar");
      }

      final prePeriodDate = nextPeriodStart.subtract(const Duration(days: 1));
      final tSoon = _getLabelsSafe('periodSoon', lang);
      await _scheduleIfFuture(204, prePeriodDate, tSoon['t']!, tSoon['b']!, payload: "screen_calendar");

      final lateDate = nextPeriodStart.add(const Duration(days: 3));
      final tLate = _getLabelsSafe('late', lang);
      await _scheduleIfFuture(205, lateDate, tLate['t']!, tLate['b']!, payload: "screen_calendar");

      final now = DateTime.now();
      final todayEvening = DateTime(now.year, now.month, now.day, 20, 0);
      if (todayEvening.isAfter(now)) {
        final tLog = _getLabelsSafe('checkin', lang);
        await _scheduleIfFuture(300, todayEvening, tLog['t']!, tLog['b']!, payload: "screen_calendar");
      }
    } catch (e) {
      debugPrint("Reschedule notifications error: $e");
    }
  }

  Future<void> _scheduleIfFuture(
      int id,
      DateTime date,
      String title,
      String body, {
        String? payload,
      }) async {
    if (_notificationService == null) return;

    DateTime scheduleTime;
    if (date.hour == 0 && date.minute == 0) {
      scheduleTime = DateTime(date.year, date.month, date.day, 9, 0);
    } else {
      scheduleTime = date;
    }

    if (scheduleTime.isAfter(DateTime.now())) {
      await _notificationService!.scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduleTime,
        payload: payload ?? 'screen_calendar',
      );
    }
  }

  // ✅ ВАЖНО: раньше это было void и теряло await → гонки/записи не успевали
  Future<void> setPeriodDate(DateTime date) async => setSpecificCycleStartDate(date);

  Future<void> reload() async => _init();
}
