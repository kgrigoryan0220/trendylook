import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../config/app_config.dart';

/// Базовая аналитика (TECH_SPEC_v1.2.md 6.8). Событие не отправляется, если
/// POSTHOG_API_KEY не задан (--dart-define) — вызовы остаются no-op, чтобы
/// код фич не менялся, когда ключ появится.
class AnalyticsService {
  bool get _enabled => AppConfig.postHogApiKey.isNotEmpty;

  Future<void> init() async {
    if (!_enabled) return;
    final config = PostHogConfig(AppConfig.postHogApiKey)
      ..host = AppConfig.postHogHost
      ..captureApplicationLifecycleEvents = true;
    await Posthog().setup(config);
  }

  void track(String event, [Map<String, Object> properties = const {}]) {
    if (!_enabled) return;
    Posthog().capture(eventName: event, properties: properties);
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
