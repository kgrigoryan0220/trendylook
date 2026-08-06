import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/gen/app_localizations.dart';

const _kLocaleKey = 'app_locale';

/// TECH_SPEC_v1.2.md 4.3 «Профиль» — язык выбирается вручную (RU/EN/…),
/// не только следует системной локали. `null` = «как в системе» (первый
/// запуск), ограничено поддерживаемыми языками с фолбэком на английский.
class LocaleController extends AsyncNotifier<Locale?> {
  @override
  Future<Locale?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey);
    if (code == null) return null;
    return AppLocalizations.supportedLocales
        .where((l) => l.languageCode == code)
        .firstOrNull;
  }

  Future<void> setLocale(Locale? locale) async {
    state = AsyncData(locale);
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_kLocaleKey);
    } else {
      await prefs.setString(_kLocaleKey, locale.languageCode);
    }
  }
}

final localeControllerProvider =
    AsyncNotifierProvider<LocaleController, Locale?>(LocaleController.new);

/// Текущий фактический языковой код для запросов, которым не нужен BuildContext
/// (Edge Function locale, AppLocalizations.lookupAppLocalizations в репозиториях).
/// Пока выбор ещё не загружен/не задан — используем системную локаль устройства
/// с фолбэком на английский, как и сам MaterialApp.localeResolutionCallback.
final currentLanguageCodeProvider = Provider<String>((ref) {
  final explicit = ref.watch(localeControllerProvider).valueOrNull;
  if (explicit != null) return explicit.languageCode;

  final deviceCode = PlatformDispatcher.instance.locale.languageCode;
  final supported = AppLocalizations.supportedLocales.map((l) => l.languageCode);
  return supported.contains(deviceCode) ? deviceCode : 'en';
});
