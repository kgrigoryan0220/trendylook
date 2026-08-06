// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get splashTagline => 'Seu estilista de IA de bolso';

  @override
  String get onboardingSlide1Title => 'Fotografe\nseu look';

  @override
  String get onboardingSlide1Subtitle => 'Uma foto — e a IA analisa seu estilo';

  @override
  String get onboardingSlide2Title => 'Descubra seu % de tendência';

  @override
  String get onboardingSlide2Subtitle =>
      'Uma avaliação honesta do look em segundos';

  @override
  String get onboardingSlide3Title => 'Receba dicas da IA';

  @override
  String get onboardingSlide3Subtitle =>
      'Recomendações de estilo personalizadas';

  @override
  String get onboardingNext => 'Avançar';

  @override
  String get onboardingStart => 'Começar';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get authSubtitle => 'Entre para começar';

  @override
  String get authTerms =>
      'Ao continuar, você concorda com os Termos e a Política de Privacidade';

  @override
  String get authAppleButton => 'Entrar com a Apple';

  @override
  String get authGoogleButton => 'Entrar com o Google';

  @override
  String authSignInError(String error) {
    return 'Não foi possível entrar: $error';
  }

  @override
  String get homeTitle => 'Início';

  @override
  String get homeRecentChecks => 'Verificações recentes';

  @override
  String get homeRecentChecksEmpty => 'Seu histórico vai aparecer aqui';

  @override
  String get homeHeroTitle => 'Verifique seu look';

  @override
  String get homeHeroSubtitle =>
      'Descubra seu % de tendência e receba dicas da IA';

  @override
  String get ctaCamera => 'Tirar uma foto';

  @override
  String get ctaGallery => 'Da galeria';

  @override
  String freeChecksLeft(int count) {
    return 'Verificações gratuitas restantes: $count';
  }

  @override
  String get graceBannerText =>
      'Sua assinatura está expirando — atualize sua forma de pagamento';

  @override
  String get graceBannerUpdate => 'Atualizar';

  @override
  String get cameraPermissionTitle => 'Sem acesso à câmera';

  @override
  String get cameraPermissionMessage =>
      'Permita o acesso à câmera nas Configurações para verificar seus looks';

  @override
  String get cameraUnavailableMessage =>
      'A câmera não está disponível neste dispositivo';

  @override
  String get openSettings => 'Abrir Configurações';

  @override
  String get cancel => 'Cancelar';

  @override
  String get retake => 'Tirar novamente';

  @override
  String get confirm => 'Confirmar';

  @override
  String get loadingPhrase1 => 'Analisando as cores…';

  @override
  String get loadingPhrase2 => 'Comparando com as tendências de 2026…';

  @override
  String get loadingPhrase3 => 'Avaliando a silhueta…';

  @override
  String get loadingPhrase4 => 'Calculando o resultado final…';

  @override
  String get analysisErrorGeneric =>
      'Não foi possível analisar a foto. Tente novamente — esta verificação não foi descontada.';

  @override
  String get rateLimitedMessage =>
      'Muitas verificações seguidas. Espere um pouco e tente novamente.';

  @override
  String get fileTooLarge => 'O arquivo é muito grande (máx. 10 MB)';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get recommendationsTitle => '💡 Recomendações';

  @override
  String get share => 'Compartilhar';

  @override
  String get checkAgain => 'Verificar de novo';

  @override
  String get back => 'Voltar';

  @override
  String get historyTitle => 'Histórico';

  @override
  String historyLoadError(String error) {
    return 'Não foi possível carregar o histórico: $error';
  }

  @override
  String get deleteCheckTitle => 'Excluir esta verificação?';

  @override
  String get delete => 'Excluir';

  @override
  String get historyEmpty => 'Seu histórico de verificações vai aparecer aqui';

  @override
  String get historyEmptyCta => 'Faça sua primeira verificação';

  @override
  String checkLoadError(String error) {
    return 'Não foi possível carregar a verificação: $error';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get defaultUserName => 'Usuário';

  @override
  String get subscriptionStatusLabel => 'Status da assinatura';

  @override
  String proUntil(String date) {
    return 'Pro até $date';
  }

  @override
  String get proStatus => 'Pro';

  @override
  String get freeStatus => 'Grátis';

  @override
  String get graceStatus => 'Período de carência';

  @override
  String get notifications => 'Notificações';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get language => 'Idioma';

  @override
  String get support => 'Suporte';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get termsOfService => 'Termos de Uso';

  @override
  String get upgradeToPro => 'Assinar o Pro';

  @override
  String get logoutConfirmTitle => 'Sair da conta?';

  @override
  String get logout => 'Sair';

  @override
  String get languagePickerTitle => 'Escolha o idioma';

  @override
  String get languageSystemDefault => 'Padrão do sistema';

  @override
  String get shareNothingToShare => 'Nada para compartilhar';

  @override
  String get shareChallengeHook => 'Verifique seu look e marque um amigo 👀';

  @override
  String shareMessageText(int score, String id) {
    return 'Meu look teve $score% de trendiness no Trendy Look! Confira o seu: trendylook://check/$id';
  }

  @override
  String get paywallTitle => 'Desbloqueie o ilimitado';

  @override
  String get paywallSubtitle =>
      'Verificações de looks ilimitadas todos os dias';

  @override
  String get paywallSocialProof => 'Mais de 12 mil verificações hoje';

  @override
  String get paywallContinue => 'Continuar';

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallNotConfigured =>
      'Os pagamentos ainda não foram configurados — adicione as chaves do RevenueCat';

  @override
  String paywallPurchaseError(String error) {
    return 'Não foi possível concluir a compra: $error';
  }

  @override
  String get paywallRestoreSuccess => 'Compras restauradas';

  @override
  String paywallRestoreError(String error) {
    return 'Não foi possível restaurar as compras: $error';
  }

  @override
  String paywallOfferError(String error) {
    return 'Erro: $error';
  }

  @override
  String get paywallSuccessTitle =>
      'Pronto! Agora você tem acesso ilimitado 🎉';

  @override
  String get paywallSuccessCta => 'Ótimo';

  @override
  String get paywallPlanWeekly => 'Semanal';

  @override
  String get paywallPlanHalfyear => 'Semestral';

  @override
  String get paywallPeriodWeek => '7 dias';

  @override
  String get paywallPeriodHalfyear => '6 meses';

  @override
  String get paywallBenefit1 => 'Verificações de looks ilimitadas';

  @override
  String get paywallBenefit2 => 'Análise de IA prioritária';

  @override
  String get paywallBenefit3 => 'Acesso antecipado às tendências';

  @override
  String get paywallBestValue => 'MELHOR OFERTA';

  @override
  String get offlineBanner => 'Sem conexão';

  @override
  String get bottomTabHome => 'Início';

  @override
  String get bottomTabHistory => 'Histórico';

  @override
  String get bottomTabProfile => 'Perfil';

  @override
  String get categoryColorPalette => 'Paleta de cores';

  @override
  String get categorySilhouette => 'Silhueta e caimento';

  @override
  String get categoryAccessories => 'Acessórios';

  @override
  String get categoryFootwear => 'Calçados';
}
