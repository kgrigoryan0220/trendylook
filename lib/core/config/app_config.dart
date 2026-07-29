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

  /// RevenueCat public SDK keys — empty until the user provisions a
  /// RevenueCat project. Purchases stay disabled (see PurchasesRepository)
  /// until these are supplied via --dart-define.
  static const revenueCatApiKeyIos =
      String.fromEnvironment('REVENUECAT_API_KEY_IOS');
  static const revenueCatApiKeyAndroid =
      String.fromEnvironment('REVENUECAT_API_KEY_ANDROID');

  /// OAuth client ID из Google Cloud Console (Web application type) — нужен
  /// google_sign_in для получения idToken на Android. Пусто до настройки.
  static const googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  static const postHogApiKey = String.fromEnvironment('POSTHOG_API_KEY');
  static const postHogHost = String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://app.posthog.com',
  );

  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static const deepLinkScheme = 'trendylook';
}
