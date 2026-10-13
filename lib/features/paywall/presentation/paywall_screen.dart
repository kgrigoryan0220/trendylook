import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/providers/billing_provider.dart';
import '../data/purchases_repository.dart';

/// 4.9 Paywall — PAY-01/02/06. Вёрстку, тексты, локализацию, выбор пакета,
/// покупку и restore рендерит RevenueCat (пейвол, привязанный к current
/// Offering в RC Dashboard). Entitlement на сервере выставляет
/// revenuecat-webhook — здесь только аналитика и ожидание billing-status.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.trigger = 'unknown'});

  /// Источник открытия: limit_reached | profile | grace | result | check_limit | deeplink …
  final String trigger;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _converted = false;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _track('paywall_shown');
    });
  }

  void _track(String event, [Map<String, Object> extra = const {}]) {
    ref.read(analyticsServiceProvider).track(event, {'trigger': widget.trigger, ...extra});
  }

  void _markClosed() {
    if (_closed) return;
    _closed = true;
    if (!_converted) _track('paywall_dismissed');
  }

  void _close() {
    if (_closed) return;
    _markClosed();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _onPurchaseCompleted(CustomerInfo customerInfo, StoreTransaction transaction) {
    _converted = true;
    _track('subscription_purchased', {'product_id': transaction.productIdentifier});
    unawaited(ref.read(billingControllerProvider.notifier).refreshUntilPro());
    // PaywallView сам вызывает onDismiss после успешной покупки.
  }

  void _onRestoreCompleted(CustomerInfo customerInfo) {
    _track('purchases_restored');
    if (customerInfo.entitlements.active.isEmpty) return;
    _converted = true;
    unawaited(ref.read(billingControllerProvider.notifier).refreshUntilPro());
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final configured = ref.watch(purchasesRepositoryProvider).isConfigured;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _markClosed();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: configured
            ? PaywallView(
                onPurchaseCompleted: _onPurchaseCompleted,
                onPurchaseCancelled: () =>
                    _track('subscription_purchase_failed', {'error': 'cancelled'}),
                onPurchaseError: (error) =>
                    _track('subscription_purchase_failed', {'error': error.code.name}),
                onRestoreCompleted: _onRestoreCompleted,
                onRestoreError: (error) =>
                    _track('purchases_restore_failed', {'error': error.code.name}),
                onDismiss: _close,
              )
            : _NotConfiguredView(onClose: _close),
      ),
    );
  }
}

/// RevenueCat SDK не сконфигурирован (нет REVENUECAT_API_KEY_* в
/// --dart-define) — честно сообщаем, а не показываем пустой экран.
class _NotConfiguredView extends StatelessWidget {
  const _NotConfiguredView({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                AppLocalizations.of(context).paywallNotConfigured,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
