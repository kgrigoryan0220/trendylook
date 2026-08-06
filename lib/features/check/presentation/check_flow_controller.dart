import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../shared/providers/billing_provider.dart';
import '../data/check_repository.dart';
import '../data/models/check_record.dart';

final checkRepositoryProvider = Provider<CheckRepository>((ref) {
  return CheckRepository(ref.watch(supabaseClientProvider));
});

/// Состояние full-screen модального потока «Проверка лука»
/// (камера/галерея → crop/confirm → анализ → результат, разд. 4.3.0).
class CheckFlowState {
  const CheckFlowState({
    this.photo,
    this.isSubmitting = false,
    this.result,
    this.error,
  });

  final File? photo;
  final bool isSubmitting;
  final CheckRecord? result;
  final Object? error;

  CheckFlowState copyWith({
    File? photo,
    bool? isSubmitting,
    CheckRecord? result,
    Object? error,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return CheckFlowState(
      photo: photo ?? this.photo,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CheckFlowController extends Notifier<CheckFlowState> {
  @override
  CheckFlowState build() => const CheckFlowState();

  void setPhoto(File file) {
    state = CheckFlowState(photo: file);
  }

  /// CHECK-01..08: upload + analyze-look. Ошибка не списывает проверку
  /// (CHECK-08) — сервер сам это гарантирует, клиент просто показывает её.
  Future<void> submit() async {
    final photo = state.photo;
    if (photo == null) return;

    state = state.copyWith(isSubmitting: true, clearError: true, clearResult: true);
    final analytics = ref.read(analyticsServiceProvider);
    analytics.track('check_started', {'source': 'camera_or_gallery'});
    final started = DateTime.now();

    try {
      final repo = ref.read(checkRepositoryProvider);
      final locale = ref.read(currentLanguageCodeProvider);
      final imagePath = await repo.uploadPhoto(photo, locale: locale);
      final result = await repo.analyzeLook(imagePath: imagePath, locale: locale);
      state = state.copyWith(isSubmitting: false, result: result);
      analytics.track('check_completed', {
        'score': result.trendScore,
        'duration_ms': DateTime.now().difference(started).inMilliseconds,
      });
      // Обновляем free_checks_left/is_pro после списания проверки.
      unawaited(ref.read(billingControllerProvider.notifier).refresh());
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e);
      analytics.track('check_failed', {'error_code': e.runtimeType.toString()});
    }
  }

  void reset() {
    state = const CheckFlowState();
  }
}

final checkFlowControllerProvider =
    NotifierProvider<CheckFlowController, CheckFlowState>(
  CheckFlowController.new,
);
