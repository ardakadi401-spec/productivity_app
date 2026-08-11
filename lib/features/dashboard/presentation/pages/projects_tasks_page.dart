import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme_mode.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/components/app_secondary_tab_bar.dart';
import '../../../../shared/components/app_top_bar.dart';
import '../../../projects/presentation/pages/projects_list_page.dart';
import '../../../projects/presentation/widgets/create_project_sheet.dart';
import '../../../tasks/presentation/pages/tasks_list_page.dart';

/// Tab 2 — Projects/Tasks — SCREENS.md §2.4, §3.2: tek shell branch, içinde
/// COMPONENTS.md §12.1 Tab Navigation ile "Projeler"/"Görevler" ikincil
/// sekmesi. `/projects` ve `/tasks` aynı sayfaya farklı başlangıç
/// sekmesiyle açılır (bkz. app_router.dart). FAZ 5/6 ile her iki sekme de
/// gerçek veriye bağlandı.
class ProjectsTasksPage extends ConsumerStatefulWidget {
  const ProjectsTasksPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<ProjectsTasksPage> createState() => _ProjectsTasksPageState();
}

class _ProjectsTasksPageState extends ConsumerState<ProjectsTasksPage>
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
          AppTopBar(
            title: 'Projeler & Görevler',
            isAmoled: isAmoled,
            actions: [
              AppIconButton(
                icon: Icons.search,
                semanticLabel: 'Ara',
                onPressed: () => context.push(RoutePaths.search),
              ),
            ],
          ),
          AppSecondaryTabBar(controller: _controller, tabs: const ['Projeler', 'Görevler']),
          Expanded(
            child: TabBarView(
              controller: _controller,
              children: const [
                ProjectsListPage(),
                TasksListPage(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabIndex == 0
          ? AppFabButton(
              icon: Icons.add,
              semanticLabel: 'Yeni Proje',
              onPressed: () => showCreateProjectSheet(context),
            )
          : AppFabButton(
              icon: Icons.add,
              semanticLabel: 'Yeni Görev',
              onPressed: () => context.push(RoutePaths.createTask),
            ),
    );
  }
}
