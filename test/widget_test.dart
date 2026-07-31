import 'package:flutter_test/flutter_test.dart';
import 'package:trendylook/features/check/data/models/look_analysis.dart';

void main() {
  test('LookCategory.displayName maps known category keys to Russian labels', () {
    expect(
      const LookCategory(name: 'color_palette', score: 80, comment: '').displayName,
      'Цветовая палитра',
    );
    expect(
      const LookCategory(name: 'footwear', score: 80, comment: '').displayName,
      'Обувь',
    );
  });
}
