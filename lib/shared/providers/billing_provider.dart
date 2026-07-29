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
}

final billingControllerProvider =
    AsyncNotifierProvider<BillingController, BillingStatus>(
  BillingController.new,
);
