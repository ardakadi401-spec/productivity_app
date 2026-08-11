import 'package:flutter/material.dart';

import '../../core/constants/app_animation_durations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Snackbar — COMPONENTS.md Bölüm 11.5 (+ 11.4 Success varyantı, ayrı bir
/// bileşen değil, yalnızca ikon/vurgu rengi `color/secondary` olan hali).
///
/// Arkaplan `color/text-primary` (ters kontrast) — bu token her temada
/// zeminin tersi bir parlaklıkta olduğundan (Açık: koyu lacivert, Koyu/AMOLED:
/// neredeyse beyaz), zeminin (`scaffoldBackgroundColor`) tersi metin rengiyle
/// eşleştirilir; hiçbir sabit renk yazılmaz.
class AppSnackbar {
  AppSnackbar._();

  /// Silme/tamamlama gibi geri alınabilir eylemlerde [actionLabel] her zaman
  /// "Geri Al" olarak geçilmelidir (11.5 kuralı).
  static void show(
    BuildContext context, {
    required String message,
    bool isSuccess = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.onSurface;
    final foreground = theme.scaffoldBackgroundColor;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: background,
          duration: AppAnimationDurations.snackbarVisible,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              if (isSuccess) ...[
                Icon(Icons.check_circle, size: 20, color: theme.colorScheme.secondary),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodyMd.copyWith(color: foreground),
                ),
              ),
            ],
          ),
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  textColor: theme.colorScheme.primary,
                  onPressed: onAction ?? () {},
                ),
        ),
      );
  }
}
