import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../features/check/data/models/check_record.dart';

/// History Item — thumbnail + score badge + дата (разд. 4.3/5, 4.11).
///
/// `photoUrl` — уже полученный signed URL (bucket приватный, см. 6.4/6.6);
/// разрешение подписанных ссылок делает вызывающий экран (батчем на страницу).
class HistoryItemTile extends StatelessWidget {
  const HistoryItemTile({
    super.key,
    required this.check,
    required this.onTap,
    this.photoUrl,
  });

  final CheckRecord check;
  final VoidCallback onTap;
  final String? photoUrl;

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
                child: photoUrl == null
                    ? Container(
                        width: 52,
                        height: 52,
                        color: Colors.white.withValues(alpha: 0.08),
                      )
                    : Image.network(
                        photoUrl!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 52,
                          height: 52,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
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
                      DateFormat('d MMM', 'ru').format(check.createdAt),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '${check.trendScore}%',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
