import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Singleton pattern
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  late final FlutterSecureStorage _storage;

  SecureStorageService._internal() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        // ✅ Сброс при ошибке ключей (Android)
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

  // 🔐 Hive encryption key (base64 of 32 bytes)
  static const String _keyHiveCipher = 'hive_cipher_key_v1';

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

  // --- PUBLIC API (existing) ---

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

  // --- NEW: Hive encryption key management ---

  /// Returns a stable 32-byte key for HiveAesCipher.
  /// Stored in secure storage as base64.
  ///
  /// ⚠️ If this key changes, previously stored Hive data becomes unreadable.
  /// So: generate once, persist forever (unless you intentionally reset user data).
  Future<Uint8List> getOrCreateHiveCipherKey() async {
    try {
      final existing = await _read(_keyHiveCipher);
      if (existing != null && existing.isNotEmpty) {
        final bytes = base64Decode(existing);
        if (bytes.length == 32) {
          return Uint8List.fromList(bytes);
        } else {
          debugPrint("⚠️ Hive cipher key has invalid length: ${bytes.length}. Regenerating.");
        }
      }
    } catch (e) {
      debugPrint("❌ Failed to read Hive cipher key: $e");
    }

    // Generate new 32-byte key
    final rnd = Random.secure();
    final keyBytes = Uint8List.fromList(List<int>.generate(32, (_) => rnd.nextInt(256)));

    try {
      await _write(_keyHiveCipher, base64Encode(keyBytes));
    } catch (e) {
      debugPrint("❌ Failed to store Hive cipher key: $e");
      // If we cannot store it reliably, better to crash early than corrupt data.
      rethrow;
    }

    return keyBytes;
  }
}
