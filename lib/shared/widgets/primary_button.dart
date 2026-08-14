import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Pill-кнопка. Без `background` — заливка градиентом pink→violet (primary
/// CTA по всему приложению); с `background` — сплошная заливка (напр. Google).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.background,
    this.foregroundColor = Colors.white,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? background;
  final Color foregroundColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: foregroundColor),
          )
        : Text(
            label,
            style: AppTheme.body(
              context,
              fontWeight: FontWeight.w700,
              fontSize: 15.5,
              color: foregroundColor,
            ),
          );

    final button = Container(
      decoration: BoxDecoration(
        color: background,
        gradient: background == null ? AppColors.gradientPrimary : null,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 17),
            child: Center(child: child),
          ),
        ),
      ),
    );

    return Opacity(opacity: onPressed == null && !isLoading ? 0.5 : 1, child: button);
  }
}
