import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../check/data/models/check_record.dart';

/// Данные для экрана «Поделиться» (4.10) — заполняется перед навигацией из
/// Result (флоу) или из детального просмотра Истории (4.12). Фото — всегда
/// локальный File: снимок из флоу или файл из дискового кэша (LookPhotoCache).
class ShareTarget {
  const ShareTarget({required this.record, this.localPhoto});

  final CheckRecord record;
  final File? localPhoto;
}

final shareTargetProvider = StateProvider<ShareTarget?>((ref) => null);
