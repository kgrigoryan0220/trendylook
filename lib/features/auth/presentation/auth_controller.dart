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
    try {
      final repo = ref.read(authRepositoryProvider);
      if (provider == AuthProviderKind.apple) {
        await repo.signInWithApple();
      } else {
        await repo.signInWithGoogle();
      }
      ref.read(analyticsServiceProvider).track('auth_success', {
        'provider': provider == AuthProviderKind.apple ? 'apple' : 'google',
      });
      state = const AsyncData(null);
    } on AuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
