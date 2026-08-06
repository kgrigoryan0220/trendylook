import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/confirm_bottom_sheet.dart';
import '../../../shared/widgets/history_item_tile.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../check/presentation/check_flow_controller.dart';
import 'history_controller.dart';

/// 4.11 История — Empty / Список, свайп-удаление с подтверждением (4.13).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final Map<String, String> _signedUrls = {};
  final Set<String> _requested = {};
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(historyControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _ensureSignedUrls(List<String> paths) async {
    final missing = paths.where((p) => !_requested.contains(p)).toList();
    if (missing.isEmpty) return;
    for (final p in missing) {
      _requested.add(p);
    }
    final urls = await ref.read(checkRepositoryProvider).getSignedUrls(missing);
    if (!mounted) return;
    setState(() => _signedUrls.addAll(urls));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final historyAsync = ref.watch(historyControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        automaticallyImplyLeading: false,
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.historyLoadError(e.toString()))),
        data: (data) {
          if (data.items.isEmpty) {
            return _EmptyHistory(
              onStart: () {
                ref.read(checkFlowControllerProvider.notifier).reset();
                context.push('/check/camera');
              },
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _ensureSignedUrls(data.items.map((c) => c.imagePath).toList());
          });

          return RefreshIndicator(
            onRefresh: () => ref.read(historyControllerProvider.notifier).refresh(),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              itemCount: data.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = data.items[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  confirmDismiss: (_) => showConfirmBottomSheet(
                    context,
                    title: l10n.deleteCheckTitle,
                    confirmLabel: l10n.delete,
                  ),
                  onDismissed: (_) =>
                      ref.read(historyControllerProvider.notifier).delete(item.id),
                  child: HistoryItemTile(
                    check: item,
                    photoUrl: _signedUrls[item.imagePath],
                    onTap: () => context.push('/history/${item.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.pink.withValues(alpha: 0.15),
                    AppColors.violet.withValues(alpha: 0.15),
                  ],
                ),
              ),
              child: const Icon(Icons.history, size: 48, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.historyEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14.5),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: l10n.historyEmptyCta, onPressed: onStart),
          ],
        ),
      ),
    );
  }
}
