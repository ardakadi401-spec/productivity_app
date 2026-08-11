import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/components/due_date_label_widget.dart';
import '../../../../shared/components/priority_badge_widget.dart';
import '../../../../shared/components/project_color_badge_widget.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/dialogs/app_dialog.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/entities/sub_task.dart';
import '../../domain/entities/task.dart';
import '../controllers/task_detail_controller.dart';
import '../providers/task_providers.dart';
import '../utils/task_priority_mapping.dart';

/// Task Detail Screen — SCREENS.md §4.10.
class TaskDetailPage extends ConsumerWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailControllerProvider(taskId));
    final subTasksAsync = ref.watch(subTasksProvider(taskId));
    final controller = ref.read(taskDetailControllerProvider(taskId).notifier);

    ref.listen(taskDetailControllerProvider(taskId), (previous, next) {
      if (next is AsyncError) {
        final failure = next.error;
        final message = failure is Failure ? failure.message : 'Bir şeyler ters gitti.';
        AppSnackbar.show(context, message: message);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görev Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Düzenle',
            onPressed: taskAsync.valueOrNull == null
                ? null
                : () => context.push(
                      RoutePaths.editTask.replaceFirst(':taskId', taskId),
                      extra: taskAsync.value,
                    ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Sil',
            onPressed: taskAsync.valueOrNull == null
                ? null
                : () async {
                    final task = taskAsync.value!;
                    final confirmed = await AppDialog.show(
                      context,
                      title: 'Görevi Sil',
                      description: '"${task.title}" görevini silmek istediğine emin misin?',
                      confirmLabel: 'Sil',
                      isDestructive: true,
                    );
                    if (confirmed != true || !context.mounted) return;
                    final result = await controller.deleteTask();
                    if (!context.mounted) return;
                    if (result case Err(:final failure)) {
                      AppSnackbar.show(context, message: failure.message);
                    } else {
                      context.pop();
                    }
                  },
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              LoadingSkeleton(height: 28, borderRadius: 8),
              SizedBox(height: AppSpacing.md),
              LoadingSkeleton(height: 80, borderRadius: 16),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: ErrorState(
            message: 'Görev yüklenemedi.',
            onRetry: () => ref.invalidate(taskDetailControllerProvider(taskId)),
          ),
        ),
        data: (task) {
          if (task == null) {
            return const Center(child: ErrorState(message: 'Bu görev artık mevcut değil.'));
          }
          return _TaskDetailBody(
            task: task,
            subTasksAsync: subTasksAsync,
            controller: controller,
          );
        },
      ),
    );
  }
}

class _TaskDetailBody extends ConsumerWidget {
  const _TaskDetailBody({
    required this.task,
    required this.subTasksAsync,
    required this.controller,
  });

  final Task task;
  final AsyncValue<List<SubTask>> subTasksAsync;
  final TaskDetailController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleCompleted(isCompleted: !task.isCompleted),
                child: Row(
                  children: [
                    Icon(
                      task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: task.isCompleted ? theme.colorScheme.primary : tokens.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        task.title,
                        style: AppTypography.h1.copyWith(
                          color: task.isCompleted ? tokens.textDisabled : theme.colorScheme.onSurface,
                          decoration:
                              task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PriorityBadge(level: toPriorityLevel(task.priority)),
          ],
        ),
        if (task.description != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(task.description!, style: AppTypography.bodyMd.copyWith(color: tokens.textSecondary)),
        ],
        if (task.dueDate != null) ...[
          const SizedBox(height: AppSpacing.sm),
          DueDateLabel(dueDate: task.dueDate, dueTime: task.dueTime, isCompleted: task.isCompleted),
        ],
        if (task.projectId != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _LinkedProjectChip(projectId: task.projectId!),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Pomodoro ile Çalış',
          variant: AppButtonVariant.outline,
          onPressed: () => context.push(RoutePaths.pomodoro),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text('Alt Görevler', style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface)),
            const Spacer(),
            Text(
              '${task.completedSubtaskCount}/${task.subtaskCount}',
              style: AppTypography.caption.copyWith(color: tokens.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: task.completionRatio,
            minHeight: 6,
            backgroundColor: tokens.primaryLight,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        subTasksAsync.when(
          loading: () => const LoadingSkeleton(height: 44, borderRadius: 12),
          error: (error, _) => const SizedBox.shrink(),
          data: (subTasks) {
            if (subTasks.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: EmptyState(icon: Icons.checklist_outlined, message: 'Alt görev eklenmedi'),
              );
            }
            return Column(
              children: [
                for (final subTask in subTasks)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: subTask.isCompleted,
                    title: Text(
                      subTask.title,
                      style: AppTypography.bodyMd.copyWith(
                        color: subTask.isCompleted ? tokens.textDisabled : theme.colorScheme.onSurface,
                        decoration:
                            subTask.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                    onChanged: (value) => controller.toggleSubTaskCompleted(
                      subTask.subtaskId,
                      isCompleted: value ?? false,
                    ),
                  ),
              ],
            );
          },
        ),
        TextButton.icon(
          onPressed: () => _showAddSubTaskSheet(context, controller),
          icon: const Icon(Icons.add),
          label: const Text('Alt Görev Ekle'),
        ),
      ],
    );
  }

  void _showAddSubTaskSheet(BuildContext context, TaskDetailController controller) {
    final textController = TextEditingController();
    AppBottomSheet.show<void>(
      context,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Alt görev başlığı'),
                onSubmitted: (value) {
                  controller.addSubTask(value);
                  Navigator.of(context).pop();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                controller.addSubTask(textController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// İlişkili proje bilgisi (SCREENS.md §4.10) — Tasks, Projects'in dışa açık
/// `projectDetailProvider`'ını okur (Tasks → Projects tek yönlü okuma,
/// ARCHITECTURE.md §4 bağımlılık tablosu).
class _LinkedProjectChip extends ConsumerWidget {
  const _LinkedProjectChip({required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailProvider(projectId));
    final project = projectAsync.valueOrNull;
    if (project == null) return const SizedBox.shrink();

    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    return InkWell(
      onTap: () => context.push(RoutePaths.projectDetail.replaceFirst(':projectId', projectId)),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProjectColorBadge(color: hexToColor(project.color)),
          const SizedBox(width: AppSpacing.xs),
          Text(project.title, style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        ],
      ),
    );
  }
}
