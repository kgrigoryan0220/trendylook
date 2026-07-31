import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../check/data/models/check_record.dart';

/// Offline-кэш первой страницы истории (разд. 7 НФТ: «история доступна
/// offline (cached)»). Без кастомных Hive-адаптеров — храним JSON-строку,
/// т.к. CheckRecord уже умеет сериализоваться через toJson/fromJson.
class HistoryCache {
  static const _boxName = 'history_cache';
  static const _key = 'first_page';

  Future<Box<String>> _box() => Hive.openBox<String>(_boxName);

  Future<void> save(List<CheckRecord> items) async {
    final box = await _box();
    await box.put(_key, jsonEncode(items.map((c) => c.toJson()).toList()));
  }

  Future<List<CheckRecord>> load() async {
    final box = await _box();
    final raw = box.get(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => CheckRecord.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
