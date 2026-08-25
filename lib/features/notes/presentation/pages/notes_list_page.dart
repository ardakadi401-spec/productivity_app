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
import '../../../../shared/dialogs/app_dialog.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_filter.dart';
import '../controllers/note_list_controller.dart';
import '../utils/note_preview_text.dart';

/// Notes Screen — SCREENS.md §4.18.
class NotesListPage extends ConsumerWidget {
  const NotesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(noteListControllerProvider(NoteFilter.none));

    return Scaffold(
      appBar: AppBar(title: const Text('Notlar')),
      floatingActionButton: AppFabButton(
        icon: Icons.add,
        semanticLabel: 'Yeni Not',
        onPressed: () => context.push(RoutePaths.createNote),
      ),
      body: notesAsync.when(
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
          final message = error is Failure ? error.message : 'Notlar yüklenemedi.';
          return Center(
            child: ErrorState(
              message: message,
              onRetry: () => ref.invalidate(noteListControllerProvider(NoteFilter.none)),
            ),
          );
        },
        data: (notes) {
          if (notes.isEmpty) {
            return EmptyState(
              icon: Icons.sticky_note_2_outlined,
              message: 'Henüz not eklemedin',
              actionLabel: 'Not Ekle',
              onAction: () => context.push(RoutePaths.createNote),
            );
          }
          final pinned = notes.where((n) => n.isPinned).toList();
          final others = notes.where((n) => !n.isPinned).toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (pinned.isNotEmpty) ...[
                _SectionLabel('Sabitlenmiş'),
                for (final note in pinned) ...[
                  _NoteListItem(key: ValueKey(note.noteId), note: note),
                  const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.sm),
              ],
              if (others.isNotEmpty) ...[
                if (pinned.isNotEmpty) _SectionLabel('Tümü'),
                for (final note in others) ...[
                  _NoteListItem(key: ValueKey(note.noteId), note: note),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(label, style: AppTypography.overline.copyWith(color: tokens.textSecondary)),
    );
  }
}

class _NoteListItem extends ConsumerWidget {
  const _NoteListItem({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(noteListControllerProvider(NoteFilter.none).notifier);
    final linkedLabel = _resolveLinkedLabel(ref);

    return NoteCardWidget(
      title: note.title,
      contentPreview: notePreviewText(note.content),
      color: note.color == null ? null : hexToColor(note.color!),
      linkedLabel: linkedLabel,
      isPinned: note.isPinned,
      onTap: () => context.push(RoutePaths.noteDetail.replaceFirst(':noteId', note.noteId)),
      onTogglePinned: () async {
        final result = await notifier.togglePinned(note.noteId, isPinned: !note.isPinned);
        if (!context.mounted) return;
        if (result case Err(:final failure)) {
          AppSnackbar.show(context, message: failure.message);
        }
      },
      onDelete: () async {
        final confirmed = await AppDialog.show(
          context,
          title: 'Notu Sil',
          description: '"${note.title}" notunu silmek istediğine emin misin?',
          confirmLabel: 'Sil',
          isDestructive: true,
        );
        if (confirmed != true || !context.mounted) return;
        final result = await notifier.deleteNote(note.noteId);
        if (!context.mounted) return;
        if (result case Err(:final failure)) {
          AppSnackbar.show(context, message: failure.message);
        }
      },
    );
  }

  /// Notes → Projects/Tasks tek yönlü okuma (ARCHITECTURE.md §4) — yalnızca
  /// görüntüleme amaçlı, yazma tetiklemez.
  String? _resolveLinkedLabel(WidgetRef ref) {
    if (note.projectId != null) {
      final project = ref.watch(projectDetailProvider(note.projectId!)).valueOrNull;
      if (project != null) return 'Proje: ${project.title}';
    }
    if (note.taskId != null) {
      final task = ref.watch(taskDetailProvider(note.taskId!)).valueOrNull;
      if (task != null) return 'Görev: ${task.title}';
    }
    return null;
  }
}
