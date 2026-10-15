import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../check/data/models/check_record.dart';
import '../../check/presentation/check_flow_controller.dart';
import '../../history/data/history_cache.dart';
import 'home_history_aspect_ratio.dart';

/// Paginated home history: ASC display (newest at bottom), older pages prepended on scroll up.
class HomeHistoryState {
  const HomeHistoryState({
    this.items = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<CheckRecord> items;
  final bool hasMore;
  final bool isLoadingMore;

  HomeHistoryState copyWith({
    List<CheckRecord>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return HomeHistoryState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class HomeHistoryController extends AsyncNotifier<HomeHistoryState> {
  int _nextPage = 1;
  // Отбрасывает фоновое обновление, если провайдер уже пересобрался.
  int _generation = 0;
  String? _userId;

  @override
  Future<HomeHistoryState> build() async {
    _nextPage = 1;
    final generation = ++_generation;
    final userId = ref.watch(currentUserProvider.select((u) => u?.id));
    _userId = userId;
    if (userId == null) return const HomeHistoryState(hasMore: false);

    // Stale-while-revalidate: Главная открывается из кэша мгновенно,
    // свежая страница подтягивается в фоне.
    final cached = await ref.read(historyCacheProvider).load(userId);
    if (cached.isNotEmpty) {
      unawaited(_revalidate(userId, generation));
      return _stateFromFirstPage(cached);
    }
    return _fetchFirstPage(userId);
  }

  HomeHistoryState _stateFromFirstPage(List<CheckRecord> pageDesc) {
    return HomeHistoryState(
      items: descPageToAsc(pageDesc),
      hasMore: pageDesc.length >= AppConstants.historyPageSize,
    );
  }

  Future<HomeHistoryState> _fetchFirstPage(String userId) async {
    final page = await ref.read(checkRepositoryProvider).fetchHistory(page: 0);
    unawaited(ref.read(historyCacheProvider).save(userId, page));
    return _stateFromFirstPage(page);
  }

  Future<void> _revalidate(String userId, int generation) async {
    try {
      final fresh = await _fetchFirstPage(userId);
      final current = state.valueOrNull;
      // Уже подгрузили старые страницы — не затираем их, кэш сохранён.
      if (generation != _generation || _nextPage != 1 || current?.isLoadingMore == true) return;
      state = AsyncData(fresh);
    } catch (_) {
      // Офлайн остаёмся на закэшированном списке.
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref.read(checkRepositoryProvider).fetchHistory(page: _nextPage);
      _nextPage++;
      final previous = state.valueOrNull ?? current;
      // Список мог прийти из устаревшего кэша — страницы сдвигаются, отсекаем дубли.
      final known = previous.items.map((c) => c.id).toSet();
      final olderAsc = descPageToAsc(page).where((c) => !known.contains(c.id));
      state = AsyncData(
        previous.copyWith(
          items: [...olderAsc, ...previous.items],
          hasMore: page.length >= AppConstants.historyPageSize,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId == null) return;
    _generation++;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      _nextPage = 1;
      return _fetchFirstPage(userId);
    });
  }

  /// Drop a check from local home state after History soft-delete.
  void removeLocally(String id) {
    final current = state.valueOrNull;
    if (current == null) return;
    final next = current.items.where((c) => c.id != id).toList();
    if (next.length == current.items.length) return;
    state = AsyncData(current.copyWith(items: next));
  }
}

final homeHistoryControllerProvider =
    AsyncNotifierProvider<HomeHistoryController, HomeHistoryState>(
  HomeHistoryController.new,
);

/// Set before [invalidateHomeHistory] so Home scrolls to newest after reload.
final homeHistoryScrollToBottomRequestProvider = StateProvider<bool>((ref) => false);

/// Reload home masonry after a completed check (Home tab stays mounted in shell).
void invalidateHomeHistory(WidgetRef ref) {
  ref.read(homeHistoryScrollToBottomRequestProvider.notifier).state = true;
  ref.invalidate(homeHistoryControllerProvider);
}
