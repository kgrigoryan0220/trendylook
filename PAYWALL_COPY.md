# Paywall: пункты подписки для RevenueCat Dashboard

Пейвол рендерит RevenueCat (`PaywallView`), его тексты живут в RevenueCat Dashboard → Paywalls → current Offering → Localizations, а не в коде. Правится вручную в каждой из 7 локализаций.

## Что не так сейчас

Пункты «Priority AI analysis» и «Early access to trends» обещают то, чего в продукте нет. Это риск отказа App Review (2.3.1, 3.1.2).

## Что реально даёт Pro сегодня

В коде Pro отличается от Free только числом проверок (`billing.isPro` проверяется только перед новой проверкой). История, рекомендации и share-карточка одинаковы для всех. Поэтому пункты ниже описывают, что получает подписчик, и не обещают эксклюзивного.

Из ТЗ (2.3) в пейвол **не** берём, пока не реализовано:

- «Детальные рекомендации (расширенный блок)» — у Free те же рекомендации.
- «Share-карточки без водяного знака» — водяного знака нет ни у кого.

## Тексты

Первый пункт не меняется, второй и третий заменяют «Priority AI analysis» и «Early access to trends».

| Язык | Пункт 1 | Пункт 2 | Пункт 3 |
| --- | --- | --- | --- |
| en | Unlimited outfit checks | AI trend score and style tips for every look | All your checks saved in History |
| de | Unbegrenzte Outfit-Checks | Trend-% und KI-Tipps für jeden Look | Alle deine Checks im Verlauf |
| es | Comprobaciones de looks ilimitadas | % de tendencia y consejos de IA para cada look | Todas tus comprobaciones en el Historial |
| fr | Analyses de looks illimitées | % de tendance et conseils de l'IA pour chaque look | Toutes tes analyses dans l'Historique |
| it | Controlli dei look illimitati | % di tendenza e consigli dell'IA per ogni look | Tutti i tuoi controlli nella Cronologia |
| pt | Verificações de looks ilimitadas | % de tendência e dicas da IA para cada look | Todas as suas verificações no Histórico |
| ru | Безлимитные проверки образов | % трендовости и советы AI для каждого лука | Все проверки сохраняются в Истории |

Термины совпадают с интерфейсом приложения (`lib/l10n/app_*.arb`): «Check / Verlauf / Historial / Historique / Cronologia / Histórico / История».

## После правки

- [ ] Открыть пейвол на каждом из 7 языков (Профиль → Язык) и сверить пункты.
- [ ] Переснять скриншот `08_paywall.png`.
- [ ] Сайт (`website/src/data/site.ts`, блок Pricing) уже приведён к тем же пунктам.
