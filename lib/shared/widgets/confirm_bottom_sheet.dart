import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/gen/app_localizations.dart';

/// 4.13 / профиль: bottom sheet подтверждения деструктивного действия.
/// [cancelLabel] по умолчанию — «Отмена» на языке приложения.
Future<bool> showConfirmBottomSheet(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? message,
  String? cancelLabel,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surface,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: AppColors.textPrimary,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(cancelLabel ?? AppLocalizations.of(context).cancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
