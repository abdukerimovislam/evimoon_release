import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/notification_service.dart';

enum PillStatus { taken, missed, pending, future }

class COCProvider with ChangeNotifier {
  final Box _box;
  final NotificationService _notifications;

  bool _isEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);

  // History of actions
  List<DateTime> _history = []; // Taken pills
  List<DateTime> _missed = [];  // Missed pills (forgot to take)

  // 🔥 Pack Data
  DateTime _startDate = DateTime.now();
  int _activePillCount = 21;
  int _breakDays = 7;

  // 🔑 Keys (Synced with CycleProvider)
  static const String _keyEnabled = 'coc_enabled';
  static const String _keyPillCount = 'coc_active_count';
  static const String _keyBreakDays = 'coc_break_days';

  static const String _keyStartDate = 'coc_start_date';
  static const String _keyTimeHour = 'coc_time_hour';
  static const String _keyTimeMinute = 'coc_time_minute';
  static const String _keyHistory = 'coc_history';
  static const String _keyMissed = 'coc_missed_history';

  static const int _notificationId = 1001;

  COCProvider(this._box, this._notifications) {
    _init();
  }

  void _init() {
    _isEnabled = _box.get(_keyEnabled, defaultValue: false);
    _activePillCount = _box.get(_keyPillCount, defaultValue: 21);
    _breakDays = _box.get(_keyBreakDays, defaultValue: 7);

    final startMs = _box.get(_keyStartDate);
    if (startMs != null) {
      _startDate = DateTime.fromMillisecondsSinceEpoch(startMs);
    } else {
      _startDate = DateTime.now();
    }

    final h = _box.get(_keyTimeHour, defaultValue: 20);
    final m = _box.get(_keyTimeMinute, defaultValue: 0);
    _reminderTime = TimeOfDay(hour: h, minute: m);

    // Load Taken History
    final rawHistory = _box.get(_keyHistory, defaultValue: []);
    if (rawHistory is List) {
      _history = rawHistory.map((e) {
        if (e is int) return DateTime.fromMillisecondsSinceEpoch(e);
        return DateTime.now();
      }).toList();
    }
    _history.sort();

    // Load Missed History
    final rawMissed = _box.get(_keyMissed, defaultValue: []);
    if (rawMissed is List) {
      _missed = rawMissed.map((e) {
        if (e is int) return DateTime.fromMillisecondsSinceEpoch(e);
        return DateTime.now();
      }).toList();
    }
    _missed.sort();
  }

  // --- Getters ---
  bool get isEnabled => _isEnabled;
  TimeOfDay get reminderTime => _reminderTime;
  int get pillCount => _activePillCount;
  int get breakDays => _breakDays;
  DateTime get startDate => _startDate;

  bool get isLoaded => true;

  int get totalCycleLength => _activePillCount + _breakDays;

  bool get isTakenToday {
    final today = _normalizeDate(DateTime.now());
    return _isSameDayInList(_history, today);
  }

  // Calculate current pill number (1-based)
  int get currentPillNumber {
    final now = _normalizeDate(DateTime.now());
    final start = _normalizeDate(_startDate);
    final diff = now.difference(start).inDays;

    if (diff < 0) return 1;
    final dayInCycle = (diff % totalCycleLength) + 1;
    return dayInCycle;
  }

  bool get isOnBreak {
    return currentPillNumber > _activePillCount;
  }

  // --- Smart Logic (New) ---

  /// Returns the status of a specific date for UI rendering
  PillStatus getPillStatus(DateTime date) {
    final normDate = _normalizeDate(date);
    final today = _normalizeDate(DateTime.now());

    if (normDate.isAfter(today)) return PillStatus.future;

    if (_isSameDayInList(_history, normDate)) return PillStatus.taken;
    if (_isSameDayInList(_missed, normDate)) return PillStatus.missed;

    return PillStatus.pending;
  }

  /// Returns list of dates that have no status (neither taken nor missed)
  /// Useful for "Did you forget?" dialogs.
  List<DateTime> getUntrackedDates({int limit = 5}) {
    List<DateTime> untracked = [];
    final today = _normalizeDate(DateTime.now());

    // Check last 5 days
    for (int i = 1; i <= limit; i++) {
      final d = today.subtract(Duration(days: i));
      // Stop if date is before start of COC tracking
      if (d.isBefore(_normalizeDate(_startDate))) break;

      if (getPillStatus(d) == PillStatus.pending) {
        untracked.add(d);
      }
    }
    return untracked;
  }

  // --- Actions ---

  Future<void> initSettings({
    required DateTime startDate,
    required int activePills,
    required int breakDays,
  }) async {
    _startDate = _normalizeDate(startDate);
    _activePillCount = activePills;
    _breakDays = breakDays;

    await _box.put(_keyStartDate, _startDate.millisecondsSinceEpoch);
    await _box.put(_keyPillCount, activePills);
    await _box.put(_keyBreakDays, breakDays);

    await toggleCOC(true);
  }

  Future<void> toggleCOC(bool value, {String? notifTitle, String? notifBody}) async {
    _isEnabled = value;
    await _box.put(_keyEnabled, value);

    if (value) {
      if (notifTitle != null && notifBody != null) {
        await _scheduleNotification(notifTitle, notifBody);
      }
    } else {
      await _notifications.cancelNotification(_notificationId);
    }
    notifyListeners();
  }

  Future<void> setPillCount(int count) async {
    _activePillCount = count;
    await _box.put(_keyPillCount, count);
    notifyListeners();
  }

  Future<void> setPackData(int active, int brk) async {
    _activePillCount = active;
    _breakDays = brk;
    await _box.put(_keyPillCount, active);
    await _box.put(_keyBreakDays, brk);
    notifyListeners();
  }

  Future<void> setTime(TimeOfDay time, {required String notifTitle, required String notifBody}) async {
    _reminderTime = time;
    await _box.put(_keyTimeHour, time.hour);
    await _box.put(_keyTimeMinute, time.minute);

    if (_isEnabled) {
      await _scheduleNotification(notifTitle, notifBody);
    }
    notifyListeners();
  }

  // --- Pill Management ---

  Future<void> takePill() async {
    final now = _normalizeDate(DateTime.now());
    await takePillOnDate(now);
  }

  Future<void> takePillOnDate(DateTime date) async {
    final normDate = _normalizeDate(date);

    // If it was marked missed, remove from missed
    if (_isSameDayInList(_missed, normDate)) {
      _missed.removeWhere((d) => _isSameDay(d, normDate));
    }

    if (_isSameDayInList(_history, normDate)) return;

    _history.add(normDate);
    _history.sort();
    if (_history.length > 90) _history.removeAt(0);

    await _saveHistory();
    notifyListeners();
  }

  // New: Mark as Missed (Forgot to take)
  Future<void> markAsMissed(DateTime date) async {
    final normDate = _normalizeDate(date);

    // If it was marked taken, remove from taken
    if (_isSameDayInList(_history, normDate)) {
      _history.removeWhere((d) => _isSameDay(d, normDate));
    }

    if (_isSameDayInList(_missed, normDate)) return;

    _missed.add(normDate);
    _missed.sort();
    if (_missed.length > 90) _missed.removeAt(0);

    await _saveHistory();
    notifyListeners();
  }

  Future<void> undoTakePill() async {
    final now = _normalizeDate(DateTime.now());
    await undoTakePillOnDate(now);
  }

  Future<void> undoTakePillOnDate(DateTime date) async {
    final normDate = _normalizeDate(date);
    _history.removeWhere((d) => _isSameDay(d, normDate));
    // Also remove from missed if present (reset to pending)
    _missed.removeWhere((d) => _isSameDay(d, normDate));

    await _saveHistory();
    notifyListeners();
  }

  bool isTakenOnDate(DateTime date) {
    final target = _normalizeDate(date);
    return _isSameDayInList(_history, target);
  }

  // --- Helpers ---

  DateTime _normalizeDate(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameDayInList(List<DateTime> list, DateTime target) {
    return list.any((d) => _isSameDay(d, target));
  }

  Future<void> _saveHistory() async {
    final historyMs = _history.map((e) => e.millisecondsSinceEpoch).toList();
    final missedMs = _missed.map((e) => e.millisecondsSinceEpoch).toList();

    await _box.put(_keyHistory, historyMs);
    await _box.put(_keyMissed, missedMs);
  }

  // --- Notifications ---

  Future<void> _scheduleNotification(String title, String body) async {
    await _notifications.scheduleDailyNotification(
      id: _notificationId,
      title: title,
      body: body,
      time: _reminderTime,
    );
  }

  Future<void> reschedule(String title, String body) async {
    if (_isEnabled) {
      await _scheduleNotification(title, body);
    }
  }
}