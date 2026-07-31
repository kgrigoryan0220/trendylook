import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Единый доступ к SupabaseClient через Riverpod (инициализируется в main.dart
/// до runApp, см. TECH_SPEC_v1.2.md 6.3).
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Стрим текущего auth-состояния — на нём строится редирект-логика go_router.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  // Пересчитывается при каждом auth-событии.
  ref.watch(authStateChangesProvider);
  return client.auth.currentUser;
});
