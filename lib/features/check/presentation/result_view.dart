import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/category_bar.dart';
import '../../../shared/widgets/confetti_overlay.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/recommendation_card.dart';
import '../../../shared/widgets/score_ring.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../data/models/check_record.dart';

/// 4.8 Result — core viral screen. Общая вёрстка для флоу-режима (после
/// анализа) и read-only детального просмотра из Истории.
class ResultView extends StatelessWidget {
  const ResultView({
    super.key,
    required this.record,
    required this.photo,
    required this.onShare,
    required this.onPrimaryAction,
    required this.primaryActionLabel,
    this.onClose,
    this.onBack,
  });

  static const _photoHeight = 210.0;
  static const _scoreRingSize = 200.0;
  static const _scoreRingPhotoOverlap = 64.0;
  static const _contentOverlap = 44.0;
  /// Доля высоты фото без затемнения (как в оригинале ~40%, чуть больше для лица).
  static const _fadeClearPhotoRatio = 0.55;

  final CheckRecord record;
  final Widget photo;
  final VoidCallback onShare;
  final VoidCallback onPrimaryAction;
  final String primaryActionLabel;
  final VoidCallback? onClose;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isIconStatus = record.trendScore >= 80;
    final screenHeight = MediaQuery.sizeOf(context).height;
    // Кольцо — по центру экрана; контент сохраняет исходный зазор относительно кольца.
    final ringTranslateY = screenHeight / 2 - _scoreRingSize / 2 - _photoHeight;
    final contentTranslateY = ringTranslateY + _scoreRingPhotoOverlap - _contentOverlap;
    final fadeHeight = _photoHeight + ringTranslateY + _scoreRingSize;
    final fadeStartStop =
        (_photoHeight * _fadeClearPhotoRatio / fadeHeight).clamp(0.0, 0.92);
    // Transform.translate не меняет layout-height — компенсируем сдвиг для скролла.
    final scrollBottomInset = math.max(0.0, contentTranslateY);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: 32 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: _photoHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: fadeHeight,
                        child: photo,
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: fadeHeight,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0, fadeStartStop, 1],
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  AppColors.background,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 8),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: _RoundBackButton(
                              icon: onBack != null ? Icons.arrow_back_ios_new : Icons.close,
                              onTap: onBack ?? onClose,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, ringTranslateY),
                  child: Center(
                    child: ScoreRing(
                      score: record.trendScore,
                      label: record.trendLabel,
                      size: _scoreRingSize,
                      animate: onBack == null,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, contentTranslateY),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: record.analysis.categories
                              .map(
                                (c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: CategoryBar(category: c),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.recommendationsTitle,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        ...record.analysis.recommendations.map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: RecommendationCard(
                              recommendation: r,
                              highlighted: r.priority == 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(label: l10n.share, onPressed: onShare),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: PrimaryButton(
                                label: primaryActionLabel,
                                onPressed: onPrimaryAction,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: scrollBottomInset),
              ],
            ),
          ),
          if (isIconStatus) const Positioned.fill(child: ConfettiOverlay()),
        ],
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.background.withValues(alpha: 0.5),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}
