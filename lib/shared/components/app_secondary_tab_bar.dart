import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Tab Navigation (ikincil seviye) — COMPONENTS.md Bölüm 12.1. Bottom
/// Navigation'ın kapsül göstergesinden görsel olarak ayırt edilmek için
/// ince (2dp) alt çizgi gösterge kullanır. Örn. Tab 2 (Projeler/Görevler),
/// Tab 4 (Alışkanlıklar/Hedefler).
class AppSecondaryTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AppSecondaryTabBar({super.key, required this.controller, required this.tabs});

  final TabController controller;
  final List<String> tabs;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return TabBar(
      controller: controller,
      tabs: [for (final label in tabs) Tab(text: label)],
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: tokens.textSecondary,
      labelStyle: AppTypography.button,
      unselectedLabelStyle: AppTypography.button,
      indicatorColor: theme.colorScheme.primary,
      indicatorWeight: 2,
      dividerColor: tokens.border,
    );
  }
}
