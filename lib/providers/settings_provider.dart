import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/secure_storage_service.dart';
import '../services/notification_service.dart';
import '../models/timer_design.dart';
import '../services/subscription_service.dart'; // 🔥 Импорт сервиса подписок

class SettingsProvider extends ChangeNotifier {
  final Box _box;
  final SecureStorageService _storageService;
  final NotificationService _notificationService;

  static const String _keyOnboarding = 'has_seen_onboarding';
  static const String _keyDailyLog = 'daily_log_enabled';
  static const String _keyDesign = 'timer_design_index';
  static const String _keyPremium = 'is_premium';

  SecureStorageService get storageService => _storageService;

  Locale _locale = const Locale('en');
  bool _notificationsEnabled = false;
  bool _biometricsEnabled = false;
  bool _isTTCMode = false;
  bool _dailyLogEnabled = false;

  TimerDesign _currentDesign = TimerDesign.classic;
  bool _isPremium = false;

  // Геттеры
  Locale get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get isTTCMode => _isTTCMode;
  bool get dailyLogEnabled => _dailyLogEnabled;
  TimerDesign get currentDesign => _currentDesign;

  // 🔥 Геттер статуса премиума
  bool get isPremium => _isPremium;

  SettingsProvider(this._box, this._storageService, this._notificationService) {
    _loadSettings();
  }

  bool get hasSeenOnboarding {
    return _box.get(_keyOnboarding, defaultValue: false);
  }

  Future<void> completeOnboarding() async {
    await _box.put(_keyOnboarding, true);
    notifyListeners();
  }

  Future<void> resetOnboarding() async {
    await _box.put(_keyOnboarding, false);
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    // Проверка на чистую установку
    final bool appWasReset = !_box.containsKey(_keyOnboarding);

    if (appWasReset) {
      // Первый запуск: очищаем всё
      await _storageService.clearAll();

      _isTTCMode = false;
      _notificationsEnabled = false;
      _biometricsEnabled = false;
      _dailyLogEnabled = false;
      _currentDesign = TimerDesign.classic;
      _isPremium = false;
    } else {
      // Обычный запуск: грузим настройки
      _notificationsEnabled = await _storageService.getNotificationsEnabled();
      _biometricsEnabled = await _storageService.getBiometricsEnabled();
      _isTTCMode = await _storageService.getTTCMode();

      // Грузим настройки из Hive
      _dailyLogEnabled = _box.get(_keyDailyLog, defaultValue: false);

      // 1. Сначала грузим кэшированный статус (для мгновенного UI)
      _isPremium = _box.get(_keyPremium, defaultValue: false);

      // Грузим дизайн
      final savedDesignIndex = _box.get(_keyDesign);
      if (savedDesignIndex != null && savedDesignIndex is int) {
        if (savedDesignIndex >= 0 && savedDesignIndex < TimerDesign.values.length) {
          _currentDesign = TimerDesign.values[savedDesignIndex];
        }
      }
    }

    final langCode = await _storageService.getLanguage();
    if (langCode != null) {
      _locale = Locale(langCode);
    }

    notifyListeners();

    // 2. 🔥 После загрузки UI — проверяем реальный статус в фоне
    _verifyPremiumStatus();
  }

  Future<void> reload() async {
    await _loadSettings();
  }

  // --- ЛОГИКА ПОДПИСОК И ВАЛИДАЦИИ ---

  /// Проверяем статус в RevenueCat и обновляем кэш
  Future<void> _verifyPremiumStatus() async {
    try {
      // 1. Спрашиваем сервис (это сетевой запрос)
      final bool actualStatus = await SubscriptionService.checkPremium();

      // 2. Если статус изменился (купили / отменили / истек)
      if (actualStatus != _isPremium) {
        debugPrint("💎 SettingsProvider: Premium status changed: $_isPremium -> $actualStatus");

        _isPremium = actualStatus;
        await _box.put(_keyPremium, _isPremium); // Обновляем кэш

        // 3. Graceful degrade: Если премиум кончился, а стоит платный дизайн -> сброс на классику
        if (!_isPremium && _currentDesign.isPremium) {
          debugPrint("⚠️ SettingsProvider: Premium lost, resetting design to Classic");
          _currentDesign = TimerDesign.classic;
          await _box.put(_keyDesign, TimerDesign.classic.index);
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ SettingsProvider: Error verifying premium: $e");
    }
  }

  /// Публичный метод для ручного обновления (вызываем после покупки в Paywall или Restore)
  Future<void> refreshPremium() async {
    await _verifyPremiumStatus();
  }

  // --- ЛОКАЛИЗАЦИЯ И НАСТРОЙКИ ---

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _storageService.saveLanguage(locale.languageCode);

    if (_dailyLogEnabled) {
      await toggleDailyLogReminder(true);
    }

    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    _notificationsEnabled = value;
    await _storageService.saveNotificationsEnabled(value);

    if (!value && _dailyLogEnabled) {
      await _notificationService.cancelAll();
    } else if (value && _dailyLogEnabled) {
      await toggleDailyLogReminder(true);
    }

    notifyListeners();
  }

  Future<void> setBiometrics(bool value) async {
    _biometricsEnabled = value;
    await _storageService.saveBiometricsEnabled(value);
    notifyListeners();
  }

  Future<void> setTTCMode(bool value) async {
    // Здесь мы просто сохраняем значение.
    // Проверка на Премиум происходит в UI (ProfileScreen) перед вызовом этого метода.
    if (_isTTCMode == value) return;
    _isTTCMode = value;
    await _storageService.saveTTCMode(value);
    notifyListeners();
  }

  // --- ЛОГИКА ДИЗАЙНОВ ---

  /// Попытка установить дизайн. Возвращает true, если успешно, false - если нужен премиум.
  Future<bool> setDesign(TimerDesign design) async {
    // 1. Если дизайн бесплатный - ставим сразу
    if (!design.isPremium) {
      _currentDesign = design;
      await _box.put(_keyDesign, design.index);
      notifyListeners();
      return true;
    }

    // 2. Если платный - проверяем подписку
    // Можно дополнительно дернуть refreshPremium(), но это замедлит UI,
    // поэтому верим текущему _isPremium
    if (design.isPremium && _isPremium) {
      _currentDesign = design;
      await _box.put(_keyDesign, design.index);
      notifyListeners();
      return true;
    }

    // 3. Если платный и НЕТ подписки - отказываем (UI должен показать Paywall)
    debugPrint("🔒 Design locked. Show Paywall.");
    return false;
  }

  /// Ручная установка статуса (для тестов или отладки)
  Future<void> setPremiumStatus(bool status) async {
    _isPremium = status;
    await _box.put(_keyPremium, status);

    if (!status && _currentDesign.isPremium) {
      _currentDesign = TimerDesign.classic;
      await _box.put(_keyDesign, TimerDesign.classic.index);
    }

    notifyListeners();
  }

  // --- ЛОГИКА ВЕЧЕРНЕГО ЧЕК-ИНА ---

  Future<void> toggleDailyLogReminder(bool value) async {
    _dailyLogEnabled = value;
    await _box.put(_keyDailyLog, value);

    if (value && _notificationsEnabled) {
      final isRu = _locale.languageCode == 'ru';

      await _notificationService.scheduleDailyNotification(
        id: 888,
        title: isRu ? "Как прошел день? 📝" : "Daily Check-in 📝",
        body: isRu ? "Отметь симптомы для точного прогноза" : "How are you feeling today? Log your symptoms.",
        time: const TimeOfDay(hour: 20, minute: 0),
      );
    } else {
      await _notificationService.cancelNotification(888);
    }

    notifyListeners();
  }

  void toggleLocale() {
    if (_locale.languageCode == 'en') {
      setLocale(const Locale('ru'));
    } else {
      setLocale(const Locale('en'));
    }
  }
}