import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/check/data/look_photo_cache.dart';
import '../../features/check/presentation/check_flow_controller.dart';

/// Локальный файл фото по `imagePath`: с диска, а при промахе — скачивание
/// по свежему signed URL с сохранением в [LookPhotoCache].
final lookPhotoProvider =
    FutureProvider.autoDispose.family<File, String>((ref, imagePath) async {
  final cached = await LookPhotoCache.instance.getFileFromCache(imagePath);
  final File file;
  if (cached != null && await cached.file.exists()) {
    file = cached.file;
  } else {
    final url = await ref.read(checkRepositoryProvider).getSignedUrl(imagePath);
    file = await LookPhotoCache.instance.getSingleFile(url, key: imagePath);
  }
  // Ошибку не держим (повторим при следующем показе), успех — держим,
  // чтобы при скролле карточки не мигали плейсхолдером.
  ref.keepAlive();
  return file;
});

/// Фото лука из дискового кэша; пока грузится или при ошибке — плейсхолдер.
class LookPhoto extends ConsumerWidget {
  const LookPhoto({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.cacheWidth,
    this.placeholderColor,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final Color? placeholderColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholder = SizedBox(
      width: width,
      height: height,
      child: ColoredBox(color: placeholderColor ?? Colors.white.withValues(alpha: 0.08)),
    );
    final file = ref.watch(lookPhotoProvider(imagePath)).valueOrNull;
    if (file == null) return placeholder;
    return Image.file(
      file,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
