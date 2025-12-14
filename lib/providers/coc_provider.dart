import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/notification_service.dart';

class COCProvider with ChangeNotifier {
  final Box _box;
  final NotificationService _notifications;

  bool _isEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  List<DateTime> _history = [];
  int _pillCount = 21;

  // Ключи
  static const String _keyEnabled = 'coc_enabled';
  static const String _keyPillCount = 'coc_pill_count';
  static const String _keyTimeHour = 'coc_time_hour';
  static const String _keyTimeMinute = 'coc_time_minute';
  static const String _keyHistory = 'coc_history';

  COCProvider(this._box, this._notifications) {
    _init();
  }

  void _init() {
    _isEnabled = _box.get(_keyEnabled, defaultValue: false);
    _pillCount = _box.get(_keyPillCount, defaultValue: 21);

    final h = _box.get(_keyTimeHour, defaultValue: 20);
    final m = _box.get(_keyTimeMinute, defaultValue: 0);
    _reminderTime = TimeOfDay(hour: h, minute: m);

    // 🔥 ИСПРАВЛЕНИЕ ОШИБКИ ЗДЕСЬ
    // Hive возвращает List<dynamic>. Нам нужно вручную привести его к List<DateTime>
    final rawHistory = _box.get(_keyHistory, defaultValue: []);

    if (rawHistory is List) {
      _history = rawHistory.map((e) {
        // Если сохранили как миллисекунды (int)
        if (e is int) return DateTime.fromMillisecondsSinceEpoch(e);
        // Если вдруг там строка (старый формат)
        if (e is String) return DateTime.tryParse(e) ?? DateTime.now();
        return DateTime.now(); // Fallback
      }).toList();
    } else {
      _history = [];
    }

    _history.sort();
  }

  // --- Getters ---
  bool get isEnabled => _isEnabled;
  TimeOfDay get reminderTime => _reminderTime;
  int get pillCount => _pillCount;
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

  // --- Actions ---

  Future<void> toggleCOC(bool value, {String? notifTitle, String? notifBody}) async {
    _isEnabled = value;
    await _box.put(_keyEnabled, value);

    if (value) {
      if (notifTitle != null && notifBody != null) {
        await _scheduleNotification(notifTitle, notifBody);
      }
    } else {
      await _notifications.cancelNotification(999);
    }
    notifyListeners();
  }

  Future<void> setPillCount(int count) async {
    _pillCount = count;
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
    // Сохраняем как список чисел (миллисекунды), это самый надежный способ для Hive
    final timestamps = _history.map((e) => e.millisecondsSinceEpoch).toList();
    await _box.put(_keyHistory, timestamps);
  }

  // --- Notifications ---

  Future<void> _scheduleNotification(String title, String body) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, _reminderTime.hour, _reminderTime.minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.scheduleNotification(
      id: 999,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
    );
  }
}