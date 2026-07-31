import 'package:flutter_test/flutter_test.dart';
import 'package:trendylook/core/theme/app_colors.dart';

void main() {
  group('AppColors.colorForScore (TECH_SPEC_v1.2.md 5.3 scale)', () {
    test('0-39 -> error (Needs Work)', () {
      expect(AppColors.colorForScore(0), AppColors.error);
      expect(AppColors.colorForScore(39), AppColors.error);
    });

    test('40-59 -> warning (Getting There)', () {
      expect(AppColors.colorForScore(40), AppColors.warning);
      expect(AppColors.colorForScore(59), AppColors.warning);
    });

    test('60-79 -> pink (Trendy)', () {
      expect(AppColors.colorForScore(60), AppColors.pink);
      expect(AppColors.colorForScore(79), AppColors.pink);
    });

    test('80-100 -> lime (Icon Status)', () {
      expect(AppColors.colorForScore(80), AppColors.lime);
      expect(AppColors.colorForScore(100), AppColors.lime);
    });
  });
}
