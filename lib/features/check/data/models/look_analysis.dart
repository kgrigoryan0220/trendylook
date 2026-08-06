/// AI-ответ по TECH_SPEC_v1.2.md 5.3.
class LookAnalysis {
  const LookAnalysis({
    required this.trendScore,
    required this.trendLabel,
    required this.categories,
    required this.recommendations,
    required this.trendTags,
    required this.summary,
  });

  factory LookAnalysis.fromJson(Map<String, dynamic> json) {
    return LookAnalysis(
      trendScore: (json['trend_score'] as num).toInt(),
      trendLabel: json['trend_label'] as String,
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => LookCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((e) => LookRecommendation.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.priority.compareTo(b.priority)),
      trendTags: (json['trend_tags'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      summary: json['summary'] as String? ?? '',
    );
  }

  final int trendScore;
  final String trendLabel;
  final List<LookCategory> categories;
  final List<LookRecommendation> recommendations;
  final List<String> trendTags;
  final String summary;

  /// Для offline-кэша истории (разд. 7 — «история доступна offline»).
  Map<String, dynamic> toJson() => {
        'trend_score': trendScore,
        'trend_label': trendLabel,
        'categories': categories.map((c) => c.toJson()).toList(),
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
        'trend_tags': trendTags,
        'summary': summary,
      };
}

class LookCategory {
  const LookCategory({
    required this.name,
    required this.score,
    required this.comment,
  });

  factory LookCategory.fromJson(Map<String, dynamic> json) {
    return LookCategory(
      name: json['name'] as String,
      score: (json['score'] as num).toInt(),
      comment: json['comment'] as String? ?? '',
    );
  }

  final String name;
  final int score;
  final String comment;

  Map<String, dynamic> toJson() => {'name': name, 'score': score, 'comment': comment};
}

class LookRecommendation {
  const LookRecommendation({
    required this.priority,
    required this.title,
    required this.description,
    required this.category,
  });

  factory LookRecommendation.fromJson(Map<String, dynamic> json) {
    return LookRecommendation(
      priority: (json['priority'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  final int priority;
  final String title;
  final String description;
  final String category;

  Map<String, dynamic> toJson() => {
        'priority': priority,
        'title': title,
        'description': description,
        'category': category,
      };
}
