import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Дисковый кэш фото луков. Bucket приватный, signed URL живёт час и каждый
/// раз новый — поэтому ключ кэша не URL, а стабильный `imagePath`
/// (`userId/uuid.jpg`): фото скачивается один раз и дальше читается с диска.
class LookPhotoCache {
  LookPhotoCache._();

  static const _maxAge = Duration(days: 90);

  static final instance = CacheManager(
    Config('look_photos', stalePeriod: _maxAge, maxNrOfCacheObjects: 500),
  );

  /// Кладёт только что загруженное фото, чтобы оно не скачивалось обратно.
  static Future<void> put(String imagePath, Uint8List bytes) async {
    await instance.putFile(
      imagePath,
      bytes,
      key: imagePath,
      maxAge: _maxAge,
      fileExtension: 'jpg',
    );
  }
}
