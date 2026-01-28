import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/notification_service.dart';

class COCProvider with ChangeNotifier {
  final Box _box;
  final NotificationService _notifications;

  bool _isEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  List<DateTime> _history = [];

  // 🔥 Новые поля для логики пачек
  DateTime _startDate = DateTime.now(); // Дата начала ТЕКУЩЕЙ пачки
  int _activePillCount = 21; // Количество активных таблеток
  int _breakDays = 7; // Количество дней перерыва

  // Ключи
  static const String _keyEnabled = 'coc_enabled';
  static const String _keyPillCount = 'coc_pill_count';
  static const String _keyBreakDays = 'coc_break_days'; // Новый ключ
  static const String _keyStartDate = 'coc_start_date'; // Новый ключ
  static const String _keyTimeHour = 'coc_time_hour';
  static const String _keyTimeMinute = 'coc_time_minute';
  static const String _keyHistory = 'coc_history';

  COCProvider(this._box, this._notifications) {
    _init();
  }

  void _init() {
    _isEnabled = _box.get(_keyEnabled, defaultValue: false);
    _activePillCount = _box.get(_keyPillCount, defaultValue: 21);
    _breakDays = _box.get(_keyBreakDays, defaultValue: 7);

    // Загрузка даты старта
    final startMs = _box.get(_keyStartDate);
    if (startMs != null) {
      _startDate = DateTime.fromMillisecondsSinceEpoch(startMs);
    } else {
      _startDate = DateTime.now();
    }

    final h = _box.get(_keyTimeHour, defaultValue: 20);
    final m = _box.get(_keyTimeMinute, defaultValue: 0);
    _reminderTime = TimeOfDay(hour: h, minute: m);

    // Загрузка истории
    final rawHistory = _box.get(_keyHistory, defaultValue: []);
    if (rawHistory is List) {
      _history = rawHistory.map((e) {
        if (e is int) return DateTime.fromMillisecondsSinceEpoch(e);
        if (e is String) return DateTime.tryParse(e) ?? DateTime.now();
        return DateTime.now();
      }).toList();
    } else {
      _history = [];
    }
    _history.sort();
  }

  // --- Getters ---
  bool get isEnabled => _isEnabled;
  TimeOfDay get reminderTime => _reminderTime;
  int get pillCount => _activePillCount;
  int get breakDays => _breakDays;
  DateTime get startDate => _startDate;
  bool get isLoaded => true;

  bool get isTakenToday {
    if (_history.isEmpty) return false;
    final today = DateTime.now();
    return isTakenOnDate(today);
  }

  bool isTakenOnDate(DateTime date) {
    return _history.any((d) =>
    d.year == date.year && d.month == date.month && d.day == date.day
    );
  }

  // 🔥 Расчет текущего дня в пачке (1-based)
  int get currentPillNumber {
    final now = DateTime.now();
    final diff = now.difference(_startDate).inDays;
    final totalCycle = _activePillCount + _breakDays;

    // Остаток от деления на длину цикла пачки
    final dayInCycle = (diff % totalCycle) + 1;
    return dayInCycle;
  }

  // Находимся ли мы сейчас на перерыве (месячные)?
  bool get isOnBreak {
    return currentPillNumber > _activePillCount;
  }

  // --- Actions ---

  // 🔥 Метод для Онбординга
  Future<void> initSettings({
    required DateTime startDate,
    required int activePills,
    required int breakDays,
  }) async {
    _startDate = startDate;
    _activePillCount = activePills;
    _breakDays = breakDays;

    await _box.put(_keyStartDate, startDate.millisecondsSinceEpoch);
    await _box.put(_keyPillCount, activePills);
    await _box.put(_keyBreakDays, breakDays);

    // Включаем уведомления по умолчанию на 20:00
    await setTime(const TimeOfDay(hour: 20, minute: 0), notifTitle: "Pill Time 💊", notifBody: "Time to take your pill!");

    notifyListeners();
  }

  Future<void> toggleCOC(bool value, {String? notifTitle, String? notifBody}) async {
    _isEnabled = value;
    await _box.put(_keyEnabled, value);

    if (value) {
      // При включении шедулим уведомление
      await _scheduleNotification(
          notifTitle ?? "Pill Time 💊",
          notifBody ?? "Don't forget your pill!"
      );
    } else {
      await _notifications.cancelNotification(1001); // Используем ID 1001 для таблеток
    }
    notifyListeners();
  }

  Future<void> setPillCount(int count) async {
    _activePillCount = count;
    await _box.put(_keyPillCount, count);
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

  Future<void> takePill() async {
    if (isTakenToday) return;
    await takePillOnDate(DateTime.now());
  }

  Future<void> takePillOnDate(DateTime date) async {
    if (isTakenOnDate(date)) return;

    _history.add(date);
    _history.sort();

    if (_history.length > 90) {
      _history.removeAt(0);
    }

    await _saveHistory();
    notifyListeners();
  }

  Future<void> undoTakePill() async {
    await undoTakePillOnDate(DateTime.now());
  }

  Future<void> undoTakePillOnDate(DateTime date) async {
    _history.removeWhere((d) =>
    d.year == date.year && d.month == date.month && d.day == date.day
    );
    await _saveHistory();
    notifyListeners();
  }

  // Вспомогательный метод сохранения
  Future<void> _saveHistory() async {
    final timestamps = _history.map((e) => e.millisecondsSinceEpoch).toList();
    await _box.put(_keyHistory, timestamps);
  }

  // --- Notifications ---

  Future<void> _scheduleNotification(String title, String body) async {
    // Используем метод для ЕЖЕДНЕВНЫХ уведомлений
    // ID 1001 зарезервирован под таблетки
    await _notifications.scheduleDailyNotification(
      id: 1001,
      title: title,
      body: body,
      time: _reminderTime,
    );
  }
}