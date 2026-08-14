import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/providers/billing_provider.dart';
import '../../../shared/widgets/history_item_tile.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../check/data/models/check_record.dart';
import '../../check/presentation/check_flow_controller.dart';

final _recentChecksProvider = FutureProvider.autoDispose<List<CheckRecord>>((ref) async {
  final all = await ref.watch(checkRepositoryProvider).fetchHistory(page: 0);
  return all.take(5).toList();
});

/// 4.4 Home — Empty / С историей / Pro.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Map<String, String> _thumbUrls = {};

  Future<bool> _canCheck() async {
    final billing = ref.read(billingControllerProvider).valueOrNull;
    return billing?.isPro == true || (billing?.freeChecksLeft ?? 0) > 0;
  }

  Future<void> _startCamera() async {
    if (!await _canCheck()) {
      if (mounted) context.push('/paywall');
      return;
    }
    ref.read(checkFlowControllerProvider.notifier).reset();
    ref.read(analyticsServiceProvider).track('check_started', {'source': 'camera'});
    if (mounted) context.push('/check/camera');
  }

  Future<void> _startGallery() async {
    if (!await _canCheck()) {
      if (mounted) context.push('/paywall');
      return;
    }
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    ref.read(checkFlowControllerProvider.notifier).setPhoto(File(picked.path));
    ref.read(analyticsServiceProvider).track('check_started', {'source': 'gallery'});
    if (mounted) context.push('/check/confirm');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final billingAsync = ref.watch(billingControllerProvider);
    final billing = billingAsync.valueOrNull;
    final recentAsync = ref.watch(_recentChecksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.homeTitle, style: AppTheme.heading(context, fontSize: 22)),
                    if (billing?.isPro == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text('PRO',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                  ],
                ),
              ),
            ),
            if (billing?.isGrace == true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _GraceBanner(onTap: () => context.push('/paywall')),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: _HeroCard(
                  freeChecksLeft: billing?.freeChecksLeft,
                  isPro: billing?.isPro ?? false,
                  onCamera: _startCamera,
                  onGallery: _startGallery,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  l10n.homeRecentChecks,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: recentAsync.when(
                loading: () => const SizedBox(
                  height: 76,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (_, _) => const SizedBox.shrink(),
                data: (items) {
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        l10n.homeRecentChecksEmpty,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    );
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    final missing = items
                        .map((c) => c.imagePath)
                        .where((p) => !_thumbUrls.containsKey(p))
                        .toList();
                    if (missing.isEmpty || !mounted) return;
                    final urls =
                        await ref.read(checkRepositoryProvider).getSignedUrls(missing);
                    if (mounted) setState(() => _thumbUrls.addAll(urls));
                  });
                  return SizedBox(
                    height: 76,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return SizedBox(
                          width: 240,
                          child: HistoryItemTile(
                            check: item,
                            photoUrl: _thumbUrls[item.imagePath],
                            onTap: () => context.push('/history/${item.id}'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.freeChecksLeft,
    required this.isPro,
    required this.onCamera,
    required this.onGallery,
  });

  final int? freeChecksLeft;
  final bool isPro;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1A24), AppColors.surface],
        ),
        border: Border.all(color: AppColors.pink.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            l10n.homeHeroTitle,
            textAlign: TextAlign.center,
            style: AppTheme.heading(context, fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.homeHeroSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: l10n.ctaCamera, onPressed: onCamera),
          const SizedBox(height: 12),
          SecondaryButton(label: l10n.ctaGallery, onPressed: onGallery),
          if (!isPro && freeChecksLeft != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                l10n.freeChecksLeft(freeChecksLeft!),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GraceBanner extends StatelessWidget {
  const _GraceBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.14),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          AppLocalizations.of(context).graceBannerText,
          style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600, fontSize: 12.5),
        ),
      ),
    );
  }
}
