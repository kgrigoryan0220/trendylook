import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Soft fade + blur at the top of the home history scroll area (HOME-HIST / HOME-UI-04).
class HistoryTopFade extends StatelessWidget {
  const HistoryTopFade({super.key, this.useBlur = true});

  static const height = 48.0;

  /// Disable blur on low-end devices if needed; gradient-only fallback.
  final bool useBlur;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (useBlur)
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: AppColors.background.withValues(alpha: 0.35)),
                ),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
