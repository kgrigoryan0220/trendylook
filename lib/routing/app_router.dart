import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/supabase/supabase_providers.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/check/presentation/camera_screen.dart';
import '../features/check/presentation/check_error_screen.dart';
import '../features/check/presentation/check_result_screen.dart';
import '../features/check/presentation/crop_confirm_screen.dart';
import '../features/check/presentation/loading_screen.dart';
import '../features/history/presentation/history_detail_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/paywall/presentation/paywall_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/share/presentation/share_screen.dart';
import '../shared/widgets/bottom_tab_shell.dart';

const _publicLocations = {'/splash', '/onboarding', '/auth'};

/// Делает GoRouter реактивным на смену auth-состояния (redirect пересчитывается).
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<void> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<void> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final refreshStream = _GoRouterRefreshStream(client.auth.onAuthStateChange);
  ref.onDispose(refreshStream.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshStream,
    redirect: (context, state) {
      final loggedIn = client.auth.currentSession != null;
      final loc = state.matchedLocation;
      final isPublic = _publicLocations.contains(loc);
      if (!loggedIn && !isPublic) return '/auth';
      if (loggedIn && (loc == '/auth' || loc == '/onboarding' || loc == '/splash')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),

      // 4.3.0: full-screen модальные потоки поверх tab bar (без нижней навигации).
      GoRoute(path: '/check/camera', builder: (context, state) => const CameraScreen()),
      GoRoute(path: '/check/confirm', builder: (context, state) => const CropConfirmScreen()),
      GoRoute(path: '/check/loading', builder: (context, state) => const LoadingScreen()),
      GoRoute(path: '/check/result', builder: (context, state) => const CheckResultScreen()),
      GoRoute(path: '/check/error', builder: (context, state) => const CheckErrorScreen()),
      GoRoute(path: '/share', builder: (context, state) => const ShareScreen()),
      GoRoute(path: '/paywall', builder: (context, state) => const PaywallScreen()),
      GoRoute(
        path: '/history/:id',
        builder: (context, state) =>
            HistoryDetailScreen(checkId: state.pathParameters['id']!),
      ),

      // Навигационная оболочка: bottom tab bar (Главная / История / Профиль).
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => BottomTabShell(shell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/history', builder: (context, state) => const HistoryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});
