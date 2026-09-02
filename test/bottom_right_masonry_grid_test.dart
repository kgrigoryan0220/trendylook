import 'package:flutter_test/flutter_test.dart';
import 'package:trendylook/shared/widgets/bottom_right_masonry_grid.dart';

void main() {
  group('groupItemsBottomRightMasonry', () {
    test('2 columns: newest in right column first', () {
      final columns = groupItemsBottomRightMasonry(
        ['A', 'B', 'C', 'D'],
        crossAxisCount: 2,
      );

      expect(columns[0], ['B', 'D']);
      expect(columns[1], ['A', 'C']);
    });

    test('3 columns: fills right to left on bottom row', () {
      final columns = groupItemsBottomRightMasonry(
        ['A', 'B', 'C', 'D', 'E'],
        crossAxisCount: 3,
      );

      expect(columns[0], ['C']);
      expect(columns[1], ['B', 'E']);
      expect(columns[2], ['A', 'D']);
    });

    test('single item lands in rightmost column', () {
      final columns = groupItemsBottomRightMasonry(
        ['only'],
        crossAxisCount: 2,
      );

      expect(columns[0], isEmpty);
      expect(columns[1], ['only']);
    });
  });
}
