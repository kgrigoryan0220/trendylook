// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get splashTagline => 'Il tuo stylist IA tascabile';

  @override
  String get onboardingSlide1Title => 'Fotografa\nil tuo look';

  @override
  String get onboardingSlide1Subtitle =>
      'Una foto — e l\'IA analizza il tuo stile';

  @override
  String get onboardingSlide2Title => 'Scopri la tua % di tendenza';

  @override
  String get onboardingSlide2Subtitle =>
      'Una valutazione onesta del look in pochi secondi';

  @override
  String get onboardingSlide3Title => 'Ricevi consigli dall\'IA';

  @override
  String get onboardingSlide3Subtitle =>
      'Raccomandazioni di stile personalizzate';

  @override
  String get onboardingNext => 'Avanti';

  @override
  String get onboardingStart => 'Inizia';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get authSubtitle => 'Accedi per iniziare';

  @override
  String get authTerms => 'Continuando, accetti i Termini e la Privacy Policy';

  @override
  String get authAppleButton => 'Accedi con Apple';

  @override
  String get authGoogleButton => 'Accedi con Google';

  @override
  String authSignInError(String error) {
    return 'Accesso non riuscito: $error';
  }

  @override
  String get homeTitle => 'Home';

  @override
  String get homeRecentChecks => 'Controlli recenti';

  @override
  String get homeRecentChecksEmpty => 'Qui apparirà la tua cronologia';

  @override
  String get homeHeroTitle => 'Controlla il tuo look';

  @override
  String get homeHeroSubtitle =>
      'Scopri la tua % di tendenza e ricevi consigli dall\'IA';

  @override
  String get ctaCamera => 'Scatta una foto';

  @override
  String get ctaGallery => 'Dalla galleria';

  @override
  String freeChecksLeft(int count) {
    return 'Controlli gratuiti rimasti: $count';
  }

  @override
  String get graceBannerText =>
      'Il tuo abbonamento sta per scadere — aggiorna il metodo di pagamento';

  @override
  String get graceBannerUpdate => 'Aggiorna';

  @override
  String get cameraPermissionTitle => 'Nessun accesso alla fotocamera';

  @override
  String get cameraPermissionMessage =>
      'Consenti l\'accesso alla fotocamera nelle Impostazioni per controllare i tuoi look';

  @override
  String get cameraUnavailableMessage =>
      'La fotocamera non è disponibile su questo dispositivo';

  @override
  String get openSettings => 'Apri Impostazioni';

  @override
  String get cancel => 'Annulla';

  @override
  String get retake => 'Rifai la foto';

  @override
  String get confirm => 'Conferma';

  @override
  String get loadingPhrase1 => 'Analisi dei colori…';

  @override
  String get loadingPhrase2 => 'Confronto con le tendenze 2026…';

  @override
  String get loadingPhrase3 => 'Valutazione della silhouette…';

  @override
  String get loadingPhrase4 => 'Calcolo del punteggio finale…';

  @override
  String get analysisErrorGeneric =>
      'Impossibile analizzare la foto. Riprova — questo controllo non è stato conteggiato.';

  @override
  String get rateLimitedMessage =>
      'Troppi controlli di fila. Aspetta un attimo e riprova.';

  @override
  String get fileTooLarge => 'Il file è troppo grande (max 10 MB)';

  @override
  String get retry => 'Riprova';

  @override
  String get recommendationsTitle => '💡 Consigli';

  @override
  String get share => 'Condividi';

  @override
  String get checkAgain => 'Rifai il controllo';

  @override
  String get back => 'Indietro';

  @override
  String get historyTitle => 'Cronologia';

  @override
  String historyLoadError(String error) {
    return 'Impossibile caricare la cronologia: $error';
  }

  @override
  String get deleteCheckTitle => 'Eliminare questo controllo?';

  @override
  String get delete => 'Elimina';

  @override
  String get historyEmpty => 'Qui apparirà la cronologia dei tuoi controlli';

  @override
  String get historyEmptyCta => 'Fai il tuo primo controllo';

  @override
  String checkLoadError(String error) {
    return 'Impossibile caricare il controllo: $error';
  }

  @override
  String get profileTitle => 'Profilo';

  @override
  String get defaultUserName => 'Utente';

  @override
  String get subscriptionStatusLabel => 'Stato dell\'abbonamento';

  @override
  String proUntil(String date) {
    return 'Pro fino al $date';
  }

  @override
  String get proStatus => 'Pro';

  @override
  String get freeStatus => 'Free';

  @override
  String get graceStatus => 'Periodo di grazia';

  @override
  String get notifications => 'Notifiche';

  @override
  String get comingSoon => 'Presto';

  @override
  String get language => 'Lingua';

  @override
  String get support => 'Assistenza';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get termsOfService => 'Termini di servizio';

  @override
  String get upgradeToPro => 'Passa a Pro';

  @override
  String get logoutConfirmTitle => 'Uscire dall\'account?';

  @override
  String get logout => 'Esci';

  @override
  String get languagePickerTitle => 'Scegli la lingua';

  @override
  String get languageSystemDefault => 'Predefinito di sistema';

  @override
  String get shareNothingToShare => 'Niente da condividere';

  @override
  String get shareChallengeHook => 'Controlla il tuo look e tagga un amico 👀';

  @override
  String shareMessageText(int score, String id) {
    return 'Il mio look ha ottenuto $score% di trendiness su Trendy Look! Controlla il tuo: trendylook://check/$id';
  }

  @override
  String get paywallTitle => 'Sblocca l\'illimitato';

  @override
  String get paywallSubtitle => 'Controlli look illimitati ogni giorno';

  @override
  String get paywallSocialProof => 'Oltre 12.000 controlli oggi';

  @override
  String get paywallContinue => 'Continua';

  @override
  String get paywallRestore => 'Ripristina acquisti';

  @override
  String get paywallNotConfigured =>
      'I pagamenti non sono ancora configurati — aggiungi le chiavi RevenueCat';

  @override
  String paywallPurchaseError(String error) {
    return 'Impossibile completare l\'acquisto: $error';
  }

  @override
  String get paywallRestoreSuccess => 'Acquisti ripristinati';

  @override
  String paywallRestoreError(String error) {
    return 'Impossibile ripristinare gli acquisti: $error';
  }

  @override
  String paywallOfferError(String error) {
    return 'Errore: $error';
  }

  @override
  String get paywallSuccessTitle => 'Fatto! Ora hai accesso illimitato 🎉';

  @override
  String get paywallSuccessCta => 'Ottimo';

  @override
  String get paywallPlanWeekly => 'Settimanale';

  @override
  String get paywallPlanHalfyear => 'Semestrale';

  @override
  String get paywallPeriodWeek => '7 giorni';

  @override
  String get paywallPeriodHalfyear => '6 mesi';

  @override
  String get paywallBenefit1 => 'Controlli look illimitati';

  @override
  String get paywallBenefit2 => 'Analisi IA prioritaria';

  @override
  String get paywallBenefit3 => 'Accesso anticipato alle tendenze';

  @override
  String get paywallBestValue => 'MIGLIOR OFFERTA';

  @override
  String get promoCodeSectionTitle => 'Hai un codice promozionale?';

  @override
  String get promoCodeHint => 'Inserisci il codice';

  @override
  String get promoCodeApply => 'Applica';

  @override
  String promoRedeemedUntil(String date) {
    return 'Codice applicato! Accesso Pro fino al $date';
  }

  @override
  String get promoCodeNotFound => 'Codice promozionale non trovato';

  @override
  String get promoCodeExpired => 'Questo codice non è più valido';

  @override
  String get promoCodeExhausted => 'Questo codice è esaurito';

  @override
  String get promoCodeAlreadyRedeemed => 'Hai già usato questo codice';

  @override
  String get promoRedeemError => 'Impossibile applicare il codice. Riprova';

  @override
  String get offlineBanner => 'Nessuna connessione';

  @override
  String get bottomTabHome => 'Home';

  @override
  String get bottomTabHistory => 'Cronologia';

  @override
  String get bottomTabProfile => 'Profilo';

  @override
  String get categoryColorPalette => 'Palette colori';

  @override
  String get categorySilhouette => 'Silhouette e vestibilità';

  @override
  String get categoryAccessories => 'Accessori';

  @override
  String get categoryFootwear => 'Calzature';
}
