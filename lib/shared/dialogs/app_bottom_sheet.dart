import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Bottom Sheet — COMPONENTS.md Bölüm 11.7. Dialog yerine tercih edilen ana
/// bileşen (görev/not hızlı ekleme, dropdown seçim listesi, filtre paneli).
/// Bu yalnızca jenerik kabuktur (handle + üst köşe radius + max-height);
/// içerik [child] olarak dışarıdan verilir.
class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
