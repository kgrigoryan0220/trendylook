// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get splashTagline => 'AI-стилист в кармане';

  @override
  String get onboardingSlide1Title => 'Сфотографируй\nсвой лук';

  @override
  String get onboardingSlide1Subtitle => 'Одно фото — и AI разберёт твой стиль';

  @override
  String get onboardingSlide2Title => 'Узнай % трендовости';

  @override
  String get onboardingSlide2Subtitle => 'Честная оценка образа за секунды';

  @override
  String get onboardingSlide3Title => 'Получи советы от AI';

  @override
  String get onboardingSlide3Subtitle => 'Персональные рекомендации по стилю';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get authSubtitle => 'Войди, чтобы начать';

  @override
  String get authTerms =>
      'Продолжая, ты соглашаешься с Условиями и Конфиденциальностью';

  @override
  String get authAppleButton => 'Войти через Apple';

  @override
  String get authGoogleButton => 'Войти через Google';

  @override
  String authSignInError(String error) {
    return 'Не получилось войти: $error';
  }

  @override
  String get homeTitle => 'Главная';

  @override
  String get homeRecentChecks => 'Последние проверки';

  @override
  String get homeRecentChecksEmpty => 'Здесь появится твоя история';

  @override
  String get homeHeroTitle => 'Проверь свой лук';

  @override
  String get homeHeroSubtitle => 'Узнай % трендовости и получи советы от AI';

  @override
  String get ctaCamera => 'Сфотографировать';

  @override
  String get ctaGallery => 'Из галереи';

  @override
  String freeChecksLeft(int count) {
    return 'Осталось бесплатных проверок: $count';
  }

  @override
  String get graceBannerText => 'Подписка истекает — обнови способ оплаты';

  @override
  String get graceBannerUpdate => 'Обновить';

  @override
  String get cameraPermissionTitle => 'Нет доступа к камере';

  @override
  String get cameraPermissionMessage =>
      'Разреши доступ к камере в настройках, чтобы проверять образы';

  @override
  String get cameraUnavailableMessage => 'Камера недоступна на этом устройстве';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get cancel => 'Отмена';

  @override
  String get retake => 'Пересъёмка';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get loadingPhrase1 => 'Анализируем цвета…';

  @override
  String get loadingPhrase2 => 'Сверяем с трендами 2026…';

  @override
  String get loadingPhrase3 => 'Оцениваем силуэт…';

  @override
  String get loadingPhrase4 => 'Считаем итоговый score…';

  @override
  String get analysisErrorGeneric =>
      'Не получилось проанализировать фото. Попробуй ещё раз — проверка не списана.';

  @override
  String get rateLimitedMessage =>
      'Слишком много проверок подряд. Подожди немного и попробуй снова.';

  @override
  String get fileTooLarge => 'Файл слишком большой (макс. 10 MB)';

  @override
  String get retry => 'Повторить';

  @override
  String get recommendationsTitle => '💡 Рекомендации';

  @override
  String get share => 'Поделиться';

  @override
  String get checkAgain => 'Ещё раз';

  @override
  String get back => 'Назад';

  @override
  String get historyTitle => 'История';

  @override
  String historyLoadError(String error) {
    return 'Не удалось загрузить историю: $error';
  }

  @override
  String get deleteCheckTitle => 'Удалить эту проверку?';

  @override
  String get delete => 'Удалить';

  @override
  String get historyEmpty => 'Здесь появится твоя история проверок';

  @override
  String get historyEmptyCta => 'Сделать первую проверку';

  @override
  String checkLoadError(String error) {
    return 'Не удалось загрузить проверку: $error';
  }

  @override
  String get profileTitle => 'Профиль';

  @override
  String get defaultUserName => 'Пользователь';

  @override
  String get subscriptionStatusLabel => 'Статус подписки';

  @override
  String proUntil(String date) {
    return 'Pro до $date';
  }

  @override
  String get proStatus => 'Pro';

  @override
  String get freeStatus => 'Free';

  @override
  String get graceStatus => 'Grace period';

  @override
  String get notifications => 'Уведомления';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get language => 'Язык';

  @override
  String get support => 'Поддержка';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get upgradeToPro => 'Перейти на Pro';

  @override
  String get logoutConfirmTitle => 'Выйти из аккаунта?';

  @override
  String get logout => 'Выйти';

  @override
  String get languagePickerTitle => 'Выбери язык';

  @override
  String get languageSystemDefault => 'Как в системе';

  @override
  String get shareNothingToShare => 'Нечем делиться';

  @override
  String get shareChallengeHook => 'Проверь свой лук и отметь друга 👀';

  @override
  String shareMessageText(int score, String id) {
    return 'Мой лук получил $score% трендовости в Trendy Look! Проверь свой: trendylook://check/$id';
  }

  @override
  String get paywallTitle => 'Открой безлимит';

  @override
  String get paywallSubtitle => 'Безграничные проверки образов каждый день';

  @override
  String get paywallSocialProof => '12 000+ проверок сегодня';

  @override
  String get paywallContinue => 'Продолжить';

  @override
  String get paywallRestore => 'Восстановить покупки';

  @override
  String get paywallNotConfigured =>
      'Оплата ещё не настроена — добавьте ключи RevenueCat';

  @override
  String paywallPurchaseError(String error) {
    return 'Не получилось оформить подписку: $error';
  }

  @override
  String get paywallRestoreSuccess => 'Покупки восстановлены';

  @override
  String paywallRestoreError(String error) {
    return 'Не получилось восстановить покупки: $error';
  }

  @override
  String paywallOfferError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get paywallSuccessTitle => 'Готово! Теперь у тебя безлимит 🎉';

  @override
  String get paywallSuccessCta => 'Отлично';

  @override
  String get paywallPlanWeekly => 'Weekly';

  @override
  String get paywallPlanHalfyear => 'Half-year';

  @override
  String get paywallPeriodWeek => '7 дней';

  @override
  String get paywallPeriodHalfyear => '6 месяцев';

  @override
  String get paywallBenefit1 => 'Безлимитные проверки образов';

  @override
  String get paywallBenefit2 => 'Приоритетный AI-анализ';

  @override
  String get paywallBenefit3 => 'Ранний доступ к трендам';

  @override
  String get paywallBestValue => 'BEST VALUE';

  @override
  String get offlineBanner => 'Нет соединения';

  @override
  String get bottomTabHome => 'Главная';

  @override
  String get bottomTabHistory => 'История';

  @override
  String get bottomTabProfile => 'Профиль';

  @override
  String get categoryColorPalette => 'Цветовая палитра';

  @override
  String get categorySilhouette => 'Силуэт и посадка';

  @override
  String get categoryAccessories => 'Аксессуары';

  @override
  String get categoryFootwear => 'Обувь';
}
