import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Конфетти-оверлей при score >= 80% (Icon Status), разд. 4.2/4.3.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key, this.pieceCount = 24});

  final int pieceCount;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Piece> _pieces;

  static const _colors = [AppColors.pink, AppColors.lime, AppColors.violet];

  @override
  void initState() {
    super.initState();
    final random = Random();
    _pieces = List.generate(widget.pieceCount, (i) {
      return _Piece(
        left: random.nextDouble(),
        delay: random.nextDouble() * 0.6,
        color: _colors[random.nextInt(_colors.length)],
        size: 6 + random.nextDouble() * 6,
        rotations: 1 + random.nextDouble() * 2,
      );
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: _pieces.map((p) {
                  final t = ((_controller.value - p.delay) / (1 - p.delay))
                      .clamp(0.0, 1.0);
                  return Positioned(
                    left: p.left * constraints.maxWidth,
                    top: -20 + t * (constraints.maxHeight + 40),
                    child: Opacity(
                      opacity: 1 - t,
                      child: Transform.rotate(
                        angle: t * p.rotations * 2 * pi,
                        child: Container(
                          width: p.size,
                          height: p.size * 1.6,
                          color: p.color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}

class _Piece {
  _Piece({
    required this.left,
    required this.delay,
    required this.color,
    required this.size,
    required this.rotations,
  });

  final double left;
  final double delay;
  final Color color;
  final double size;
  final double rotations;
}
