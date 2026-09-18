# PostHog — каталог событийной аналитики

Актуально для кодовой базы Trendy Look (EU Cloud, project `278024`).  
Host: `https://eu.i.posthog.com`

События уходят только если задан `POSTHOG_API_KEY` (например через `dart_defines.dev.json`).

---

## Identity / session

| Событие / API | Когда | Свойства |
|---------------|--------|----------|
| `identify(userId)` | Логин или восстановление сессии | `email?`, `auth_provider?` |
| `reset()` | Logout / очистка сессии (в т.ч. после delete account) | — |
| `screen(routeName)` | Навигация GoRouter (`AnalyticsNavigatorObserver`) | имя роута |
| Lifecycle (SDK) | `Application Opened` / background / etc. | системные |

---

## Onboarding & Auth

| Event | Когда | Properties |
|-------|--------|------------|
| `onboarding_complete` | «Начать» или «Пропустить» на онбординге | — |
| `auth_success` | Успешный Sign in with Apple / Google | `provider`: `apple` \| `google` |
| `auth_failed` | Ошибка входа | `provider`, `error` |
| `logout_tapped` | Пользователь подтвердил выход в Profile | — |
| `logout` | Сессия стала `null` (после signOut / delete) | — |
| `account_deleted` | Перед вызовом delete-account | — |
| `account_delete_failed` | Ошибка удаления аккаунта | — |

---

## Check (анализ лука)

| Event | Когда | Properties |
|-------|--------|------------|
| `check_started` | Старт проверки | `source`: `camera` \| `gallery` \| `camera_or_gallery` |
| `check_completed` | Успешный analyze-look | `score` (int), `duration_ms` (int) |
| `check_failed` | Ошибка анализа / upload | `error_code` (runtimeType) |

> На Home шлётся `check_started` с `camera`/`gallery`; в `CheckFlowController` дополнительно может уйти `camera_or_gallery` при submit.

---

## Monetization

| Event | Когда | Properties |
|-------|--------|------------|
| `paywall_shown` | Открыт paywall | `trigger` (см. ниже) |
| `paywall_dismissed` | Закрыт крестиком без покупки | `trigger` |
| `subscription_purchased` | Успешная покупка | `plan`: `weekly` \| `halfyear`, `price` |
| `subscription_purchase_failed` | Ошибка покупки | `trigger`, `error` |
| `purchases_restored` | Restore OK | `trigger` |
| `purchases_restore_failed` | Restore fail | `error` |
| `promo_redeemed` | Промокод применён | `extended` (bool) |

### Значения `trigger` для paywall

| `trigger` | Откуда |
|-----------|--------|
| `limit_reached` | Home: нет free checks / не Pro |
| `check_limit` | Loading после `PaywallException` |
| `result` | Экран результата → upgrade |
| `profile` | Profile → Upgrade |
| `grace` | Grace banner (Home / Profile) |
| `deeplink` | `trendylook://paywall` |
| `unknown` | Открыт `/paywall` без query |

---

## Share & History

| Event | Когда | Properties |
|-------|--------|------------|
| `share_tapped` | Шаринг карточки | `template`: `bold`, `score` |
| `history_viewed` | Открыт detail проверки | `check_id` |

---

## Screens (автоматически)

Через `Posthog().screen` при push/replace роутов, например:

- `/splash`, `/onboarding`, `/auth`
- `/home`, `/history`, `/profile`
- `/check/camera`, `/check/confirm`, `/check/loading`, `/check/result`, `/check/error`
- `/paywall`, `/share`, `/history/:id`

---

## Не включено (намеренно)

- Session replay
- Surveys
- Отдельные screen-события с кастомными именами (используются path GoRouter)

---

## Связанные файлы

| Файл | Роль |
|------|------|
| `lib/core/analytics/analytics_service.dart` | init / track / identify / reset / screen |
| `lib/core/analytics/analytics_navigator_observer.dart` | screen views |
| `POSTHOG.md` | setup, EU, smoke-test |
| `dart_defines.dev.json` | локальный ключ (gitignore) |
