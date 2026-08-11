import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../controllers/create_goal_controller.dart';
import '../providers/goal_providers.dart';
import 'goal_form_fields.dart';

/// Yeni Hedef Bottom Sheet — SCREENS.md §4.14 "FAB ile yeni hedef oluşturma
/// (Bottom Sheet)".
Future<void> showCreateGoalSheet(BuildContext context) {
  return AppBottomSheet.show<void>(context, child: const CreateGoalSheet());
}

class CreateGoalSheet extends ConsumerStatefulWidget {
  const CreateGoalSheet({super.key});

  @override
  ConsumerState<CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends ConsumerState<CreateGoalSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
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
    final formState = ref.watch(createGoalControllerProvider);
    final controller = ref.read(createGoalControllerProvider.notifier);
    final tasks = ref.watch(goalAvailableTasksProvider).valueOrNull ?? const [];

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
            GoalFormFields(
              titleController: _titleController,
              descriptionController: _descriptionController,
              titleError: _titleError,
              periodType: formState.periodType,
              onPeriodTypeChanged: controller.setPeriodType,
              progressType: formState.progressType,
              onProgressTypeChanged: controller.setProgressType,
              manualProgress: formState.manualProgress,
              onManualProgressChanged: controller.setManualProgress,
              linkedTaskIds: formState.linkedTaskIds,
              onToggleLinkedTask: controller.toggleLinkedTask,
              availableTasks: tasks,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Oluştur',
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
                          AppSnackbar.show(context, message: 'Hedef oluşturuldu', isSuccess: true);
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
