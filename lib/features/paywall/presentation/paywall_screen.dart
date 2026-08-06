import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/plan_card.dart';
import '../../../shared/widgets/primary_button.dart';
import 'paywall_controller.dart';

String _planTitle(AppLocalizations l10n, PlanOffer plan) =>
    plan.planId == 'weekly' ? l10n.paywallPlanWeekly : l10n.paywallPlanHalfyear;

String _planSubtitle(AppLocalizations l10n, PlanOffer plan) {
  final period = plan.planId == 'weekly' ? l10n.paywallPeriodWeek : l10n.paywallPeriodHalfyear;
  return plan.hasPackage ? period : '${plan.fallbackPriceLabel} / $period';
}

/// 4.9 Paywall — PAY-01/02/06.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _purchasing = false;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).track('paywall_shown', {'trigger': 'limit_reached'});
    });
  }

  Future<void> _continue() async {
    setState(() => _purchasing = true);
    try {
      await ref.read(paywallControllerProvider.notifier).purchase();
      if (!mounted) return;
      setState(() {
        _purchasing = false;
        _success = true;
      });
    } on PurchasesNotConfiguredException {
      if (!mounted) return;
      setState(() => _purchasing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).paywallNotConfigured)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _purchasing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).paywallPurchaseError(e.toString()))),
      );
    }
  }

  Future<void> _restore() async {
    try {
      await ref.read(paywallControllerProvider.notifier).restore();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).paywallRestoreSuccess)),
      );
    } on PurchasesNotConfiguredException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).paywallNotConfigured)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).paywallRestoreError(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final offerAsync = ref.watch(paywallControllerProvider);
    final selectedPlan = ref.watch(selectedPlanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1),
            radius: 0.9,
            colors: [Color(0x387B5CFF), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (_success)
                _SuccessView(onDone: () => context.go('/home'))
              else
                offerAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(l10n.paywallOfferError(e.toString()))),
                  data: (offer) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
                    child: Column(
                      children: [
                        Text(
                          l10n.paywallTitle,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 26),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.paywallSubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PlanCard(
                              title: _planTitle(l10n, offer.weekly),
                              price: offer.weekly.priceText,
                              subtitle: _planSubtitle(l10n, offer.weekly),
                              selected: selectedPlan == 'weekly',
                              onTap: () =>
                                  ref.read(selectedPlanProvider.notifier).state = 'weekly',
                            ),
                            const SizedBox(width: 12),
                            PlanCard(
                              title: _planTitle(l10n, offer.halfyear),
                              price: offer.halfyear.priceText,
                              subtitle: _planSubtitle(l10n, offer.halfyear),
                              selected: selectedPlan == 'halfyear',
                              badgeText: l10n.paywallBestValue,
                              onTap: () =>
                                  ref.read(selectedPlanProvider.notifier).state = 'halfyear',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const _BenefitsList(),
                        const SizedBox(height: 20),
                        Text(
                          l10n.paywallSocialProof,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: l10n.paywallContinue,
                          isLoading: _purchasing,
                          onPressed: _purchasing ? null : _continue,
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: _restore,
                          child: Text(
                            l10n.paywallRestore,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.termsOfService} · ${l10n.privacyPolicy}',
                          style: const TextStyle(color: Color(0xFF5C5C68), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              // Крестик — последним в Stack, чтобы быть поверх скролл-контента
              // и реально ловить тапы (иначе SingleChildScrollView перехватывает их).
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitsList extends StatelessWidget {
  const _BenefitsList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [l10n.paywallBenefit1, l10n.paywallBenefit2, l10n.paywallBenefit3];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (text) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.check, color: AppColors.lime, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5))),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.paywallSuccessTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: l10n.paywallSuccessCta, onPressed: onDone),
          ],
        ),
      ),
    );
  }
}
