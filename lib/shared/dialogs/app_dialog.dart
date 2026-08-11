import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../buttons/app_button_widget.dart';

/// Dialog — COMPONENTS.md Bölüm 11.6. Yalnızca gerçekten kesintili onay
/// gerektiren eylemler için kullanılır (örn. hesap silme onayı); sık/hızlı
/// eylemler için [AppBottomSheet] tercih edilir.
class AppDialog {
  AppDialog._();

  /// En fazla 2 aksiyon: [cancelLabel] (Text Button) + [confirmLabel]
  /// (Primary veya [isDestructive] ise Destructive Button).
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String description,
    required String confirmLabel,
    String cancelLabel = 'Vazgeç',
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.h2.copyWith(color: theme.colorScheme.onSurface)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  style: AppTypography.bodyMd.copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      label: cancelLabel,
                      variant: AppButtonVariant.text,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton(
                      label: confirmLabel,
                      isDestructive: isDestructive,
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
