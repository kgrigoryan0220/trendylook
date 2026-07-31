import 'dart:io';

import 'package:collection/collection.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';

/// PAY-02/06 (TECH_SPEC_v1.2.md 5.5, 6.2) — RevenueCat (purchases_flutter).
///
/// Остаётся выключенным (`isConfigured == false`), пока не заданы
/// REVENUECAT_API_KEY_IOS/ANDROID через --dart-define — тогда покупки не
/// вызываются вовсе, вместо падения без ключей. Остальной код готов к работе,
/// как только ключи появятся.
class PurchasesRepository {
  bool _configured = false;
  bool get isConfigured => _configured;

  Future<void> init(String appUserId) async {
    final apiKey = Platform.isIOS
        ? AppConfig.revenueCatApiKeyIos
        : AppConfig.revenueCatApiKeyAndroid;
    if (apiKey.isEmpty) return;

    await Purchases.configure(
      PurchasesConfiguration(apiKey)..appUserID = appUserId,
    );
    _configured = true;
  }

  Future<Offerings?> fetchOfferings() async {
    if (!_configured) return null;
    return Purchases.getOfferings();
  }

  Package? weeklyPackage(Offerings offerings) {
    return offerings.current?.availablePackages
        .where((p) => p.storeProduct.identifier.contains(AppConstants.weeklyProductId))
        .firstOrNull;
  }

  Package? halfyearPackage(Offerings offerings) {
    return offerings.current?.availablePackages
        .where((p) => p.storeProduct.identifier.contains(AppConstants.halfyearProductId))
        .firstOrNull;
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  Future<CustomerInfo> restorePurchases() async {
    return Purchases.restorePurchases();
  }
}
