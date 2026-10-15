import 'package:flutter/foundation.dart';

/// Runtime configuration, supplied via --dart-define at build time.
///
/// Supabase URL/publishable key are safe to embed in a client (that's their
/// purpose); RevenueCat public SDK keys and the deep link scheme are not
/// secrets either. Nothing that must stay server-side (OpenAI key, Supabase
/// service role key, RevenueCat webhook secret) lives here.
class AppConfig {
  const AppConfig._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jilreygcmqhemhsmetqd.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'sb_publishable_DTRYYWiYPqmGqVfxx5BUNw_8sWJKODy',
  );

  /// RevenueCat Test Store (ненастоящие покупки) — дефолт только для
  /// debug/profile, чтобы `flutter run` работал на любой машине без флагов.
  /// В release дефолт пустой: туда обязательно передаются боевые appl_/goog_
  /// ключи (STORE_RELEASE_CHECKLIST.md), и test_ не может уйти в стор
  /// по забывчивости. Без ключа покупки выключены (PurchasesRepository).
  static const _revenueCatTestStoreKey = 'test_PJmXvoWtvhYeItWncmUqUGYhrxT';

  static const revenueCatApiKeyIos = String.fromEnvironment(
    'REVENUECAT_API_KEY_IOS',
    defaultValue: kReleaseMode ? '' : _revenueCatTestStoreKey,
  );
  static const revenueCatApiKeyAndroid = String.fromEnvironment(
    'REVENUECAT_API_KEY_ANDROID',
    defaultValue: kReleaseMode ? '' : _revenueCatTestStoreKey,
  );

  /// OAuth client ID из Google Cloud Console (Web application type) — нужен
  /// google_sign_in для получения idToken. Публичный, поэтому дефолт.
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '296414004775-pdog1isingjoa3f2spfnia6cekg9dhok.apps.googleusercontent.com',
  );

  static const postHogApiKey = String.fromEnvironment('POSTHOG_API_KEY');
  /// EU Cloud project — override via `--dart-define=POSTHOG_HOST=...` if needed.
  static const postHogHost = String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://eu.i.posthog.com',
  );

  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static const deepLinkScheme = 'trendylook';
}
