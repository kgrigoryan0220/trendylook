import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trendylook/l10n/gen/app_localizations.dart';
import 'package:trendylook/shared/widgets/promo_code_section.dart';

void main() {
  testWidgets('promo apply button fits on narrow width for every locale', (tester) async {
    for (final locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: SizedBox(
                width: 320,
                child: PromoCodeSection(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'overflow for locale ${locale.languageCode}');
    }
  });
}
