import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart'; // Для debugPrint

class AuthService {
  // Singleton pattern (один экземпляр на все приложение)
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Проверка: поддерживает ли устройство биометрию?
  /// (Есть ли сканер и настроен ли он)
  Future<bool> get canCheckBiometrics async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics || isDeviceSupported;
    } on PlatformException catch (e) {
      debugPrint("Auth Error: $e");
      return false;
    }
  }

  /// Получить список доступных методов (FaceID, TouchID, Pin)
  /// Полезно для отладки или UI (показать иконку лица или пальца)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint("List Auth Error: $e");
      return <BiometricType>[];
    }
  }

  /// Запрос аутентификации
  /// [reason] - текст, который увидит пользователь (нужен для локализации)
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true, // Держать окно активным, если приложение свернули
          biometricOnly: false, // Разрешить ПИН-код телефона, если биометрия не сработала
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint("Authentication Error: $e");
      return false;
    }
  }

  /// Метод для отмены аутентификации (если нужно программно закрыть окно)
  Future<void> stopAuthentication() async {
    await _auth.stopAuthentication();
  }
}