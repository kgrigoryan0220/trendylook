import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import 'promo_exceptions.dart';

/// Ответ redeem-promo (PROMO_CODES_PLAN.md, разд. 6.1).
class PromoRedeemResult {
  const PromoRedeemResult({required this.expiresAt, required this.extended});

  final DateTime expiresAt;

  /// true, если на момент активации уже был активен Pro и срок продлился
  /// (а не выдался с нуля) — max(current_expires, now + duration_days).
  final bool extended;
}

class PromoRepository {
  PromoRepository(this._client);

  final SupabaseClient _client;

  Future<PromoRedeemResult> redeem(String code) async {
    try {
      final response = await _client.functions.invoke(
        'redeem-promo',
        body: {'code': code},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      return PromoRedeemResult(
        expiresAt: DateTime.parse(data['expires_at'] as String),
        extended: data['extended'] as bool? ?? false,
      );
    } on FunctionException catch (e) {
      final details = e.details;
      final errorCode = details is Map ? details['error'] as String? : null;
      switch (errorCode) {
        case 'code_not_found':
          throw const PromoCodeNotFoundException();
        case 'code_expired':
          throw const PromoCodeExpiredException();
        case 'code_exhausted':
          throw const PromoCodeExhaustedException();
        case 'already_redeemed':
          throw const PromoCodeAlreadyRedeemedException();
        default:
          throw const PromoRedeemFailedException();
      }
    }
  }
}

final promoRepositoryProvider = Provider<PromoRepository>((ref) {
  return PromoRepository(ref.watch(supabaseClientProvider));
});
