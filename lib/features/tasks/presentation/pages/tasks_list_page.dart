import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/components/task_card_widget.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/dialogs/app_dialog.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../controllers/task_list_controller.dart';
import '../utils/task_priority_mapping.dart';

/// Tasks Screen'in liste içeriği (SCREENS.md §4.9) — `ProjectsTasksPage`'in
/// "Görevler" sekmesine gömülür; kendi App Bar'ı yoktur.
class TasksListPage extends ConsumerStatefulWidget {
  const TasksListPage({super.key});

  @override
  ConsumerState<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends ConsumerState<TasksListPage> {
  TaskFilter _filter = TaskFilter.none;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListControllerProvider(_filter));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AppChip(
                  label: 'Tümü',
                  selected: _filter.priority == null && _filter.includeCompleted,
                  onTap: () => setState(
                    () => _filter = TaskFilter(projectId: _filter.projectId),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppChip(
                  label: 'Aktif',
                  selected: !_filter.includeCompleted,
                  onTap: () => setState(
                    () => _filter = TaskFilter(
                      priority: _filter.priority,
                      projectId: _filter.projectId,
                      includeCompleted: !_filter.includeCompleted,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _priorityChip(TaskPriority.low, 'Düşük', AppPriorityColors.low),
                const SizedBox(width: AppSpacing.sm),
                _priorityChip(TaskPriority.medium, 'Orta', AppPriorityColors.medium),
                const SizedBox(width: AppSpacing.sm),
                _priorityChip(TaskPriority.high, 'Yüksek', AppPriorityColors.high),
                const SizedBox(width: AppSpacing.sm),
                Consumer(
                  builder: (context, ref, _) {
                    final projects = ref.watch(projectListProvider(null)).valueOrNull ?? const [];
                    final selected = _filter.projectId;
                    String label = 'Proje';
                    if (selected != null) {
                      for (final project in projects) {
                        if (project.projectId == selected) label = project.title;
                      }
                    }
                    return AppChip(
                      label: label,
                      selected: selected != null,
                      onTap: () => _pickProjectFilter(context, projects),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: tasksAsync.when(
            loading: () => ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: List.generate(
                4,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: LoadingSkeleton(height: 76, borderRadius: 16),
                ),
              ),
            ),
            error: (error, _) {
              final message = error is Failure ? error.message : 'Görevler yüklenemedi.';
              return Center(
                child: ErrorState(
                  message: message,
                  onRetry: () => ref.invalidate(taskListControllerProvider(_filter)),
                ),
              );
            },
            data: (tasks) {
              if (tasks.isEmpty) {
                final hasActiveFilter = _filter.priority != null || !_filter.includeCompleted;
                return hasActiveFilter
                    ? const EmptyState(
                        icon: Icons.filter_alt_off_outlined,
                        message: 'Bu filtreyle görev bulunamadı',
                      )
                    : EmptyState(
                        icon: Icons.check_circle_outline,
                        message: 'Henüz görev eklemedin',
                        actionLabel: 'Görev Ekle',
                        onAction: () => context.push(RoutePaths.createTask),
                      );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: tasks.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => _TaskListItem(task: tasks[index], filter: _filter),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _priorityChip(TaskPriority priority, String label, Color color) {
    final selected = _filter.priority == priority;
    return AppChip(
      label: label,
      selected: selected,
      selectedColor: color,
      onTap: () => setState(
        () => _filter = TaskFilter(
          priority: selected ? null : priority,
          projectId: _filter.projectId,
          includeCompleted: _filter.includeCompleted,
        ),
      ),
    );
  }

  /// COMPONENTS.md §5.4 — Dropdown, Bottom Sheet içinde seçenek listesi
  /// açar. `projects`, Projects'in dışa açık `projectListProvider`'ından
  /// okunur (Tasks → Projects tek yönlü okuma, ARCHITECTURE.md §4).
  void _pickProjectFilter(BuildContext context, List<Project> projects) {
    AppBottomSheet.show<void>(
      context,
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Tüm Projeler'),
            selected: _filter.projectId == null,
            onTap: () {
              setState(
                () => _filter = TaskFilter(
                  priority: _filter.priority,
                  includeCompleted: _filter.includeCompleted,
                ),
              );
              Navigator.of(context).pop();
            },
          ),
          for (final project in projects)
            ListTile(
              title: Text(project.title),
              selected: project.projectId == _filter.projectId,
              onTap: () {
                setState(
                  () => _filter = TaskFilter(
                    priority: _filter.priority,
                    projectId: project.projectId,
                    includeCompleted: _filter.includeCompleted,
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}

class _TaskListItem extends ConsumerWidget {
  const _TaskListItem({required this.task, required this.filter});

  final Task task;
  final TaskFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(taskListControllerProvider(filter).notifier);

    return TaskCardWidget(
      title: task.title,
      isCompleted: task.isCompleted,
      priority: toPriorityLevel(task.priority),
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      subtaskCount: task.subtaskCount,
      completedSubtaskCount: task.completedSubtaskCount,
      onTap: () => context.push(RoutePaths.taskDetail.replaceFirst(':taskId', task.taskId)),
      onCompletedChanged: (value) async {
        final result = await notifier.toggleCompleted(task.taskId, isCompleted: value);
        if (!context.mounted) return;
        if (result case Err(:final failure)) {
          AppSnackbar.show(context, message: failure.message);
          return;
        }
        AppSnackbar.show(
          context,
          message: value ? 'Görev tamamlandı' : 'Görev tekrar açıldı',
          isSuccess: value,
          actionLabel: 'Geri Al',
          onAction: () => notifier.toggleCompleted(task.taskId, isCompleted: !value),
        );
      },
      onDelete: () async {
        final confirmed = await AppDialog.show(
          context,
          title: 'Görevi Sil',
          description: '"${task.title}" görevini silmek istediğine emin misin?',
          confirmLabel: 'Sil',
          isDestructive: true,
        );
        if (confirmed != true || !context.mounted) return;
        final result = await notifier.deleteTask(task.taskId);
        if (!context.mounted) return;
        if (result case Err(:final failure)) {
          AppSnackbar.show(context, message: failure.message);
        }
      },
    );
  }
}
