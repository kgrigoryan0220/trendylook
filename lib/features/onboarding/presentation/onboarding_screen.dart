import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/score_ring.dart';
import 'onboarding_prefs.dart';

/// 4.2 Onboarding (3 слайда + progress dots).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  List<_SlideData> _slides(AppLocalizations l10n) => [
        _SlideData(
          title: l10n.onboardingSlide1Title,
          subtitle: l10n.onboardingSlide1Subtitle,
          icon: Icons.camera_alt_outlined,
        ),
        _SlideData(
          title: l10n.onboardingSlide2Title,
          subtitle: l10n.onboardingSlide2Subtitle,
          icon: null,
        ),
        _SlideData(
          title: l10n.onboardingSlide3Title,
          subtitle: l10n.onboardingSlide3Subtitle,
          icon: Icons.auto_awesome_outlined,
        ),
      ];

  Future<void> _finish() async {
    await ref.read(onboardingPrefsProvider).markSeen();
    ref.read(analyticsServiceProvider).track('onboarding_complete');
    if (mounted) context.go('/auth');
  }

  static const _slideCount = 3;

  void _next() {
    if (_page == _slideCount - 1) {
      _finish();
    } else {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = _slides(l10n);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 60, 28, 40),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: slides.length,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (context, index) => _SlideView(data: slides[index]),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? AppColors.pink : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: _next,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            child: Center(
                              child: Text(
                                _page == slides.length - 1
                                    ? l10n.onboardingStart
                                    : l10n.onboardingNext,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 0,
              child: TextButton(
                onPressed: _finish,
                child: Text(l10n.onboardingSkip, style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  const _SlideData({required this.title, required this.subtitle, this.icon});
  final String title;
  final String subtitle;
  final IconData? icon;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.data});
  final _SlideData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (data.icon != null)
          Container(
            width: 220,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(data.icon, size: 56, color: AppColors.textSecondary),
          )
        else
          const ScoreRing(score: 82, label: 'Trendy', size: 200, animate: false),
        const SizedBox(height: 32),
        Text(
          data.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 24, height: 1.25),
        ),
        const SizedBox(height: 8),
        Text(
          data.subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}
