import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import 'check_flow_controller.dart';

/// 4.5 Camera capture — полноэкранный видоискатель, спуск затвора,
/// переключатель фронт/тыл, крестик закрытия. 4.15: нет доступа к камере.
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool _permissionDenied = false;
  bool _initFailed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _permissionDenied = true);
      return;
    }
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _initFailed = true);
        return;
      }
      await _startController(_cameraIndex);
    } catch (_) {
      setState(() => _initFailed = true);
    }
  }

  Future<void> _startController(int index) async {
    final previous = _controller;
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();
    await previous?.dispose();
    if (!mounted) return;
    setState(() {
      _controller = controller;
      _cameraIndex = index;
    });
  }

  Future<void> _toggleFacing() async {
    if (_cameras.length < 2) return;
    await _startController((_cameraIndex + 1) % _cameras.length);
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final file = await controller.takePicture();
    if (!mounted) return;
    ref.read(checkFlowControllerProvider.notifier).setPhoto(File(file.path));
    context.push('/check/confirm');
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) return _CameraPermissionError(onRetry: _init);
    if (_initFailed) {
      return _CameraPermissionError(
        onRetry: _init,
        message: AppLocalizations.of(context).cameraUnavailableMessage,
      );
    }

    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && controller.value.isInitialized)
            _FullScreenCameraPreview(controller: controller)
          else
            const Center(child: CircularProgressIndicator(color: AppColors.pink)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundIconButton(
                    icon: Icons.close,
                    onTap: () => context.pop(),
                  ),
                  _RoundIconButton(
                    icon: Icons.cameraswitch_outlined,
                    onTap: _toggleFacing,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 56),
              child: GestureDetector(
                onTap: _capture,
                child: Container(
                  width: 76,
                  height: 76,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 4),
                  ),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.gradientPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

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
          color: Colors.white.withValues(alpha: 0.12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _CameraPermissionError extends StatelessWidget {
  const _CameraPermissionError({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.cameraPermissionTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              const SizedBox(height: 10),
              Text(
                message ?? l10n.cameraPermissionMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
              ),
              const SizedBox(height: 20),
              PrimaryButton(label: l10n.openSettings, onPressed: openAppSettings),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(l10n.cancel, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Масштабирует превью камеры так, чтобы заполнить весь экран без искажений
/// и без чёрных полос — вместо растягивания CameraPreview на весь Stack
/// (сжимало картинку по бокам) и вместо повторного AspectRatio поверх нее
/// (CameraPreview уже оборачивает себя в AspectRatio с учётом поворота
/// устройства — 1/aspectRatio в портрете, aspectRatio в ландшафте, см.
/// package:camera/src/camera_preview.dart — оборачивать её ещё раз своим
/// AspectRatio с сырым controller.value.aspectRatio даёт двойное,
/// рассогласованное соотношение сторон и как раз вызывало этот баг).
class _FullScreenCameraPreview extends StatelessWidget {
  const _FullScreenCameraPreview({required this.controller});

  final CameraController controller;

  bool get _isLandscape {
    final orientation = controller.value.isRecordingVideo
        ? controller.value.recordingOrientation
        : (controller.value.previewPauseOrientation ??
            controller.value.lockedCaptureOrientation ??
            controller.value.deviceOrientation);
    return orientation == DeviceOrientation.landscapeLeft ||
        orientation == DeviceOrientation.landscapeRight;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final previewRatio =
            _isLandscape ? controller.value.aspectRatio : 1 / controller.value.aspectRatio;
        var scale = size.aspectRatio / previewRatio;
        if (scale < 1) scale = 1 / scale;
        return ClipRect(
          child: Transform.scale(
            scale: scale,
            child: Center(child: CameraPreview(controller)),
          ),
        );
      },
    );
  }
}
