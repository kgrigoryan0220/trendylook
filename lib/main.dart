import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  // Требуется для DateFormat(..., locale) в history_item_tile/profile_screen —
  // по одному вызову на каждый поддерживаемый язык (см. lib/l10n).
  for (final code in ['ru', 'en', 'es', 'it', 'de', 'fr', 'pt']) {
    await initializeDateFormatting(code);
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );

  if (AppConfig.sentryDsn.isEmpty) {
    runApp(const ProviderScope(child: TrendyLookApp()));
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      options.tracesSampleRate = 0.2;
    },
    appRunner: () => runApp(const ProviderScope(child: TrendyLookApp())),
  );
}
