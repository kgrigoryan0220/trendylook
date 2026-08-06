import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/primary_button.dart';
import 'share_card.dart';
import 'share_target.dart';

/// 4.10 Share preview — SHARE-01/02/03.
class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final _screenshotController = ScreenshotController();
  bool _sharing = false;

  Future<void> _share(ShareTarget target) async {
    setState(() => _sharing = true);
    try {
      final bytes = await _screenshotController.capture(pixelRatio: 3);
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/trendylook_share_${target.record.id}.png');
      await file.writeAsBytes(bytes);

      ref.read(analyticsServiceProvider).track('share_tapped', {
        'template': 'bold',
        'score': target.record.trendScore,
      });

      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: AppLocalizations.of(context)
              .shareMessageText(target.record.trendScore, target.record.id),
        ),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final target = ref.watch(shareTargetProvider);
    if (target == null) {
      return Scaffold(body: Center(child: Text(l10n.shareNothingToShare)));
    }

    final photo = target.localPhoto != null
        ? Image.file(target.localPhoto!, fit: BoxFit.cover)
        : target.photoUrl != null
            ? Image.network(target.photoUrl!, fit: BoxFit.cover)
            : const ColoredBox(color: Colors.black26);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.share),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Screenshot(
                    controller: _screenshotController,
                    child: ShareCard(record: target.record, photo: photo),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: PrimaryButton(
                label: l10n.share,
                isLoading: _sharing,
                onPressed: _sharing ? null : () => _share(target),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
