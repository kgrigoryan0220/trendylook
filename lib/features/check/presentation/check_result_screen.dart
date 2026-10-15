import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/providers/billing_provider.dart';
import '../../history/presentation/history_controller.dart';
import '../../home/presentation/home_history_controller.dart';
import '../../share/presentation/share_target.dart';
import 'check_flow_controller.dart';
import 'result_view.dart';

/// Result в режиме флоу «Проверка лука» (4.3.0): «Поделиться» / «Ещё раз».
class CheckResultScreen extends ConsumerWidget {
  const CheckResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(checkFlowControllerProvider);
    final record = flow.result;
    if (record == null) {
      // Défensive: не должно случиться при штатной навигации из Loading.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ResultView(
      record: record,
      photo: flow.photo != null
          ? Image.file(flow.photo!, fit: BoxFit.cover, alignment: Alignment.topCenter)
          : const ColoredBox(color: Colors.black12),
      onClose: () {
        ref.read(checkFlowControllerProvider.notifier).reset();
        _reloadHistory(ref);
        context.go('/home');
      },
      onShare: () {
        ref.read(shareTargetProvider.notifier).state = ShareTarget(
          record: record,
          localPhoto: flow.photo,
        );
        context.push('/share');
      },
      primaryActionLabel: AppLocalizations.of(context).checkAgain,
      onPrimaryAction: () async {
        final billing = ref.read(billingControllerProvider).valueOrNull;
        final canCheck = billing?.isPro == true || (billing?.freeChecksLeft ?? 0) > 0;
        if (canCheck) {
          ref.read(checkFlowControllerProvider.notifier).reset();
          _reloadHistory(ref);
          context.go('/check/camera');
        } else {
          context.push('/paywall?trigger=result');
        }
      },
    );
  }
}

/// Новая проверка уже лежит в локальном кэше истории (см. CheckFlowController),
/// так что пересборка Главной и Истории мгновенная, без ожидания сети.
void _reloadHistory(WidgetRef ref) {
  invalidateHomeHistory(ref);
  ref.invalidate(historyControllerProvider);
}
