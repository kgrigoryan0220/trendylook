import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/locale_controller.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/providers/billing_provider.dart';
import '../../../shared/widgets/confirm_bottom_sheet.dart';
import '../../auth/presentation/auth_controller.dart';

const _localeEndonyms = {
  'en': 'English',
  'ru': 'Русский',
  'es': 'Español',
  'it': 'Italiano',
  'de': 'Deutsch',
  'fr': 'Français',
  'pt': 'Português',
};

/// 4.14 Профиль.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _subStatusText(AppLocalizations l10n, String languageCode, dynamic billing) {
    if (billing == null) return '—';
    if (billing.isGrace) return l10n.graceStatus;
    if (billing.isPro && billing.expiresAt != null) {
      return l10n.proUntil(
          DateFormat('d MMM yyyy', languageCode).format(billing.expiresAt!));
    }
    if (billing.isPro) return l10n.proStatus;
    return l10n.freeStatus;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final user = ref.watch(currentUserProvider);
    final billingAsync = ref.watch(billingControllerProvider);
    final billing = billingAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l10n.profileTitle), automaticallyImplyLeading: false),
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
                      (user?.userMetadata?['full_name'] as String?) ?? l10n.defaultUserName,
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
                Text(
                  l10n.subscriptionStatusLabel,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  _subStatusText(l10n, languageCode, billing),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                if (billing != null && !billing.isPro) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.freeChecksLeft(billing.freeChecksLeft),
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
          const _SettingsList(),
          const SizedBox(height: 24),
          _LogoutButton(
            onLoggedOut: () => context.go('/auth'),
          ),
        ],
      ),
    );
  }
}

Future<void> _showLanguagePicker(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final current = ref.read(localeControllerProvider).valueOrNull;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.8,
          ),
          child: RadioGroup<Locale?>(
            groupValue: current,
            onChanged: (value) {
              ref.read(localeControllerProvider.notifier).setLocale(value);
              Navigator.of(sheetContext).pop();
            },
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.languagePickerTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
                RadioListTile<Locale?>(
                  value: null,
                  title: Text(l10n.languageSystemDefault),
                  activeColor: AppColors.pink,
                ),
                for (final locale in AppLocalizations.supportedLocales)
                  RadioListTile<Locale?>(
                    value: locale,
                    title: Text(_localeEndonyms[locale.languageCode] ?? locale.languageCode),
                    activeColor: AppColors.pink,
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _GraceBanner extends StatelessWidget {
  const _GraceBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.graceBannerText,
                style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600, fontSize: 12.5),
              ),
            ),
            Text(l10n.graceBannerUpdate,
                style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w800, fontSize: 12.5)),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).upgradeToPro,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _SettingsList extends ConsumerWidget {
  const _SettingsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selectedLocale = ref.watch(localeControllerProvider).valueOrNull;
    final languageLabel = selectedLocale != null
        ? (_localeEndonyms[selectedLocale.languageCode] ?? selectedLocale.languageCode)
        : l10n.languageSystemDefault;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _SettingsRow(
            label: l10n.notifications,
            trailing: Text(l10n.comingSoon,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
          _SettingsRow(
            label: l10n.language,
            trailing: Text(languageLabel, style: const TextStyle(color: AppColors.textSecondary)),
            onTap: () => _showLanguagePicker(context, ref),
          ),
          _SettingsRow(label: l10n.support),
          _SettingsRow(label: l10n.privacyPolicy),
          _SettingsRow(label: l10n.termsOfService),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, this.trailing, this.onTap});

  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton({required this.onLoggedOut});

  final VoidCallback onLoggedOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () async {
        final confirmed = await showConfirmBottomSheet(
          context,
          title: l10n.logoutConfirmTitle,
          confirmLabel: l10n.logout,
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
        child: Center(
          child: Text(
            l10n.logout,
            style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 14.5),
          ),
        ),
      ),
    );
  }
}
