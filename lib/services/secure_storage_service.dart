import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Для полной очистки кэша

class SecureStorageService {
  // Настройки безопасности хранилища (Keystore/Keychain)
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Ключи
  static const _keyNotifications = 'notifications_enabled';
  static const _keyBiometrics = 'biometrics_enabled';
  static const _keyLanguage = 'language_code';

  // --- 1. СИСТЕМНЫЕ НАСТРОЙКИ (Нужны для SettingsProvider) ---

  // Уведомления
  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _storage.write(key: _keyNotifications, value: enabled.toString());
  }

  Future<bool> getNotificationsEnabled() async {
    final val = await _storage.read(key: _keyNotifications);
    // По умолчанию false, если не сохранено
    return val == 'true';
  }

  // Биометрия (Критично хранить в SecureStorage)
  Future<void> saveBiometricsEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometrics, value: enabled.toString());
  }

  Future<bool> getBiometricsEnabled() async {
    final val = await _storage.read(key: _keyBiometrics);
    return val == 'true';
  }

  // Язык
  Future<void> saveLanguage(String code) async {
    await _storage.write(key: _keyLanguage, value: code);
  }

  Future<String?> getLanguage() async {
    return await _storage.read(key: _keyLanguage);
  }

  // --- 2. УПРАВЛЕНИЕ АККАУНТОМ ---

  /// Полная очистка данных (Сброс / Удаление аккаунта)
  Future<void> clearAll() async {
    try {
      // 1. Удаляем ключи шифрования и настройки
      await _storage.deleteAll();

      // 2. Чистим SharedPreferences (если что-то осталось от старых версий)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Примечание: Hive чистится в ProfileScreen через Hive.deleteFromDisk(),
      // здесь мы чистим только секретную часть.
    } catch (e) {
      // Игнорируем ошибки при очистке
    }
  }

  // Инициализация (сейчас пустая, но может пригодиться для миграций)
  Future<void> init() async {
    // Здесь можно добавить логику проверки первого запуска, если нужно
  }
}