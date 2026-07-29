/// Значения, зафиксированные в TECH_SPEC_v1.2.md — держать в синхроне
/// с константами в supabase/functions/analyze-look/index.ts.
class AppConstants {
  const AppConstants._();

  static const freeChecksLimit = 2; // 2.1
  static const historyPageSize = 20; // HIST-01
  static const maxUploadBytes = 10 * 1024 * 1024; // CHECK-05 / 6.6
  static const maxImageDimension = 2048; // CHECK-02
  static const jpegQuality = 85; // CHECK-02
  static const analysisTimeout = Duration(seconds: 30); // CHECK-07

  static const lookPhotosBucket = 'look-photos';

  static const weeklyProductId = 'weekly_unlimited'; // PAY-02
  static const halfyearProductId = 'halfyear_unlimited'; // PAY-02
}
