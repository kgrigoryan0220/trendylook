import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../shared/providers/billing_provider.dart';
import '../data/purchases_repository.dart';

/// Оффер не настроен на стороне RevenueCat — секреты добавляются позже
/// (см. PurchasesRepository). UI остаётся честным вместо фейкового успеха.
class PurchasesNotConfiguredException implements Exception {
  const PurchasesNotConfiguredException();
}

final purchasesRepositoryProvider = Provider<PurchasesRepository>((ref) {
  return PurchasesRepository();
});

class PlanOffer {
  const PlanOffer({
    required this.planId,
    required this.priceText,
    required this.hasPackage,
    this.fallbackPriceLabel,
    this.package,
  });

  final String planId; // 'weekly' | 'halfyear'
  final String priceText;
  final bool hasPackage;

  /// Локальная (₽) цена, показываемая рядом с периодом, пока оффер
  /// RevenueCat не настроен — заголовок/период локализуются в UI-слое
  /// (title/subtitle строит виджет через AppLocalizations, у контроллера
  /// нет BuildContext).
  final String? fallbackPriceLabel;
  final Package? package;
}

class PaywallData {
  const PaywallData({required this.weekly, required this.halfyear});

  final PlanOffer weekly;
  final PlanOffer halfyear;
}

final selectedPlanProvider = StateProvider<String>((ref) => 'halfyear');

class PaywallController extends AsyncNotifier<PaywallData> {
  @override
  Future<PaywallData> build() async {
    final repo = ref.read(purchasesRepositoryProvider);
    Offerings? offerings;
    try {
      offerings = await repo.fetchOfferings();
    } catch (_) {
      offerings = null;
    }

    final weeklyPkg = offerings != null ? repo.weeklyPackage(offerings) : null;
    final halfyearPkg = offerings != null ? repo.halfyearPackage(offerings) : null;

    return PaywallData(
      weekly: PlanOffer(
        planId: 'weekly',
        priceText: weeklyPkg?.storeProduct.priceString ?? '\$4.99',
        hasPackage: weeklyPkg != null,
        fallbackPriceLabel: '399₽',
        package: weeklyPkg,
      ),
      halfyear: PlanOffer(
        planId: 'halfyear',
        priceText: halfyearPkg?.storeProduct.priceString ?? '\$29.99',
        hasPackage: halfyearPkg != null,
        fallbackPriceLabel: '1990₽',
        package: halfyearPkg,
      ),
    );
  }

  /// PAY-02/03: покупка выбранного плана. Entitlement на сервере
  /// обновляется асинхронно через revenuecat-webhook (PAY-04) — здесь только
  /// подтверждение SDK + обновление локального billing-статуса.
  Future<void> purchase() async {
    final data = state.valueOrNull;
    if (data == null) return;
    final planId = ref.read(selectedPlanProvider);
    final plan = planId == 'weekly' ? data.weekly : data.halfyear;
    if (plan.package == null) {
      throw const PurchasesNotConfiguredException();
    }
    final repo = ref.read(purchasesRepositoryProvider);
    await repo.purchasePackage(plan.package!);
    ref.read(analyticsServiceProvider).track('subscription_purchased', {
      'plan': plan.planId,
      'price': plan.priceText,
    });
    await ref.read(billingControllerProvider.notifier).refresh();
  }

  Future<void> restore() async {
    final repo = ref.read(purchasesRepositoryProvider);
    if (!repo.isConfigured) {
      throw const PurchasesNotConfiguredException();
    }
    await repo.restorePurchases();
    await ref.read(billingControllerProvider.notifier).refresh();
  }
}

final paywallControllerProvider =
    AsyncNotifierProvider<PaywallController, PaywallData>(PaywallController.new);
