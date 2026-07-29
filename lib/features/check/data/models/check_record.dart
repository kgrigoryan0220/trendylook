import 'look_analysis.dart';

/// Строка таблицы `checks` (TECH_SPEC_v1.2.md 6.4).
class CheckRecord {
  const CheckRecord({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.trendScore,
    required this.trendLabel,
    required this.analysis,
    required this.createdAt,
    this.shareImagePath,
  });

  factory CheckRecord.fromJson(Map<String, dynamic> json) {
    return CheckRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imagePath: json['image_path'] as String,
      trendScore: (json['trend_score'] as num).toInt(),
      trendLabel: json['trend_label'] as String,
      analysis: LookAnalysis.fromJson(
        Map<String, dynamic>.from(json['ai_response'] as Map),
      ),
      shareImagePath: json['share_image_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String userId;
  final String imagePath;
  final int trendScore;
  final String trendLabel;
  final LookAnalysis analysis;
  final String? shareImagePath;
  final DateTime createdAt;

  /// Для offline-кэша истории (разд. 7 — «история доступна offline»).
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'image_path': imagePath,
        'trend_score': trendScore,
        'trend_label': trendLabel,
        'ai_response': analysis.toJson(),
        'share_image_path': shareImagePath,
        'created_at': createdAt.toIso8601String(),
      };
}
