import '../../check/data/models/check_record.dart';

/// Deterministic masonry heights without loading image metadata (HOME_HISTORY_MASONRY_TZ §6.3).
const homeHistoryAspectRatios = [0.75, 0.85, 1.0, 1.15, 1.3];

double aspectRatioForCheck(CheckRecord check) {
  return homeHistoryAspectRatios[check.id.hashCode.abs() % homeHistoryAspectRatios.length];
}

/// API pages are DESC; display on Home is ASC (oldest first).
List<CheckRecord> descPageToAsc(List<CheckRecord> pageDesc) {
  return pageDesc.reversed.toList();
}
