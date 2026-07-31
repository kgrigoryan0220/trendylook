import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../data/check_exceptions.dart';
import 'check_flow_controller.dart';

const _phrases = [
  'Анализируем цвета…',
  'Сверяем с трендами 2026…',
  'Оцениваем силуэт…',
  'Считаем итоговый score…',
];

/// 4.7 Loading/Анализ — blur превью, scan-line, ротация фраз, progress bar.
class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;
  late final Timer _phraseTimer;
  int _phraseIndex = 0;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _phraseTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      setState(() => _phraseIndex = (_phraseIndex + 1) % _phrases.length);
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _phraseTimer.cancel();
    super.dispose();
  }

  void _handleState(CheckFlowState state) {
    if (_navigated || state.isSubmitting) return;
    _navigated = true;
    if (state.result != null) {
      context.replace('/check/result');
    } else if (state.error is PaywallException) {
      context.replace('/paywall');
    } else {
      context.replace('/check/error');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(checkFlowControllerProvider, (previous, next) => _handleState(next));

    final photo = ref.read(checkFlowControllerProvider).photo;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (photo != null)
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Opacity(opacity: 0.5, child: Image.file(photo, fit: BoxFit.cover)),
            ),
          Container(color: AppColors.background.withValues(alpha: 0.55)),
          AnimatedBuilder(
            animation: _scanController,
            builder: (context, _) {
              return Align(
                alignment: Alignment(0, -1 + _scanController.value * 2),
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.pink,
                        AppColors.violet,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: const Alignment(0, 0.65),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _phrases[_phraseIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor: Color(0x1FFFFFFF),
                      valueColor: AlwaysStoppedAnimation(AppColors.pink),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
