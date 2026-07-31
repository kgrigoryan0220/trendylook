import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/check_exceptions.dart';
import 'check_flow_controller.dart';

/// 4.15 Ошибка анализа (CHECK-08) — «Не получилось проанализировать фото.
/// Попробуй ещё раз — проверка не списана».
class CheckErrorScreen extends ConsumerWidget {
  const CheckErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = ref.watch(checkFlowControllerProvider).error;
    final message = error is RateLimitedException
        ? 'Слишком много проверок подряд. Подожди немного и попробуй снова.'
        : error is AnalysisFailedException
            ? error.message
            : 'Не получилось проанализировать фото. Попробуй ещё раз — проверка не списана.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    ref.read(checkFlowControllerProvider.notifier).reset();
                    context.go('/home');
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error.withValues(alpha: 0.14),
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15.5, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Повторить',
                      onPressed: () {
                        ref.read(checkFlowControllerProvider.notifier).submit();
                        context.replace('/check/loading');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
