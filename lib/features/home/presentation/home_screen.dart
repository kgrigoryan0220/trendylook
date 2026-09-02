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
import '../../../shared/widgets/bottom_right_masonry_grid.dart';
import '../../../shared/widgets/history_masonry_card.dart';
import '../../../shared/widgets/history_top_fade.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../check/presentation/check_flow_controller.dart';
import 'home_history_controller.dart';

const _gridHorizontalPadding = 20.0;
const _gridTopPadding = 8.0;
const _gridBottomInset = 12.0;
const _wideScreenWidth = 600.0;

/// 4.4 Home — Empty / С историей / Pro.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  final Map<String, String> _thumbUrls = {};
  final Set<String> _requestedPaths = {};

  bool _scrollToBottomOnNextData = false;
  bool _isLoadingMore = false;

  static const _loadMoreThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore) return;

    final position = _scrollController.position;
    final offset = _scrollController.offset;
    // reverse: true — older content lives toward maxScrollExtent (visual top).
    if (offset < position.maxScrollExtent - _loadMoreThreshold) return;

    final history = ref.read(homeHistoryControllerProvider).valueOrNull;
    if (history == null || !history.hasMore || history.isLoadingMore) return;

    _loadOlder();
  }

  Future<void> _loadOlder() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;

    final oldMax = _scrollController.hasClients ? _scrollController.position.maxScrollExtent : 0;
    final oldOffset = _scrollController.hasClients ? _scrollController.offset : 0;

    try {
      await ref.read(homeHistoryControllerProvider.notifier).loadMore();
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        final delta = _scrollController.position.maxScrollExtent - oldMax;
        _scrollController.jumpTo(oldOffset + delta);
      });
    } finally {
      _isLoadingMore = false;
    }
  }

  void _scrollToBottom({bool animated = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      // reverse: true — offset 0 anchors the newest row to the visual bottom.
      if (animated) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(0);
      }
    });
  }

  Future<void> _ensureSignedUrls(List<String> paths) async {
    final missing = paths.where((p) => !_requestedPaths.contains(p)).toList();
    if (missing.isEmpty) return;
    _requestedPaths.addAll(missing);
    final urls = await ref.read(checkRepositoryProvider).getSignedUrls(missing);
    if (!mounted) return;
    setState(() => _thumbUrls.addAll(urls));
  }

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

  int _crossAxisCount(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= _wideScreenWidth ? 3 : 2;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final billingAsync = ref.watch(billingControllerProvider);
    final billing = billingAsync.valueOrNull;
    final historyAsync = ref.watch(homeHistoryControllerProvider);

    ref.listen(homeHistoryScrollToBottomRequestProvider, (_, next) {
      if (next) _scrollToBottomOnNextData = true;
    });

    ref.listen(homeHistoryControllerProvider, (previous, next) {
      next.whenData((state) {
        if (state.items.isEmpty) return;
        _ensureSignedUrls(state.items.map((c) => c.imagePath).toList());

        final wasLoading = previous is AsyncLoading || previous?.isLoading == true;
        if (_scrollToBottomOnNextData || wasLoading) {
          final animate = _scrollToBottomOnNextData;
          _scrollToBottomOnNextData = false;
          ref.read(homeHistoryScrollToBottomRequestProvider.notifier).state = false;
          _scrollToBottom(animated: animate);
        }
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
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
                      child: const Text(
                        'PRO',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),
            if (billing?.isGrace == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _GraceBanner(onTap: () => context.push('/paywall')),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: _HeroCard(
                freeChecksLeft: billing?.freeChecksLeft,
                isPro: billing?.isPro ?? false,
                onCamera: _startCamera,
                onGallery: _startGallery,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                l10n.homeRecentChecks,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
                  ),
                ),
                child: historyAsync.when(
                  loading: () => _HistorySkeleton(crossAxisCount: _crossAxisCount(context)),
                  error: (_, _) => _HistoryError(
                    onRetry: () => ref.invalidate(homeHistoryControllerProvider),
                  ),
                  data: (state) {
                    if (state.items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            l10n.homeRecentChecksEmpty,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ),
                      );
                    }

                    // Newest-first for bottom-right → left → up masonry placement.
                    final newestFirst = state.items.reversed.toList();

                    return Stack(
                      children: [
                        ClipRect(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              _scrollToBottomOnNextData = true;
                              await ref.read(homeHistoryControllerProvider.notifier).refresh();
                            },
                            child: CustomScrollView(
                              controller: _scrollController,
                              reverse: true,
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              slivers: [
                                const SliverToBoxAdapter(
                                  child: SizedBox(height: _gridBottomInset),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                    _gridHorizontalPadding,
                                    0,
                                    _gridHorizontalPadding,
                                    _gridTopPadding,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: BottomRightMasonryGrid(
                                      crossAxisCount: _crossAxisCount(context),
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                      items: newestFirst,
                                      itemBuilder: (context, item) {
                                        return HistoryMasonryCard(
                                          check: item,
                                          photoUrl: _thumbUrls[item.imagePath],
                                          onTap: () => context.push('/history/${item.id}'),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                if (state.isLoadingMore)
                                  const SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: HistoryTopFade(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton({required this.crossAxisCount});

  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    const skeletonRatios = [0.85, 1.15, 1.0, 0.75, 1.3, 0.85];
    return Stack(
      children: [
        ClipRect(
          child: CustomScrollView(
            reverse: true,
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: _gridBottomInset)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  _gridHorizontalPadding,
                  0,
                  _gridHorizontalPadding,
                  _gridTopPadding,
                ),
                sliver: SliverToBoxAdapter(
                  child: BottomRightMasonryGrid<double>(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    items: skeletonRatios,
                    itemBuilder: (_, ratio) =>
                        HistoryMasonryCard.skeleton(aspectRatio: ratio),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Positioned(top: 0, left: 0, right: 0, child: HistoryTopFade()),
      ],
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(onPressed: onRetry, child: const Icon(Icons.refresh)),
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
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
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
          style: const TextStyle(
            color: AppColors.warning,
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
