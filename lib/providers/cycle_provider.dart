import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/cycle_model.dart';
import '../services/notification_service.dart';
import '../logic/cycle_ai_engine.dart';

// Enum для вероятности зачатия
enum FertilityChance { low, high, peak }

// ✅ TTC стратегия (для "вау" UX: план действий)
enum TTCStrategy { minimal, maximal }

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

  // ✅ TTC Strategy (persisted)
  TTCStrategy _ttcStrategy = TTCStrategy.minimal;

  // ✅ OVERRIDE: Пользователь нажал “Закончить месячные”
  int? _periodEndCycleStartMs;
  int? _periodEndedAtDay;

  // ✅ OVERRIDE: Подтвержденная овуляция (Тест/БТТ) для ТЕКУЩЕГО цикла
  DateTime? _ovulationOverride;

  // Источник подтверждения овуляции (для безопасного автосброса)
  // Возможные значения: 'lh', 'bbt', 'manual'
  String? _ovulationOverrideSource;

  // Флаг загрузки
  bool _isLoaded = false;

  CycleProvider(this._cycleBox, this._settingsBox, [this._notificationService]) {
    _init();
  }

  // --- Геттеры ---
  CycleData get currentData => _currentData;
  List<CycleModel> get history => List.unmodifiable(_history);
  CycleConfidenceResult? get aiConfidence => _aiConfidence;

  // Длина цикла динамическая: если есть override овуляции, цикл подстраивается
  int get cycleLength => _currentData.totalCycleLength > 0
      ? _currentData.totalCycleLength
      : (_isCOCEnabled ? 28 : _avgCycleLength);

  int get avgPeriodDuration => _avgPeriodDuration;
  int get periodDuration => _avgPeriodDuration;

  bool get isCOCEnabled => _isCOCEnabled;
  bool get isTTCMode => _isTTCMode;
  bool get isLoaded => _isLoaded;

  // ✅ New getters for TTC UI
  TTCStrategy get ttcStrategy => _ttcStrategy;

  // ✅ Ovulation confirmation status for badge in UI
  bool get isOvulationConfirmed => _ovulationOverride != null;

  // ✅ Source for badge (lh/bbt/manual)
  String? get ovulationOverrideSource => _ovulationOverrideSource;

  // --- 🤰 TTC (ПЛАНИРОВАНИЕ) ---

  // День овуляции относительно начала цикла (1-based)
  int get ovulationDay {
    if (_isCOCEnabled) return 14;
    // Если есть override, считаем по нему
    if (_ovulationOverride != null) {
      return _ovulationOverride!.difference(_currentData.cycleStartDate).inDays + 1;
    }
    return cycleLength - 14;
  }

  int? get currentDPO {
    if (!_isTTCMode || _isCOCEnabled) return null;
    final current = _currentData.currentDay;
    if (current > ovulationDay) return current - ovulationDay;
    return null;
  }

  FertilityChance get conceptionChance {
    if (!_isTTCMode || _isCOCEnabled) return FertilityChance.low;

    final current = _currentData.currentDay;
    final ovDay = ovulationDay;

    // Защита: во время месячных шанс всегда низкий (если только цикл не супер короткий)
    if (_currentData.phase == CyclePhase.menstruation && current < 6) {
      return FertilityChance.low;
    }

    if (current == ovDay || current == ovDay - 1) {
      return FertilityChance.peak;
    }
    if (current >= ovDay - 5 && current < ovDay - 1) {
      return FertilityChance.high;
    }
    return FertilityChance.low;
  }

  bool get isFertileWindow {
    if (!_isTTCMode || _isCOCEnabled) return false;
    final current = _currentData.currentDay;
    final ovDay = ovulationDay;
    return current >= (ovDay - 5) && current <= ovDay;
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

  void _loadOverrides() {
    try {
      _periodEndCycleStartMs = _settingsBox.get('period_end_cycle_start') as int?;
      _periodEndedAtDay = _settingsBox.get('period_end_day') as int?;

      final ovMs = _settingsBox.get('current_ovulation_override') as int?;
      _ovulationOverride = ovMs != null ? DateTime.fromMillisecondsSinceEpoch(ovMs) : null;

      _ovulationOverrideSource = _settingsBox.get('current_ovulation_override_source') as String?;

      // ✅ load TTC strategy
      final rawStrategy = _settingsBox.get('ttc_strategy') as String?;
      if (rawStrategy == 'maximal') {
        _ttcStrategy = TTCStrategy.maximal;
      } else {
        _ttcStrategy = TTCStrategy.minimal;
      }
    } catch (_) {
      _periodEndCycleStartMs = null;
      _periodEndedAtDay = null;
      _ovulationOverride = null;
      _ovulationOverrideSource = null;
      _ttcStrategy = TTCStrategy.minimal;
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

  Future<void> _clearOvulationOverride() async {
    _ovulationOverride = null;
    _ovulationOverrideSource = null;
    try {
      await _settingsBox.delete('current_ovulation_override');
      await _settingsBox.delete('current_ovulation_override_source');
    } catch (_) {}
  }

  bool _periodOverrideApplies(DateTime cycleStart) {
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

      _loadOverrides();

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

      // Ставим уведомления после загрузки
      _rescheduleNotifications();
    } catch (e) {
      debugPrint("CycleProvider Init Error: $e");
      // В случае ошибки ставим флаг, чтобы UI не завис вечно
      _isLoaded = true;
      notifyListeners();
    }
  }

  // --- 🧮 Ядро расчетов ---

  void _updateCurrentData(
      DateTime startDate,
      int avgLen,
      int periodLen, {
        bool notify = true,
      }) {
    final now = DateTime.now();
    final normalizedNow = _normalizeDate(now);
    final normalizedStart = _normalizeDate(startDate);

    // Если старт в будущем — фиксируем на сегодня
    final safeStart = normalizedStart.isAfter(normalizedNow) ? normalizedNow : normalizedStart;

    final diff = normalizedNow.difference(safeStart).inDays;
    int currentDay = diff + 1;
    if (currentDay <= 0) currentDay = 1;

    // 🔥 РАСЧЕТ ДЛИНЫ ЦИКЛА И ОВУЛЯЦИИ
    int effectiveCycleLen;
    DateTime predictedOvulation;

    if (_isCOCEnabled) {
      effectiveCycleLen = 28;
      predictedOvulation = safeStart.add(const Duration(days: 14)); // Условно
    } else if (_ovulationOverride != null) {
      // А. Если овуляция подтверждена пользователем
      predictedOvulation = _normalizeDate(_ovulationOverride!);
      // Если овуляция была на X день, то весь цикл будет X + 14 (лютеиновая фаза)
      final daysToOvulation = predictedOvulation.difference(safeStart).inDays;
      effectiveCycleLen = daysToOvulation + 14;
    } else {
      // Б. Стандартный календарный метод
      effectiveCycleLen = avgLen.clamp(21, 45);
      predictedOvulation = safeStart.add(Duration(days: effectiveCycleLen - 14));
    }

    final phase = _calculatePhase(
      day: currentDay,
      length: effectiveCycleLen,
      period: periodLen,
      isCOC: _isCOCEnabled,
      cycleStart: safeStart,
      ovulationDate: predictedOvulation,
    );

    // Окно фертильности (для UI)
    final ovDayIndex = predictedOvulation.difference(safeStart).inDays + 1;
    final bool isFertile =
        !_isCOCEnabled && (currentDay >= (ovDayIndex - 5) && currentDay <= ovDayIndex);

    // Дни до следующих месячных
    final nextPeriodDate = safeStart.add(Duration(days: effectiveCycleLen));
    int daysUntilNext = nextPeriodDate.difference(normalizedNow).inDays;

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
    required DateTime ovulationDate,
  }) {
    if (isCOC) {
      if (day <= 21) return CyclePhase.follicular;
      if (day <= 28) return CyclePhase.menstruation;
      return CyclePhase.late;
    }

    // Проверка на Override конца месячных
    final bool endedForThisCycle = _periodOverrideApplies(cycleStart);
    final int? endedAtDay = endedForThisCycle ? _periodEndedAtDay : null;

    // 1. Менструация
    if (period > 0 && day <= period) {
      if (endedAtDay != null && day >= endedAtDay) {
        // Месячные принудительно закончены -> Фолликулярная
        return CyclePhase.follicular;
      } else {
        return CyclePhase.menstruation;
      }
    }

    final ovDayIndex = ovulationDate.difference(cycleStart).inDays + 1;

    // 2. Овуляция (день Х и +- окно фертильности в визуале, но здесь строгий расчет)
    // Защита: Овуляция не может быть во время месячных
    if (ovDayIndex > period) {
      if (day >= ovDayIndex - 2 && day <= ovDayIndex + 1) return CyclePhase.ovulation;
    }

    // 3. Фолликулярная (до овуляции)
    if (day < ovDayIndex - 2) return CyclePhase.follicular;

    // 4. Задержка (после ожидаемого конца)
    if (day > length) return CyclePhase.late;

    // 5. Лютеиновая (все остальное после овуляции)
    return CyclePhase.luteal;
  }

  // --- 🎮 Действия пользователя ---

  // ✅ New: set TTC strategy + persist (Hive)
  Future<void> setTTCStrategy(TTCStrategy strategy) async {
    await _ensureBoxOpen();
    _ttcStrategy = strategy;
    try {
      await _settingsBox.put('ttc_strategy', strategy == TTCStrategy.maximal ? 'maximal' : 'minimal');
    } catch (_) {}
    notifyListeners();
  }

  // 🔥 Вызывается из UI, когда тест ЛГ положительный
  Future<void> confirmOvulation(DateTime date, {String source = 'manual'}) async {
    await _ensureBoxOpen();

    // Валидация: Овуляция не может быть до начала цикла
    if (date.isBefore(_currentData.cycleStartDate)) return;

    _ovulationOverride = _normalizeDate(date);
    _ovulationOverrideSource = source;
    await _settingsBox.put('current_ovulation_override', _ovulationOverride!.millisecondsSinceEpoch);
    await _settingsBox.put('current_ovulation_override_source', source);

    // Обновляем данные (теперь цикл пересчитается от этой даты)
    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await _rescheduleNotifications();
  }

  /// Безопасный сброс подтвержденной овуляции, если она была выставлена
  /// именно этим ЛГ-тестом (т.е. testDate + 1 день) и источник = 'lh'.
  /// Это предотвращает ситуацию, когда отрицательный тест/ресет случайно
  /// стирает подтверждение, полученное по БТТ или вручную.
  Future<void> clearOvulationIfMatchesLHTestDate(DateTime testDate) async {
    await _ensureBoxOpen();

    if (_ovulationOverride == null) return;
    if (_ovulationOverrideSource != 'lh') return;

    final expectedOvulation = _normalizeDate(testDate.add(const Duration(days: 1)));
    if (_normalizeDate(_ovulationOverride!) != expectedOvulation) return;

    await _clearOvulationOverride();
    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await _rescheduleNotifications();
    notifyListeners();
  }

  /// Автоподтверждение овуляции по сдвигу БТТ.
  /// Работает ТОЛЬКО для текущего цикла и только если овуляция ещё не подтверждена.
  ///
  /// Алгоритм (упрощенный, но устойчивый):
  /// - берем температуры текущего цикла
  /// - ищем первую дату, когда есть 3 подряд значения >= (среднее из 6 предыдущих) + 0.2°C
  /// - овуляция оценивается как день ДО первого "высокого" дня
  Future<void> tryAutoConfirmOvulationFromBBT(List<MapEntry<DateTime, double>> tempHistory) async {
    await _ensureBoxOpen();

    if (!_isTTCMode || _isCOCEnabled) return;
    if (_ovulationOverride != null) return;

    final cycleStart = _normalizeDate(_currentData.cycleStartDate);

    // Отфильтровать температуры по текущему циклу
    final temps = tempHistory
        .map((e) => MapEntry(_normalizeDate(e.key), e.value))
        .where((e) => !e.key.isBefore(cycleStart))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (temps.length < 10) return; // мало данных

    // Индексируем по дате для быстрого доступа к последовательности
    final Map<DateTime, double> map = {for (final e in temps) e.key: e.value};
    final dates = map.keys.toList()..sort();

    DateTime? shiftStart;

    for (int i = 6; i < dates.length; i++) {
      final d = dates[i];
      // 6 дней "до" должны существовать как даты с измерениями
      final prevDates = <DateTime>[];
      for (int k = 1; k <= 6; k++) {
        final pd = d.subtract(Duration(days: k));
        if (map.containsKey(pd)) prevDates.add(pd);
      }
      if (prevDates.length < 5) continue; // допускаем 1 пропуск

      final baseline =
          prevDates.map((pd) => map[pd]!).reduce((a, b) => a + b) / prevDates.length;

      // Проверяем 3 подряд "высоких" дня: d, d+1, d+2
      final d1 = d.add(const Duration(days: 1));
      final d2 = d.add(const Duration(days: 2));
      if (!map.containsKey(d1) || !map.containsKey(d2)) continue;

      final threshold = baseline + 0.20;
      if (map[d]! >= threshold && map[d1]! >= threshold && map[d2]! >= threshold) {
        shiftStart = d;
        break;
      }
    }

    if (shiftStart == null) return;

    final estimatedOvulation = _normalizeDate(shiftStart.subtract(const Duration(days: 1)));

    // Защита: не подтверждаем овуляцию во время месячных
    final minOvulation = cycleStart.add(Duration(days: _avgPeriodDuration));
    if (!estimatedOvulation.isAfter(minOvulation)) return;

    _ovulationOverride = estimatedOvulation;
    _ovulationOverrideSource = 'bbt';
    await _settingsBox.put('current_ovulation_override', estimatedOvulation.millisecondsSinceEpoch);
    await _settingsBox.put('current_ovulation_override_source', 'bbt');

    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await _rescheduleNotifications();
    notifyListeners();
  }

  // 🔥 НОВЫЙ МЕТОД: Отмена подтвержденной овуляции
  Future<void> clearOvulationData(DateTime date) async {
    await _ensureBoxOpen();

    // Работаем только с текущим циклом
    if (date.isBefore(_currentData.cycleStartDate)) return;

    await _clearOvulationOverride();

    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await _rescheduleNotifications();

    notifyListeners();
  }

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

    // Новый цикл = сбрасываем override текущего цикла
    await _clearPeriodEndOverride();

    final now = DateTime.now();
    final normalizedNow = _normalizeDate(now);
    final normalizedStart = _normalizeDate(_currentData.cycleStartDate);

    if (normalizedStart.isAfter(normalizedNow)) return;

    // Если уже сегодня — просто обновляем старт
    if (normalizedNow.isAtSameMomentAs(normalizedStart)) {
      await setSpecificCycleStartDate(normalizedNow);
      return;
    }

    final prevEnd = normalizedNow.subtract(const Duration(days: 1));
    final length = prevEnd.difference(normalizedStart).inDays + 1;

    // Сохраняем историю
    if (length >= 11 && length <= 120 && !_isCOCEnabled) {
      final historyItem = CycleModel(
        startDate: normalizedStart,
        endDate: prevEnd,
        length: length,
        ovulationOverrideDate: _ovulationOverride, // 🔥 Сохраняем подтвержденную овуляцию в историю
      );

      await _cycleBox.add(historyItem);

      _history = _cycleBox.values.cast<CycleModel>().toList();
      _history.sort((a, b) => b.startDate.compareTo(a.startDate));

      _recalculateAverages();
      _calculateAIConfidence();
    }

    // Сбрасываем override овуляции для НОВОГО цикла
    await _clearOvulationOverride();

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

    final startMs = start.millisecondsSinceEpoch;
    _periodEndCycleStartMs = startMs;
    _periodEndedAtDay = _currentData.currentDay;

    await _settingsBox.put('period_end_cycle_start', startMs);
    await _settingsBox.put('period_end_day', _periodEndedAtDay);

    await setAveragePeriodDuration(newDuration);

    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
  }

  Future<void> setSpecificCycleStartDate(DateTime date) async {
    await _ensureBoxOpen();
    final normalizedDate = _normalizeDate(date);

    await _clearPeriodEndOverride();
    await _clearOvulationOverride(); // Новый старт = новый расчет

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
      await _clearOvulationOverride();

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
      _aiConfidence = CycleAIEngine.calculateConfidence(_history);
    } catch (e) {
      debugPrint("AI Engine error: $e");
      _aiConfidence = null;
    }
  }

  // --- 📅 Календарь ---
  /// Возвращает фазу цикла для любой даты (в прошлом или будущем)
  CyclePhase? getPhaseForDate(DateTime date) {
    final normalized = _normalizeDate(date);

    // 1. Проверяем историю
    for (final h in _history) {
      if (h.endDate == null) continue;

      final hs = _normalizeDate(h.startDate);
      final he = _normalizeDate(h.endDate!);

      if (!normalized.isBefore(hs) && !normalized.isAfter(he)) {
        final day = normalized.difference(hs).inDays + 1;
        final len = _cycleLenFromModel(h);
        if (len <= 0) return null;

        // Если в истории есть подтвержденная овуляция
        DateTime ovDate;
        if (h.ovulationOverrideDate != null) {
          ovDate = h.ovulationOverrideDate!;
        } else {
          ovDate = hs.add(Duration(days: len - 14));
        }

        return _calculatePhase(
          day: day,
          length: len,
          period: _avgPeriodDuration,
          isCOC: false,
          cycleStart: hs,
          ovulationDate: ovDate,
        );
      }
    }

    // 2. Проверяем текущий/будущий цикл
    final start = _normalizeDate(_currentData.cycleStartDate);
    if (!normalized.isBefore(start)) {
      final daysDiff = normalized.difference(start).inDays;
      final len = cycleLength; // Учитывает текущий override овуляции
      final dayInCycle = (daysDiff % len) + 1;

      // Определяем начало ЭТОГО конкретного цикла (для будущего прогноза)
      final cyclesPassed = (daysDiff / len).floor();
      final thisCycleStart = start.add(Duration(days: cyclesPassed * len));

      // Для овуляции:
      // Если это самый ПЕРВЫЙ (текущий) цикл — учитываем override.
      // Если это будущие циклы — считаем стандартно (т.к. мы не знаем дату овуляции в будущем).
      DateTime ovDate;
      if (cyclesPassed == 0 && _ovulationOverride != null) {
        ovDate = _ovulationOverride!;
      } else {
        ovDate = thisCycleStart.add(Duration(days: len - 14));
      }

      return _calculatePhase(
        day: dayInCycle,
        length: len,
        period: _avgPeriodDuration,
        isCOC: _isCOCEnabled,
        cycleStart: thisCycleStart,
        ovulationDate: ovDate,
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
        await _scheduleIfFuture(100, nextPeriodStart, "New Pack 💊", "Time to start a new pack!",
            payload: "screen_coc");
        final breakDate = lastStart.add(const Duration(days: 21));
        await _scheduleIfFuture(101, breakDate, "Break Week 🩸", "Active pills finished.",
            payload: "screen_coc");
        return;
      }

      final day7 = lastStart.add(const Duration(days: 6));
      final tFoll = _getLabelsSafe('follicular', lang);
      await _scheduleIfFuture(201, day7, tFoll['t']!, tFoll['b']!, payload: "screen_calendar");

      // Овуляция (учитываем override)
      final ovDay = ovulationDay;
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

  Future<void> setPeriodDate(DateTime date) async => setSpecificCycleStartDate(date);

  Future<void> reload() async => _init();
}
