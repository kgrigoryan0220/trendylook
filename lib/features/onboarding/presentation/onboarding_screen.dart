import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/score_ring.dart';
import 'onboarding_look_carousel.dart';
import 'onboarding_prefs.dart';
import 'onboarding_tips_preview.dart';

const _slide1Looks = [
  'assets/onboarding/look_1.jpg',
  'assets/onboarding/look_2.jpg',
  'assets/onboarding/look_3.jpg',
];

/// 4.2 Onboarding (3 слайда + progress dots).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  final _viewedSteps = <int>{};

  List<_SlideData> _slides(AppLocalizations l10n) => [
        _SlideData(
          title: l10n.onboardingSlide1Title,
          subtitle: l10n.onboardingSlide1Subtitle,
          visual: _SlideVisual.lookCarousel,
        ),
        _SlideData(
          title: l10n.onboardingSlide2Title,
          subtitle: l10n.onboardingSlide2Subtitle,
          visual: _SlideVisual.scoreRing,
        ),
        _SlideData(
          title: l10n.onboardingSlide3Title,
          subtitle: l10n.onboardingSlide3Subtitle,
          visual: _SlideVisual.tipsPreview,
        ),
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _trackStepViewed(0));
  }

  void _trackStepViewed(int pageIndex) {
    final step = pageIndex + 1;
    if (!_viewedSteps.add(step)) return;
    ref.read(analyticsServiceProvider).track('onboarding_step_viewed', {
      'step': step,
      'step_total': _slideCount,
    });
  }

  Future<void> _complete({required String method}) async {
    await ref.read(onboardingPrefsProvider).markSeen();
    ref.read(analyticsServiceProvider).track('onboarding_complete', {
      'method': method, // start | skip
      'last_step': _page + 1,
      'steps_viewed': _viewedSteps.length,
    });
    if (mounted) context.go('/auth');
  }

  Future<void> _skip() async {
    ref.read(analyticsServiceProvider).track('onboarding_skipped', {
      'from_step': _page + 1,
      'steps_viewed': _viewedSteps.length,
    });
    await _complete(method: 'skip');
  }

  static const _slideCount = 3;

  void _next() {
    if (_page == _slideCount - 1) {
      _complete(method: 'start');
    } else {
      ref.read(analyticsServiceProvider).track('onboarding_next_tapped', {
        'from_step': _page + 1,
        'to_step': _page + 2,
      });
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
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 40),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: slides.length,
                      onPageChanged: (i) {
                        setState(() => _page = i);
                        _trackStepViewed(i);
                      },
                      itemBuilder: (context, index) => _SlideView(
                        data: slides[index],
                        active: index == _page,
                      ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
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
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 0,
              child: TextButton(
                onPressed: _skip,
                child: Text(l10n.onboardingSkip, style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SlideVisual { lookCarousel, scoreRing, tipsPreview }

class _SlideData {
  const _SlideData({
    required this.title,
    required this.subtitle,
    required this.visual,
  });
  final String title;
  final String subtitle;
  final _SlideVisual visual;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.data, required this.active});
  final _SlideData data;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                switch (data.visual) {
                  _SlideVisual.lookCarousel => const OnboardingLookCarousel(
                      images: _slide1Looks,
                      height: 268,
                    ),
                  _SlideVisual.scoreRing => ScoreRing(
                      score: 82,
                      label: 'Trendy',
                      size: 200,
                      animate: active,
                    ),
                  _SlideVisual.tipsPreview => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OnboardingTipsPreview(l10n: l10n, play: active),
                    ),
                },
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: AppTheme.heading(context, fontSize: 24, height: 1.25),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
