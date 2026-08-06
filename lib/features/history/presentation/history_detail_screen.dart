import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../check/data/models/check_record.dart';
import '../../check/presentation/check_flow_controller.dart';
import '../../check/presentation/result_view.dart';
import '../../share/presentation/share_target.dart';

final _checkByIdProvider =
    FutureProvider.autoDispose.family<CheckRecord, String>((ref, id) {
  return ref.watch(checkRepositoryProvider).fetchCheck(id);
});

final _signedPhotoUrlProvider =
    FutureProvider.autoDispose.family<String, String>((ref, imagePath) {
  return ref.watch(checkRepositoryProvider).getSignedUrl(imagePath);
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
        final photoAsync = ref.watch(_signedPhotoUrlProvider(record.imagePath));

        return ResultView(
          record: record,
          photo: photoAsync.when(
            data: (url) => Image.network(url, fit: BoxFit.cover),
            loading: () => const ColoredBox(color: Colors.black12),
            error: (_, _) => const ColoredBox(color: Colors.black12),
          ),
          onBack: () => context.pop(),
          onShare: () {
            ref.read(shareTargetProvider.notifier).state = ShareTarget(
              record: record,
              photoUrl: photoAsync.valueOrNull,
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
