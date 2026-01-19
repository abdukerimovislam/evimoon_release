import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  // TODO: Insert your keys from RevenueCat Dashboard here
  static const _apiKeyApple = 'appl_dOYuGbsNjTMsUkdPujsfNRbpLWK';
  static const _apiKeyGoogle = 'goog_...';

  static const String entitlementID = 'EviMoon Pro';

  static Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_apiKeyGoogle);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_apiKeyApple);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
    }
  }

  /// Check current status
  static Future<bool> checkPremium() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementID]?.isActive ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Get available packages
  static Future<List<Package>> getOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
    } on PlatformException catch (_) {}
    return [];
  }

  /// Purchase a package (Fixed for SDK v9+)
  static Future<bool> purchasePackage(Package package) async {
    try {
      // In v9.10.6, this returns a PurchaseResult object
      final purchaseResult = await Purchases.purchasePackage(package);

      // We explicitly extract the customerInfo property.
      // Using 'dynamic' ensures we bypass the strict type check if the IDE/Compiler
      // is confused about the exact version, but in v9+ .customerInfo exists on the result.
      final CustomerInfo info = (purchaseResult as dynamic).customerInfo;

      return info.entitlements.all[entitlementID]?.isActive ?? false;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        print("Purchase Error: $e");
      }
      return false;
    } catch (e) {
      print("General Error: $e");
      return false;
    }
  }

  /// Restore purchases
  static Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[entitlementID]?.isActive ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }
}