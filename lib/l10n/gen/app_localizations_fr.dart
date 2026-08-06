// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get splashTagline => 'Ton styliste IA de poche';

  @override
  String get onboardingSlide1Title => 'Photographie\nton look';

  @override
  String get onboardingSlide1Subtitle =>
      'Une photo — et l\'IA décortique ton style';

  @override
  String get onboardingSlide2Title => 'Découvre ton % de tendance';

  @override
  String get onboardingSlide2Subtitle =>
      'Une évaluation honnête de ta tenue en quelques secondes';

  @override
  String get onboardingSlide3Title => 'Reçois des conseils de l\'IA';

  @override
  String get onboardingSlide3Subtitle =>
      'Des recommandations de style personnalisées';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get authSubtitle => 'Connecte-toi pour commencer';

  @override
  String get authTerms =>
      'En continuant, tu acceptes les Conditions et la Politique de confidentialité';

  @override
  String get authAppleButton => 'Se connecter avec Apple';

  @override
  String get authGoogleButton => 'Se connecter avec Google';

  @override
  String authSignInError(String error) {
    return 'Connexion impossible : $error';
  }

  @override
  String get homeTitle => 'Accueil';

  @override
  String get homeRecentChecks => 'Dernières analyses';

  @override
  String get homeRecentChecksEmpty => 'Ton historique apparaîtra ici';

  @override
  String get homeHeroTitle => 'Analyse ton look';

  @override
  String get homeHeroSubtitle =>
      'Découvre ton % de tendance et reçois des conseils de l\'IA';

  @override
  String get ctaCamera => 'Prendre une photo';

  @override
  String get ctaGallery => 'Depuis la galerie';

  @override
  String freeChecksLeft(int count) {
    return 'Analyses gratuites restantes : $count';
  }

  @override
  String get graceBannerText =>
      'Ton abonnement arrive à expiration — mets à jour ton moyen de paiement';

  @override
  String get graceBannerUpdate => 'Mettre à jour';

  @override
  String get cameraPermissionTitle => 'Pas d\'accès à l\'appareil photo';

  @override
  String get cameraPermissionMessage =>
      'Autorise l\'accès à l\'appareil photo dans les réglages pour analyser tes looks';

  @override
  String get cameraUnavailableMessage =>
      'L\'appareil photo n\'est pas disponible sur cet appareil';

  @override
  String get openSettings => 'Ouvrir les réglages';

  @override
  String get cancel => 'Annuler';

  @override
  String get retake => 'Reprendre la photo';

  @override
  String get confirm => 'Confirmer';

  @override
  String get loadingPhrase1 => 'Analyse des couleurs…';

  @override
  String get loadingPhrase2 => 'Comparaison avec les tendances 2026…';

  @override
  String get loadingPhrase3 => 'Évaluation de la silhouette…';

  @override
  String get loadingPhrase4 => 'Calcul du score final…';

  @override
  String get analysisErrorGeneric =>
      'Impossible d\'analyser la photo. Réessaie — cette analyse n\'a pas été décomptée.';

  @override
  String get rateLimitedMessage =>
      'Trop d\'analyses à la suite. Attends un peu puis réessaie.';

  @override
  String get fileTooLarge => 'Le fichier est trop volumineux (max. 10 Mo)';

  @override
  String get retry => 'Réessayer';

  @override
  String get recommendationsTitle => '💡 Recommandations';

  @override
  String get share => 'Partager';

  @override
  String get checkAgain => 'Recommencer';

  @override
  String get back => 'Retour';

  @override
  String get historyTitle => 'Historique';

  @override
  String historyLoadError(String error) {
    return 'Impossible de charger l\'historique : $error';
  }

  @override
  String get deleteCheckTitle => 'Supprimer cette analyse ?';

  @override
  String get delete => 'Supprimer';

  @override
  String get historyEmpty => 'Ton historique d\'analyses apparaîtra ici';

  @override
  String get historyEmptyCta => 'Fais ta première analyse';

  @override
  String checkLoadError(String error) {
    return 'Impossible de charger l\'analyse : $error';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get defaultUserName => 'Utilisateur';

  @override
  String get subscriptionStatusLabel => 'Statut de l\'abonnement';

  @override
  String proUntil(String date) {
    return 'Pro jusqu\'au $date';
  }

  @override
  String get proStatus => 'Pro';

  @override
  String get freeStatus => 'Gratuit';

  @override
  String get graceStatus => 'Période de grâce';

  @override
  String get notifications => 'Notifications';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get language => 'Langue';

  @override
  String get support => 'Assistance';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get upgradeToPro => 'Passer à Pro';

  @override
  String get logoutConfirmTitle => 'Se déconnecter du compte ?';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get languagePickerTitle => 'Choisir la langue';

  @override
  String get languageSystemDefault => 'Paramètres système';

  @override
  String get shareNothingToShare => 'Rien à partager';

  @override
  String get shareChallengeHook => 'Analyse ton look et identifie un ami 👀';

  @override
  String shareMessageText(int score, String id) {
    return 'Mon look a obtenu $score% de tendance sur Trendy Look ! Vérifie le tien : trendylook://check/$id';
  }

  @override
  String get paywallTitle => 'Débloque l\'illimité';

  @override
  String get paywallSubtitle => 'Des analyses de tenues illimitées chaque jour';

  @override
  String get paywallSocialProof => 'Plus de 12 000 analyses aujourd\'hui';

  @override
  String get paywallContinue => 'Continuer';

  @override
  String get paywallRestore => 'Restaurer les achats';

  @override
  String get paywallNotConfigured =>
      'Les paiements ne sont pas encore configurés — ajoute les clés RevenueCat';

  @override
  String paywallPurchaseError(String error) {
    return 'Impossible de finaliser l\'achat : $error';
  }

  @override
  String get paywallRestoreSuccess => 'Achats restaurés';

  @override
  String paywallRestoreError(String error) {
    return 'Impossible de restaurer les achats : $error';
  }

  @override
  String paywallOfferError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get paywallSuccessTitle =>
      'C\'est fait ! Tu as maintenant un accès illimité 🎉';

  @override
  String get paywallSuccessCta => 'Super';

  @override
  String get paywallPlanWeekly => 'Hebdomadaire';

  @override
  String get paywallPlanHalfyear => 'Semestriel';

  @override
  String get paywallPeriodWeek => '7 jours';

  @override
  String get paywallPeriodHalfyear => '6 mois';

  @override
  String get paywallBenefit1 => 'Analyses de tenues illimitées';

  @override
  String get paywallBenefit2 => 'Analyse IA prioritaire';

  @override
  String get paywallBenefit3 => 'Accès anticipé aux tendances';

  @override
  String get paywallBestValue => 'MEILLEURE OFFRE';

  @override
  String get offlineBanner => 'Pas de connexion';

  @override
  String get bottomTabHome => 'Accueil';

  @override
  String get bottomTabHistory => 'Historique';

  @override
  String get bottomTabProfile => 'Profil';

  @override
  String get categoryColorPalette => 'Palette de couleurs';

  @override
  String get categorySilhouette => 'Silhouette et coupe';

  @override
  String get categoryAccessories => 'Accessoires';

  @override
  String get categoryFootwear => 'Chaussures';
}
