import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/check/data/models/look_analysis.dart';

/// Category Bar — иконка + название + мини progress bar (Result, разд. 4.3/5).
class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key, required this.category, this.compact = false});

  final LookCategory category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.colorForScore(category.score);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.displayName,
              style: TextStyle(
                fontSize: compact ? 9.5 : 13,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: compact ? 0.85 : 1),
              ),
            ),
            Text(
              '${category.score}%',
              style: TextStyle(
                fontSize: compact ? 9.5 : 13,
                color: compact ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 2 : 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: category.score / 100,
            minHeight: compact ? 4 : 7,
            backgroundColor: Colors.white.withValues(alpha: compact ? 0.2 : 0.08),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
