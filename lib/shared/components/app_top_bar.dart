import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_elevation.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// App Bar — COMPONENTS.md Bölüm 2.1. 56dp, `color/surface`; varsayılan
/// durumda yalnızca alt `color/border` ayracı, scroll edilince `elevation/1`
/// belirir. Sağda en fazla 2 ikon eylemi (her biri 48dp dokunma alanlı —
/// çağıran taraf [AppIconButton] kullanmalı).
///
/// Bir `PreferredSizeWidget` DEĞİLDİR (Scaffold'ın `appBar:` yuvası yerine
/// `body`'nin ilk çocuğu olarak kullanılır) — kendi `SafeArea` üst
/// boşluğunu içeride yönetir, böylece 5 shell sekmesinde tekrarlanan
/// SafeArea sarmalama ihtiyacını ortadan kaldırır.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.elevated = false,
    this.isAmoled = false,
  });

  final String title;
  final List<Widget> actions;
  final bool elevated;

  /// AMOLED temada gölge yerine yalnızca border kullanılır (AppElevation
  /// doc-comment'i, UI_GUIDELINES.md Bölüm 12.4) — çağıran taraf aktif
  /// temayı bildiğinden bu bilgiyi açıkça iletir.
  final bool isAmoled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: elevated && !isAmoled ? AppElevation.level1() : AppElevation.none,
          border: elevated ? null : Border(bottom: BorderSide(color: tokens.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.h2.copyWith(color: theme.colorScheme.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}
