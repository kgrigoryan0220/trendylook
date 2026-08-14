import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/gen/app_localizations.dart';

/// 4.3.0 Навигационная оболочка — bottom tab bar (Главная/История/Профиль).
class BottomTabShell extends StatelessWidget {
  const BottomTabShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xEB14141B),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _TabItem(
                  icon: Icons.home_outlined,
                  label: l10n.bottomTabHome,
                  selected: shell.currentIndex == 0,
                  onTap: () => shell.goBranch(0),
                ),
                _TabItem(
                  icon: Icons.history,
                  label: l10n.bottomTabHistory,
                  selected: shell.currentIndex == 1,
                  onTap: () => shell.goBranch(1),
                ),
                _TabItem(
                  icon: Icons.person_outline,
                  label: l10n.bottomTabProfile,
                  selected: shell.currentIndex == 2,
                  onTap: () => shell.goBranch(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.pink : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.body(
                context,
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
