import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme_mode.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/components/app_secondary_tab_bar.dart';
import '../../../../shared/components/app_top_bar.dart';
import '../../../goals/presentation/pages/goals_list_page.dart';
import '../../../goals/presentation/widgets/create_goal_sheet.dart';
import '../../../habits/presentation/pages/habits_list_page.dart';
import '../../../habits/presentation/widgets/create_habit_sheet.dart';

/// Tab 4 — Habits/Goals — SCREENS.md §2.4, §3.2: tek shell branch, içinde
/// "Alışkanlıklar"/"Hedefler" ikincil sekmesi. `/habits` ve `/goals` aynı
/// sayfaya farklı başlangıç sekmesiyle açılır. Her iki sekme de gerçek
/// veriye bağlı (Alışkanlıklar FAZ 9, Hedefler FAZ 8).
class HabitsGoalsPage extends ConsumerStatefulWidget {
  const HabitsGoalsPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<HabitsGoalsPage> createState() => _HabitsGoalsPageState();
}

class _HabitsGoalsPageState extends ConsumerState<HabitsGoalsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller =
      TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  late int _tabIndex = widget.initialTab;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.index != _tabIndex) setState(() => _tabIndex = _controller.index);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAmoled = ref.watch(themeModeProvider) == AppThemeMode.amoled;

    return Scaffold(
      body: Column(
        children: [
          AppTopBar(title: 'Alışkanlıklar & Hedefler', isAmoled: isAmoled),
          AppSecondaryTabBar(controller: _controller, tabs: const ['Alışkanlıklar', 'Hedefler']),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: const [
                HabitsListPage(),
                GoalsListPage(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 0
          ? AppFabButton(
              icon: Icons.add,
              semanticLabel: 'Yeni Alışkanlık',
              onPressed: () => showCreateHabitSheet(context),
            )
          : AppFabButton(
              icon: Icons.add,
              semanticLabel: 'Yeni Hedef',
              onPressed: () => showCreateGoalSheet(context),
            ),
    );
  }
}
