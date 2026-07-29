import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/analytics/analytics_service.dart';
import 'core/deep_links/deep_link_service.dart';
import 'core/supabase/supabase_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/paywall/presentation/paywall_controller.dart';
import 'routing/app_router.dart';
import 'shared/widgets/offline_banner.dart';

class TrendyLookApp extends ConsumerStatefulWidget {
  const TrendyLookApp({super.key});

  @override
  ConsumerState<TrendyLookApp> createState() => _TrendyLookAppState();
}

class _TrendyLookAppState extends ConsumerState<TrendyLookApp> {
  DeepLinkService? _deepLinks;
  bool _purchasesInitialized = false;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsServiceProvider).init();
  }

  @override
  void dispose() {
    _deepLinks?.dispose();
    super.dispose();
  }

  void _bootstrapForUser() {
    if (_purchasesInitialized) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    _purchasesInitialized = true;
    // PAY-02: app_user_id в RevenueCat = Supabase user.id, чтобы revenuecat-webhook
    // мог сматчить событие с profiles.id (см. supabase/functions/revenuecat-webhook).
    ref.read(purchasesRepositoryProvider).init(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    _deepLinks ??= DeepLinkService(router)..init();

    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) _bootstrapForUser();
    });
    _bootstrapForUser();

    return MaterialApp.router(
      title: 'Trendy Look',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (context, child) => OfflineBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
