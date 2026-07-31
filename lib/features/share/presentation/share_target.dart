import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../check/data/models/check_record.dart';

/// Данные для экрана «Поделиться» (4.10) — заполняется перед навигацией из
/// Result (флоу) или из детального просмотра Истории (4.12), т.к. источник
/// фото разный (локальный File vs. подписанный URL из Storage).
class ShareTarget {
  const ShareTarget({required this.record, this.localPhoto, this.photoUrl});

  final CheckRecord record;
  final File? localPhoto;
  final String? photoUrl;
}

final shareTargetProvider = StateProvider<ShareTarget?>((ref) => null);
