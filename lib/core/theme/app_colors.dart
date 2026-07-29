import 'package:flutter/widgets.dart';

/// Design tokens per Trendy_Look_Design_Brief.md section 2 (тёмная тема).
class AppColors {
  const AppColors._();

  static const background = Color(0xFF0B0B10);
  static const surface = Color(0xFF17171F);

  static const pink = Color(0xFFFF3D8A);
  static const lime = Color(0xFFC6FF3D);
  static const violet = Color(0xFF7B5CFF);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9A9AA8);

  static const warning = Color(0xFFFFD23D);
  static const error = Color(0xFFFF5C5C);

  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pink, violet],
  );

  /// Score-ring / label color per trend_label scale (TECH_SPEC_v1.2.md 5.3).
  static Color colorForScore(int score) {
    if (score >= 80) return lime;
    if (score >= 60) return pink;
    if (score >= 40) return warning;
    return error;
  }
}
