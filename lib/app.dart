import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/analytics/analytics_service.dart';
import 'core/deep_links/deep_link_service.dart';
import 'core/l10n/locale_controller.dart';
import 'core/supabase/supabase_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/paywall/presentation/paywall_controller.dart';
import 'l10n/gen/app_localizations.dart';
import 'routing/app_router.dart';
import 'shared/widgets/offline_banner.dart';

class TrendyLookApp extends ConsumerStatefulWidget {
  const TrendyLookApp({super.key});

  @override
  ConsumerState<TrendyLookApp> createState() => _TrendyLookAppState();
}

class _TrendyLookAppState extends ConsumerState<TrendyLookApp> {
  DeepLinkService? _deepLinks;
  // app_user_id, на который сейчас залогинен RC SDK — null значит SDK ещё
  // не сконфигурирован или разлогинен. Отслеживаем явно, а не одноразовым
  // флагом, чтобы logout -> login другим аккаунтом переключал RC-сессию
  // (иначе новый пользователь наследует entitlement предыдущего).
  String? _rcUserId;
  String? _analyticsUserId;
  bool _analyticsReady = false;

  @override
  void initState() {
    super.initState();
    _bootstrapAnalytics();
  }

  Future<void> _bootstrapAnalytics() async {
    await ref.read(analyticsServiceProvider).init();
    if (!mounted) return;
    _analyticsReady = true;
    _syncAnalyticsIdentity();
  }

  @override
  void dispose() {
    _deepLinks?.dispose();
    super.dispose();
  }

  void _syncPurchasesSession() {
    final user = ref.read(currentUserProvider);
    final repo = ref.read(purchasesRepositoryProvider);
    if (user == null) {
      if (_rcUserId != null) {
        _rcUserId = null;
        repo.logOut();
      }
      return;
    }
    if (_rcUserId == user.id) return;
    _rcUserId = user.id;
    // PAY-02: app_user_id в RevenueCat = Supabase user.id, чтобы revenuecat-webhook
    // мог сматчить событие с profiles.id (см. supabase/functions/revenuecat-webhook).
    repo.logIn(user.id);
  }

  void _syncAnalyticsIdentity() {
    if (!_analyticsReady) return;
    final user = ref.read(currentUserProvider);
    final analytics = ref.read(analyticsServiceProvider);
    if (user == null) {
      if (_analyticsUserId != null) {
        _analyticsUserId = null;
        analytics.track('logout');
        analytics.reset();
      }
      return;
    }
    if (_analyticsUserId == user.id) return;
    _analyticsUserId = user.id;
    final email = user.email;
    analytics.identify(
      user.id,
      properties: {
        if (email != null && email.isNotEmpty) 'email': email,
        if (user.appMetadata['provider'] != null)
          'auth_provider': '${user.appMetadata['provider']}',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    _deepLinks ??= DeepLinkService(router)..init();

    ref.listen(currentUserProvider, (previous, next) {
      _syncPurchasesSession();
      _syncAnalyticsIdentity();
    });
    _syncPurchasesSession();
    _syncAnalyticsIdentity();

    final explicitLocale = ref.watch(localeControllerProvider).valueOrNull;
    final languageCode = ref.watch(currentLanguageCodeProvider);
    final theme = AppTheme.darkForLanguage(languageCode);

    return MaterialApp.router(
      title: 'Trendy Look',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      // 4.3 Профиль: язык выбирается вручную и переживает системную локаль.
      // Пока не выбран явно (null) — резолвим из системной локали с фолбэком
      // на английский (а не первый по алфавиту supportedLocale).
      locale: explicitLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        final match = supportedLocales
            .firstWhereOrNull((l) => l.languageCode == deviceLocale?.languageCode);
        return match ?? const Locale('en');
      },
      builder: (context, child) {
        final body = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
        return DefaultTextStyle(
          style: body,
          child: OfflineBanner(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
