/// Типизированные ошибки redeem-promo (PROMO_CODES_PLAN.md, разд. 6.1).
class PromoCodeNotFoundException implements Exception {
  const PromoCodeNotFoundException();
}

class PromoCodeExpiredException implements Exception {
  const PromoCodeExpiredException();
}

class PromoCodeExhaustedException implements Exception {
  const PromoCodeExhaustedException();
}

class PromoCodeAlreadyRedeemedException implements Exception {
  const PromoCodeAlreadyRedeemedException();
}

class PromoRedeemFailedException implements Exception {
  const PromoRedeemFailedException();
}
