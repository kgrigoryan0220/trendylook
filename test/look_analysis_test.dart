import 'package:flutter_test/flutter_test.dart';
import 'package:trendylook/features/check/data/models/look_analysis.dart';

void main() {
  test('LookAnalysis.fromJson parses the analyze-look response shape (5.3)', () {
    final analysis = LookAnalysis.fromJson({
      'trend_score': 78,
      'trend_label': 'Trendy',
      'categories': [
        {'name': 'color_palette', 'score': 82, 'comment': 'ok'},
        {'name': 'silhouette', 'score': 75, 'comment': 'ok'},
        {'name': 'accessories', 'score': 70, 'comment': 'ok'},
        {'name': 'footwear', 'score': 80, 'comment': 'ok'},
      ],
      'recommendations': [
        {
          'priority': 2,
          'title': 'second',
          'description': '...',
          'category': 'accessories',
        },
        {
          'priority': 1,
          'title': 'first',
          'description': '...',
          'category': 'accessories',
        },
      ],
      'trend_tags': ['quiet luxury', 'minimalist'],
      'summary': 'Собранный образ.',
    });

    expect(analysis.trendScore, 78);
    expect(analysis.categories, hasLength(4));
    // Отсортированы по priority независимо от порядка в ответе API.
    expect(analysis.recommendations.first.title, 'first');
    expect(analysis.recommendations.last.title, 'second');
    expect(analysis.trendTags, contains('quiet luxury'));
  });
}
