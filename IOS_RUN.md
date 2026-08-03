# Запуск Trendy Look на iOS

Инструкция для debug-запуска на симуляторе iPhone и на реальном устройстве.

## Один раз перед стартом

1. Flutter ≥ **3.44**, установлен Xcode.
2. В Supabase → **Authentication → Providers → Google** включён **Skip nonce check**.
3. В Google Cloud созданы OAuth clients:
   - **Web application** — его Client ID используется в `--dart-define`
   - **iOS** — Bundle ID: `app.trendylook.trendylook` (Client ID и URL scheme уже в `ios/Runner/Info.plist`)
4. Открой в Xcode `ios/Runner.xcworkspace` → target **Runner** → **Signing & Capabilities**:
   - включи **Automatically manage signing**
   - выбери **Team** (свой Apple ID / Apple Developer)
5. Для реального iPhone: устройство разблокировано, доверие компьютеру подтверждено. При первой установке может понадобиться: **Настройки → Основные → VPN и управление устройством** → доверить Developer App.

## Web Client ID

Во всех командах ниже подставляй **Web** Client ID (не iOS):

```text
296414004775-pdog1isingjoa3f2spfnia6cekg9dhok.apps.googleusercontent.com
```

iOS Client ID уже прописан в `Info.plist` (`GIDClientID` + reversed URL scheme) — в `--dart-define` его передавать не нужно.

## Симулятор iPhone

```bash
cd /path/to/trendylook

flutter devices

open -a Simulator

flutter run \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=296414004775-pdog1isingjoa3f2spfnia6cekg9dhok.apps.googleusercontent.com
```

Если устройств несколько:

```bash
flutter run -d <simulator_id> \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=296414004775-pdog1isingjoa3f2spfnia6cekg9dhok.apps.googleusercontent.com
```

На симуляторе: **Войти через Google** → выбрать аккаунт (при необходимости войти в Google через Safari).

## Реальный iPhone

1. Подключи iPhone по USB (или Wireless Debugging после первой пары).
2. Проверь, что устройство видно:

```bash
flutter devices
```

3. Запусти:

```bash
flutter run -d <iphone_id> \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=296414004775-pdog1isingjoa3f2spfnia6cekg9dhok.apps.googleusercontent.com
```

4. При первой установке: **Настройки → Основные → VPN и управление устройством** → доверить сертификат разработчика.

## Важно

| Тема | Детали |
|---|---|
| `GOOGLE_SERVER_CLIENT_ID` | Всегда **Web** Client ID, на каждом cold start debug |
| iOS Client ID | Уже в `ios/Runner/Info.plist` |
| Signing Team | Обязателен для реального iPhone; для симулятора лучше тоже выставить |
| Sign in with Apple | Отдельная настройка; для теста Google не нужна |

## Проверка

1. Кнопка **Войти через Google** отрабатывает без ошибки.
2. Открывается главный экран приложения.
3. В Supabase → **Authentication → Users** появился новый пользователь.
