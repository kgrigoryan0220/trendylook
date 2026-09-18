import 'package:flutter/widgets.dart';

import 'analytics_service.dart';

/// Sends `$screen` / screen events for GoRouter navigations.
class AnalyticsNavigatorObserver extends NavigatorObserver {
  AnalyticsNavigatorObserver(this._analytics);

  final AnalyticsService _analytics;

  void _track(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty || name == '/') return;
    _analytics.screen(name);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _track(newRoute);
  }
}
