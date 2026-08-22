import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../controllers/create_habit_controller.dart';
import 'habit_form_fields.dart';

/// Yeni Alışkanlık Bottom Sheet — SCREENS.md §4.15 "FAB ile yeni alışkanlık
/// oluşturma".
Future<void> showCreateHabitSheet(BuildContext context) {
  return AppBottomSheet.show<void>(context, child: const CreateHabitSheet());
}

class CreateHabitSheet extends ConsumerStatefulWidget {
  const CreateHabitSheet({super.key});

  @override
  ConsumerState<CreateHabitSheet> createState() => _CreateHabitSheetState();
}

class _CreateHabitSheetState extends ConsumerState<CreateHabitSheet> {
  final _nameController = TextEditingController();
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Alışkanlık adı boş olamaz.' : null;
    });
    return _nameError == null;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createHabitControllerProvider);
    final controller = ref.read(createHabitControllerProvider.notifier);

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
            HabitFormFields(
              nameController: _nameController,
              nameError: _nameError,
              icon: formState.icon,
              onIconChanged: controller.setIcon,
              color: formState.color,
              onColorChanged: controller.setColor,
              targetFrequency: formState.targetFrequency,
              onTargetFrequencyChanged: controller.setTargetFrequency,
              targetDays: formState.targetDays,
              onToggleTargetDay: controller.toggleTargetDay,
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
                      final result = await controller.save(name: _nameController.text);
                      if (!context.mounted) return;
                      switch (result) {
                        case Ok():
                          AppSnackbar.show(context, message: 'Alışkanlık oluşturuldu', isSuccess: true);
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
