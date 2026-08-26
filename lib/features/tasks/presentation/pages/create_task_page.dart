import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../controllers/create_task_controller.dart';
import '../widgets/task_form_fields.dart';

/// `/tasks/new` rotasına `extra` ile geçilen, önceden seçili alanları
/// taşıyan yük — Project Detail Screen'in "Görev Ekle"si (SCREENS.md §4.8)
/// ve Calendar Screen'in "Bu Güne Görev Ekle"si (SCREENS.md §4.13) tarafından
/// kullanılır.
class CreateTaskArgs {
  const CreateTaskArgs({this.projectId, this.dueDate});

  final String? projectId;
  final DateTime? dueDate;
}

/// Create Task Screen — SCREENS.md §4.11.
class CreateTaskPage extends ConsumerStatefulWidget {
  const CreateTaskPage({super.key, this.initialProjectId, this.initialDueDate});

  /// Project Detail Screen'in "Görev Ekle" eylemiyle önceden seçilen proje
  /// (SCREENS.md §4.8).
  final String? initialProjectId;

  /// Calendar Screen'in "Bu Güne Görev Ekle" eylemiyle önceden seçilen tarih
  /// (SCREENS.md §4.13).
  final DateTime? initialDueDate;

  @override
  ConsumerState<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends ConsumerState<CreateTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _draftSubTaskController = TextEditingController();
  String? _titleError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _draftSubTaskController.dispose();
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
    final provider = createTaskControllerProvider(
      (projectId: widget.initialProjectId, dueDate: widget.initialDueDate),
    );
    final formState = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Görev')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Proje listesini yalnızca bu alt-ağaç izler (`Consumer`) —
              // sayfadaki başka bir projenin değişmesi AppBar'ı, Kaydet
              // butonunu veya alt görev taslak listesini yeniden inşa
              // etmez (ARCHITECTURE.md §12.1). `TaskFormFields` kasıtlı
              // olarak provider-bağımsız (bkz. kendi doc notu) kaldığından
              // watch burada, çağıran sayfada kalır.
              Consumer(
                builder: (context, ref, _) {
                  final projects = ref.watch(projectListProvider(null)).valueOrNull ?? const <Project>[];
                  return TaskFormFields(
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
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _DraftSubTasksSection(
                controller: _draftSubTaskController,
                drafts: formState.draftSubTasks,
                onAdd: () {
                  controller.addDraftSubTask(_draftSubTaskController.text);
                  _draftSubTaskController.clear();
                },
                onRemove: controller.removeDraftSubTask,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Görevi Kaydet',
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
                            AppSnackbar.show(context, message: 'Görev oluşturuldu', isSuccess: true);
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

class _DraftSubTasksSection extends StatelessWidget {
  const _DraftSubTasksSection({
    required this.controller,
    required this.drafts,
    required this.onAdd,
    required this.onRemove,
  });

  final TextEditingController controller;
  final List<String> drafts;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Alt Görevler', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        for (var i = 0; i < drafts.length; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_box_outline_blank),
            title: Text(drafts[i]),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => onRemove(i),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Alt görev ekle'),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
          ],
        ),
      ],
    );
  }
}
