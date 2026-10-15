import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/config/app_config.dart';

/// PAY-02/06 (TECH_SPEC_v1.2.md 5.5, 6.2) — RevenueCat (purchases_flutter).
///
/// Остаётся выключенным (`isConfigured == false`), пока не заданы
/// REVENUECAT_API_KEY_IOS/ANDROID через --dart-define. Сам пейвол, выбор
/// пакета, покупку и restore рендерит RevenueCat (PaywallView), здесь —
/// только жизненный цикл SDK и привязка app_user_id к Supabase user.id.
class PurchasesRepository {
  bool _configured = false;
  bool get isConfigured => _configured;
  String? _uiLocale;

  Future<void> init(String appUserId) async {
    final apiKey = Platform.isIOS
        ? AppConfig.revenueCatApiKeyIos
        : AppConfig.revenueCatApiKeyAndroid;
    if (apiKey.isEmpty) return;

    final locale = _uiLocale;
    await Purchases.configure(
      PurchasesConfiguration(apiKey)
        ..appUserID = appUserId
        ..preferredUILocaleOverride = locale,
    );
    _configured = true;
    // Язык успели сменить, пока шёл configure.
    if (_uiLocale != locale) await Purchases.overridePreferredUILocale(_uiLocale);
  }

  /// Пейвол рендерит нативный RC SDK, а он по умолчанию берёт язык
  /// устройства — передаём язык, выбранный в приложении (Профиль → Язык).
  Future<void> setUiLocale(String languageCode) async {
    if (_uiLocale == languageCode) return;
    _uiLocale = languageCode;
    if (!_configured) return;
    await Purchases.overridePreferredUILocale(languageCode);
  }

  /// Вызывается при входе, включая смену аккаунта после logOut — SDK уже
  /// сконфигурирован (init() отработал при первом входе), поэтому здесь
  /// только переключаем RC app_user_id, а не конфигурируем заново.
  Future<void> logIn(String appUserId) async {
    if (!_configured) {
      await init(appUserId);
      return;
    }
    await Purchases.logIn(appUserId);
  }

  /// Отвязывает текущего пользователя от RC app_user_id при выходе, чтобы
  /// следующий login (другим аккаунтом) не унаследовал чужой entitlement.
  Future<void> logOut() async {
    if (!_configured) return;
    await Purchases.logOut();
  }

  /// Синхронизирует локальный кэш RC с сервером — используется после
  /// успешного redeem промокода (grant применяется на стороне RC мгновенно,
  /// но SDK о нём узнаёт только через sync/restore).
  Future<void> syncPurchases() async {
    if (!_configured) return;
    await Purchases.syncPurchases();
  }
}

final purchasesRepositoryProvider = Provider<PurchasesRepository>((ref) {
  return PurchasesRepository();
});
