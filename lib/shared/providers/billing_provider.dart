import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase/supabase_providers.dart';
import '../../features/paywall/data/billing_repository.dart';

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  return BillingRepository(ref.watch(supabaseClientProvider));
});

/// Единый источник правды об entitlement (PAY-03) — используется Home,
/// Профилем и Paywall. `refresh()` вызывается после успешной проверки
/// (списание free check) и после "покупки" на Paywall.
class BillingController extends AsyncNotifier<BillingStatus> {
  @override
  Future<BillingStatus> build() {
    return ref.read(billingRepositoryProvider).fetchStatus();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(billingRepositoryProvider).fetchStatus(),
    );
  }

  /// После покупки/промокода Pro появляется в subscriptions только когда
  /// дойдёт revenuecat-webhook (асинхронно, обычно секунды) — повторяем
  /// запрос, пока сервер не увидит Pro, вместо одного «слепого» refresh.
  Future<void> refreshUntilPro({
    int attempts = 6,
    Duration interval = const Duration(seconds: 2),
  }) async {
    for (var i = 0; i < attempts; i++) {
      // Без промежуточного AsyncLoading — экран не мигает лоадером на каждой попытке.
      final next = await AsyncValue.guard(
        () => ref.read(billingRepositoryProvider).fetchStatus(),
      );
      if (next.hasValue) state = next;
      if (next.valueOrNull?.isPro == true) return;
      if (i < attempts - 1) await Future<void>.delayed(interval);
    }
  }
}

final billingControllerProvider =
    AsyncNotifierProvider<BillingController, BillingStatus>(
  BillingController.new,
);
