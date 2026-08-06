import 'package:flutter/widgets.dart';

import '../../l10n/gen/app_localizations.dart';

/// Локализованное название категории по фиксированному английскому ключу,
/// который возвращает AI (color_palette/silhouette/accessories/footwear —
/// TECH_SPEC_v1.2.md 5.3). Сам ключ не переводится нейросетью, поэтому
/// подпись строим на клиенте по текущей локали приложения.
String localizedCategoryName(BuildContext context, String key) {
  final l10n = AppLocalizations.of(context);
  switch (key) {
    case 'color_palette':
      return l10n.categoryColorPalette;
    case 'silhouette':
      return l10n.categorySilhouette;
    case 'accessories':
      return l10n.categoryAccessories;
    case 'footwear':
      return l10n.categoryFootwear;
    default:
      return key;
  }
}
