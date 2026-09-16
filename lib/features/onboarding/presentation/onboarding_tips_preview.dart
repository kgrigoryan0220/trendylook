import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../features/check/data/models/look_analysis.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/recommendation_card.dart';

/// Три демо-совета на 3-м слайде онбординга — тот же `RecommendationCard`,
/// что на экране результата проверки. Тексты из l10n.
/// Фиолетовый акцент циклически переходит 1 → 2 → 3 раз в секунду.
class OnboardingTipsPreview extends StatefulWidget {
  const OnboardingTipsPreview({
    super.key,
    required this.l10n,
    required this.play,
  });

  final AppLocalizations l10n;
  final bool play;

  @override
  State<OnboardingTipsPreview> createState() => _OnboardingTipsPreviewState();
}

class _OnboardingTipsPreviewState extends State<OnboardingTipsPreview> {
  static const _focusInterval = Duration(seconds: 1);

  int _focusedIndex = 0;
  Timer? _focusTimer;

  List<LookRecommendation> get _tips => [
        LookRecommendation(
          priority: 1,
          title: widget.l10n.onboardingTip1Title,
          description: widget.l10n.onboardingTip1Description,
          category: 'accessories',
        ),
        LookRecommendation(
          priority: 2,
          title: widget.l10n.onboardingTip2Title,
          description: widget.l10n.onboardingTip2Description,
          category: 'layers',
        ),
        LookRecommendation(
          priority: 3,
          title: widget.l10n.onboardingTip3Title,
          description: widget.l10n.onboardingTip3Description,
          category: 'proportions',
        ),
      ];

  @override
  void initState() {
    super.initState();
    if (widget.play) _startFocusCycle();
  }

  @override
  void didUpdateWidget(covariant OnboardingTipsPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _focusedIndex = 0;
      _startFocusCycle();
    } else if (!widget.play && oldWidget.play) {
      _stopFocusCycle();
      _focusedIndex = 0;
    }
  }

  void _startFocusCycle() {
    _focusTimer?.cancel();
    _focusTimer = Timer.periodic(_focusInterval, (_) {
      if (!mounted) return;
      setState(() => _focusedIndex = (_focusedIndex + 1) % 3);
    });
  }

  void _stopFocusCycle() {
    _focusTimer?.cancel();
    _focusTimer = null;
  }

  @override
  void dispose() {
    _stopFocusCycle();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tips = _tips;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < tips.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == tips.length - 1 ? 0 : 10),
            child: RecommendationCard(
              recommendation: tips[i],
              highlighted: widget.play && i == _focusedIndex,
            )
                .animate(
                  key: ValueKey('onboarding-tip-$i-${widget.play}'),
                  target: widget.play ? 1 : 0,
                )
                .fadeIn(
                  delay: (90 * i).ms,
                  duration: 420.ms,
                  curve: Curves.easeOutCubic,
                )
                .slideY(
                  begin: 0.22,
                  end: 0,
                  delay: (90 * i).ms,
                  duration: 480.ms,
                  curve: Curves.easeOutCubic,
                )
                .scale(
                  begin: const Offset(0.96, 0.96),
                  end: const Offset(1, 1),
                  delay: (90 * i).ms,
                  duration: 480.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
      ],
    );
  }
}
