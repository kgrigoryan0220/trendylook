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

  /// Куда ведёт QR на share-карточке (4.3, SHARE-02). Лендинг со ссылками на
  /// сторы: `https://trendylook.app/check/{id}` заработает только вместе с
  /// Universal Links (SHARE-04, v1.1), до тех пор это была бы 404.
  static const shareCardUrl = 'https://trendylook.app';
}
