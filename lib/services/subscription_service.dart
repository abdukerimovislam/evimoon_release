import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  // Ключи оставлены как вы просили
  static const _apiKeyApple = 'appl_dOYuGbsNjTMsUkdPujsfNRbpLWK';
  // static const _apiKeyGoogle = 'goog_...'; // Раскомментируйте и добавьте, когда будет нужно

  static const String entitlementID = 'EviMoon Pro';

  // 🔥 Стрим для прослушивания статуса подписки в реальном времени
  static final StreamController<bool> _premiumController = StreamController<bool>.broadcast();
  static Stream<bool> get premiumStatusStream => _premiumController.stream;

  static Future<void> init() async {
    // Не инициализируем на неподдерживаемых платформах (например, Web)
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) return;

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;

    if (Platform.isAndroid) {
      // configuration = PurchasesConfiguration(_apiKeyGoogle); // TODO: Включить для Android
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_apiKeyApple);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);

      // Слушаем изменения статуса в реальном времени (даже если покупка вне приложения)
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _updateStream(customerInfo);
      });

      // Первичная проверка при запуске
      await checkPremium();
    }
  }

  /// Проверить текущий статус (и обновить стрим)
  static Future<bool> checkPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _updateStream(customerInfo);
    } on PlatformException catch (e) {
      debugPrint("Check Premium Error: ${e.message}");
      return false;
    }
  }

  /// Получить доступные тарифы (Paywall)
  static Future<List<Package>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
    } on PlatformException catch (e) {
      debugPrint("Get Offerings Error: ${e.message}");
    }
    return [];
  }

  /// Купить пакет
  static Future<bool> purchasePackage(Package package) async {
    try {
      // Покупка для SDK v9+
      final purchaseResult = await Purchases.purchasePackage(package);

      // Здесь мы получаем CustomerInfo напрямую из результата
      // Если у вас старая версия SDK и нужен dynamic, можно раскомментировать старый вариант,
      // но для актуальных версий v9+ это стандартный способ:
      final CustomerInfo info = purchaseResult.customerInfo;

      return _updateStream(info);
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        debugPrint("Purchase Failed: $errorCode - ${e.message}");
      } else {
        debugPrint("User cancelled purchase");
      }
      return false;
    } catch (e) {
      debugPrint("General Purchase Error: $e");
      return false;
    }
  }

  /// Восстановить покупки
  static Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      debugPrint("Restore success. Active: ${_checkEntitlement(customerInfo)}");
      return _updateStream(customerInfo);
    } on PlatformException catch (e) {
      debugPrint("Restore Error: ${e.message}");
      return false;
    }
  }

  // --- Helpers ---

  /// Проверяет наличие активного Entitlement
  static bool _checkEntitlement(CustomerInfo customerInfo) {
    return customerInfo.entitlements.all[entitlementID]?.isActive ?? false;
  }

  /// Обновляет Stream и возвращает статус
  static bool _updateStream(CustomerInfo customerInfo) {
    final isPro = _checkEntitlement(customerInfo);
    _premiumController.add(isPro); // Уведомляем всё приложение
    return isPro;
  }
}