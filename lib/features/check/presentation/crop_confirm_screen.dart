import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import 'check_flow_controller.dart';

/// 4.6 Crop / Confirm — превью фото с рамкой, «Пересъёмка» / «Подтвердить».
class CropConfirmScreen extends ConsumerWidget {
  const CropConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = ref.watch(checkFlowControllerProvider).photo;

    return Scaffold(
      backgroundColor: const Color(0xFF05050A),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (photo != null) Image.file(photo, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(36),
                  child: CustomPaint(painter: _CornerFramePainter()),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Пересъёмка',
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Подтвердить',
                      onPressed: photo == null
                          ? null
                          : () {
                              ref.read(checkFlowControllerProvider.notifier).submit();
                              context.push('/check/loading');
                            },
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

class _CornerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const len = 22.0;

    void corner(Offset origin, Offset dx, Offset dy) {
      canvas.drawLine(origin, origin + dx, paint);
      canvas.drawLine(origin, origin + dy, paint);
    }

    corner(const Offset(0, 0), const Offset(len, 0), const Offset(0, len));
    corner(Offset(size.width, 0), Offset(-len, 0), const Offset(0, len));
    corner(Offset(0, size.height), const Offset(len, 0), Offset(0, -len));
    corner(Offset(size.width, size.height), Offset(-len, 0), Offset(0, -len));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
