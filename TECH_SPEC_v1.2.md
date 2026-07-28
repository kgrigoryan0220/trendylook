# Техническое задание: Trendy Look

**Версия:** 1.2  
**Дата:** 28.07.2026  
**Статус:** Draft  
**Стек:** Flutter + Supabase

### Changelog v1.1 → v1.2 (устранены нестыковки)

- Share-карточки: зафиксировано **1 шаблон в MVP** (было противоречие: в 4.3 указано 3 шаблона, в разделе 8 — исключение «нескольких шаблонов»).
- Occasion selector убран из Tone of Voice (4.5) как активная фича MVP — вопрос уже был исключён из MVP в разделе 8, теперь текст 4.5 это отражает.
- Исправлена/убрана некорректная цифра скидки Half-year тарифа (было «−40% vs weekly», математически это ближе к −77%).
- Добавлен статус `grace` в подписки + логика grace-периода в Edge Function (PAY-05 ранее не был реализован в схеме/коде).
- Добавлен явный раздел 4.3.0 «Навигационная оболочка» (bottom tab bar) — раньше общая навигация не была описана.
- Sticker export вынесен в v2 явно (раньше не был указан ни в MVP, ни в исключениях).
- Уточнено происхождение email в профиле (из `auth.users`, не хранится в `profiles`).
- Добавлено явное требование по rate-limiting и timeout/retry в код Edge Function (были заявлены как требования, но отсутствовали в примере реализации).

---

## 1. Обзор продукта

### 1.1. Название и позиционирование

**Trendy Look** — мобильное приложение, которое оценивает трендовость образа пользователя по фото и даёт персональные рекомендации по улучшению стиля.

**Ключевая ценность:** мгновенная, понятная и «шерибельная» оценка лука в формате, который хочется показать друзьям.

**Слоган (варианты):**
- «Насколько твой лук в тренде?»
- «AI-стилист в кармане»
- «Проверь свой outfit за 10 секунд»

### 1.2. Целевая аудитория

| Сегмент | Возраст | Мотивация |
|---------|---------|-----------|
| Gen Z / молодые миллениалы | 16–30 | Тренды, соцсети, самовыражение |
| Fashion-curious | 18–35 | Хотят выглядеть актуально, но без стилиста |
| UGC-креаторы | 18–28 | Контент для TikTok / Reels / Stories |

### 1.3. Платформы

| Платформа | Приоритет | Комментарий |
|-----------|-----------|-------------|
| iOS | P0 (MVP) | Apple Sign In обязателен при наличии других соц. логинов |
| Android | P0 (MVP) | Flutter — единая кодовая база, Google Sign In |
| Web (лендинг) | P2 | Маркетинг, deep links (опционально Flutter Web) |

---

## 2. Бизнес-модель

### 2.1. Freemium

| Параметр | Значение |
|----------|----------|
| Бесплатные проверки | **2** на аккаунт (lifetime, не сбрасываются) |
| После исчерпания | Paywall |
| Триал | Нет (2 бесплатные проверки = onboarding hook) |

### 2.2. Тарифы (подписка)

| Тариф | Период | Рекомендуемая цена* | Особенности |
|-------|--------|---------------------|-------------|
| **Weekly** | 7 дней | $4.99 / 399 ₽ | Для импульсных пользователей |
| **Half-year** | 6 месяцев | $29.99 / 1 990 ₽ | «Best value» badge |

*Цены — ориентиры для MVP; финальные — после A/B и локализации.
*Примечание: точная % скидки half-year относительно weekly не зафиксирована в ТЗ намеренно — при пересчёте по цене за неделю фактическая экономия существенно выше «−40%», которая фигурировала в черновике. Конкретную цифру для маркетинга нужно посчитать и утвердить отдельно перед релизом (в UI использовать нейтральный бейдж «Best value» без числа, пока цифра не утверждена).

### 2.3. Что входит в подписку

- Безлимитные проверки лука
- Полная история проверок
- Детальные рекомендации (расширенный блок)
- Share-карточки без водяного знака (опционально)

### 2.4. Платёжная инфраструктура

- **iOS:** StoreKit 2 + RevenueCat (или Adapty) для кросс-платформенной аналитики
- **Android:** Google Play Billing
- Восстановление покупок обязательно
- Серверная валидация receipt через Supabase Edge Function + webhook RevenueCat

---

## 3. Пользовательские сценарии

### 3.1. Основной flow (Happy Path)

```
Запуск → Onboarding (3 экрана) → Auth (Apple/Google) →
→ Главный экран → Загрузка/съёмка фото →
→ AI-анализ (loading) → Результат (score + рекомендации) →
→ Share / Сохранить в историю → Повтор
```

### 3.2. Flow исчерпания лимита

```
Попытка 3-й проверки → Paywall →
  → Покупка → Продолжение
  → Отказ → Возврат на главный (история доступна)
```

### 3.3. Детальные сценарии

| ID | Сценарий | Результат |
|----|----------|-----------|
| UC-01 | Регистрация через Apple ID | Создание профиля, 2 free checks |
| UC-02 | Регистрация через Google | Аналогично UC-01 |
| UC-03 | Повторный вход | Восстановление сессии, история |
| UC-04 | Съёмка фото в приложении | Фронт/тыл камера, кроп |
| UC-05 | Загрузка из галереи | JPEG/HEIC/PNG, max 10 MB |
| UC-06 | Анализ лука | Score 0–100%, 3–5 рекомендаций |
| UC-07 | Шеринг результата | Генерация share-карточки (Stories 9:16) |
| UC-08 | Просмотр истории | Список + детальный просмотр |
| UC-09 | Покупка подписки | Активация unlimited |
| UC-10 | Восстановление покупок | Синхронизация entitlement |

---

## 4. Дизайн и UX (виральность / UGC)

### 4.1. Дизайн-принципы

1. **Instant gratification** — результат за 5–15 секунд, крупный score на экране
2. **Share-first** — каждый результат спроектирован как контент для Stories/Reels
3. **Bold & playful** — яркая типографика, градиенты, микроанимации
4. **Mobile-native** — жесты, haptics, bottom sheets
5. **Inclusive** — работает с разными типами телосложения, стилями, гендерами

### 4.2. Визуальный стиль

| Элемент | Рекомендация |
|---------|--------------|
| Цветовая палитра | Неоновые акценты (electric pink / lime / violet) на тёмном или светлом фоне |
| Типографика | Display: **Clash Display** / **Satoshi**; Body: **Inter** |
| Иконки | Lucide / custom outlined, 2px stroke |
| Скругления | 16–24px cards, pill buttons |
| Анимации | Score counter (0→N%), confetti при 80%+, skeleton loading |

### 4.3. Ключевые экраны

#### 4.3.0 Навигационная оболочка (Navigation Shell)

Приложение использует **нижний tab bar из 3 вкладок**: Главная (Home), История, Профиль.

- Flow «Проверка лука» (камера/галерея → анализ → результат → шеринг) открывается как **full-screen модальный поток поверх tab bar**, без видимой навигации внутри самого флоу (фокус-режим).
- Paywall — отдельная full-screen модалка, вызывается контекстно (при исчерпании лимита или вручную из Профиля), не является вкладкой.

#### Onboarding (3 слайда)
1. «Сфотографируй свой лук» — иллюстрация камеры
2. «Узнай % трендовости» — анимированный score ring
3. «Получи советы от AI» — карточки рекомендаций  
→ CTA: «Начать» → Auth

#### Главный экран (Home)
- Hero: «Проверь свой лук» + кнопки **Сфотографировать** / **Из галереи**
- Counter: «Осталось проверок: 2» (или badge Pro)
- Блок «Последние проверки» (горизонтальный скролл)

#### Экран анализа (Loading)
- Blur превью фото
- Анимация сканирования (scan line / pulse)
- Ротация фраз: «Анализируем цвета…», «Сверяем с трендами 2026…»
- Progress bar (indeterminate → determinate при ответе API)

#### Экран результата (Core viral screen)
```
┌─────────────────────────┐
│  [Фото пользователя]    │
│                         │
│     ╭─────────╮         │
│     │  78%    │  ← крупный score ring
│     │ TRENDY  │
│     ╰─────────╯         │
│                         │
│  ✦ Цветовая палитра     │
│  ✦ Силуэт и посадка     │
│  ✦ Аксессуары           │
│                         │
│  💡 Рекомендации:       │
│  1. Добавь контраст...  │
│  2. Замени обувь на...  │
│                         │
│  [Поделиться] [Ещё раз] │
└─────────────────────────┘
```

#### Share-карточка (генерируется сервером/клиентом)
- Формат: **1080×1920** (Stories), **1080×1080** (Feed)
- Элементы: фото, score, 1 топ-рекомендация, брендинг + QR/deep link
- **MVP: 1 шаблон** (Bold, как основной для виральности). Дополнительные шаблоны (Minimal / Aesthetic) — v1.1/v2, см. раздел 8.
- Watermark «trendylook.app» на free tier (опционально)

#### Paywall
- Сравнение тарифов: Weekly vs Half-year (highlight half-year)
- Social proof: «12 000+ проверок сегодня»
- Benefits list с иконками
- Кнопки: «Продолжить» / «Восстановить покупки»
- Ссылка на Terms / Privacy

#### История
- Grid или list с thumbnail, score badge, дата
- Tap → детальный просмотр (read-only)
- Swipe to delete (с подтверждением)

#### Профиль
- Аватар (из Apple/Google), email — **email берётся из `supabase.auth.currentUser.email` на клиенте, отдельно в таблице `profiles` не хранится** (см. 6.4)
- Статус подписки: Free / Pro / **Grace period** (см. 5.5, PAY-05)
- Остаток free checks
- Настройки, поддержка, logout

### 4.4. UGC-механики для продвижения

| Механика | Описание |
|----------|----------|
| **Score reveal** | Драматичная анимация числа — идеально для screen recording |
| **Challenge hooks** | (MVP) «Проверь свой лук и отметь друга» — текст-CTA внутри share-карточки, использует существующий deep link `trendylook://check/{id}`, отдельной инфраструктуры не требует |
| **Sticker export** | (v2) Отдельный PNG-стикер score для Stories, вне единого шаблона share-карточки |
| **Before/After** | (v2) Два фото, сравнение score |
| **Leaderboard** | (v2) Анонимный топ недели |
| **Referral** | (v2) +1 free check за приглашение |

### 4.5. Tone of Voice (AI-ответы)

- Дружелюбный, без токсичности
- Конкретные actionable советы (не «будь собой»)
- Учёт сезона на основе даты анализа (без явного вопроса пользователю)
- Запрет: оценка веса/телосложения, дискриминационные формулировки

> Occasion selector (casual/office/party) как отдельный вопрос перед анализом — **не входит в MVP** (см. раздел 8), перенесён в v2. В MVP AI ориентируется только на фото и сезон по дате, без дополнительного UI-шага.

---

## 5. Функциональные требования

### 5.1. Авторизация

| ID | Требование |
|----|------------|
| AUTH-01 | Sign in with Apple через Supabase Auth (обязательно на iOS) |
| AUTH-02 | Sign in with Google через Supabase Auth |
| AUTH-03 | Supabase JWT (auto-refresh через `supabase_flutter`) |
| AUTH-04 | Автоматический refresh сессии SDK |
| AUTH-05 | Logout через `supabase.auth.signOut()` |
| AUTH-06 | Identity linking Apple + Google к одному аккаунту (v1.1) |

### 5.2. Проверка лука (Core)

| ID | Требование |
|----|------------|
| CHECK-01 | Приём фото: camera capture + gallery pick |
| CHECK-02 | Препроцессинг: resize max 2048px, JPEG quality 85%, EXIF strip |
| CHECK-03 | Вызов Supabase Edge Function `analyze-look` → OpenAI Vision API (GPT-4o / GPT-4.1) |
| CHECK-04 | Парсинг структурированного ответа (JSON schema) в Edge Function |
| CHECK-05 | Сохранение результата в PostgreSQL + Supabase Storage |
| CHECK-06 | Проверка лимита free checks перед вызовом API |
| CHECK-07 | Timeout анализа: 30 сек, retry 1 раз |
| CHECK-08 | Fallback при ошибке API: понятное сообщение + не списывать check |

### 5.3. Структура ответа AI

```json
{
  "trend_score": 78,
  "trend_label": "Trendy",
  "categories": [
    { "name": "color_palette", "score": 82, "comment": "..." },
    { "name": "silhouette", "score": 75, "comment": "..." },
    { "name": "accessories", "score": 70, "comment": "..." },
    { "name": "footwear", "score": 80, "comment": "..." }
  ],
  "recommendations": [
  {
    "priority": 1,
    "title": "Добавь контрастный акцент",
    "description": "Нейтральный верх можно разбавить ярким шарфом или сумкой terracotta.",
    "category": "accessories"
  }
  ],
  "trend_tags": ["quiet luxury", "minimalist", "neutral tones"],
  "summary": "Образ собранный и актуальный. Главная зона роста — аксессуары."
}
```

**Шкала trend_label:**

| Score | Label |
|-------|-------|
| 0–39 | Needs Work |
| 40–59 | Getting There |
| 60–79 | Trendy |
| 80–100 | Icon Status |

### 5.4. История

| ID | Требование |
|----|------------|
| HIST-01 | Список всех проверок пользователя (paginated, 20/page) |
| HIST-02 | Детальный просмотр: фото, score, рекомендации, дата |
| HIST-03 | Удаление записи (soft delete) |
| HIST-04 | Free users: история доступна, но новые проверки — paywall |

### 5.5. Paywall и подписки

| ID | Требование |
|----|------------|
| PAY-01 | Отображение paywall при попытке 3-й проверки |
| PAY-02 | Два продукта: `weekly_unlimited`, `halfyear_unlimited` |
| PAY-03 | Серверная проверка entitlement перед каждой проверкой |
| PAY-04 | Webhook RevenueCat → Supabase Edge Function `revenuecat-webhook` → обновление `subscriptions` |
| PAY-05 | Grace period при истечении подписки: 24h. Реализация: статус `grace` в `subscriptions.status` + поле `grace_expires_at` (= `expires_at` + 24h), проверка в Edge Function `analyze-look` (см. 6.5) |
| PAY-06 | Restore purchases |

### 5.6. Share

| ID | Требование |
|----|------------|
| SHARE-01 | Native share sheet (`share_plus`) |
| SHARE-02 | Генерация branded image 1080×1920 |
| SHARE-03 | Deep link в приложение: `trendylook://check/{id}` |
| SHARE-04 | (v1.1) Universal Links / App Links |

---

## 6. Техническая архитектура

### 6.1. High-level схема

```
┌──────────────────┐                    ┌─────────────────────────────────────┐
│   Flutter App    │                    │            Supabase                 │
│   (iOS/Android)  │                    │                                     │
│                  │  supabase_flutter  │  ┌─────────┐  ┌──────────────┐    │
│  • UI / UX       │ ──────────────────→│  │  Auth   │  │  PostgreSQL  │    │
│  • Camera        │                    │  │ Apple/  │  │  + RLS       │    │
│  • Share cards   │                    │  │ Google  │  └──────────────┘    │
│  • RevenueCat    │                    │  └─────────┘                       │
│                  │                    │  ┌─────────┐  ┌──────────────┐    │
│                  │  Edge Functions    │  │ Storage │  │ Edge Funcs   │    │
│                  │ ──────────────────→│  │ (photos)│  │ analyze-look │    │
│                  │                    │  └─────────┘  │ rc-webhook   │    │
└──────────────────┘                    │               └──────┬───────┘    │
         │                              └──────────────────────┼────────────┘
         │ RevenueCat SDK                                       │
         ▼                                                      ▼
┌──────────────────┐                                    ┌─────────────────┐
│   App Store /    │                                    │   OpenAI API    │
│   Google Play    │                                    │   (Vision)      │
└──────────────────┘                                    └─────────────────┘
```

**Принцип:** вся серверная логика — в Supabase. Отдельный backend-сервер не нужен.

### 6.2. Стек технологий

#### Mobile — Flutter

| Слой | Пакет / технология | Назначение |
|------|-------------------|------------|
| Framework | **Flutter 3.24+** (Dart 3.5+) | Единая кодовая база iOS + Android |
| State management | **Riverpod** (или Bloc) | Реактивное состояние, DI |
| Navigation | **go_router** | Declarative routing, deep links |
| Supabase client | **supabase_flutter** | Auth, DB, Storage, Edge Functions |
| Camera | **image_picker** + **camera** | Съёмка и выбор из галереи |
| Image processing | **flutter_image_compress** | Resize, EXIF strip перед upload |
| Auth (native) | **sign_in_with_apple** + **google_sign_in** | Нативные OAuth flows → Supabase |
| Payments | **purchases_flutter** (RevenueCat) | In-app subscriptions |
| Animations | **flutter_animate** + **lottie** | Score counter, confetti, loading |
| Share | **screenshot** + **share_plus** | Генерация и шеринг share-карточек |
| Local cache | **hive** / **drift** | Offline-история проверок |
| Analytics | **posthog_flutter** / **firebase_analytics** | Product events |
| Crash reporting | **sentry_flutter** | Error tracking |
| Deep links | **app_links** + go_router | `trendylook://` / Universal Links |

#### Backend — Supabase

| Сервис | Назначение |
|--------|------------|
| **Supabase Auth** | Apple / Google OAuth, JWT, session management |
| **PostgreSQL** | Профили, проверки, подписки |
| **Row Level Security (RLS)** | Изоляция данных пользователей |
| **Supabase Storage** | Private bucket `look-photos` |
| **Edge Functions** (Deno/TS) | OpenAI вызовы, billing webhooks, бизнес-логика |
| **Realtime** (опционально) | Live-обновление статуса анализа (v1.1) |
| **Database Webhooks** (опционально) | Триггеры на события (v1.1) |

#### Edge Functions

| Function | Trigger | Описание |
|----------|---------|----------|
| `analyze-look` | Client POST | Проверка лимита → OpenAI Vision → сохранение в DB |
| `revenuecat-webhook` | RevenueCat POST | Обновление статуса подписки |
| `delete-account` | Client POST | GDPR: удаление user + photos + checks |

#### DevOps

| Инструмент | Назначение |
|------------|------------|
| GitHub Actions | CI: lint, test, build |
| Codemagic / Fastlane | Сборка и деплой iOS/Android |
| Supabase CLI | Миграции, deploy Edge Functions |
| Sentry | Crash reporting (Flutter + Edge Functions) |
| PostHog | Product analytics |
| RevenueCat Dashboard | Subscription analytics |

### 6.3. Supabase API (вместо custom REST)

#### Auth (через `supabase_flutter`)

```dart
// Apple Sign In
await supabase.auth.signInWithOAuth(OAuthProvider.apple);

// Google Sign In
await supabase.auth.signInWithOAuth(OAuthProvider.google);

// Текущий пользователь
final user = supabase.auth.currentUser;

// Logout
await supabase.auth.signOut();
```

#### Storage — загрузка фото

```dart
final path = '${user.id}/${uuid}.jpg';
await supabase.storage
    .from('look-photos')
    .upload(path, file, fileOptions: FileOptions(upsert: false));
```

#### Edge Function — анализ лука

```dart
final response = await supabase.functions.invoke(
  'analyze-look',
  body: {'image_path': path, 'locale': 'ru'},
);
// → { check_id, trend_score, trend_label, recommendations, ... }
```

#### Database — история (прямой запрос с RLS)

```dart
final checks = await supabase
    .from('checks')
    .select()
    .order('created_at', ascending: false)
    .range(0, 19);
```

#### Edge Function — billing status

```dart
final status = await supabase.functions.invoke('billing-status');
// → { is_pro, plan, expires_at, free_checks_left }
```

### 6.4. Модель данных (Supabase PostgreSQL)

```sql
-- profiles (расширение auth.users)
-- Примечание: email намеренно не дублируется здесь — он есть в auth.users
-- и доступен клиенту через supabase.auth.currentUser.email (см. 4.3 «Профиль»).
CREATE TABLE public.profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name  TEXT,
  avatar_url    TEXT,
  free_checks_used INT NOT NULL DEFAULT 0,
  locale        TEXT DEFAULT 'ru',
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now()
);

-- subscriptions
CREATE TYPE plan_type AS ENUM ('weekly', 'halfyear');
CREATE TYPE sub_status AS ENUM ('active', 'grace', 'expired', 'cancelled');
-- 'grace' — статус для PAY-05: подписка формально истекла (expires_at в прошлом),
-- но пользователю ещё доступен полный функционал в течение 24ч (grace_expires_at).
-- Переход active → grace происходит по расписанию (pg_cron) или при следующей проверке entitlement,
-- переход grace → expired — по истечении grace_expires_at.

CREATE TABLE public.subscriptions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  plan            plan_type NOT NULL,
  status          sub_status NOT NULL DEFAULT 'active',
  revenuecat_id   TEXT,
  expires_at      TIMESTAMPTZ,
  grace_expires_at TIMESTAMPTZ,  -- expires_at + 24h, используется только при status = 'grace'
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- Уникальность: у пользователя может быть только одна активная/grace подписка одновременно
CREATE UNIQUE INDEX idx_one_active_subscription_per_user
  ON public.subscriptions(user_id)
  WHERE status IN ('active', 'grace');

-- checks (история луков)
CREATE TABLE public.checks (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  image_path      TEXT NOT NULL,          -- путь в Storage bucket
  trend_score     INT NOT NULL CHECK (trend_score BETWEEN 0 AND 100),
  trend_label     TEXT NOT NULL,
  ai_response     JSONB NOT NULL,
  share_image_path TEXT,
  deleted_at      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_checks_user_created ON public.checks(user_id, created_at DESC);
```

#### Row Level Security (RLS)

```sql
-- profiles: пользователь видит только свой профиль
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users read own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- checks: CRUD только своих записей
ALTER TABLE public.checks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users read own checks" ON public.checks
  FOR SELECT USING (auth.uid() = user_id AND deleted_at IS NULL);
CREATE POLICY "Users soft-delete own checks" ON public.checks
  FOR UPDATE USING (auth.uid() = user_id);

-- subscriptions: read-only для пользователя
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users read own subscription" ON public.subscriptions
  FOR SELECT USING (auth.uid() = user_id);
```

#### Storage policies

```sql
-- Bucket: look-photos (private)
-- Upload: только в свою папку {user_id}/*
-- Read: signed URLs через Edge Function или policy на свой path
CREATE POLICY "Users upload own photos"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'look-photos' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Users read own photos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'look-photos' AND (storage.foldername(name))[1] = auth.uid()::text);
```

#### Trigger: auto-create profile on signup

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### 6.5. Edge Function: `analyze-look`

```typescript
// supabase/functions/analyze-look/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import OpenAI from 'https://esm.sh/openai@4'

const FREE_CHECKS_LIMIT = 2;

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );
  const openai = new OpenAI({ apiKey: Deno.env.get('OPENAI_API_KEY')! });

  // 1. Auth
  const authHeader = req.headers.get('Authorization')!;
  const { data: { user } } = await supabase.auth.getUser(
    authHeader.replace('Bearer ', '')
  );
  if (!user) return new Response('Unauthorized', { status: 401 });

  const { image_path, locale = 'ru' } = await req.json();

  // 2. Check entitlement
  const { data: profile } = await supabase
    .from('profiles').select('free_checks_used').eq('id', user.id).single();

  // Учитываем both 'active' (expires_at ещё не наступил) и 'grace' (24ч после истечения, PAY-05)
  const { data: sub } = await supabase
    .from('subscriptions').select('status, expires_at, grace_expires_at')
    .eq('user_id', user.id)
    .in('status', ['active', 'grace'])
    .maybeSingle();
  // Благодаря idx_one_active_subscription_per_user у пользователя не может быть
  // больше одной строки в статусах active/grace одновременно — maybeSingle() безопасен.

  const isPro = !!sub && (
    (sub.status === 'active' && new Date(sub.expires_at) >= new Date()) ||
    (sub.status === 'grace' && new Date(sub.grace_expires_at) >= new Date())
  );
  if (!isPro && profile!.free_checks_used >= FREE_CHECKS_LIMIT) {
    return new Response(JSON.stringify({ error: 'paywall' }), { status: 402 });
  }

  // Rate limit: 10 checks/hour per user (см. раздел 6.5/6.6) — ранее было
  // заявлено как требование, но не реализовано в примере кода.
  const { count: recentChecksCount } = await supabase
    .from('checks')
    .select('id', { count: 'exact', head: true })
    .eq('user_id', user.id)
    .gte('created_at', new Date(Date.now() - 60 * 60 * 1000).toISOString());
  if ((recentChecksCount ?? 0) >= 10) {
    return new Response(JSON.stringify({ error: 'rate_limited' }), { status: 429 });
  }

  // 3. Get signed URL for OpenAI
  const { data: signed } = await supabase.storage
    .from('look-photos').createSignedUrl(image_path, 300);

  // 4. Call OpenAI Vision — timeout 30с, retry 1 раз (CHECK-07)
  const callOpenAI = () => openai.chat.completions.create({
    model: 'gpt-4o',
    response_format: { type: 'json_schema', json_schema: LOOK_ANALYSIS_SCHEMA },
    messages: [
      { role: 'system', content: SYSTEM_PROMPT },
      {
        role: 'user',
        content: [
          { type: 'text', text: 'Проанализируй мой outfit и оцени трендовость.' },
          { type: 'image_url', image_url: { url: signed!.signedUrl, detail: 'high' } }
        ]
      }
    ],
    max_tokens: 1500,
    temperature: 0.7,
  }, { timeout: 30_000 });

  let completion;
  try {
    completion = await callOpenAI();
  } catch (err) {
    // Fallback: одна попытка retry (CHECK-07). Если снова ошибка — CHECK-08:
    // понятное сообщение пользователю, free_checks_used НЕ инкрементируется.
    try {
      completion = await callOpenAI();
    } catch (retryErr) {
      return new Response(
        JSON.stringify({ error: 'analysis_failed', message: 'Не получилось проанализировать фото. Попробуй ещё раз — проверка не списана.' }),
        { status: 502 }
      );
    }
  }

  const analysis = JSON.parse(completion.choices[0].message.content!);

  // 5. Save check
  const { data: check } = await supabase.from('checks').insert({
    user_id: user.id,
    image_path,
    trend_score: analysis.trend_score,
    trend_label: analysis.trend_label,
    ai_response: analysis,
  }).select().single();

  // 6. Increment free_checks_used if not pro
  if (!isPro) {
    await supabase.from('profiles')
      .update({ free_checks_used: profile!.free_checks_used + 1 })
      .eq('id', user.id);
  }

  return new Response(JSON.stringify({ check_id: check!.id, ...analysis }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

#### System prompt (черновик)

```
Ты — AI-стилист приложения Trendy Look. Анализируй фото outfit пользователя.

Правила:
- Оцени трендовость образа по шкале 0–100
- Учитывай актуальные тренды 2025–2026: quiet luxury, mob wife, office siren, coquette, gorpcore, etc.
- Дай 3–5 конкретных рекомендаций по улучшению
- Оцени категории: color_palette, silhouette, accessories, footwear
- Будь конструктивным и дружелюбным
- НЕ комментируй вес, телосложение, внешность лица
- НЕ используй дискриминационные формулировки
- Отвечай на языке пользователя (определяй по locale или default: ru)

Верни JSON по схеме.
```

#### Оптимизация costs

| Мера | Эффект |
|------|--------|
| Resize до 1024px на клиенте (`flutter_image_compress`) | −60% tokens |
| `detail: "high"` только в production | Контроль cost |
| Кэш по hash фото в Edge Function | Защита от abuse |
| Rate limit: 10 checks/hour (Edge Function middleware) | Защита API budget |

**Ориентировочная стоимость:** ~$0.01–0.03 за проверку (GPT-4o vision).

### 6.6. Безопасность

| Область | Мера |
|---------|------|
| Auth | Supabase Auth JWT, auto-refresh |
| Данные | RLS на всех таблицах — пользователь видит только свои записи |
| Фото | Private Storage bucket, signed URLs (5 min TTL) |
| OpenAI key | Только в Edge Function secrets, never in Flutter client |
| Edge Functions | Verify JWT на каждом вызове |
| Input | Валидация MIME + max 10 MB на клиенте и в Storage policy |
| Rate limiting | Edge Function: max 10 checks/hour per user |
| PII / GDPR | Edge Function `delete-account`: cascade delete profile + checks + storage |
| Content | OpenAI Moderation API в Edge Function перед анализом (v1.1) |

### 6.7. Структура Flutter-проекта

```
lib/
├── main.dart
├── app.dart                    # MaterialApp + go_router
├── core/
│   ├── constants/
│   ├── theme/                  # Design system, colors, typography
│   ├── utils/
│   └── extensions/
├── features/
│   ├── auth/
│   │   ├── data/               # AuthRepository (Supabase)
│   │   ├── domain/
│   │   └── presentation/       # LoginScreen, AuthController
│   ├── onboarding/
│   ├── home/
│   ├── check/
│   │   ├── data/               # CheckRepository, image upload
│   │   └── presentation/       # CameraScreen, LoadingScreen, ResultScreen
│   ├── history/
│   ├── paywall/
│   ├── profile/
│   └── share/                  # ShareCardGenerator
├── shared/
│   ├── widgets/                # ScoreRing, TrendCard, etc.
│   └── providers/              # Riverpod providers
└── routing/
    └── app_router.dart
```

### 6.8. Аналитика (события)

| Событие | Параметры |
|---------|-----------|
| `onboarding_complete` | — |
| `auth_success` | provider: apple \| google |
| `check_started` | source: camera \| gallery |
| `check_completed` | score, duration_ms |
| `check_failed` | error_code |
| `paywall_shown` | trigger: limit_reached |
| `subscription_purchased` | plan, price |
| `share_tapped` | template, score |
| `history_viewed` | check_id |

---

## 7. Нефункциональные требования

| Параметр | Целевое значение |
|----------|------------------|
| Время анализа (p95) | < 15 сек |
| App launch (cold start) | < 2 сек |
| Uptime API | 99.5% |
| Поддерживаемые OS | iOS 16+, Android 12+ |
| Локализация MVP | RU, EN |
| Accessibility | VoiceOver, min touch target 44pt |
| Offline | История доступна offline (cached), анализ — только online |

---

## 8. MVP Scope

### Включено в MVP (v1.0)

- [x] iOS + Android приложение (Flutter)
- [x] Auth: Apple + Google (Supabase Auth)
- [x] Camera + Gallery upload
- [x] AI анализ через Edge Function → OpenAI Vision
- [x] Score + рекомендации
- [x] 2 free checks + paywall
- [x] Подписки: weekly + half-year (RevenueCat)
- [x] История проверок (Supabase DB + RLS)
- [x] Share-карточка (1 шаблон, Bold) с текстом-CTA «отметь друга» (Challenge hook)
- [x] Базовая аналитика
- [x] Навигация: bottom tab bar (Главная / История / Профиль)

### Не входит в MVP

- Referral program
- Before/After сравнение
- Несколько шаблонов share (Minimal / Aesthetic)
- Sticker export (отдельный PNG-стикер вне share-карточки)
- Occasion selector (casual/office/party)
- Push notifications
- In-app чат поддержки

---

## 9. Этапы разработки

| Этап | Срок | Deliverables |
|------|------|--------------|
| **0. Discovery** | 1 нед | Финал ТЗ, дизайн-макеты Figma, Supabase schema |
| **1. Supabase setup** | 1 нед | Auth providers, DB migrations, RLS, Storage, Edge Functions scaffold |
| **2. Flutter shell** | 1.5 нед | Navigation, theme, auth flows, camera/gallery |
| **3. Core feature** | 2 нед | Upload → analyze-look → результат, история |
| **4. Monetization** | 1 нед | RevenueCat, paywall, webhook, entitlement logic |
| **5. Share & Polish** | 1 нед | Share cards, animations, error states |
| **6. QA & Launch** | 1.5 нед | TestFlight + Internal Testing, bug fixes, store submission |

**Итого MVP:** ~9 недель при команде 1 Flutter dev + 0.5 backend (Supabase) + 1 designer.

*Supabase сокращает backend-этап: нет отдельного сервера, auth и storage из коробки.*

---

## 10. Команда

| Роль | Зона ответственности |
|------|---------------------|
| Product Owner | Приоритеты, метрики, App Store / Google Play |
| UI/UX Designer | Figma, design system, share templates |
| Flutter Developer | Flutter app (iOS + Android) |
| Supabase / Backend | Миграции, RLS, Edge Functions, OpenAI, webhooks |
| QA | Test cases, TestFlight, Internal Testing |

---

## 11. Риски и митигация

| Риск | Вероятность | Митигация |
|------|-------------|-----------|
| Высокий cost OpenAI API | Средняя | Resize, rate limits, кэш |
| App Store reject (AI content) | Низкая | Content moderation, clear ToS |
| Низкая конверсия paywall | Средняя | A/B цен, улучшение free experience |
| Неточные AI-рекомендации | Средняя | Prompt engineering, user feedback loop |
| Abuse (боты, spam) | Средняя | Auth required, RLS, rate limits в Edge Functions |
| Vendor lock-in Supabase | Низкая | PostgreSQL portable, Edge Functions → можно мигрировать |

---

## 12. Метрики успеха (KPI)

| Метрика | Цель (30 дней после launch) |
|---------|----------------------------|
| DAU | 1 000 |
| Free → Paid conversion | 5% |
| Checks per DAU | 1.5 |
| Share rate | 20% от completed checks |
| D1 retention | 40% |
| App Store rating | 4.5+ |
| Crash-free rate | 99.5% |

---

## 13. Юридические требования

- Privacy Policy (обработка фото, AI, third-party services)
- Terms of Service
- EULA для подписок (auto-renewable)
- GDPR compliance (EU users)
- Удаление данных по запросу (right to erasure)
- Apple Privacy Nutrition Labels
- Указание «AI-generated recommendations» в UI

---

## 14. Приложения

### A. Референсы дизайна

- [Cal AI](https://www.calai.app/) — score reveal, share cards
- [Lensa AI](https://prisma-ai.com/lensa) — photo-first UX
- [Duolingo](https://www.duolingo.com/) — gamification, streaks (для v2)
- [BeReal](https://bereal.com/) — authentic UGC aesthetic

### B. Конкуренты

| Приложение | Отличие Trendy Look |
|------------|---------------------|
| Combyne | Фокус на outfit builder, не на score |
| Stylebook | Wardrobe management, не AI-тренды |
| ChatGPT (напрямую) | Нет специализированного UX, paywall, истории |

### C. Deep link схема

```
trendylook://                    → Home
trendylook://check               → New check
trendylook://check/{id}          → View result
trendylook://paywall             → Paywall
trendylook://history             → History
https://trendylook.app/check/{id} → Universal link (web fallback)
```

---

*Документ подготовлен для старта разработки. Следующий шаг: дизайн-макеты в Figma и Supabase migrations + Edge Functions scaffold.*
