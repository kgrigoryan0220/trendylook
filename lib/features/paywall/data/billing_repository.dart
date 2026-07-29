import 'package:supabase_flutter/supabase_flutter.dart';

/// TECH_SPEC_v1.2.md 6.3 — billing-status Edge Function.
class BillingStatus {
  const BillingStatus({
    required this.isPro,
    required this.plan,
    required this.status,
    required this.expiresAt,
    required this.graceExpiresAt,
    required this.freeChecksLeft,
  });

  factory BillingStatus.fromJson(Map<String, dynamic> json) {
    return BillingStatus(
      isPro: json['is_pro'] as bool? ?? false,
      plan: json['plan'] as String?,
      status: json['status'] as String?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      graceExpiresAt: json['grace_expires_at'] != null
          ? DateTime.parse(json['grace_expires_at'] as String)
          : null,
      freeChecksLeft: (json['free_checks_left'] as num?)?.toInt() ?? 0,
    );
  }

  final bool isPro;
  final String? plan;
  final String? status;
  final DateTime? expiresAt;
  final DateTime? graceExpiresAt;
  final int freeChecksLeft;

  bool get isGrace => status == 'grace';
}

class BillingRepository {
  BillingRepository(this._client);

  final SupabaseClient _client;

  Future<BillingStatus> fetchStatus() async {
    final response = await _client.functions.invoke('billing-status');
    return BillingStatus.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}
