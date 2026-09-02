import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/check/data/models/check_record.dart';
import '../../features/home/presentation/home_history_aspect_ratio.dart';

/// Pinterest-style history card for Home masonry grid.
class HistoryMasonryCard extends StatelessWidget {
  const HistoryMasonryCard({
    super.key,
    required this.check,
    required this.onTap,
    this.photoUrl,
  })  : skeletonAspectRatio = null;

  const HistoryMasonryCard.skeleton({
    super.key,
    required double aspectRatio,
  })  : check = null,
        onTap = null,
        photoUrl = null,
        skeletonAspectRatio = aspectRatio;

  final CheckRecord? check;
  final VoidCallback? onTap;
  final String? photoUrl;
  final double? skeletonAspectRatio;

  @override
  Widget build(BuildContext context) {
    final skeletonRatio = skeletonAspectRatio;
    if (check == null && skeletonRatio != null) {
      return AspectRatio(
        aspectRatio: skeletonRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    final record = check!;
    final ratio = aspectRatioForCheck(record);
    final scoreColor = AppColors.colorForScore(record.trendScore);
    final dateLabel = DateFormat(
      'd MMM',
      Localizations.localeOf(context).languageCode,
    ).format(record.createdAt);
    final semanticsLabel = '${record.trendLabel}, ${record.trendScore}%, $dateLabel';

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: ratio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _Photo(photoUrl: photoUrl),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xCC0B0B10)],
                      stops: [0.45, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: scoreColor.withValues(alpha: 0.7)),
                    ),
                    child: Text(
                      '${record.trendScore}%',
                      style: AppTheme.heading(context, fontSize: 13, color: scoreColor),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        record.trendLabel.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateLabel,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null) {
      return ColoredBox(color: Colors.white.withValues(alpha: 0.08));
    }
    return Image.network(
      photoUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => ColoredBox(color: Colors.white.withValues(alpha: 0.08)),
    );
  }
}
