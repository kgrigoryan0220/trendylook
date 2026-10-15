import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/look_photo.dart';
import '../../check/data/models/check_record.dart';
import '../../check/presentation/check_flow_controller.dart';
import '../../check/presentation/result_view.dart';
import '../../home/presentation/home_history_controller.dart';
import '../../share/presentation/share_target.dart';
import 'history_controller.dart';

/// Проверка из уже загруженных списков (Главная/История), без запроса в сеть;
/// с сервера — только если её там нет (например, переход по deep link).
final _checkByIdProvider =
    FutureProvider.autoDispose.family<CheckRecord, String>((ref, id) {
  final local = [
    ...?ref.read(historyControllerProvider).valueOrNull?.items,
    ...?ref.read(homeHistoryControllerProvider).valueOrNull?.items,
  ].firstWhereOrNull((c) => c.id == id);
  if (local != null) return local;
  return ref.watch(checkRepositoryProvider).fetchCheck(id);
});

/// 4.12 Детальный просмотр (история, read-only) — тот же вид, что Result,
/// но вместо «Ещё раз» кнопка «Назад».
class HistoryDetailScreen extends ConsumerWidget {
  const HistoryDetailScreen({super.key, required this.checkId});

  final String checkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final checkAsync = ref.watch(_checkByIdProvider(checkId));

    return checkAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(child: Text(l10n.checkLoadError(e.toString()))),
      ),
      data: (record) {
        ref.read(analyticsServiceProvider).track('history_viewed', {'check_id': record.id});
        final photoFile = ref.watch(lookPhotoProvider(record.imagePath)).valueOrNull;

        return ResultView(
          record: record,
          photo: LookPhoto(imagePath: record.imagePath, placeholderColor: Colors.black12),
          onBack: () => context.pop(),
          onShare: () {
            ref.read(shareTargetProvider.notifier).state = ShareTarget(
              record: record,
              localPhoto: photoFile,
            );
            context.push('/share');
          },
          primaryActionLabel: l10n.back,
          onPrimaryAction: () => context.pop(),
        );
      },
    );
  }
}
