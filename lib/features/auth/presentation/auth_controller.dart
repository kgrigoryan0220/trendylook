import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

enum AuthProviderKind { apple, google }

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signIn(AuthProviderKind provider) async {
    state = const AsyncLoading();
    final providerName = provider == AuthProviderKind.apple ? 'apple' : 'google';
    try {
      final repo = ref.read(authRepositoryProvider);
      if (provider == AuthProviderKind.apple) {
        await repo.signInWithApple();
      } else {
        await repo.signInWithGoogle();
      }
      ref.read(analyticsServiceProvider).track('auth_success', {
        'provider': providerName,
      });
      state = const AsyncData(null);
    } on AuthException catch (e) {
      ref.read(analyticsServiceProvider).track('auth_failed', {
        'provider': providerName,
        'error': e.message,
      });
      state = AsyncError(e, StackTrace.current);
    } catch (e, st) {
      ref.read(analyticsServiceProvider).track('auth_failed', {
        'provider': providerName,
        'error': e.runtimeType.toString(),
      });
      state = AsyncError(e, st);
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
