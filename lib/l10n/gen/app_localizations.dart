import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
  ];

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'AI stylist in your pocket'**
  String get splashTagline;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Take a photo\nof your look'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'One photo — and AI will break down your style'**
  String get onboardingSlide1Subtitle;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Discover your trend %'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'An honest outfit rating in seconds'**
  String get onboardingSlide2Subtitle;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Get AI style advice'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized recommendations for your style'**
  String get onboardingSlide3Subtitle;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to get started'**
  String get authSubtitle;

  /// No description provided for @authTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to the Terms and Privacy Policy'**
  String get authTerms;

  /// No description provided for @authAppleButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get authAppleButton;

  /// No description provided for @authGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authGoogleButton;

  /// No description provided for @authSignInError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in: {error}'**
  String authSignInError(String error);

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeRecentChecks.
  ///
  /// In en, this message translates to:
  /// **'Recent checks'**
  String get homeRecentChecks;

  /// No description provided for @homeRecentChecksEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your history will appear here'**
  String get homeRecentChecksEmpty;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your look'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover your trend % and get AI advice'**
  String get homeHeroSubtitle;

  /// No description provided for @ctaCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get ctaCamera;

  /// No description provided for @ctaGallery.
  ///
  /// In en, this message translates to:
  /// **'From gallery'**
  String get ctaGallery;

  /// No description provided for @freeChecksLeft.
  ///
  /// In en, this message translates to:
  /// **'Free checks left: {count}'**
  String freeChecksLeft(int count);

  /// No description provided for @graceBannerText.
  ///
  /// In en, this message translates to:
  /// **'Your subscription is expiring — update your payment method'**
  String get graceBannerText;

  /// No description provided for @graceBannerUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get graceBannerUpdate;

  /// No description provided for @cameraPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'No camera access'**
  String get cameraPermissionTitle;

  /// No description provided for @cameraPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access in Settings to check your looks'**
  String get cameraPermissionMessage;

  /// No description provided for @cameraUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Camera is not available on this device'**
  String get cameraUnavailableMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @loadingPhrase1.
  ///
  /// In en, this message translates to:
  /// **'Analyzing colors…'**
  String get loadingPhrase1;

  /// No description provided for @loadingPhrase2.
  ///
  /// In en, this message translates to:
  /// **'Comparing with 2026 trends…'**
  String get loadingPhrase2;

  /// No description provided for @loadingPhrase3.
  ///
  /// In en, this message translates to:
  /// **'Evaluating silhouette…'**
  String get loadingPhrase3;

  /// No description provided for @loadingPhrase4.
  ///
  /// In en, this message translates to:
  /// **'Calculating final score…'**
  String get loadingPhrase4;

  /// No description provided for @analysisErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t analyze the photo. Try again — this check wasn\'t used.'**
  String get analysisErrorGeneric;

  /// No description provided for @rateLimitedMessage.
  ///
  /// In en, this message translates to:
  /// **'Too many checks in a row. Wait a bit and try again.'**
  String get rateLimitedMessage;

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File is too large (max 10 MB)'**
  String get fileTooLarge;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @recommendationsTitle.
  ///
  /// In en, this message translates to:
  /// **'💡 Recommendations'**
  String get recommendationsTitle;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get checkAgain;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load history: {error}'**
  String historyLoadError(String error);

  /// No description provided for @deleteCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this check?'**
  String get deleteCheckTitle;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your check history will appear here'**
  String get historyEmpty;

  /// No description provided for @historyEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Do your first check'**
  String get historyEmptyCta;

  /// No description provided for @checkLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the check: {error}'**
  String checkLoadError(String error);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;

  /// No description provided for @subscriptionStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Subscription status'**
  String get subscriptionStatusLabel;

  /// No description provided for @proUntil.
  ///
  /// In en, this message translates to:
  /// **'Pro until {date}'**
  String proUntil(String date);

  /// No description provided for @proStatus.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get proStatus;

  /// No description provided for @freeStatus.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeStatus;

  /// No description provided for @graceStatus.
  ///
  /// In en, this message translates to:
  /// **'Grace period'**
  String get graceStatus;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of your account?'**
  String get logoutConfirmTitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get languagePickerTitle;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @shareNothingToShare.
  ///
  /// In en, this message translates to:
  /// **'Nothing to share'**
  String get shareNothingToShare;

  /// No description provided for @shareChallengeHook.
  ///
  /// In en, this message translates to:
  /// **'Check your look and tag a friend 👀'**
  String get shareChallengeHook;

  /// No description provided for @shareMessageText.
  ///
  /// In en, this message translates to:
  /// **'My look got {score}% trendiness on Trendy Look! Check yours: trendylook://check/{id}'**
  String shareMessageText(int score, String id);

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited outfit checks every day'**
  String get paywallSubtitle;

  /// No description provided for @paywallSocialProof.
  ///
  /// In en, this message translates to:
  /// **'12,000+ checks today'**
  String get paywallSocialProof;

  /// No description provided for @paywallContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get paywallContinue;

  /// No description provided for @paywallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestore;

  /// No description provided for @paywallNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Payments aren\'t set up yet — add RevenueCat keys'**
  String get paywallNotConfigured;

  /// No description provided for @paywallPurchaseError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t complete the purchase: {error}'**
  String paywallPurchaseError(String error);

  /// No description provided for @paywallRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored'**
  String get paywallRestoreSuccess;

  /// No description provided for @paywallRestoreError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore purchases: {error}'**
  String paywallRestoreError(String error);

  /// No description provided for @paywallOfferError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String paywallOfferError(String error);

  /// No description provided for @paywallSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Done! You now have unlimited access 🎉'**
  String get paywallSuccessTitle;

  /// No description provided for @paywallSuccessCta.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get paywallSuccessCta;

  /// No description provided for @paywallPlanWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get paywallPlanWeekly;

  /// No description provided for @paywallPlanHalfyear.
  ///
  /// In en, this message translates to:
  /// **'Half-year'**
  String get paywallPlanHalfyear;

  /// No description provided for @paywallPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get paywallPeriodWeek;

  /// No description provided for @paywallPeriodHalfyear.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get paywallPeriodHalfyear;

  /// No description provided for @paywallBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Unlimited outfit checks'**
  String get paywallBenefit1;

  /// No description provided for @paywallBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Priority AI analysis'**
  String get paywallBenefit2;

  /// No description provided for @paywallBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Early access to trends'**
  String get paywallBenefit3;

  /// No description provided for @paywallBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get paywallBestValue;

  /// No description provided for @promoCodeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Have a promo code?'**
  String get promoCodeSectionTitle;

  /// No description provided for @promoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get promoCodeHint;

  /// No description provided for @promoCodeApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get promoCodeApply;

  /// No description provided for @promoRedeemedUntil.
  ///
  /// In en, this message translates to:
  /// **'Promo code applied! Pro access until {date}'**
  String promoRedeemedUntil(String date);

  /// No description provided for @promoCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'This promo code wasn\'t found'**
  String get promoCodeNotFound;

  /// No description provided for @promoCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This promo code is no longer valid'**
  String get promoCodeExpired;

  /// No description provided for @promoCodeExhausted.
  ///
  /// In en, this message translates to:
  /// **'This promo code has been fully redeemed'**
  String get promoCodeExhausted;

  /// No description provided for @promoCodeAlreadyRedeemed.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already redeemed this code'**
  String get promoCodeAlreadyRedeemed;

  /// No description provided for @promoRedeemError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t apply the promo code. Try again'**
  String get promoRedeemError;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get offlineBanner;

  /// No description provided for @bottomTabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomTabHome;

  /// No description provided for @bottomTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get bottomTabHistory;

  /// No description provided for @bottomTabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get bottomTabProfile;

  /// No description provided for @categoryColorPalette.
  ///
  /// In en, this message translates to:
  /// **'Color palette'**
  String get categoryColorPalette;

  /// No description provided for @categorySilhouette.
  ///
  /// In en, this message translates to:
  /// **'Silhouette & fit'**
  String get categorySilhouette;

  /// No description provided for @categoryAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get categoryAccessories;

  /// No description provided for @categoryFootwear.
  ///
  /// In en, this message translates to:
  /// **'Footwear'**
  String get categoryFootwear;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
