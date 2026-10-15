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
flutter run
```

Для debug-запуска флаги не нужны: в `lib/core/config/app_config.dart` зашиты
значения по умолчанию — Supabase URL/publishable key, Google Web Client ID и
тестовый ключ RevenueCat Test Store (только debug/profile; это не секреты —
все они предназначены для клиента). Покупки в Test Store ненастоящие.

Опционально (локальный `dart_defines.dev.json` в `.gitignore`):
`POSTHOG_API_KEY`, `SENTRY_DSN` — без них аналитика и крэш-репортинг no-op.
PostHog: см. [`POSTHOG.md`](POSTHOG.md).

```bash
flutter run --dart-define-from-file=dart_defines.dev.json
```

Release-сборки обязательно получают боевые ключи RevenueCat
(`REVENUECAT_API_KEY_IOS=appl_…`, `REVENUECAT_API_KEY_ANDROID=goog_…`) — в release
тестового ключа по умолчанию нет, без них покупки выключены.
См. [`STORE_RELEASE_CHECKLIST.md`](STORE_RELEASE_CHECKLIST.md).

### Проверка

```bash
flutter analyze
flutter test
```

Camera/IAP/нативный OAuth нельзя протестировать без физического устройства —
статическим анализом и тестами покрыта вся логика, которую можно проверить
без него (entitlement, парсинг ответов API, роутинг).
