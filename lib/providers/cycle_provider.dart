import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/cycle_model.dart';
import '../services/notification_service.dart';
import '../logic/cycle_ai_engine.dart';
import '../l10n/app_localizations.dart';

enum FertilityChance { low, high, peak }
enum TTCStrategy { minimal, maximal }

class CycleProvider with ChangeNotifier {
  Box _cycleBox;
  Box _settingsBox;
  final NotificationService? _notificationService;

  CycleData _currentData = CycleData.empty();
  List<CycleModel> _history = [];
  CycleConfidenceResult? _aiConfidence;

  bool _isCOCEnabled = false;
  bool _isTTCMode = false;
  int _avgCycleLength = 28;
  int _avgPeriodDuration = 5;

  TTCStrategy _ttcStrategy = TTCStrategy.minimal;

  int? _periodEndCycleStartMs;
  int? _periodEndedAtDay;

  DateTime? _ovulationOverride;
  String? _ovulationOverrideSource;

  bool _isLoaded = false;

  CycleProvider(this._cycleBox, this._settingsBox, [this._notificationService]) {
    _init();
  }

  CycleData get currentData => _currentData;
  List<CycleModel> get history => List.unmodifiable(_history);
  CycleConfidenceResult? get aiConfidence => _aiConfidence;

  int get cycleLength => _currentData.totalCycleLength > 0
      ? _currentData.totalCycleLength
      : (_isCOCEnabled ? 28 : _avgCycleLength);

  int get avgPeriodDuration => _avgPeriodDuration;
  int get periodDuration => _avgPeriodDuration;

  bool get isCOCEnabled => _isCOCEnabled;
  bool get isTTCMode => _isTTCMode;
  bool get isLoaded => _isLoaded;

  TTCStrategy get ttcStrategy => _ttcStrategy;
  bool get isOvulationConfirmed => _ovulationOverride != null;
  String? get ovulationOverrideSource => _ovulationOverrideSource;

  int get ovulationDay {
    if (_isCOCEnabled) return 14;
    // Защита от некорректного расчета до инициализации
    if (_currentData.cycleStartDate.year == 1970) return 14;

    if (_ovulationOverride != null) {
      return _ovulationOverride!.difference(_currentData.cycleStartDate).inDays + 1;
    }
    return cycleLength - 14;
  }

  int? get currentDPO {
    if (!_isTTCMode || _isCOCEnabled) return null;
    final current = _currentData.currentDay;
    final ovDay = ovulationDay;
    if (current > ovulationDay) return current - ovulationDay;
    return null;
  }

  FertilityChance get conceptionChance {
    if (!_isTTCMode || _isCOCEnabled) return FertilityChance.low;

    final current = _currentData.currentDay;
    final ovDay = ovulationDay;

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

  Future<void> _ensureBoxOpen() async {
    if (!_settingsBox.isOpen) {
      _settingsBox = await Hive.openBox(_settingsBox.name);
    }
    if (!_cycleBox.isOpen) {
      _cycleBox = await Hive.openBox(_cycleBox.name);
    }
  }

  DateTime _normalizeDate(DateTime d) {
    final local = d.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  void _loadOverrides() {
    try {
      _periodEndCycleStartMs = _settingsBox.get('period_end_cycle_start') as int?;
      _periodEndedAtDay = _settingsBox.get('period_end_day') as int?;

      final ovMs = _settingsBox.get('current_ovulation_override') as int?;
      _ovulationOverride = ovMs != null ? DateTime.fromMillisecondsSinceEpoch(ovMs) : null;

      _ovulationOverrideSource = _settingsBox.get('current_ovulation_override_source') as String?;

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

  Future<void> _init() async {
    _isLoaded = false;

    try {
      await _ensureBoxOpen();

      _isCOCEnabled = _settingsBox.get('coc_enabled', defaultValue: false);
      _isTTCMode = _settingsBox.get('ttc_mode_enabled', defaultValue: false);
      _avgCycleLength = _settingsBox.get('avg_cycle_len', defaultValue: 28);
      _avgPeriodDuration = _settingsBox.get('avg_period_len', defaultValue: 5);

      _loadOverrides();

      _history = [];
      if (_cycleBox.isNotEmpty) {
        _history = _cycleBox.values.cast<CycleModel>().toList();
        _history.sort((a, b) => b.startDate.compareTo(a.startDate));
      }

      DateTime start;
      final savedStartTimestamp = _settingsBox.get('current_cycle_start');

      if (savedStartTimestamp != null) {
        start = DateTime.fromMillisecondsSinceEpoch(savedStartTimestamp);
      } else if (_history.isNotEmpty) {
        start = _history.first.startDate;
      } else {
        start = DateTime.now();
      }

      start = _normalizeDate(start);

      _recalculateAverages();
      _calculateAIConfidence();
      _updateCurrentData(start, _avgCycleLength, _avgPeriodDuration, notify: false);

      _isLoaded = true;
      notifyListeners();

      rescheduleNotifications();
    } catch (e) {
      debugPrint("CycleProvider Init Error: $e");
      _isLoaded = true;
      notifyListeners();
    }
  }

  void _updateCurrentData(
      DateTime startDate,
      int avgLen,
      int periodLen, {
        bool notify = true,
      }) {
    final now = DateTime.now();
    final normalizedNow = _normalizeDate(now);
    final normalizedStart = _normalizeDate(startDate);

    final safeStart = normalizedStart.isAfter(normalizedNow) ? normalizedNow : normalizedStart;

    final diff = normalizedNow.difference(safeStart).inDays;
    int currentDay = diff + 1;
    if (currentDay <= 0) currentDay = 1;

    int effectiveCycleLen;
    DateTime predictedOvulation;

    if (_isCOCEnabled) {
      effectiveCycleLen = 28;
      predictedOvulation = safeStart.add(const Duration(days: 14));
    } else if (_ovulationOverride != null) {
      predictedOvulation = _normalizeDate(_ovulationOverride!);
      final daysToOvulation = predictedOvulation.difference(safeStart).inDays;
      effectiveCycleLen = daysToOvulation + 14;
    } else {
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

    final ovDayIndex = predictedOvulation.difference(safeStart).inDays + 1;
    final bool isFertile =
        !_isCOCEnabled && (currentDay >= (ovDayIndex - 5) && currentDay <= ovDayIndex);

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

    final bool endedForThisCycle = _periodOverrideApplies(cycleStart);
    final int? endedAtDay = endedForThisCycle ? _periodEndedAtDay : null;

    if (period > 0 && day <= period) {
      if (endedAtDay != null && day >= endedAtDay) {
        return CyclePhase.follicular;
      } else {
        return CyclePhase.menstruation;
      }
    }

    final ovDayIndex = ovulationDate.difference(cycleStart).inDays + 1;

    if (ovDayIndex > period) {
      if (day >= ovDayIndex - 2 && day <= ovDayIndex + 1) return CyclePhase.ovulation;
    }

    if (day < ovDayIndex - 2) return CyclePhase.follicular;
    if (day > length) return CyclePhase.late;

    return CyclePhase.luteal;
  }

  CyclePhase? getPhaseForDate(DateTime date) {
    final normalized = _normalizeDate(date);

    for (final h in _history) {
      if (h.endDate == null) continue;

      final hs = _normalizeDate(h.startDate);
      final he = _normalizeDate(h.endDate!);

      if (!normalized.isBefore(hs) && !normalized.isAfter(he)) {
        final day = normalized.difference(hs).inDays + 1;
        final len = _cycleLenFromModel(h);
        if (len <= 0) return null;

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

    final start = _normalizeDate(_currentData.cycleStartDate);

    if (!normalized.isBefore(start)) {
      final currentCycleLen = cycleLength;
      final currentCycleEnd = start.add(Duration(days: currentCycleLen));

      if (normalized.isBefore(currentCycleEnd)) {
        final dayInCycle = normalized.difference(start).inDays + 1;

        DateTime ovDate;
        if (_ovulationOverride != null) {
          ovDate = _ovulationOverride!;
        } else {
          ovDate = start.add(Duration(days: currentCycleLen - 14));
        }

        return _calculatePhase(
          day: dayInCycle,
          length: currentCycleLen,
          period: _avgPeriodDuration,
          isCOC: _isCOCEnabled,
          cycleStart: start,
          ovulationDate: ovDate,
        );
      } else {
        final avgLen = _isCOCEnabled ? 28 : _avgCycleLength;
        final daysFromNextStart = normalized.difference(currentCycleEnd).inDays;
        final futureCyclesPassed = (daysFromNextStart / avgLen).floor();
        final thisFutureCycleStart = currentCycleEnd.add(Duration(days: futureCyclesPassed * avgLen));
        final dayInCycle = normalized.difference(thisFutureCycleStart).inDays + 1;
        final ovDate = thisFutureCycleStart.add(Duration(days: avgLen - 14));

        return _calculatePhase(
          day: dayInCycle,
          length: avgLen,
          period: _avgPeriodDuration,
          isCOC: _isCOCEnabled,
          cycleStart: thisFutureCycleStart,
          ovulationDate: ovDate,
        );
      }
    }

    return null;
  }

  Future<void> setTTCStrategy(TTCStrategy strategy) async {
    await _ensureBoxOpen();
    _ttcStrategy = strategy;
    try {
      await _settingsBox.put('ttc_strategy', strategy == TTCStrategy.maximal ? 'maximal' : 'minimal');
    } catch (_) {}
    notifyListeners();
  }

  Future<void> confirmOvulation(DateTime date, {String source = 'manual'}) async {
    await _ensureBoxOpen();
    final normDate = _normalizeDate(date);
    if (normDate.isBefore(_currentData.cycleStartDate)) return;

    _ovulationOverride = normDate;
    _ovulationOverrideSource = source;
    await _settingsBox.put('current_ovulation_override', _ovulationOverride!.millisecondsSinceEpoch);
    await _settingsBox.put('current_ovulation_override_source', source);

    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await rescheduleNotifications();
  }

  Future<void> clearOvulationIfMatchesLHTestDate(DateTime testDate) async {
    await _ensureBoxOpen();
    if (_ovulationOverride == null) return;
    if (_ovulationOverrideSource != 'lh') return;

    final expectedOvulation = _normalizeDate(testDate.add(const Duration(days: 1)));
    if (_normalizeDate(_ovulationOverride!) != expectedOvulation) return;

    await _clearOvulationOverride();
    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await rescheduleNotifications();
    notifyListeners();
  }

  Future<void> tryAutoConfirmOvulationFromBBT(List<MapEntry<DateTime, double>> tempHistory) async {
    await _ensureBoxOpen();
    if (!_isTTCMode || _isCOCEnabled) return;
    if (_ovulationOverride != null) return;

    final cycleStart = _normalizeDate(_currentData.cycleStartDate);
    final temps = tempHistory
        .map((e) => MapEntry(_normalizeDate(e.key), e.value))
        .where((e) => !e.key.isBefore(cycleStart))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (temps.length < 10) return;

    final Map<DateTime, double> map = {for (final e in temps) e.key: e.value};
    final dates = map.keys.toList()..sort();

    DateTime? shiftStart;

    for (int i = 6; i < dates.length; i++) {
      final d = dates[i];
      final prevDates = <DateTime>[];
      for (int k = 1; k <= 6; k++) {
        final pd = d.subtract(Duration(days: k));
        if (map.containsKey(pd)) prevDates.add(pd);
      }
      if (prevDates.length < 5) continue;

      final baseline = prevDates.map((pd) => map[pd]!).reduce((a, b) => a + b) / prevDates.length;
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
    final minOvulation = cycleStart.add(Duration(days: _avgPeriodDuration));
    if (!estimatedOvulation.isAfter(minOvulation)) return;

    _ovulationOverride = estimatedOvulation;
    _ovulationOverrideSource = 'bbt';
    await _settingsBox.put('current_ovulation_override', estimatedOvulation.millisecondsSinceEpoch);
    await _settingsBox.put('current_ovulation_override_source', 'bbt');

    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await rescheduleNotifications();
    notifyListeners();
  }

  Future<void> clearOvulationData(DateTime date) async {
    await _ensureBoxOpen();
    if (date.isBefore(_currentData.cycleStartDate)) return;
    await _clearOvulationOverride();
    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, _avgPeriodDuration);
    await rescheduleNotifications();
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
    await _clearPeriodEndOverride();

    final now = DateTime.now();
    final normalizedNow = _normalizeDate(now);
    final normalizedStart = _normalizeDate(_currentData.cycleStartDate);

    if (normalizedStart.isAfter(normalizedNow)) return;

    if (normalizedNow.isAtSameMomentAs(normalizedStart)) {
      await setSpecificCycleStartDate(normalizedNow);
      return;
    }

    final prevEnd = normalizedNow.subtract(const Duration(days: 1));
    final length = prevEnd.difference(normalizedStart).inDays + 1;

    if (length >= 11 && length <= 150 && !_isCOCEnabled) {
      final historyItem = CycleModel(
        startDate: normalizedStart,
        endDate: prevEnd,
        length: length,
        ovulationOverrideDate: _ovulationOverride,
      );

      await _cycleBox.add(historyItem);

      _history = _cycleBox.values.cast<CycleModel>().toList();
      _history.sort((a, b) => b.startDate.compareTo(a.startDate));

      _recalculateAverages();
      _calculateAIConfidence();
    }

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

    if (normalizedDate.isAfter(_normalizeDate(DateTime.now()))) return;

    await _clearPeriodEndOverride();
    await _clearOvulationOverride();

    if (_avgPeriodDuration < 2) {
      _avgPeriodDuration = 5;
      await _settingsBox.put('avg_period_len', 5);
    }

    await _settingsBox.put('current_cycle_start', normalizedDate.millisecondsSinceEpoch);

    _updateCurrentData(normalizedDate, _avgCycleLength, _avgPeriodDuration);
    await rescheduleNotifications();
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
      await rescheduleNotifications();
    }

    notifyListeners();
  }

  Future<void> setAveragePeriodDuration(int days) async {
    await _ensureBoxOpen();
    days = days.clamp(1, 14);
    await _settingsBox.put('avg_period_len', days);
    _avgPeriodDuration = days;
    _updateCurrentData(_currentData.cycleStartDate, _avgCycleLength, days);
    await rescheduleNotifications();
  }

  Future<void> setCycleLength(int length) async {
    await _ensureBoxOpen();
    length = length.clamp(21, 45);
    await _settingsBox.put('avg_cycle_len', length);
    _avgCycleLength = length;
    _updateCurrentData(_currentData.cycleStartDate, length, _avgPeriodDuration);
    await rescheduleNotifications();
  }

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

  Future<void> rescheduleNotifications() async {
    if (_notificationService == null) return;

    try {
      await _notificationService!.cancelAll();

      Locale targetLocale;
      final savedLang = _settingsBox.get('language_code') as String?;

      if (savedLang != null) {
        targetLocale = Locale(savedLang);
      } else {
        final sysCode = Intl.defaultLocale?.split('_')[0] ?? 'en';
        targetLocale = Locale(sysCode);
      }

      final l10n = await AppLocalizations.delegate.load(targetLocale);

      final lastStart = _normalizeDate(_currentData.cycleStartDate);
      final len = cycleLength;
      final nextPeriodStart = lastStart.add(Duration(days: len));

      if (_isCOCEnabled) {
        await _scheduleIfFuture(
            100,
            nextPeriodStart,
            l10n.notifNewPackTitle,
            l10n.notifNewPackBody,
            payload: "screen_coc"
        );

        final breakDate = lastStart.add(const Duration(days: 21));
        await _scheduleIfFuture(
            101,
            breakDate,
            l10n.notifBreakTitle,
            l10n.notifBreakBody,
            payload: "screen_coc"
        );
        return;
      }

      final day7 = lastStart.add(const Duration(days: 6));
      await _scheduleIfFuture(
          201,
          day7,
          l10n.notifFollTitle,
          l10n.notifFollBody,
          payload: "screen_calendar"
      );

      final ovDay = ovulationDay;
      if (ovDay > 1) {
        final ovDate = lastStart.add(Duration(days: ovDay - 1));
        await _scheduleIfFuture(
            202,
            ovDate,
            l10n.notifOvulationTitle,
            l10n.notifOvulationBody,
            payload: "screen_calendar"
        );
      }

      final pmsDay = len - 5;
      if (pmsDay > 10) {
        final pmsDate = lastStart.add(Duration(days: pmsDay - 1));
        await _scheduleIfFuture(
            203,
            pmsDate,
            l10n.notifLutealTitle,
            l10n.notifLutealBody,
            payload: "screen_calendar"
        );
      }

      final prePeriodDate = nextPeriodStart.subtract(const Duration(days: 1));
      await _scheduleIfFuture(
          204,
          prePeriodDate,
          l10n.notifPeriodSoonTitle,
          l10n.notifPeriodSoonBody,
          payload: "screen_calendar"
      );

      final lateDate = nextPeriodStart.add(const Duration(days: 3));
      await _scheduleIfFuture(
          205,
          lateDate,
          l10n.notifLateTitle,
          l10n.notifLateBody,
          payload: "screen_calendar"
      );

      final now = DateTime.now();
      final todayEvening = DateTime(now.year, now.month, now.day, 20, 0);
      if (todayEvening.isAfter(now)) {
        await _scheduleIfFuture(
            300,
            todayEvening,
            l10n.notifCheckinTitle,
            l10n.notifCheckinBody,
            payload: "screen_calendar"
        );
      }

      debugPrint("✅ Notifications scheduled for locale: ${targetLocale.languageCode}");

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