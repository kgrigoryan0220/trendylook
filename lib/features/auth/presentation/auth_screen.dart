import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';
import 'auth_controller.dart';

/// 4.3 Auth (Trendy_Look_Design_Brief.md).
class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не получилось войти: ${next.error}')),
        );
      }
    });

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.7),
            radius: 0.9,
            colors: [Color(0x337B5CFF), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.gradientPrimary.createShader(bounds),
                  child: Text(
                    'Trendy Look',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 28,
                          color: Colors.white,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Войди, чтобы начать',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 40),
                _AppleSignInButton(
                  isLoading: isLoading,
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signIn(
                            AuthProviderKind.apple,
                          ),
                ),
                const SizedBox(height: 12),
                _GoogleSignInButton(
                  isLoading: isLoading,
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signIn(
                            AuthProviderKind.google,
                          ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Продолжая, ты соглашаешься с Условиями и Конфиденциальностью',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppleSignInButton extends StatelessWidget {
  const _AppleSignInButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        icon: const Icon(Icons.apple, size: 20),
        label: const Text('Войти через Apple'),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        label: 'Войти через Google',
        onPressed: isLoading ? null : onPressed,
        background: Colors.white,
        foregroundColor: AppColors.background,
      ),
    );
  }
}
