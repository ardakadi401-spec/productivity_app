import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../domain/entities/goal.dart';
import '../controllers/edit_goal_controller.dart';
import '../providers/goal_providers.dart';
import 'goal_form_fields.dart';

/// Hedef düzenleme Bottom Sheet — Goal Card'a dokunmayla açılır (SCREENS.md
/// §4.14 "hedef detay/düzenleme etkileşimi Bottom Sheet üzerinden bu ekran
/// içinde çözülür").
class EditGoalSheet extends ConsumerStatefulWidget {
  const EditGoalSheet({super.key, required this.goal});

  final Goal goal;

  @override
  ConsumerState<EditGoalSheet> createState() => _EditGoalSheetState();
}

class _EditGoalSheetState extends ConsumerState<EditGoalSheet> {
  late final _titleController = TextEditingController(text: widget.goal.title);
  late final _descriptionController = TextEditingController(text: widget.goal.description ?? '');
  String? _titleError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty ? 'Hedef başlığı boş olamaz.' : null;
    });
    return _titleError == null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = editGoalControllerProvider(widget.goal);
    final formState = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görev listesini yalnızca bu alt-ağaç izler (`Consumer`) —
            // ARCHITECTURE.md §12.1, `create_goal_sheet.dart` ile aynı
            // gerekçe.
            Consumer(
              builder: (context, ref, _) {
                final tasks = ref.watch(goalAvailableTasksProvider).valueOrNull ?? const [];
                return GoalFormFields(
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                  titleError: _titleError,
                  periodType: widget.goal.periodType,
                  progressType: formState.progressType,
                  onProgressTypeChanged: controller.setProgressType,
                  manualProgress: formState.manualProgress,
                  onManualProgressChanged: controller.setManualProgress,
                  linkedTaskIds: formState.linkedTaskIds,
                  onToggleLinkedTask: controller.toggleLinkedTask,
                  availableTasks: tasks,
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Güncelle',
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
                          AppSnackbar.show(context, message: 'Hedef güncellendi', isSuccess: true);
                          Navigator.of(context).pop();
                        case Err(:final failure):
                          AppSnackbar.show(context, message: failure.message);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
