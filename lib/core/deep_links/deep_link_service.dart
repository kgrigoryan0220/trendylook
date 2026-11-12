import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:collection/collection.dart';
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
    // trendylook://history — раздел в host, trendylook:///history — в пути.
    final section = [uri.host, ...uri.pathSegments].firstWhereOrNull((s) => s.isNotEmpty);

    switch (section) {
      case 'paywall':
        // На холодном старте под пейволом остался бы Splash, и его таймер
        // увёл бы на /home поверх пейвола. Поэтому go: закрытие пейвола без
        // стека под ним само ведёт на /home.
        final path = _router.routerDelegate.currentConfiguration.uri.path;
        if (path.isEmpty || path == '/splash') {
          _router.go('/paywall?trigger=deeplink');
        } else {
          _router.push('/paywall?trigger=deeplink');
        }
      case 'history':
        _router.go('/history');
      default: // trendylook://, check, check/{id}
        _router.go('/home');
    }
  }
}
