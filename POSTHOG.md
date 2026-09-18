# PostHog — production analytics

Project: **278024** (EU Cloud)  
Dashboard: https://eu.posthog.com/project/278024  
Ingestion host: `https://eu.i.posthog.com`  
Local key file: `dart_defines.dev.json` (gitignored)

## Run / build with analytics

```bash
# Debug
flutter run --dart-define-from-file=dart_defines.dev.json

# Release (CI / local)
flutter build ipa --dart-define-from-file=dart_defines.dev.json
flutter build appbundle --dart-define-from-file=dart_defines.dev.json
```

Required defines:

| Key | Value |
|-----|--------|
| `POSTHOG_API_KEY` | Project API Key (`phc_…`) |
| `POSTHOG_HOST` | `https://eu.i.posthog.com` (also AppConfig default) |

Without `POSTHOG_API_KEY`, all analytics calls are no-ops.

## What the app does

- `AnalyticsService.init()` on startup (EU host, lifecycle events on, session replay **off**)
- `identify(supabase_user_id)` on login / session restore (+ email / auth_provider when present)
- `reset()` on logout / after session cleared (account delete included)
- Screen views via `AnalyticsNavigatorObserver` (GoRouter)
- Product events (see below)

## Event catalog

Полный каталог: [`POSTHOG_EVENTS.md`](POSTHOG_EVENTS.md).

## Smoke test

1. Run with `dart_defines.dev.json`
2. Open app → Live events in EU project
3. Sign in → person identified by Supabase UUID
4. Open paywall from Profile → `paywall_shown` with `trigger=profile`
5. Log out → `logout` + new anonymous distinct id

## Not enabled (by design)

- **Session replay** — off (outfit photos / sensitive UI)
- **Surveys** — not wired
- PostHog Wizard — optional; SDK already integrated
