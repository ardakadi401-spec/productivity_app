import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/components/app_bottom_nav_bar.dart';

/// Ana uygulama kabuğu — ARCHITECTURE.md Bölüm 9.3, SCREENS.md Bölüm 2.4.
/// `StatefulShellRoute.indexedStack` her sekmenin widget ağacını
/// (`IndexedStack` ile) canlı tutar — bu, dokümanın istediği "sekmeler
/// arası geçişte durum korunması" davranışının go_router karşılığıdır.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    AppBottomNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    AppBottomNavItem(icon: Icons.folder_outlined, label: 'Projeler'),
    AppBottomNavItem(icon: Icons.calendar_today_outlined, label: 'Takvim'),
    AppBottomNavItem(icon: Icons.repeat_rounded, label: 'Alışkanlıklar'),
    AppBottomNavItem(icon: Icons.settings_outlined, label: 'Ayarlar'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        items: _items,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
