import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Тёмная тема как основная (Trendy_Look_Design_Brief.md section 2).
///
/// Не-RU: весь UI на Poppins (заголовки, body, кнопки).
/// RU: заголовки Sora, остальной текст Inter — у Poppins нет кириллицы.
class AppTheme {
  const AppTheme._();

  static ThemeData get dark => darkForLanguage('en');

  static ThemeData darkForLanguage(String languageCode) {
    final isRussian = languageCode == 'ru';
    final uiTheme =
        isRussian ? GoogleFonts.interTextTheme() : GoogleFonts.poppinsTextTheme();
    final displayTheme =
        isRussian ? GoogleFonts.soraTextTheme() : GoogleFonts.poppinsTextTheme();
    final fontFamily =
        (isRussian ? GoogleFonts.inter() : GoogleFonts.poppins()).fontFamily;

    final coloredUi = uiTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    final textTheme = coloredUi.copyWith(
      displayLarge: displayTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      headlineLarge: displayTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      headlineMedium: displayTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      headlineSmall: displayTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      titleLarge: displayTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );

    final buttonText = coloredUi.titleMedium?.copyWith(fontWeight: FontWeight.w700);

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.background,
        primary: AppColors.pink,
        secondary: AppColors.violet,
        error: AppColors.error,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: const StadiumBorder(),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.16), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: const StadiumBorder(),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: buttonText),
      ),
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: coloredUi.bodyMedium?.copyWith(color: Colors.white),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: coloredUi.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        subtitleTextStyle: coloredUi.bodySmall?.copyWith(color: AppColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerColor: Colors.white.withValues(alpha: 0.08),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  /// Display/заголовки: Poppins, для ru — Sora.
  static TextStyle heading(
    BuildContext context, {
    double? fontSize,
    FontWeight fontWeight = FontWeight.w800,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return (Theme.of(context).textTheme.headlineMedium ?? const TextStyle()).copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Body / кнопки: Poppins, для ru — Inter. Явно прокидывает fontFamily,
  /// чтобы не потеряться внутри Material/InkWell.
  static TextStyle body(
    BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return (Theme.of(context).textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }
}
