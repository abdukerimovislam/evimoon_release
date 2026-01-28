import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/secure_storage_service.dart';
import '../services/notification_service.dart';
import '../models/timer_design.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';

class SettingsProvider extends ChangeNotifier {
  final Box _box;
  final SecureStorageService _storageService;
  final NotificationService _notificationService;

  static const String _keyOnboarding = 'has_seen_onboarding';
  static const String _keyDailyLog = 'daily_log_enabled';
  static const String _keyDesign = 'timer_design_index';
  static const String _keyPremium = 'is_premium';
  static const String _keyTheme = 'app_theme_type';

  SecureStorageService get storageService => _storageService;

  // По умолчанию английский, но _loadSettings попытается определить системный
  Locale _locale = const Locale('en');

  bool _notificationsEnabled = false;
  bool _biometricsEnabled = false;
  bool _isTTCMode = false;
  bool _dailyLogEnabled = false;

  TimerDesign _currentDesign = TimerDesign.classic;
  bool _isPremium = false;

  AppThemeType _currentTheme = AppThemeType.oceanic;

  // --- Геттеры ---
  Locale get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricsEnabled => _biometricsEnabled;
  bool get isTTCMode => _isTTCMode;
  bool get dailyLogEnabled => _dailyLogEnabled;
  TimerDesign get currentDesign => _currentDesign;
  bool get isPremium => _isPremium;
  AppThemeType get currentTheme => _currentTheme;

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
    // Проверка на чистую установку (сброс данных)
    final bool appWasReset = !_box.containsKey(_keyOnboarding);

    if (appWasReset) {
      await _storageService.clearAll();
      _isTTCMode = false;
      _notificationsEnabled = false;
      _biometricsEnabled = false;
      _dailyLogEnabled = false;
      _currentDesign = TimerDesign.classic;
      _isPremium = false;
      _currentTheme = AppThemeType.oceanic;
      // При сбросе язык тоже сбросится на авто-определение ниже
    } else {
      _notificationsEnabled = await _storageService.getNotificationsEnabled();
      _biometricsEnabled = await _storageService.getBiometricsEnabled();
      _isTTCMode = await _storageService.getTTCMode();

      _dailyLogEnabled = _box.get(_keyDailyLog, defaultValue: false);
      _isPremium = _box.get(_keyPremium, defaultValue: false);

      final savedDesignIndex = _box.get(_keyDesign);
      if (savedDesignIndex != null && savedDesignIndex is int) {
        if (savedDesignIndex >= 0 && savedDesignIndex < TimerDesign.values.length) {
          _currentDesign = TimerDesign.values[savedDesignIndex];
        }
      }

      // Загрузка темы
      final themeIndex = _box.get(_keyTheme, defaultValue: 0);
      if (themeIndex >= 0 && themeIndex < AppThemeType.values.length) {
        _currentTheme = AppThemeType.values[themeIndex];
        AppTheme.setPalette(_currentTheme);
      }
    }

    // 🔥 ЛОГИКА ОПРЕДЕЛЕНИЯ ЯЗЫКА
    final langCode = await _storageService.getLanguage();

    if (langCode != null) {
      // 1. Если пользователь уже выбирал язык (сохранено в SecureStorage)
      _locale = Locale(langCode);
    } else {
      // 2. Если это первый запуск: определяем системный язык
      try {
        final sysLocales = WidgetsBinding.instance.platformDispatcher.locales;
        if (sysLocales.isNotEmpty) {
          final sysCode = sysLocales.first.languageCode;

          if (sysCode == 'ru') {
            _locale = const Locale('ru');
          } else {
            // Для всех остальных языков ставим английский по умолчанию
            _locale = const Locale('en');
          }
        }
      } catch (e) {
        debugPrint("Locale auto-detect error: $e");
        _locale = const Locale('en');
      }
    }

    notifyListeners();
    _verifyPremiumStatus();
  }

  Future<void> reload() async {
    await _loadSettings();
  }

  // --- ЛОГИКА ТЕМ ---

  Future<void> setTheme(AppThemeType theme) async {
    if (_currentTheme == theme) return;

    _currentTheme = theme;
    AppTheme.setPalette(theme);
    await _box.put(_keyTheme, theme.index);

    notifyListeners();
  }

  // --- ЛОГИКА ПОДПИСОК ---

  Future<void> _verifyPremiumStatus() async {
    try {
      final bool actualStatus = await SubscriptionService.checkPremium();

      if (actualStatus != _isPremium) {
        debugPrint("💎 SettingsProvider: Premium status changed: $_isPremium -> $actualStatus");

        _isPremium = actualStatus;
        await _box.put(_keyPremium, _isPremium);

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

  Future<void> refreshPremium() async {
    await _verifyPremiumStatus();
  }

  // --- НАСТРОЙКИ ---

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _storageService.saveLanguage(locale.languageCode);

    if (_dailyLogEnabled) {
      await toggleDailyLogReminder(true);
    }

    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _storageService.saveNotificationsEnabled(value);

    if (!value && _dailyLogEnabled) {
      await _notificationService.cancelAll();
    } else if (value && _dailyLogEnabled) {
      await toggleDailyLogReminder(true);
    }

    notifyListeners();
  }

  Future<void> setBiometricsEnabled(bool value) async {
    _biometricsEnabled = value;
    await _storageService.saveBiometricsEnabled(value);
    notifyListeners();
  }

  Future<void> setTTCMode(bool value) async {
    if (_isTTCMode == value) return;
    _isTTCMode = value;
    await _storageService.saveTTCMode(value);
    notifyListeners();
  }

  Future<bool> setDesign(TimerDesign design) async {
    if (!design.isPremium) {
      _currentDesign = design;
      await _box.put(_keyDesign, design.index);
      notifyListeners();
      return true;
    }

    if (design.isPremium && _isPremium) {
      _currentDesign = design;
      await _box.put(_keyDesign, design.index);
      notifyListeners();
      return true;
    }

    debugPrint("🔒 Design locked. Show Paywall.");
    return false;
  }

  Future<void> setPremiumStatus(bool status) async {
    _isPremium = status;
    await _box.put(_keyPremium, status);

    if (!status && _currentDesign.isPremium) {
      _currentDesign = TimerDesign.classic;
      await _box.put(_keyDesign, TimerDesign.classic.index);
    }

    notifyListeners();
  }

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