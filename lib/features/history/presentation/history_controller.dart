import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../check/data/models/check_record.dart';
import '../../check/presentation/check_flow_controller.dart';
import '../../home/presentation/home_history_controller.dart';
import '../data/history_cache.dart';

/// HIST-01/03 (TECH_SPEC_v1.2.md 5.4) — пагинированная история + soft delete.
class HistoryState {
  const HistoryState({
    this.items = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<CheckRecord> items;
  final bool hasMore;
  final bool isLoadingMore;

  HistoryState copyWith({
    List<CheckRecord>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HistoryState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HistoryController extends AsyncNotifier<HistoryState> {
  int _page = 0;
  // Отбрасывает фоновое обновление, если провайдер уже пересобрался.
  int _generation = 0;
  String? _userId;

  @override
  Future<HistoryState> build() async {
    _page = 0;
    final generation = ++_generation;
    final userId = ref.watch(currentUserProvider.select((u) => u?.id));
    _userId = userId;
    if (userId == null) return const HistoryState(hasMore: false);

    // Stale-while-revalidate: сразу показываем кэш, свежую страницу — в фоне.
    final cached = await ref.read(historyCacheProvider).load(userId);
    if (cached.isNotEmpty) {
      unawaited(_revalidate(userId, generation));
      return HistoryState(
        items: cached,
        hasMore: cached.length >= AppConstants.historyPageSize,
      );
    }
    return _fetchFirstPage(userId);
  }

  Future<HistoryState> _fetchFirstPage(String userId) async {
    final items = await ref.read(checkRepositoryProvider).fetchHistory(page: 0);
    unawaited(ref.read(historyCacheProvider).save(userId, items));
    return HistoryState(items: items, hasMore: items.length >= AppConstants.historyPageSize);
  }

  Future<void> _revalidate(String userId, int generation) async {
    try {
      final fresh = await _fetchFirstPage(userId);
      final current = state.valueOrNull;
      // Пока шла загрузка, пользователь мог уйти дальше по страницам —
      // тогда не затираем подгруженное, свежий кэш уже сохранён.
      if (generation != _generation || _page != 0 || current?.isLoadingMore == true) return;
      state = AsyncData(fresh);
    } catch (_) {
      // Разд. 7 НФТ: офлайн остаёмся на закэшированном списке.
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = _page + 1;
    try {
      final more = await ref.read(checkRepositoryProvider).fetchHistory(page: nextPage);
      _page = nextPage;
      // Список мог прийти из устаревшего кэша — страницы сдвигаются, отсекаем дубли.
      final known = current.items.map((c) => c.id).toSet();
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...more.where((c) => !known.contains(c.id))],
          hasMore: more.length >= AppConstants.historyPageSize,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      // Офлайн со списком из кэша — не зависаем в isLoadingMore.
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  /// Soft-deletes [id]. Returns `true` on success.
  /// On failure restores previous list and returns `false`.
  Future<bool> delete(String id) async {
    final current = state.valueOrNull;
    if (current == null) return false;
    final previousItems = current.items;
    final nextItems = previousItems.where((c) => c.id != id).toList();
    state = AsyncData(current.copyWith(items: nextItems));

    try {
      await ref.read(checkRepositoryProvider).softDeleteCheck(id);
      final userId = _userId;
      if (userId != null) {
        unawaited(ref.read(historyCacheProvider).removeById(userId, id));
      }
      ref.read(homeHistoryControllerProvider.notifier).removeLocally(id);
      return true;
    } catch (e, st) {
      // ignore: avoid_print
      print('soft_delete_check failed id=$id error=$e\n$st');
      state = AsyncData(current.copyWith(items: previousItems));
      return false;
    }
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId == null) return;
    _generation++;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      _page = 0;
      return _fetchFirstPage(userId);
    });
  }
}

final historyControllerProvider =
    AsyncNotifierProvider<HistoryController, HistoryState>(HistoryController.new);
