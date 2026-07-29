import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_colors.dart';
import 'onboarding_prefs.dart';

/// 4.1 Splash — авто-переход в Onboarding/Auth/Home по auth-состоянию (UC-03).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 900), _proceed);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _proceed() async {
    if (!mounted) return;
    final session = ref.read(supabaseClientProvider).auth.currentSession;
    if (session != null) {
      context.go('/home');
      return;
    }
    final seenOnboarding = await ref.read(onboardingPrefsProvider).hasSeenOnboarding();
    if (!mounted) return;
    context.go(seenOnboarding ? '/auth' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _timer?.cancel();
        _proceed();
      },
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.5, -0.4),
            radius: 1,
            colors: [Color(0x477B5CFF), AppColors.background],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.gradientPrimary.createShader(bounds),
                  child: const Text(
                    'Trendy Look',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'AI-стилист в кармане',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
