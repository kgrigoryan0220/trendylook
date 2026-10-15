import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../check/data/models/check_record.dart';

final historyCacheProvider = Provider<HistoryCache>((ref) => HistoryCache());

/// Локальный кэш первой страницы истории (разд. 7 НФТ: «история доступна
/// offline (cached)»). Главная и История открываются из него мгновенно,
/// свежая страница подтягивается в фоне. Без кастомных Hive-адаптеров —
/// храним JSON-строку, т.к. CheckRecord уже умеет toJson/fromJson.
///
/// Ключ — по пользователю: на одном устройстве могут входить разные аккаунты.
class HistoryCache {
  static const _boxName = 'history_cache';
  static const _legacyKey = 'first_page';

  static String _key(String userId) => 'first_page:$userId';

  Future<Box<String>> _box() async {
    final box = await Hive.openBox<String>(_boxName);
    // Старый общий для всех аккаунтов ключ — больше не читаем.
    if (box.containsKey(_legacyKey)) await box.delete(_legacyKey);
    return box;
  }

  Future<void> save(String userId, List<CheckRecord> items) async {
    final box = await _box();
    await box.put(_key(userId), jsonEncode(items.map((c) => c.toJson()).toList()));
  }

  Future<List<CheckRecord>> load(String userId) async {
    final box = await _box();
    final raw = box.get(_key(userId));
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => CheckRecord.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      // Формат CheckRecord поменялся — кэш просто пересоберётся из сети.
      await box.delete(_key(userId));
      return [];
    }
  }

  /// Новая проверка сразу попадает в кэш, чтобы Главная показала её без сети.
  Future<void> prepend(String userId, CheckRecord record) async {
    final items = await load(userId);
    await save(userId, [record, ...items.where((c) => c.id != record.id)]);
  }

  Future<void> removeById(String userId, String id) async {
    final items = await load(userId);
    final next = items.where((c) => c.id != id).toList();
    if (next.length == items.length) return;
    await save(userId, next);
  }

  Future<void> clear(String userId) async {
    final box = await _box();
    await box.delete(_key(userId));
  }
}
