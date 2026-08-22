import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/dialogs/app_dialog.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_filter.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../domain/entities/note.dart';
import '../controllers/create_note_controller.dart';
import '../controllers/edit_note_controller.dart';
import '../providers/note_providers.dart';
import '../widgets/note_form_fields.dart';
import '../widgets/note_link_picker_widget.dart';
import '../widgets/tag_picker_widget.dart';

/// `/notes/new` rotasına `extra` ile geçilen, önceden seçili proje/görev
/// bağlantısını taşıyan yük — Project Detail / Task Detail'in "Not Ekle"
/// eylemi tarafından kullanılır (`CreateTaskArgs` ile aynı desen).
class CreateNoteArgs {
  const CreateNoteArgs({this.projectId, this.taskId});

  final String? projectId;
  final String? taskId;
}

/// Note Detail Screen — SCREENS.md §4.19. Oluşturma ve düzenleme aynı
/// ekranda ele alınır: [noteId] `null` ise Create modu, doluysa mevcut notu
/// yükleyip Edit modunda render eder.
class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, this.noteId, this.initialProjectId, this.initialTaskId});

  final String? noteId;
  final String? initialProjectId;
  final String? initialTaskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (noteId == null) {
      return _CreateNoteForm(initialProjectId: initialProjectId, initialTaskId: initialTaskId);
    }

    final noteAsync = ref.watch(noteDetailProvider(noteId!));
    return noteAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Not')),
        body: const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              LoadingSkeleton(height: 52, borderRadius: 12),
              SizedBox(height: AppSpacing.md),
              LoadingSkeleton(height: 120, borderRadius: 12),
            ],
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Not')),
        body: Center(
          child: ErrorState(
            message: 'Not yüklenemedi.',
            onRetry: () => ref.invalidate(noteDetailProvider(noteId!)),
          ),
        ),
      ),
      data: (note) => note == null
          ? Scaffold(
              appBar: AppBar(title: const Text('Not')),
              body: const Center(child: ErrorState(message: 'Bu not artık mevcut değil.')),
            )
          : _EditNoteForm(note: note),
    );
  }
}

class _CreateNoteForm extends ConsumerStatefulWidget {
  const _CreateNoteForm({this.initialProjectId, this.initialTaskId});

  final String? initialProjectId;
  final String? initialTaskId;

  @override
  ConsumerState<_CreateNoteForm> createState() => _CreateNoteFormState();
}

class _CreateNoteFormState extends ConsumerState<_CreateNoteForm> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _titleError;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty ? 'Not başlığı boş olamaz.' : null;
    });
    return _titleError == null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = createNoteControllerProvider(
      (projectId: widget.initialProjectId, taskId: widget.initialTaskId),
    );
    final formState = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final projects = ref.watch(projectListProvider(null)).valueOrNull ?? const <Project>[];
    final tasks = ref.watch(taskListProvider(TaskFilter.none)).valueOrNull ?? const <Task>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Not'),
        actions: [
          IconButton(
            icon: Icon(formState.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            tooltip: 'Sabitle',
            onPressed: controller.togglePinned,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NoteFormFields(
                titleController: _titleController,
                contentController: _contentController,
                titleError: _titleError,
                color: formState.color,
                onColorChanged: controller.setColor,
              ),
              const SizedBox(height: AppSpacing.md),
              NoteLinkPickerWidget(
                projects: projects,
                selectedProjectId: formState.projectId,
                onProjectChanged: controller.setProjectId,
                tasks: tasks,
                selectedTaskId: formState.taskId,
                onTaskChanged: controller.setTaskId,
              ),
              const SizedBox(height: AppSpacing.md),
              TagPickerWidget(selectedTagIds: formState.tagIds, onToggle: controller.toggleTag),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Notu Kaydet',
                isFullWidth: true,
                isLoading: formState.isSaving,
                onPressed: formState.isSaving
                    ? null
                    : () async {
                        if (!_validate()) return;
                        final result = await controller.save(
                          title: _titleController.text,
                          content: _contentController.text,
                        );
                        if (!context.mounted) return;
                        switch (result) {
                          case Ok():
                            AppSnackbar.show(context, message: 'Not oluşturuldu', isSuccess: true);
                            context.pop();
                          case Err(:final failure):
                            AppSnackbar.show(context, message: failure.message);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditNoteForm extends ConsumerStatefulWidget {
  const _EditNoteForm({required this.note});

  final Note note;

  @override
  ConsumerState<_EditNoteForm> createState() => _EditNoteFormState();
}

class _EditNoteFormState extends ConsumerState<_EditNoteForm> {
  late final _titleController = TextEditingController(text: widget.note.title);
  late final _contentController = TextEditingController(text: widget.note.content ?? '');
  String? _titleError;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty ? 'Not başlığı boş olamaz.' : null;
    });
    return _titleError == null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = editNoteControllerProvider(widget.note);
    final formState = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final projects = ref.watch(projectListProvider(null)).valueOrNull ?? const <Project>[];
    final tasks = ref.watch(taskListProvider(TaskFilter.none)).valueOrNull ?? const <Task>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notu Düzenle'),
        actions: [
          IconButton(
            icon: Icon(formState.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            tooltip: 'Sabitle',
            onPressed: controller.togglePinned,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Sil',
            onPressed: () async {
              final confirmed = await AppDialog.show(
                context,
                title: 'Notu Sil',
                description: '"${widget.note.title}" notunu silmek istediğine emin misin?',
                confirmLabel: 'Sil',
                isDestructive: true,
              );
              if (confirmed != true || !context.mounted) return;
              final result = await ref.read(deleteNoteUseCaseProvider).call(widget.note.noteId);
              if (!context.mounted) return;
              switch (result) {
                case Ok():
                  context.pop();
                case Err(:final failure):
                  AppSnackbar.show(context, message: failure.message);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NoteFormFields(
                titleController: _titleController,
                contentController: _contentController,
                titleError: _titleError,
                color: formState.color,
                onColorChanged: controller.setColor,
              ),
              const SizedBox(height: AppSpacing.md),
              NoteLinkPickerWidget(
                projects: projects,
                selectedProjectId: formState.projectId,
                onProjectChanged: controller.setProjectId,
                tasks: tasks,
                selectedTaskId: formState.taskId,
                onTaskChanged: controller.setTaskId,
              ),
              const SizedBox(height: AppSpacing.md),
              TagPickerWidget(selectedTagIds: formState.tagIds, onToggle: controller.toggleTag),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Notu Güncelle',
                isFullWidth: true,
                isLoading: formState.isSaving,
                onPressed: formState.isSaving
                    ? null
                    : () async {
                        if (!_validate()) return;
                        final result = await controller.save(
                          title: _titleController.text,
                          content: _contentController.text,
                        );
                        if (!context.mounted) return;
                        switch (result) {
                          case Ok():
                            AppSnackbar.show(context, message: 'Not güncellendi', isSuccess: true);
                            context.pop();
                          case Err(:final failure):
                            AppSnackbar.show(context, message: failure.message);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
