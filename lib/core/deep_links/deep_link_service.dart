import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

/// Приложение C (TECH_SPEC_v1.2.md): trendylook:// deep links.
///
/// `check/{id}` ведёт на чужую (по отношению к получателю) проверку — RLS не
/// даёт её открыть кому-то кроме автора, так что осмысленный таргет для
/// получателя — Home с CTA сделать свою проверку (challenge hook, 4.4).
class DeepLinkService {
  DeepLinkService(this._router);

  final GoRouter _router;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  Future<void> init() async {
    final initialUri = await _appLinks.getInitialLinkString();
    if (initialUri != null) {
      _handle(Uri.parse(initialUri));
    }
    _subscription = _appLinks.uriLinkStream.listen(_handle);
  }

  void dispose() {
    _subscription?.cancel();
  }

  void _handle(Uri uri) {
    if (uri.scheme != 'trendylook') return;
    final segments = uri.pathSegments.isNotEmpty
        ? uri.pathSegments
        : [uri.host].where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) {
      _router.go('/home');
      return;
    }
    switch (segments.first) {
      case 'paywall':
        _router.push('/paywall');
      case 'history':
        _router.go('/history');
      case 'check':
      default:
        _router.go('/home');
    }
  }
}
