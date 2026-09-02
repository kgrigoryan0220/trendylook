import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/paywall/data/promo_exceptions.dart';
import '../../features/paywall/data/promo_repository.dart';
import '../../features/paywall/presentation/paywall_controller.dart';
import '../../l10n/gen/app_localizations.dart';
import '../providers/billing_provider.dart';
import 'secondary_button.dart';

/// Ввод и активация промокода (PROMO_CODES_PLAN.md, разд. 7.2) — переиспользуется
/// на Paywall и в Профиле.
class PromoCodeSection extends ConsumerStatefulWidget {
  const PromoCodeSection({super.key});

  @override
  ConsumerState<PromoCodeSection> createState() => _PromoCodeSectionState();
}

class _PromoCodeSectionState extends ConsumerState<PromoCodeSection> {
  final _controller = TextEditingController();
  bool _redeeming = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _redeem() async {
    final code = _controller.text.trim();
    if (code.isEmpty || _redeeming) return;
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    setState(() => _redeeming = true);
    try {
      final result = await ref.read(promoRepositoryProvider).redeem(code);
      if (!mounted) return;
      _controller.clear();
      // Grant в RC применяется мгновенно, но SDK и subscriptions узнают о нём
      // через sync/webhook — синхронизируем явно перед обновлением статуса,
      // чтобы billing-status не увидел устаревшее состояние.
      await ref.read(purchasesRepositoryProvider).syncPurchases();
      await ref.read(billingControllerProvider.notifier).refresh();
      ref.read(analyticsServiceProvider).track('promo_redeemed', {'extended': result.extended});
      if (!mounted) return;
      final formattedDate = DateFormat('d MMM yyyy', languageCode).format(result.expiresAt);
      _showMessage(l10n.promoRedeemedUntil(formattedDate));
    } on PromoCodeNotFoundException {
      _showMessage(l10n.promoCodeNotFound);
    } on PromoCodeExpiredException {
      _showMessage(l10n.promoCodeExpired);
    } on PromoCodeExhaustedException {
      _showMessage(l10n.promoCodeExhausted);
    } on PromoCodeAlreadyRedeemedException {
      _showMessage(l10n.promoCodeAlreadyRedeemed);
    } catch (_) {
      _showMessage(l10n.promoRedeemError);
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.promoCodeSectionTitle,
          style: AppTheme.body(context, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              enabled: !_redeeming,
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => _redeem(),
              decoration: InputDecoration(
                hintText: l10n.promoCodeHint,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16), width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: AppColors.pink, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: l10n.promoCodeApply,
              isLoading: _redeeming,
              onPressed: _redeeming ? null : _redeem,
            ),
          ],
        ),
      ],
    );
  }
}
