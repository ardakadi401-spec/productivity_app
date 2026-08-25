import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../domain/entities/project.dart';
import '../controllers/project_list_controller.dart';
import '../providers/project_providers.dart';
import '../widgets/create_project_sheet.dart';
import '../widgets/project_card_widget.dart';

/// Projects Screen'in liste içeriği (SCREENS.md §4.7) — `ProjectsTasksPage`'in
/// "Projeler" sekmesine gömülür; kendi App Bar'ı yoktur (Tasks'ın
/// `TasksListPage`'i ile aynı desen).
class ProjectsListPage extends ConsumerStatefulWidget {
  const ProjectsListPage({super.key});

  @override
  ConsumerState<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends ConsumerState<ProjectsListPage> {
  ProjectStatus _status = ProjectStatus.active;

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListControllerProvider(_status));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              AppChip(
                label: 'Aktif',
                selected: _status == ProjectStatus.active,
                onTap: () => setState(() => _status = ProjectStatus.active),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppChip(
                label: 'Arşivlenmiş',
                selected: _status == ProjectStatus.archived,
                onTap: () => setState(() => _status = ProjectStatus.archived),
              ),
            ],
          ),
        ),
        Expanded(
          child: projectsAsync.when(
            loading: () => ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: List.generate(
                4,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: LoadingSkeleton(height: 96, borderRadius: 16),
                ),
              ),
            ),
            error: (error, _) {
              final message = error is Failure ? error.message : 'Projeler yüklenemedi.';
              return Center(
                child: ErrorState(
                  message: message,
                  onRetry: () => ref.invalidate(projectListControllerProvider(_status)),
                ),
              );
            },
            data: (projects) {
              if (projects.isEmpty) {
                return _status == ProjectStatus.active
                    ? EmptyState(
                        icon: Icons.folder_outlined,
                        message: 'Henüz proje eklemedin',
                        actionLabel: 'Yeni Proje',
                        onAction: () => showCreateProjectSheet(context),
                      )
                    : const EmptyState(
                        icon: Icons.archive_outlined,
                        message: 'Arşivlenmiş proje yok',
                      );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: projects.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => _ProjectListItem(
                  key: ValueKey(projects[index].projectId),
                  project: projects[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProjectListItem extends ConsumerWidget {
  const _ProjectListItem({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(projectTaskStatsProvider(project.projectId));
    final stats = statsAsync.valueOrNull;

    return ProjectCardWidget(
      title: project.title,
      colorHex: project.color,
      taskCount: stats?.taskCount ?? project.taskCount,
      completedTaskCount: stats?.completedTaskCount ?? project.completedTaskCount,
      isArchived: project.isArchived,
      onTap: () =>
          context.push(RoutePaths.projectDetail.replaceFirst(':projectId', project.projectId)),
    );
  }
}
