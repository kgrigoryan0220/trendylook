# Store Release Checklist — Trendy Look

Что нужно сделать / чего не хватает для выгрузки билда в **App Store** и **Google Play**.  
Актуально на состояние репозитория (Bundle ID, signing, monетизация, legal).

---

## Уже есть в коде

| Что | Значение |
|-----|----------|
| iOS Bundle ID | `app.trendylook.trendylook` |
| Android `applicationId` / namespace | `app.trendylook.trendylook` |
| Version | `1.0.0+1` (`pubspec.yaml`) |
| Product IDs (в коде) | `weekly_unlimited`, `halfyear_unlimited` |
| Delete account | Profile → «Удалить аккаунт» |
| Legal docs (markdown) | `legal/PRIVACY_POLICY.md`, `legal/TERMS_OF_SERVICE.md` |
| Camera / Photos usage strings | `ios/Runner/Info.plist` |
| Deep link scheme | `trendylook://` |
| Google Sign-In iOS Client ID | прописан в `Info.plist` (`GIDClientID` + reversed URL scheme) |
| App icons | брендированные (iOS `AppIcon` + Android `ic_launcher`) |
| Support / legal email (в docs) | `trendylook2026@outlook.com` |
| Legal entity | Artur Arzumanian, Lochini str., N 3, Floor 2, Apt N5, Tbilisi 0152, Georgia |

---

## 1. Идентичность и брендинг

- [ ] Display name: сейчас `Trendylook` / `trendylook` — зафиксировать финальное имя (например **Trendy Look**)
- [x] Иконки: брендированные уже стоят (iOS `AppIcon.appiconset`, Android `mipmap/*/ic_launcher`)
- [ ] Splash / launch screen — проверить, что совпадает с брендом (не дефолтный Flutter)
- [ ] App Store / Play screenshots (iPhone 6.7", 6.5", 5.5"; Android phone; tablet — если поддерживаете)
- [ ] Описание, subtitle/short description, keywords, категории, age rating

---

## 2. Подписи и релиз-сборки

### iOS

- [ ] Apple Developer Program (платный аккаунт)
- [ ] `DEVELOPMENT_TEAM` в Xcode (сейчас в `project.pbxproj` не зафиксирован)
- [ ] Capability **Sign In with Apple**
- [ ] Capability **In-App Purchase**
- [ ] Distribution certificate + App Store provisioning profile (или Automatic signing с Team)
- [ ] Archive → Upload (Xcode / Transporter / `flutter build ipa`)
- [ ] `ITSAppUsesNonExemptEncryption` в `Info.plist` (обычно `false`, если только HTTPS)

### Android

- [ ] Release keystore (**сейчас release подписан debug** — в Play Console так нельзя)
- [ ] `key.properties` + `signingConfigs.release` в `android/app/build.gradle.kts`
- [ ] Upload key + Google Play App Signing
- [ ] Сборка: `flutter build appbundle` (AAB, не APK)

Пример команд после настройки signing:

```bash
flutter build ipa \
  --dart-define=REVENUECAT_API_KEY_IOS=appl_... \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=...

flutter build appbundle \
  --dart-define=REVENUECAT_API_KEY_ANDROID=goog_... \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=...
```

---

## 3. App Store Connect / Google Play Console

- [ ] Создать приложение с Bundle ID / package `app.trendylook.trendylook`
- [ ] Banking / tax / agreements (Paid Applications, In-App Purchases)
- [ ] **Privacy Policy URL** (публичный HTTPS) — markdown есть, **хостинга нет**
- [ ] Terms of Service URL (желательно)
- [ ] Support URL / support email: `trendylook2026@outlook.com`
- [ ] Apple Privacy Nutrition Labels / Google Play **Data safety** — по `legal/PRIVACY_POLICY.md`
- [ ] Account deletion disclosure (Apple): путь **Profile → Delete account**
- [ ] Age rating / «Made for Kids» = No

---

## 4. Подписки и RevenueCat

Product IDs должны **совпадать** в коде, сторах и RC:

| Plan | Product ID | Длительность |
|------|------------|--------------|
| Weekly | `weekly_unlimited` | 7 дней |
| Half-year | `halfyear_unlimited` | 6 месяцев |

- [ ] App Store Connect: Subscription Group + оба продукта
- [ ] Google Play Console: те же product IDs + base plans
- [ ] RevenueCat: apps iOS + Android, entitlement (напр. `pro`), Current Offering с двумя packages
- [ ] Связать RC ↔ App Store Connect / Google Play (Shared Secret / Service Account)
- [ ] Webhook URL:  
  `https://jilreygcmqhemhsmetqd.supabase.co/functions/v1/revenuecat-webhook`  
  Authorization: `Bearer <REVENUECAT_WEBHOOK_SECRET>`
- [ ] Supabase secret: `REVENUECAT_WEBHOOK_SECRET`
- [ ] Release-сборки с `--dart-define=REVENUECAT_API_KEY_IOS/ANDROID=...`
- [ ] Sandbox E2E: покупка → RC webhook → таблица `subscriptions` → статус Pro в Profile
- [ ] (Опционально, промокоды) `REVENUECAT_SECRET_API_KEY`, `REVENUECAT_ENTITLEMENT_ID=pro`

> В приложении нет отдельного «sandbox mode»: sandbox — это тестовые покупки Apple/Google; пайплайн тот же, что и live.

---

## 5. Auth

### Sign in with Apple

- [ ] Services ID, Key, Team ID в Supabase → Authentication → Providers → Apple
- [ ] Capability **Sign In with Apple** в Xcode (Runner target)
- [ ] Bundle ID совпадает с ASC app

### Google Sign-In

- [ ] OAuth clients в Google Cloud: **Web** + **iOS** + **Android**
- [ ] Android: SHA-1 **release** keystore добавлен в Google Cloud Console
- [ ] `--dart-define=GOOGLE_SERVER_CLIENT_ID=<Web Client ID>` в release build  
  (для debug см. `IOS_RUN.md`)
- [ ] Supabase Auth: Google provider включён; для iOS — Skip nonce check (см. `IOS_RUN.md`)

---

## 6. Legal / in-app (важно для модерации)

- [ ] Захостить Privacy Policy + Terms на публичный HTTPS (GitHub Pages, Notion, свой домен и т.п.)
- [ ] В Profile: кликабельные строки Privacy / Terms / Support — **сейчас без `onTap`**
- [ ] На Paywall: кликабельные «Terms · Privacy»
- [ ] Auto-renew disclosure: есть в Terms; продублировать короткий текст на paywall (Apple часто требует)

Контакты в docs уже проставлены:

- Legal entity: Artur Arzumanian  
- Address: Lochini str., N 3, Floor 2, Apartment N5, Tbilisi 0152, Georgia  
- Email: `trendylook2026@outlook.com`  
- Governing law: Georgia / courts in Tbilisi

---

## 7. Secrets для prod

### Flutter (`--dart-define` при build)

| Define | Обязателен |
|--------|------------|
| `REVENUECAT_API_KEY_IOS` | да (iOS) |
| `REVENUECAT_API_KEY_ANDROID` | да (Android) |
| `GOOGLE_SERVER_CLIENT_ID` | да (Google Sign-In) |
| `SENTRY_DSN` | опционально |
| `POSTHOG_API_KEY` | опционально |

Supabase URL / anon key уже зашиты в `AppConfig` по умолчанию (это клиентские ключи).

### Supabase Edge Functions → Secrets

| Secret | Для |
|--------|-----|
| `OPENAI_API_KEY` | `analyze-look` |
| `REVENUECAT_WEBHOOK_SECRET` | `revenuecat-webhook` |
| `REVENUECAT_SECRET_API_KEY` | промокоды (`redeem-promo`) |
| `REVENUECAT_ENTITLEMENT_ID` | промокоды (напр. `pro`) |

---

## 8. Мелочи, которые часто режут ревью

- [ ] Android 13+: доступ к галерее (`READ_MEDIA_IMAGES` / Photo Picker) — проверить фактическое поведение `image_picker`
- [ ] Play Billing permission подтянется через billing library; убедиться, что AAB включает billing
- [ ] Privacy Manifest (`PrivacyInfo.xcprivacy`) — отдельного файла в репо нет; plugins Flutter могут добавлять свои
- [ ] Export compliance (шифрование) в ASC
- [ ] TestFlight (iOS) / Internal testing (Android) перед публичным релизом
- [ ] Проверить, что paywall без RC keys не уходит в прод («Payments aren't set up yet»)

---

## Рекомендуемый порядок работ

1. Release signing (Android keystore + iOS Team) + display name (иконки уже готовы) 
2. Захостить legal + кликабельные ссылки в Profile / Paywall  
3. Создать apps в ASC / Play + IAP products  
4. RevenueCat + webhook + keys в release build  
5. Sign In with Apple capability + Google SHA-1 release  
6. Sandbox E2E покупка → Pro  
7. TestFlight / Internal testing → Submit for review  

---

## Критичные дыры прямо сейчас

1. **Android release signing** — всё ещё debug  
2. **Публичный Privacy Policy URL** — нет хостинга  
3. **IAP products в сторах + RC public keys** в релизе  
4. **Sign In with Apple** capability в Xcode  
5. **Кликабельные legal/support** в Profile и на Paywall  
6. **DEVELOPMENT_TEAM** / App Store distribution для iOS  

---

## Связанные файлы

| Файл | Зачем |
|------|--------|
| `legal/PRIVACY_POLICY.md` | Privacy Policy |
| `legal/TERMS_OF_SERVICE.md` | Terms of Service |
| `lib/core/constants/app_constants.dart` | Product IDs |
| `lib/core/config/app_config.dart` | dart-defines |
| `android/app/build.gradle.kts` | applicationId, signing (сейчас debug) |
| `ios/Runner/Info.plist` | Bundle display name, permissions, Google |
| `IOS_RUN.md` | Debug-запуск iOS + Google Client ID |
| `README.md` | Supabase secrets, RC webhook |
| `PROMO_CODES_PLAN.md` | Staging / RC / промокоды (расширенный план) |
