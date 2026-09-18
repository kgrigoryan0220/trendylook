import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../config/app_config.dart';

/// Product analytics (TECH_SPEC_v1.2.md 6.8) via PostHog EU Cloud.
///
/// Without `POSTHOG_API_KEY` all calls are no-ops. Host defaults to
/// `https://eu.i.posthog.com` (override with `POSTHOG_HOST`).
class AnalyticsService {
  bool _initialized = false;

  bool get _enabled => AppConfig.postHogApiKey.isNotEmpty;
  bool get isEnabled => _enabled && _initialized;

  Future<void> init() async {
    if (!_enabled || _initialized) return;
    final config = PostHogConfig(AppConfig.postHogApiKey)
      ..host = AppConfig.postHogHost
      ..captureApplicationLifecycleEvents = true
      // Photo fashion app — do not record screen replay by default.
      ..sessionReplay = false;
    await Posthog().setup(config);
    _initialized = true;
  }

  void track(String event, [Map<String, Object> properties = const {}]) {
    if (!isEnabled) return;
    Posthog().capture(eventName: event, properties: properties);
  }

  /// Binds events to Supabase `user.id` so funnels survive reinstalls/logins.
  Future<void> identify(
    String userId, {
    Map<String, Object>? properties,
  }) async {
    if (!isEnabled) return;
    await Posthog().identify(
      userId: userId,
      userProperties: properties,
    );
  }

  /// Clears distinct id after logout / account deletion.
  Future<void> reset() async {
    if (!isEnabled) return;
    await Posthog().reset();
  }

  void screen(String name, [Map<String, Object> properties = const {}]) {
    if (!isEnabled || name.isEmpty) return;
    Posthog().screen(screenName: name, properties: properties);
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
