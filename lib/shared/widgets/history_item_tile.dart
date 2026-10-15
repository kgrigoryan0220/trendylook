import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../features/check/data/models/check_record.dart';
import 'look_photo.dart';

/// History Item — thumbnail + score badge + дата (разд. 4.3/5, 4.11).
///
/// Фото берётся из дискового кэша по `check.imagePath` (см. [LookPhoto]).
class HistoryItemTile extends StatelessWidget {
  const HistoryItemTile({
    super.key,
    required this.check,
    required this.onTap,
  });

  final CheckRecord check;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.colorForScore(check.trendScore);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: LookPhoto(
                  imagePath: check.imagePath,
                  width: 52,
                  height: 52,
                  cacheWidth: (52 * MediaQuery.devicePixelRatioOf(context)).round(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      check.trendLabel.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('d MMM', Localizations.localeOf(context).languageCode)
                          .format(check.createdAt),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '${check.trendScore}%',
                style: AppTheme.heading(context, fontSize: 16, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
