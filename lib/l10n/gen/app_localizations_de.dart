// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get splashTagline => 'Dein KI-Stylist für die Hosentasche';

  @override
  String get onboardingSlide1Title => 'Fotografiere\ndeinen Look';

  @override
  String get onboardingSlide1Subtitle =>
      'Ein Foto — und die KI analysiert deinen Stil';

  @override
  String get onboardingSlide2Title => 'Erfahre deine Trend-%';

  @override
  String get onboardingSlide2Subtitle =>
      'Eine ehrliche Bewertung deines Outfits in Sekunden';

  @override
  String get onboardingSlide3Title => 'Erhalte KI-Styling-Tipps';

  @override
  String get onboardingSlide3Subtitle => 'Persönliche Stilempfehlungen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingStart => 'Los geht\'s';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get authSubtitle => 'Melde dich an, um loszulegen';

  @override
  String get authTerms =>
      'Mit der Fortsetzung stimmst du den Nutzungsbedingungen und der Datenschutzerklärung zu';

  @override
  String get authAppleButton => 'Mit Apple anmelden';

  @override
  String get authGoogleButton => 'Mit Google anmelden';

  @override
  String authSignInError(String error) {
    return 'Anmeldung fehlgeschlagen: $error';
  }

  @override
  String get homeTitle => 'Start';

  @override
  String get homeRecentChecks => 'Letzte Checks';

  @override
  String get homeRecentChecksEmpty => 'Hier erscheint dein Verlauf';

  @override
  String get homeHeroTitle => 'Check deinen Look';

  @override
  String get homeHeroSubtitle => 'Erfahre deine Trend-% und erhalte KI-Tipps';

  @override
  String get ctaCamera => 'Foto aufnehmen';

  @override
  String get ctaGallery => 'Aus der Galerie';

  @override
  String freeChecksLeft(int count) {
    return 'Verbleibende kostenlose Checks: $count';
  }

  @override
  String get graceBannerText =>
      'Dein Abo läuft bald ab — aktualisiere deine Zahlungsmethode';

  @override
  String get graceBannerUpdate => 'Aktualisieren';

  @override
  String get cameraPermissionTitle => 'Kein Kamerazugriff';

  @override
  String get cameraPermissionMessage =>
      'Erlaube den Kamerazugriff in den Einstellungen, um Looks zu checken';

  @override
  String get cameraUnavailableMessage =>
      'Die Kamera ist auf diesem Gerät nicht verfügbar';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get retake => 'Neu aufnehmen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get loadingPhrase1 => 'Farben werden analysiert…';

  @override
  String get loadingPhrase2 => 'Abgleich mit den Trends 2026…';

  @override
  String get loadingPhrase3 => 'Silhouette wird bewertet…';

  @override
  String get loadingPhrase4 => 'Endergebnis wird berechnet…';

  @override
  String get analysisErrorGeneric =>
      'Das Foto konnte nicht analysiert werden. Versuch es noch mal — dieser Check wurde nicht verbraucht.';

  @override
  String get rateLimitedMessage =>
      'Zu viele Checks hintereinander. Warte kurz und versuch es noch mal.';

  @override
  String get fileTooLarge => 'Die Datei ist zu groß (max. 10 MB)';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get recommendationsTitle => '💡 Empfehlungen';

  @override
  String get share => 'Teilen';

  @override
  String get checkAgain => 'Nochmal checken';

  @override
  String get back => 'Zurück';

  @override
  String get historyTitle => 'Verlauf';

  @override
  String historyLoadError(String error) {
    return 'Verlauf konnte nicht geladen werden: $error';
  }

  @override
  String get deleteCheckTitle => 'Diesen Check löschen?';

  @override
  String get delete => 'Löschen';

  @override
  String get historyEmpty => 'Hier erscheint dein Check-Verlauf';

  @override
  String get historyEmptyCta => 'Mach deinen ersten Check';

  @override
  String checkLoadError(String error) {
    return 'Check konnte nicht geladen werden: $error';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get defaultUserName => 'Nutzer';

  @override
  String get subscriptionStatusLabel => 'Abo-Status';

  @override
  String proUntil(String date) {
    return 'Pro bis $date';
  }

  @override
  String get proStatus => 'Pro';

  @override
  String get freeStatus => 'Free';

  @override
  String get graceStatus => 'Kulanzzeitraum';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get comingSoon => 'Demnächst';

  @override
  String get language => 'Sprache';

  @override
  String get support => 'Support';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get upgradeToPro => 'Auf Pro upgraden';

  @override
  String get logoutConfirmTitle => 'Vom Konto abmelden?';

  @override
  String get logout => 'Abmelden';

  @override
  String get languagePickerTitle => 'Sprache wählen';

  @override
  String get languageSystemDefault => 'Systemstandard';

  @override
  String get shareNothingToShare => 'Nichts zu teilen';

  @override
  String get shareChallengeHook =>
      'Check deinen Look und markiere einen Freund 👀';

  @override
  String shareMessageText(int score, String id) {
    return 'Mein Look hat $score% Trend-Score bei Trendy Look erreicht! Check deinen: trendylook://check/$id';
  }

  @override
  String get paywallTitle => 'Unbegrenzt freischalten';

  @override
  String get paywallSubtitle => 'Jeden Tag unbegrenzt Looks checken';

  @override
  String get paywallSocialProof => 'Über 12.000 Checks heute';

  @override
  String get paywallContinue => 'Weiter';

  @override
  String get paywallRestore => 'Käufe wiederherstellen';

  @override
  String get paywallNotConfigured =>
      'Zahlungen sind noch nicht eingerichtet — RevenueCat-Schlüssel hinzufügen';

  @override
  String paywallPurchaseError(String error) {
    return 'Kauf konnte nicht abgeschlossen werden: $error';
  }

  @override
  String get paywallRestoreSuccess => 'Käufe wiederhergestellt';

  @override
  String paywallRestoreError(String error) {
    return 'Käufe konnten nicht wiederhergestellt werden: $error';
  }

  @override
  String paywallOfferError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get paywallSuccessTitle =>
      'Fertig! Du hast jetzt unbegrenzten Zugriff 🎉';

  @override
  String get paywallSuccessCta => 'Super';

  @override
  String get paywallPlanWeekly => 'Wöchentlich';

  @override
  String get paywallPlanHalfyear => 'Halbjährlich';

  @override
  String get paywallPeriodWeek => '7 Tage';

  @override
  String get paywallPeriodHalfyear => '6 Monate';

  @override
  String get paywallBenefit1 => 'Unbegrenzte Look-Checks';

  @override
  String get paywallBenefit2 => 'Priorisierte KI-Analyse';

  @override
  String get paywallBenefit3 => 'Früher Zugang zu Trends';

  @override
  String get paywallBestValue => 'BESTES ANGEBOT';

  @override
  String get promoCodeSectionTitle => 'Hast du einen Promo-Code?';

  @override
  String get promoCodeHint => 'Code eingeben';

  @override
  String get promoCodeApply => 'Anwenden';

  @override
  String promoRedeemedUntil(String date) {
    return 'Code angewendet! Pro-Zugang bis $date';
  }

  @override
  String get promoCodeNotFound => 'Dieser Promo-Code wurde nicht gefunden';

  @override
  String get promoCodeExpired => 'Dieser Code ist nicht mehr gültig';

  @override
  String get promoCodeExhausted => 'Dieser Code ist bereits aufgebraucht';

  @override
  String get promoCodeAlreadyRedeemed =>
      'Du hast diesen Code bereits eingelöst';

  @override
  String get promoRedeemError =>
      'Code konnte nicht angewendet werden. Versuch es noch mal';

  @override
  String get offlineBanner => 'Keine Verbindung';

  @override
  String get bottomTabHome => 'Start';

  @override
  String get bottomTabHistory => 'Verlauf';

  @override
  String get bottomTabProfile => 'Profil';

  @override
  String get categoryColorPalette => 'Farbpalette';

  @override
  String get categorySilhouette => 'Silhouette & Passform';

  @override
  String get categoryAccessories => 'Accessoires';

  @override
  String get categoryFootwear => 'Schuhe';
}
