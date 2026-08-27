// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get splashTagline => 'Tu estilista con IA de bolsillo';

  @override
  String get onboardingSlide1Title => 'Fotografía\ntu look';

  @override
  String get onboardingSlide1Subtitle => 'Una foto — y la IA analiza tu estilo';

  @override
  String get onboardingSlide2Title => 'Descubre tu % de tendencia';

  @override
  String get onboardingSlide2Subtitle =>
      'Una valoración honesta de tu outfit en segundos';

  @override
  String get onboardingSlide3Title => 'Recibe consejos de la IA';

  @override
  String get onboardingSlide3Subtitle =>
      'Recomendaciones personalizadas de estilo';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => 'Empezar';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get authSubtitle => 'Inicia sesión para empezar';

  @override
  String get authTerms =>
      'Al continuar, aceptas los Términos y la Política de privacidad';

  @override
  String get authAppleButton => 'Iniciar sesión con Apple';

  @override
  String get authGoogleButton => 'Iniciar sesión con Google';

  @override
  String authSignInError(String error) {
    return 'No se pudo iniciar sesión: $error';
  }

  @override
  String get homeTitle => 'Inicio';

  @override
  String get homeRecentChecks => 'Últimas comprobaciones';

  @override
  String get homeRecentChecksEmpty => 'Aquí aparecerá tu historial';

  @override
  String get homeHeroTitle => 'Comprueba tu look';

  @override
  String get homeHeroSubtitle =>
      'Descubre tu % de tendencia y recibe consejos de la IA';

  @override
  String get ctaCamera => 'Hacer una foto';

  @override
  String get ctaGallery => 'Desde la galería';

  @override
  String freeChecksLeft(int count) {
    return 'Comprobaciones gratuitas restantes: $count';
  }

  @override
  String get graceBannerText =>
      'Tu suscripción está por vencer — actualiza tu método de pago';

  @override
  String get graceBannerUpdate => 'Actualizar';

  @override
  String get cameraPermissionTitle => 'Sin acceso a la cámara';

  @override
  String get cameraPermissionMessage =>
      'Permite el acceso a la cámara en Ajustes para comprobar tus looks';

  @override
  String get cameraUnavailableMessage =>
      'La cámara no está disponible en este dispositivo';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get cancel => 'Cancelar';

  @override
  String get retake => 'Repetir foto';

  @override
  String get confirm => 'Confirmar';

  @override
  String get loadingPhrase1 => 'Analizando colores…';

  @override
  String get loadingPhrase2 => 'Comparando con las tendencias de 2026…';

  @override
  String get loadingPhrase3 => 'Evaluando la silueta…';

  @override
  String get loadingPhrase4 => 'Calculando el resultado final…';

  @override
  String get analysisErrorGeneric =>
      'No se pudo analizar la foto. Inténtalo de nuevo — esta comprobación no se ha descontado.';

  @override
  String get rateLimitedMessage =>
      'Demasiadas comprobaciones seguidas. Espera un momento e inténtalo de nuevo.';

  @override
  String get fileTooLarge => 'El archivo es demasiado grande (máx. 10 MB)';

  @override
  String get retry => 'Reintentar';

  @override
  String get recommendationsTitle => '💡 Recomendaciones';

  @override
  String get share => 'Compartir';

  @override
  String get checkAgain => 'Otra vez';

  @override
  String get back => 'Atrás';

  @override
  String get historyTitle => 'Historial';

  @override
  String historyLoadError(String error) {
    return 'No se pudo cargar el historial: $error';
  }

  @override
  String get deleteCheckTitle => '¿Eliminar esta comprobación?';

  @override
  String get delete => 'Eliminar';

  @override
  String get historyEmpty => 'Aquí aparecerá tu historial de comprobaciones';

  @override
  String get historyEmptyCta => 'Haz tu primera comprobación';

  @override
  String checkLoadError(String error) {
    return 'No se pudo cargar la comprobación: $error';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get defaultUserName => 'Usuario';

  @override
  String get subscriptionStatusLabel => 'Estado de la suscripción';

  @override
  String proUntil(String date) {
    return 'Pro hasta el $date';
  }

  @override
  String get proStatus => 'Pro';

  @override
  String get freeStatus => 'Gratis';

  @override
  String get graceStatus => 'Periodo de gracia';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get language => 'Idioma';

  @override
  String get support => 'Soporte';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String get upgradeToPro => 'Pasar a Pro';

  @override
  String get logoutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get languagePickerTitle => 'Elige el idioma';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';

  @override
  String get shareNothingToShare => 'No hay nada que compartir';

  @override
  String get shareChallengeHook => 'Comprueba tu look y etiqueta a un amigo 👀';

  @override
  String shareMessageText(int score, String id) {
    return '¡Mi look obtuvo $score% de tendencia en Trendy Look! Comprueba el tuyo: trendylook://check/$id';
  }

  @override
  String get paywallTitle => 'Desbloquea el ilimitado';

  @override
  String get paywallSubtitle => 'Comprobaciones de outfits ilimitadas cada día';

  @override
  String get paywallSocialProof => 'Más de 12.000 comprobaciones hoy';

  @override
  String get paywallContinue => 'Continuar';

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallNotConfigured =>
      'Los pagos aún no están configurados — añade las claves de RevenueCat';

  @override
  String paywallPurchaseError(String error) {
    return 'No se pudo completar la compra: $error';
  }

  @override
  String get paywallRestoreSuccess => 'Compras restauradas';

  @override
  String paywallRestoreError(String error) {
    return 'No se pudieron restaurar las compras: $error';
  }

  @override
  String paywallOfferError(String error) {
    return 'Error: $error';
  }

  @override
  String get paywallSuccessTitle => '¡Listo! Ahora tienes acceso ilimitado 🎉';

  @override
  String get paywallSuccessCta => 'Genial';

  @override
  String get paywallPlanWeekly => 'Semanal';

  @override
  String get paywallPlanHalfyear => 'Semestral';

  @override
  String get paywallPeriodWeek => '7 días';

  @override
  String get paywallPeriodHalfyear => '6 meses';

  @override
  String get paywallBenefit1 => 'Comprobaciones de outfits ilimitadas';

  @override
  String get paywallBenefit2 => 'Análisis de IA prioritario';

  @override
  String get paywallBenefit3 => 'Acceso anticipado a tendencias';

  @override
  String get paywallBestValue => 'MEJOR OFERTA';

  @override
  String get promoCodeSectionTitle => '¿Tienes un código promocional?';

  @override
  String get promoCodeHint => 'Introduce el código';

  @override
  String get promoCodeApply => 'Aplicar';

  @override
  String promoRedeemedUntil(String date) {
    return '¡Código aplicado! Acceso Pro hasta $date';
  }

  @override
  String get promoCodeNotFound => 'No se encontró este código promocional';

  @override
  String get promoCodeExpired => 'Este código ya no es válido';

  @override
  String get promoCodeExhausted => 'Este código ya se ha agotado';

  @override
  String get promoCodeAlreadyRedeemed => 'Ya has usado este código';

  @override
  String get promoRedeemError =>
      'No se pudo aplicar el código. Inténtalo de nuevo';

  @override
  String get offlineBanner => 'Sin conexión';

  @override
  String get bottomTabHome => 'Inicio';

  @override
  String get bottomTabHistory => 'Historial';

  @override
  String get bottomTabProfile => 'Perfil';

  @override
  String get categoryColorPalette => 'Paleta de colores';

  @override
  String get categorySilhouette => 'Silueta y ajuste';

  @override
  String get categoryAccessories => 'Accesorios';

  @override
  String get categoryFootwear => 'Calzado';
}
