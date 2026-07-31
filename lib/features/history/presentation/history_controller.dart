import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../check/data/models/check_record.dart';
import '../../check/presentation/check_flow_controller.dart';
import '../data/history_cache.dart';

final historyCacheProvider = Provider<HistoryCache>((ref) => HistoryCache());

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

  @override
  Future<HistoryState> build() async {
    _page = 0;
    final cache = ref.read(historyCacheProvider);
    try {
      final items = await ref.read(checkRepositoryProvider).fetchHistory(page: 0);
      unawaited(cache.save(items));
      return HistoryState(items: items, hasMore: items.length >= AppConstants.historyPageSize);
    } catch (e) {
      // Разд. 7 НФТ: история доступна offline — при сетевой ошибке отдаём
      // последний закэшированный список (только для чтения, без пагинации).
      final cached = await cache.load();
      if (cached.isNotEmpty) {
        return HistoryState(items: cached, hasMore: false);
      }
      rethrow;
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = _page + 1;
    final more = await ref.read(checkRepositoryProvider).fetchHistory(page: nextPage);
    _page = nextPage;
    state = AsyncData(
      current.copyWith(
        items: [...current.items, ...more],
        hasMore: more.length >= AppConstants.historyPageSize,
        isLoadingMore: false,
      ),
    );
  }

  Future<void> delete(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final previousItems = current.items;
    state = AsyncData(current.copyWith(items: previousItems.where((c) => c.id != id).toList()));
    try {
      await ref.read(checkRepositoryProvider).softDeleteCheck(id);
    } catch (_) {
      // Откатываем при ошибке.
      state = AsyncData(current.copyWith(items: previousItems));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      _page = 0;
      final items = await ref.read(checkRepositoryProvider).fetchHistory(page: 0);
      unawaited(ref.read(historyCacheProvider).save(items));
      return HistoryState(
        items: items,
        hasMore: items.length >= AppConstants.historyPageSize,
      );
    });
  }
}

final historyControllerProvider =
    AsyncNotifierProvider<HistoryController, HistoryState>(HistoryController.new);
