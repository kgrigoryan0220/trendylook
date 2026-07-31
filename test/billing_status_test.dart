import 'package:flutter_test/flutter_test.dart';
import 'package:trendylook/features/paywall/data/billing_repository.dart';

void main() {
  group('BillingStatus.fromJson', () {
    test('parses active pro subscription', () {
      final status = BillingStatus.fromJson({
        'is_pro': true,
        'plan': 'halfyear',
        'status': 'active',
        'expires_at': '2026-12-01T00:00:00.000Z',
        'grace_expires_at': null,
        'free_checks_left': 0,
      });

      expect(status.isPro, isTrue);
      expect(status.isGrace, isFalse);
      expect(status.plan, 'halfyear');
      expect(status.freeChecksLeft, 0);
    });

    test('parses grace-period subscription (PAY-05)', () {
      final status = BillingStatus.fromJson({
        'is_pro': true,
        'plan': 'weekly',
        'status': 'grace',
        'expires_at': '2026-07-01T00:00:00.000Z',
        'grace_expires_at': '2026-07-02T00:00:00.000Z',
        'free_checks_left': 0,
      });

      expect(status.isGrace, isTrue);
      expect(status.isPro, isTrue);
    });

    test('parses free user with checks left', () {
      final status = BillingStatus.fromJson({
        'is_pro': false,
        'plan': null,
        'status': null,
        'expires_at': null,
        'grace_expires_at': null,
        'free_checks_left': 2,
      });

      expect(status.isPro, isFalse);
      expect(status.isGrace, isFalse);
      expect(status.freeChecksLeft, 2);
    });
  });
}
