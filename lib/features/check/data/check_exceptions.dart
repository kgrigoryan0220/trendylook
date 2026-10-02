/// Типизированные ошибки analyze-look (TECH_SPEC_v1.2.md 5.2, 5.5, 6.5).
class PaywallException implements Exception {
  const PaywallException();
}

class RateLimitedException implements Exception {
  const RateLimitedException();
}

class AnalysisFailedException implements Exception {
  const AnalysisFailedException(this.message);
  final String message;
}

/// Soft-delete did not update any row (RLS / already deleted / wrong id).
class SoftDeleteFailedException implements Exception {
  const SoftDeleteFailedException();
}
