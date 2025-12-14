import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // ✅ Обязательно для типа Box
import '../services/secure_storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  // ✅ Добавляем переменную для Hive Box
  final Box _box;
  final SecureStorageService _storageService;

  static const String _keyOnboarding = 'has_seen_onboarding';

  // Геттер для доступа к стореджу из UI
  SecureStorageService get storageService => _storageService;

  Locale _locale = const Locale('en');
  bool _notificationsEnabled = false;
  bool _biometricsEnabled = false;

  Locale get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get biometricsEnabled => _biometricsEnabled;

  // ✅ Обновленный конструктор: принимает И Box, И StorageService
  SettingsProvider(this._box, this._storageService) {
    _loadSettings();
  }

  // --- ЛОГИКА ОНБОРДИНГА (Через Hive) ---

  bool get hasSeenOnboarding {
    // Теперь _box существует, ошибок не будет
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

  // --- ОСТАЛЬНЫЕ НАСТРОЙКИ (Через SecureStorage) ---

  Future<void> _loadSettings() async {
    // Загрузка языка
    final langCode = await _storageService.getLanguage();
    if (langCode != null) {
      _locale = Locale(langCode);
    }

    // Загрузка настроек уведомлений
    _notificationsEnabled = await _storageService.getNotificationsEnabled();

    // Загрузка биометрии
    _biometricsEnabled = await _storageService.getBiometricsEnabled();

    notifyListeners();
  }

  Future<void> reload() async {
    await _loadSettings();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _storageService.saveLanguage(locale.languageCode);
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    _notificationsEnabled = value;
    await _storageService.saveNotificationsEnabled(value);
    notifyListeners();
  }

  Future<void> setBiometrics(bool value) async {
    _biometricsEnabled = value;
    await _storageService.saveBiometricsEnabled(value);
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