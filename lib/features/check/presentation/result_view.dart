import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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

  final CheckRecord record;
  final Widget photo;
  final VoidCallback onShare;
  final VoidCallback onPrimaryAction;
  final String primaryActionLabel;
  final VoidCallback? onClose;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final isIconStatus = record.trendScore >= 80;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    SizedBox(height: 210, width: double.infinity, child: photo),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.4, 1],
                            colors: [
                              Colors.transparent,
                              AppColors.background,
                            ],
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
                Transform.translate(
                  offset: const Offset(0, -64),
                  child: Center(
                    child: ScoreRing(
                      score: record.trendScore,
                      label: record.trendLabel,
                      animate: onBack == null,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -44),
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
                        const Text(
                          '💡 Рекомендации',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
                              child: SecondaryButton(label: 'Поделиться', onPressed: onShare),
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
