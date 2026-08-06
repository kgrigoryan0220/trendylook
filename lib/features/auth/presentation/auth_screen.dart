import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import 'auth_controller.dart';

/// 4.3 Auth (Trendy_Look_Design_Brief.md).
class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.authSignInError(next.error.toString()))),
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
                Text(
                  l10n.authSubtitle,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 40),
                _AppleSignInButton(
                  label: l10n.authAppleButton,
                  isLoading: isLoading,
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signIn(
                            AuthProviderKind.apple,
                          ),
                ),
                const SizedBox(height: 12),
                _GoogleSignInButton(
                  label: l10n.authGoogleButton,
                  isLoading: isLoading,
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).signIn(
                            AuthProviderKind.google,
                          ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.authTerms,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
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
  const _AppleSignInButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
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
        label: Text(label),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        label: label,
        onPressed: isLoading ? null : onPressed,
        background: Colors.white,
        foregroundColor: AppColors.background,
      ),
    );
  }
}
