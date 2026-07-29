# Trendy Look

AI-стилист: оценка трендовости образа по фото + рекомендации. Flutter (Riverpod,
go_router) + Supabase. См. `TECH_SPEC_v1.2.md` — основной источник правды по
бизнес-логике; `Trendy_Look_Design_Brief.md` — визуальный референс.

## Supabase

Проект: `trendylook` (`jilreygcmqhemhsmetqd`, eu-central-1).

Развёрнуто через Supabase MCP:
- Миграции — `supabase/migrations/` (schema, RLS, storage policies, триггер
  автосоздания профиля, pg_cron грейс-период).
- Edge Functions — `supabase/functions/` (`analyze-look`, `revenuecat-webhook`,
  `delete-account`, `billing-status`).
- Security/performance advisors проверены и чисты.

### Секреты Edge Functions (нужно добавить самостоятельно)

Supabase Dashboard → Project Settings → Edge Functions → Secrets:

| Секрет | Для чего |
|---|---|
| `OPENAI_API_KEY` | `analyze-look` — вызов GPT-4o Vision |
| `REVENUECAT_WEBHOOK_SECRET` | `revenuecat-webhook` — статичный Bearer-токен, тот же нужно задать в RevenueCat Dashboard → Webhooks |

`SUPABASE_URL`/`SUPABASE_SERVICE_ROLE_KEY` уже доступны Edge Functions
автоматически.

## Flutter

### Настройка перед первым запуском

1. Auth-провайдеры в Supabase Dashboard → Authentication → Providers:
   Apple (Services ID, Team ID, Key ID, private key) и Google (OAuth client).
2. RevenueCat: создать проект, продукты `weekly_unlimited` / `halfyear_unlimited`,
   привязать App Store Connect / Google Play. Webhook →
   `https://jilreygcmqhemhsmetqd.supabase.co/functions/v1/revenuecat-webhook`
   с тем же секретом, что и `REVENUECAT_WEBHOOK_SECRET`.
3. Google Sign-In на Android нуждается в `GOOGLE_SERVER_CLIENT_ID` (Web
   application OAuth client id из Google Cloud Console). На iOS дополнительно
   нужно добавить `REVERSED_CLIENT_ID` в `CFBundleURLTypes` в
   `ios/Runner/Info.plist` (там уже есть схема `trendylook`, добавьте вторую).
4. Sign In with Apple: в Xcode (Runner target → Signing & Capabilities) с
   реальным Apple Developer Team добавить capability «Sign In with Apple» —
   без своего Team ID Xcode не создаст это автоматически.

### Запуск

```bash
flutter pub get
flutter run \
  --dart-define=REVENUECAT_API_KEY_IOS=... \
  --dart-define=REVENUECAT_API_KEY_ANDROID=... \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=... \
  --dart-define=SENTRY_DSN=... \
  --dart-define=POSTHOG_API_KEY=...
```

Supabase URL/publishable key уже зашиты в `lib/core/config/app_config.dart`
как значения по умолчанию (это не секреты — они предназначены для клиента).
Все `--dart-define` выше опциональны: без них подписки/аналитика/крэш-репортинг
остаются выключенными (no-op), а не падают.

### Проверка

```bash
flutter analyze
flutter test
```

Camera/IAP/нативный OAuth нельзя протестировать без физического устройства —
статическим анализом и тестами покрыта вся логика, которую можно проверить
без него (entitlement, парсинг ответов API, роутинг).
