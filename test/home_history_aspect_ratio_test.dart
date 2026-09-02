import 'package:flutter_test/flutter_test.dart';
import 'package:trendylook/features/check/data/models/check_record.dart';
import 'package:trendylook/features/check/data/models/look_analysis.dart';
import 'package:trendylook/features/home/presentation/home_history_aspect_ratio.dart';

CheckRecord _record(String id, DateTime createdAt) {
  return CheckRecord(
    id: id,
    userId: 'user-1',
    imagePath: 'path/$id.jpg',
    trendScore: 70,
    trendLabel: 'Trendy',
    analysis: LookAnalysis.fromJson(const {
      'trend_score': 70,
      'trend_label': 'Trendy',
      'categories': [],
      'recommendations': [],
      'trend_tags': [],
      'summary': 'ok',
    }),
    createdAt: createdAt,
  );
}

void main() {
  group('aspectRatioForCheck', () {
    test('returns a ratio from the predefined set', () {
      final ratio = aspectRatioForCheck(_record('abc', DateTime(2026, 1, 1)));
      expect(homeHistoryAspectRatios, contains(ratio));
    });

    test('is stable for the same check id', () {
      final check = _record('stable-id', DateTime(2026, 1, 1));
      expect(aspectRatioForCheck(check), aspectRatioForCheck(check));
    });
  });

  group('descPageToAsc', () {
    test('reverses API DESC page to ASC display order', () {
      final t1 = DateTime(2026, 1, 1);
      final t2 = DateTime(2026, 1, 2);
      final t3 = DateTime(2026, 1, 3);
      final pageDesc = [
        _record('new', t3),
        _record('mid', t2),
        _record('old', t1),
      ];

      final asc = descPageToAsc(pageDesc);

      expect(asc.map((c) => c.id).toList(), ['old', 'mid', 'new']);
    });
  });
}
