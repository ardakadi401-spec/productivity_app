import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../domain/entities/task.dart';
import '../controllers/edit_task_controller.dart';
import '../providers/task_providers.dart';
import '../widgets/task_form_fields.dart';

/// Edit Task Screen — SCREENS.md §4.12. `initialTask` verilirse (Task Detail
/// ekranından `extra` ile geçildiyse) doğrudan formu render eder; verilmezse
/// (örn. doğrudan derin bağlantı) `taskDetailProvider`'dan bir kerelik veri
/// bekler.
class EditTaskPage extends ConsumerWidget {
  const EditTaskPage({super.key, required this.taskId, this.initialTask});

  final String taskId;
  final Task? initialTask;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialTask != null) {
      return _EditTaskForm(task: initialTask!);
    }

    final taskAsync = ref.watch(taskDetailProvider(taskId));
    return taskAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Görevi Düzenle')),
        body: const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              LoadingSkeleton(height: 52, borderRadius: 12),
              SizedBox(height: AppSpacing.md),
              LoadingSkeleton(height: 52, borderRadius: 12),
            ],
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Görevi Düzenle')),
        body: Center(
          child: ErrorState(
            message: 'Görev yüklenemedi.',
            onRetry: () => ref.invalidate(taskDetailProvider(taskId)),
          ),
        ),
      ),
      data: (task) => task == null
          ? Scaffold(
              appBar: AppBar(title: const Text('Görevi Düzenle')),
              body: const Center(child: ErrorState(message: 'Bu görev artık mevcut değil.')),
            )
          : _EditTaskForm(task: task),
    );
  }
}

class _EditTaskForm extends ConsumerStatefulWidget {
  const _EditTaskForm({required this.task});

  final Task task;

  @override
  ConsumerState<_EditTaskForm> createState() => _EditTaskFormState();
}

class _EditTaskFormState extends ConsumerState<_EditTaskForm> {
  late final _titleController = TextEditingController(text: widget.task.title);
  late final _descriptionController = TextEditingController(text: widget.task.description ?? '');
  String? _titleError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty ? 'Görev başlığı boş olamaz.' : null;
    });
    return _titleError == null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = editTaskControllerProvider(widget.task);
    final formState = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final projects = ref.watch(projectListProvider(null)).valueOrNull ?? const <Project>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Görevi Düzenle')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaskFormFields(
                titleController: _titleController,
                descriptionController: _descriptionController,
                titleError: _titleError,
                priority: formState.priority,
                onPriorityChanged: controller.setPriority,
                dueDate: formState.dueDate,
                onDueDateChanged: controller.setDueDate,
                dueTime: formState.dueTime,
                onDueTimeChanged: controller.setDueTime,
                projects: projects,
                selectedProjectId: formState.projectId,
                onProjectChanged: controller.setProjectId,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Görevi Güncelle',
                isFullWidth: true,
                isLoading: formState.isSaving,
                onPressed: formState.isSaving
                    ? null
                    : () async {
                        if (!_validate()) return;
                        final result = await controller.save(
                          title: _titleController.text,
                          description: _descriptionController.text,
                        );
                        if (!context.mounted) return;
                        switch (result) {
                          case Ok():
                            AppSnackbar.show(context, message: 'Görev güncellendi', isSuccess: true);
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
