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
import '../../../../shared/components/note_card_widget.dart';
import '../../../../shared/components/priority_badge_widget.dart';
import '../../../../shared/components/project_color_badge_widget.dart';
import '../../../../shared/components/task_card_widget.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/dialogs/app_dialog.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../notes/presentation/pages/note_detail_page.dart';
import '../../../notes/presentation/utils/note_preview_text.dart';
import '../../../notes/presentation/providers/note_providers.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/pages/create_task_page.dart';
import '../../domain/entities/project.dart';
import '../controllers/project_detail_controller.dart';
import '../providers/project_providers.dart';
import '../widgets/edit_project_sheet.dart';

/// Project Detail Screen — SCREENS.md §4.8.
class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailControllerProvider(projectId));
    final controller = ref.read(projectDetailControllerProvider(projectId).notifier);

    ref.listen(projectDetailControllerProvider(projectId), (previous, next) {
      if (next is AsyncError) {
        final failure = next.error;
        final message = failure is Failure ? failure.message : 'Bir şeyler ters gitti.';
        AppSnackbar.show(context, message: message);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(projectAsync.valueOrNull?.title ?? 'Proje Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Düzenle',
            onPressed: projectAsync.valueOrNull == null
                ? null
                : () => AppBottomSheet.show<void>(
                      context,
                      child: EditProjectSheet(project: projectAsync.value!),
                    ),
          ),
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: 'Arşivle',
            onPressed: projectAsync.valueOrNull == null
                ? null
                : () async {
                    final project = projectAsync.value!;
                    final archiving = !project.isArchived;
                    final confirmed = await AppDialog.show(
                      context,
                      title: archiving ? 'Projeyi Arşivle' : 'Arşivden Çıkar',
                      description: archiving
                          ? '"${project.title}" projesini arşivlemek istediğine emin misin? Bağlı görevler silinmez, salt-okunur olarak erişilebilir kalır.'
                          : '"${project.title}" projesini tekrar aktif hale getirmek istediğine emin misin?',
                      confirmLabel: archiving ? 'Arşivle' : 'Aktif Et',
                    );
                    if (confirmed != true || !context.mounted) return;
                    final result = await controller.setArchived(isArchived: archiving);
                    if (!context.mounted) return;
                    if (result case Err(:final failure)) {
                      AppSnackbar.show(context, message: failure.message);
                    } else {
                      AppSnackbar.show(
                        context,
                        message: archiving ? 'Proje arşivlendi' : 'Proje arşivden çıkarıldı',
                        isSuccess: true,
                      );
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Sil',
            onPressed: projectAsync.valueOrNull == null
                ? null
                : () async {
                    final project = projectAsync.value!;
                    final confirmed = await AppDialog.show(
                      context,
                      title: 'Projeyi Sil',
                      description:
                          '"${project.title}" projesini silmek istediğine emin misin? Bağlı görevler silinmez, yalnızca proje bağlantıları kaldırılır. Bu işlem geri alınamaz.',
                      confirmLabel: 'Sil',
                      isDestructive: true,
                    );
                    if (confirmed != true || !context.mounted) return;
                    final result = await controller.delete();
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
      body: projectAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              LoadingSkeleton(height: 28, borderRadius: 8),
              SizedBox(height: AppSpacing.md),
              LoadingSkeleton(height: 60, borderRadius: 16),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: ErrorState(
            message: 'Proje yüklenemedi.',
            onRetry: () => ref.invalidate(projectDetailControllerProvider(projectId)),
          ),
        ),
        data: (project) {
          if (project == null) {
            return const Center(child: ErrorState(message: 'Bu proje artık mevcut değil.'));
          }
          return _ProjectDetailBody(project: project);
        },
      ),
    );
  }
}

class _ProjectDetailBody extends ConsumerWidget {
  const _ProjectDetailBody({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final statsAsync = ref.watch(projectTaskStatsProvider(project.projectId));
    final tasksAsync = ref.watch(projectTasksProvider(project.projectId));
    final notesAsync = ref.watch(notesByProjectProvider(project.projectId));

    final taskCount = statsAsync.valueOrNull?.taskCount ?? project.taskCount;
    final completedTaskCount = statsAsync.valueOrNull?.completedTaskCount ?? project.completedTaskCount;
    final ratio = taskCount == 0 ? 0.0 : completedTaskCount / taskCount;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            ProjectColorBadge(color: hexToColor(project.color)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                project.title,
                style: AppTypography.h1.copyWith(color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
        if (project.description != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            project.description!,
            style: AppTypography.bodyMd.copyWith(color: tokens.textSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text('İlerleme', style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface)),
            const Spacer(),
            Text(
              '$completedTaskCount/$taskCount görev',
              style: AppTypography.caption.copyWith(color: tokens.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        // COMPONENTS.md §7.2 — detay ekranında 6dp, dolgu primary, track primary-light.
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: tokens.primaryLight,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text('Görevler', style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface)),
            const Spacer(),
            AppButton(
              label: 'Görev Ekle',
              variant: AppButtonVariant.text,
              onPressed: () =>
                  context.push(RoutePaths.createTask, extra: CreateTaskArgs(projectId: project.projectId)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        tasksAsync.when(
          loading: () => const LoadingSkeleton(height: 76, borderRadius: 16),
          error: (error, _) => const SizedBox.shrink(),
          data: (tasks) {
            if (tasks.isEmpty) {
              return EmptyState(
                icon: Icons.checklist_outlined,
                message: 'Bu projede henüz görev yok',
                actionLabel: 'Görev Ekle',
                onAction: () => context.push(RoutePaths.createTask, extra: CreateTaskArgs(projectId: project.projectId)),
              );
            }
            return Column(
              children: [
                for (final task in tasks) ...[
                  TaskCardWidget(
                    key: ValueKey(task.taskId),
                    title: task.title,
                    isCompleted: task.isCompleted,
                    priority: _toPriorityLevel(task.priority),
                    dueDate: task.dueDate,
                    dueTime: task.dueTime,
                    subtaskCount: task.subtaskCount,
                    completedSubtaskCount: task.completedSubtaskCount,
                    onTap: () =>
                        context.push(RoutePaths.taskDetail.replaceFirst(':taskId', task.taskId)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text('Notlar', style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface)),
            const Spacer(),
            AppButton(
              label: 'Not Ekle',
              variant: AppButtonVariant.text,
              onPressed: () => context.push(
                RoutePaths.createNote,
                extra: CreateNoteArgs(projectId: project.projectId),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        notesAsync.when(
          loading: () => const LoadingSkeleton(height: 64, borderRadius: 16),
          error: (error, _) => const SizedBox.shrink(),
          data: (notes) {
            if (notes.isEmpty) {
              return EmptyState(
                icon: Icons.sticky_note_2_outlined,
                message: 'Bu projeye bağlı not yok',
                actionLabel: 'Not Ekle',
                onAction: () => context.push(
                  RoutePaths.createNote,
                  extra: CreateNoteArgs(projectId: project.projectId),
                ),
              );
            }
            return Column(
              children: [
                for (final note in notes) ...[
                  NoteCardWidget(
                    key: ValueKey(note.noteId),
                    title: note.title,
                    contentPreview: notePreviewText(note.content),
                    color: note.color == null ? null : hexToColor(note.color!),
                    isPinned: note.isPinned,
                    onTap: () =>
                        context.push(RoutePaths.noteDetail.replaceFirst(':noteId', note.noteId)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  /// `Task` feature'ının `TaskPriority`'sini `shared/`'ın feature-agnostik
  /// `PriorityLevel`'ına eşler — Tasks'ın kendi eşlemesi
  /// (`task_priority_mapping.dart`) Tasks'ın Presentation katmanında olduğundan
  /// (ARCHITECTURE.md §10.2 madde 1 "feature'lar birbirinin Presentation
  /// katmanına bağımlı olamaz") buradan import edilemez; üç satırlık aynı
  /// eşleme burada ayrıca tanımlanır.
  PriorityLevel _toPriorityLevel(TaskPriority priority) => switch (priority) {
        TaskPriority.low => PriorityLevel.low,
        TaskPriority.medium => PriorityLevel.medium,
        TaskPriority.high => PriorityLevel.high,
      };
}
