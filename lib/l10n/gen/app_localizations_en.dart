// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get splashTagline => 'AI stylist in your pocket';

  @override
  String get onboardingSlide1Title => 'Take a photo\nof your look';

  @override
  String get onboardingSlide1Subtitle =>
      'One photo — and AI will break down your style';

  @override
  String get onboardingSlide2Title => 'Discover your trend %';

  @override
  String get onboardingSlide2Subtitle => 'An honest outfit rating in seconds';

  @override
  String get onboardingSlide3Title => 'Get AI style advice';

  @override
  String get onboardingSlide3Subtitle =>
      'Personalized recommendations for your style';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get authSubtitle => 'Sign in to get started';

  @override
  String get authTerms =>
      'By continuing, you agree to the Terms and Privacy Policy';

  @override
  String get authAppleButton => 'Sign in with Apple';

  @override
  String get authGoogleButton => 'Sign in with Google';

  @override
  String authSignInError(String error) {
    return 'Couldn\'t sign in: $error';
  }

  @override
  String get homeTitle => 'Home';

  @override
  String get homeRecentChecks => 'Recent checks';

  @override
  String get homeRecentChecksEmpty => 'Your history will appear here';

  @override
  String get homeHeroTitle => 'Check your look';

  @override
  String get homeHeroSubtitle => 'Discover your trend % and get AI advice';

  @override
  String get ctaCamera => 'Take a photo';

  @override
  String get ctaGallery => 'From gallery';

  @override
  String freeChecksLeft(int count) {
    return 'Free checks left: $count';
  }

  @override
  String get graceBannerText =>
      'Your subscription is expiring — update your payment method';

  @override
  String get graceBannerUpdate => 'Update';

  @override
  String get cameraPermissionTitle => 'No camera access';

  @override
  String get cameraPermissionMessage =>
      'Allow camera access in Settings to check your looks';

  @override
  String get cameraUnavailableMessage =>
      'Camera is not available on this device';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get retake => 'Retake';

  @override
  String get confirm => 'Confirm';

  @override
  String get loadingPhrase1 => 'Analyzing colors…';

  @override
  String get loadingPhrase2 => 'Comparing with 2026 trends…';

  @override
  String get loadingPhrase3 => 'Evaluating silhouette…';

  @override
  String get loadingPhrase4 => 'Calculating final score…';

  @override
  String get analysisErrorGeneric =>
      'Couldn\'t analyze the photo. Try again — this check wasn\'t used.';

  @override
  String get rateLimitedMessage =>
      'Too many checks in a row. Wait a bit and try again.';

  @override
  String get fileTooLarge => 'File is too large (max 10 MB)';

  @override
  String get retry => 'Retry';

  @override
  String get recommendationsTitle => '💡 Recommendations';

  @override
  String get share => 'Share';

  @override
  String get checkAgain => 'Check again';

  @override
  String get back => 'Back';

  @override
  String get historyTitle => 'History';

  @override
  String historyLoadError(String error) {
    return 'Couldn\'t load history: $error';
  }

  @override
  String get deleteCheckTitle => 'Delete this check?';

  @override
  String get delete => 'Delete';

  @override
  String get historyEmpty => 'Your check history will appear here';

  @override
  String get historyEmptyCta => 'Do your first check';

  @override
  String checkLoadError(String error) {
    return 'Couldn\'t load the check: $error';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get defaultUserName => 'User';

  @override
  String get subscriptionStatusLabel => 'Subscription status';

  @override
  String proUntil(String date) {
    return 'Pro until $date';
  }

  @override
  String get proStatus => 'Pro';

  @override
  String get freeStatus => 'Free';

  @override
  String get graceStatus => 'Grace period';

  @override
  String get notifications => 'Notifications';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get language => 'Language';

  @override
  String get support => 'Support';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get upgradeToPro => 'Upgrade to Pro';

  @override
  String get logoutConfirmTitle => 'Log out of your account?';

  @override
  String get logout => 'Log out';

  @override
  String get languagePickerTitle => 'Choose language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get shareNothingToShare => 'Nothing to share';

  @override
  String get shareChallengeHook => 'Check your look and tag a friend 👀';

  @override
  String shareMessageText(int score, String id) {
    return 'My look got $score% trendiness on Trendy Look! Check yours: trendylook://check/$id';
  }

  @override
  String get paywallTitle => 'Unlock unlimited';

  @override
  String get paywallSubtitle => 'Unlimited outfit checks every day';

  @override
  String get paywallSocialProof => '12,000+ checks today';

  @override
  String get paywallContinue => 'Continue';

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallNotConfigured =>
      'Payments aren\'t set up yet — add RevenueCat keys';

  @override
  String paywallPurchaseError(String error) {
    return 'Couldn\'t complete the purchase: $error';
  }

  @override
  String get paywallRestoreSuccess => 'Purchases restored';

  @override
  String paywallRestoreError(String error) {
    return 'Couldn\'t restore purchases: $error';
  }

  @override
  String paywallOfferError(String error) {
    return 'Error: $error';
  }

  @override
  String get paywallSuccessTitle => 'Done! You now have unlimited access 🎉';

  @override
  String get paywallSuccessCta => 'Great';

  @override
  String get paywallPlanWeekly => 'Weekly';

  @override
  String get paywallPlanHalfyear => 'Half-year';

  @override
  String get paywallPeriodWeek => '7 days';

  @override
  String get paywallPeriodHalfyear => '6 months';

  @override
  String get paywallBenefit1 => 'Unlimited outfit checks';

  @override
  String get paywallBenefit2 => 'Priority AI analysis';

  @override
  String get paywallBenefit3 => 'Early access to trends';

  @override
  String get paywallBestValue => 'BEST VALUE';

  @override
  String get promoCodeSectionTitle => 'Have a promo code?';

  @override
  String get promoCodeHint => 'Enter code';

  @override
  String get promoCodeApply => 'Apply';

  @override
  String promoRedeemedUntil(String date) {
    return 'Promo code applied! Pro access until $date';
  }

  @override
  String get promoCodeNotFound => 'This promo code wasn\'t found';

  @override
  String get promoCodeExpired => 'This promo code is no longer valid';

  @override
  String get promoCodeExhausted => 'This promo code has been fully redeemed';

  @override
  String get promoCodeAlreadyRedeemed => 'You\'ve already redeemed this code';

  @override
  String get promoRedeemError => 'Couldn\'t apply the promo code. Try again';

  @override
  String get offlineBanner => 'No connection';

  @override
  String get bottomTabHome => 'Home';

  @override
  String get bottomTabHistory => 'History';

  @override
  String get bottomTabProfile => 'Profile';

  @override
  String get categoryColorPalette => 'Color palette';

  @override
  String get categorySilhouette => 'Silhouette & fit';

  @override
  String get categoryAccessories => 'Accessories';

  @override
  String get categoryFootwear => 'Footwear';
}
