import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/billing_provider.dart';
import '../../../shared/widgets/confirm_bottom_sheet.dart';
import '../../auth/presentation/auth_controller.dart';

/// 4.14 Профиль.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _subStatusText(dynamic billing) {
    if (billing == null) return '—';
    if (billing.isGrace) return 'Grace period';
    if (billing.isPro && billing.expiresAt != null) {
      return 'Pro до ${DateFormat('d MMM yyyy', 'ru').format(billing.expiresAt!)}';
    }
    if (billing.isPro) return 'Pro';
    return 'Free';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final billingAsync = ref.watch(billingControllerProvider);
    final billing = billingAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Профиль'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.surface,
                backgroundImage: user?.userMetadata?['avatar_url'] != null
                    ? NetworkImage(user!.userMetadata!['avatar_url'] as String)
                    : null,
                child: user?.userMetadata?['avatar_url'] == null
                    ? const Icon(Icons.person, color: AppColors.textSecondary)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (user?.userMetadata?['full_name'] as String?) ?? 'Пользователь',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Статус подписки',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  _subStatusText(billing),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                if (billing != null && !billing.isPro) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Осталось бесплатных проверок: ${billing.freeChecksLeft}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ],
              ],
            ),
          ),
          if (billing?.isGrace == true) ...[
            const SizedBox(height: 14),
            _GraceBanner(onTap: () => context.push('/paywall')),
          ],
          if (billing != null && !billing.isPro) ...[
            const SizedBox(height: 14),
            _UpgradeBanner(onTap: () => context.push('/paywall')),
          ],
          const SizedBox(height: 20),
          _SettingsList(),
          const SizedBox(height: 24),
          _LogoutButton(
            onLoggedOut: () => context.go('/auth'),
          ),
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
        child: const Row(
          children: [
            Expanded(
              child: Text(
                'Подписка истекает — обнови способ оплаты',
                style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600, fontSize: 12.5),
              ),
            ),
            Text('Обновить', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w800, fontSize: 12.5)),
          ],
        ),
      ),
    );
  }
}

class _UpgradeBanner extends StatelessWidget {
  const _UpgradeBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.pink.withValues(alpha: 0.18),
              AppColors.violet.withValues(alpha: 0.18),
            ],
          ),
          border: Border.all(color: AppColors.pink.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Перейти на Pro', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: const [
          _SettingsRow(label: 'Уведомления', trailing: Text('Скоро', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
          _SettingsRow(label: 'Язык', trailing: Text('RU', style: TextStyle(color: AppColors.textSecondary))),
          _SettingsRow(label: 'Поддержка'),
          _SettingsRow(label: 'Privacy Policy'),
          _SettingsRow(label: 'Terms of Service'),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0FFFFFFF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14.5)),
          trailing ??
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton({required this.onLoggedOut});

  final VoidCallback onLoggedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () async {
        final confirmed = await showConfirmBottomSheet(
          context,
          title: 'Выйти из аккаунта?',
          confirmLabel: 'Выйти',
        );
        if (!confirmed) return;
        await ref.read(authRepositoryProvider).signOut();
        onLoggedOut();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4), width: 1.5),
        ),
        child: const Center(
          child: Text(
            'Выйти',
            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 14.5),
          ),
        ),
      ),
    );
  }
}
