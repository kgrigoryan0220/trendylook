import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../check/data/models/check_record.dart';
import '../../check/presentation/check_flow_controller.dart';
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

  @override
  Future<HomeHistoryState> build() async {
    _nextPage = 1;
    final page = await ref.read(checkRepositoryProvider).fetchHistory(page: 0);
    final asc = descPageToAsc(page);
    return HomeHistoryState(
      items: asc,
      hasMore: page.length >= AppConstants.historyPageSize,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref.read(checkRepositoryProvider).fetchHistory(page: _nextPage);
      _nextPage++;
      final olderAsc = descPageToAsc(page);
      final previous = state.valueOrNull ?? current;
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
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
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
