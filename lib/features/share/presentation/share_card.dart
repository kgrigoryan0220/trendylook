import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../check/data/models/check_record.dart';

/// Share-карточка — MVP: 1 шаблон (Bold), формат 9:16 (TECH_SPEC_v1.2.md 4.3,
/// SHARE-02). Challenge hook: «отметь друга» — использует deep link
/// `trendylook://check/{id}` (4.4 UGC-механики), отдельной инфраструктуры не требует.
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.record, required this.photo});

  final CheckRecord record;
  final Widget photo;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.colorForScore(record.trendScore);
    final topRec =
        record.analysis.recommendations.isNotEmpty ? record.analysis.recommendations.first : null;

    return AspectRatio(
      aspectRatio: 9 / 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            photo,
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.55, 1],
                  colors: [
                    Color(0x260B0B10),
                    Color(0x260B0B10),
                    Color(0xE60B0B10),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: ShaderMask(
                shaderCallback: (bounds) => AppColors.gradientPrimary.createShader(bounds),
                child: const Text(
                  'Trendy Look',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${record.trendScore}%',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 40, color: color),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        record.trendLabel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (topRec != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      topRec.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.3),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).shareChallengeHook,
                    style: const TextStyle(fontSize: 10.5, color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'trendylook.app',
                        style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
                      ),
                      Container(width: 22, height: 22, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
