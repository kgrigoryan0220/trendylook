import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trendylook/core/l10n/category_names.dart';
import 'package:trendylook/l10n/gen/app_localizations.dart';

void main() {
  testWidgets('localizedCategoryName maps known category keys per locale', (tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(localizedCategoryName(capturedContext, 'color_palette'), 'Цветовая палитра');
    expect(localizedCategoryName(capturedContext, 'footwear'), 'Обувь');
  });
}
