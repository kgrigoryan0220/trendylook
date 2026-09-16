import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Cover-flow карусель для онбординга: центр крупный и яркий,
/// соседние карточки меньше и приглушены. Автопрокрутка + свайп.
class OnboardingLookCarousel extends StatefulWidget {
  const OnboardingLookCarousel({
    super.key,
    required this.images,
    this.height = 240,
  });

  final List<String> images;
  final double height;

  @override
  State<OnboardingLookCarousel> createState() => _OnboardingLookCarouselState();
}

class _OnboardingLookCarouselState extends State<OnboardingLookCarousel> {
  static const _viewportFraction = 0.58;
  static const _autoPlayInterval = Duration(seconds: 2);
  static const _animDuration = Duration(milliseconds: 520);

  late final PageController _controller;
  late final int _initialPage;
  Timer? _timer;
  double _page = 0;

  int get _count => widget.images.length;

  @override
  void initState() {
    super.initState();
    // Большой «кольцевой» буфер, чтобы свайп/автопрокрутка шли бесконечно.
    _initialPage = _count * 500;
    _page = _initialPage.toDouble();
    _controller = PageController(
      initialPage: _initialPage,
      viewportFraction: _viewportFraction,
    );
    _controller.addListener(_onScroll);
    _startAutoPlay();
  }

  void _onScroll() {
    if (!_controller.hasClients || _controller.page == null) return;
    setState(() => _page = _controller.page!);
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (_count < 2) return;
    _timer = Timer.periodic(_autoPlayInterval, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_controller.page ?? _initialPage.toDouble()).round() + 1;
      _controller.animateToPage(
        next,
        duration: _animDuration,
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _pauseAutoPlay() {
    _timer?.cancel();
  }

  void _resumeAutoPlay() {
    _startAutoPlay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0) return SizedBox(height: widget.height);

    return SizedBox(
      height: widget.height,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification &&
              notification.dragDetails != null) {
            _pauseAutoPlay();
          } else if (notification is ScrollEndNotification) {
            _resumeAutoPlay();
          }
          return false;
        },
        child: PageView.builder(
          controller: _controller,
          itemBuilder: (context, index) {
            final image = widget.images[index % _count];
            final delta = (_page - index).abs();
            final t = (1.0 - delta).clamp(0.0, 1.0);
            final scale = 0.78 + 0.22 * t;
            final opacity = 0.38 + 0.62 * t;
            final elevation = 2.0 + 10.0 * t;

            return Center(
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: _LookCard(
                    assetPath: image,
                    elevation: elevation,
                    highlighted: t > 0.85,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LookCard extends StatelessWidget {
  const _LookCard({
    required this.assetPath,
    required this.elevation,
    required this.highlighted,
  });

  final String assetPath;
  final double elevation;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: highlighted
                  ? AppColors.pink.withValues(alpha: 0.28)
                  : Colors.black.withValues(alpha: 0.35),
              blurRadius: elevation * 1.4,
              offset: Offset(0, elevation * 0.45),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                assetPath,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              if (!highlighted)
                ColoredBox(color: Colors.black.withValues(alpha: 0.28)),
              // Лёгкий нижний fade, чтобы карточка лучше стыковалась с текстом.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Color(0x66000000),
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
