import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorageService {
  // Singleton pattern
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  late final FlutterSecureStorage _storage;

  SecureStorageService._internal() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        // 🔥 ВАЖНО: Сброс при ошибке ключей (Android)
        resetOnError: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }

  // --- KEYS ---
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyBiometrics = 'biometrics_enabled';
  static const String _keyLanguage = 'language_code';
  static const String _keyTTC = 'ttc_mode_enabled';

  // --- GENERIC HELPERS (С защитой от ошибок) ---

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint("❌ SecureStorage Write Error: $e");
      // Если запись не удалась, пробуем удалить и записать снова
      try {
        await _storage.delete(key: key);
        await _storage.write(key: key, value: value);
      } catch (e2) {
        debugPrint("❌ CRITICAL Storage Error: $e2");
      }
    }
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint("❌ SecureStorage Read Error: $e");
      return null;
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint("❌ SecureStorage Delete Error: $e");
    }
  }

  // --- PUBLIC API ---

  Future<void> saveNotificationsEnabled(bool enabled) async {
    await _write(_keyNotifications, enabled.toString());
  }

  Future<bool> getNotificationsEnabled() async {
    final val = await _read(_keyNotifications);
    return val == 'true';
  }

  Future<void> saveBiometricsEnabled(bool enabled) async {
    await _write(_keyBiometrics, enabled.toString());
  }

  Future<bool> getBiometricsEnabled() async {
    final val = await _read(_keyBiometrics);
    return val == 'true';
  }

  Future<void> saveLanguage(String langCode) async {
    await _write(_keyLanguage, langCode);
  }

  Future<String?> getLanguage() async {
    return await _read(_keyLanguage);
  }

  Future<void> saveTTCMode(bool enabled) async {
    await _write(_keyTTC, enabled.toString());
  }

  Future<bool> getTTCMode() async {
    final val = await _read(_keyTTC);
    return val == 'true';
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint("❌ Error clearing storage: $e");
    }
  }
}