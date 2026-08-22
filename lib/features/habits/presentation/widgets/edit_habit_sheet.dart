import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../domain/entities/habit.dart';
import '../controllers/edit_habit_controller.dart';
import 'habit_form_fields.dart';

/// Alışkanlık düzenleme Bottom Sheet — Habit Detail Screen'in "düzenle"
/// eylemiyle açılır (SCREENS.md §4.16).
class EditHabitSheet extends ConsumerStatefulWidget {
  const EditHabitSheet({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<EditHabitSheet> createState() => _EditHabitSheetState();
}

class _EditHabitSheetState extends ConsumerState<EditHabitSheet> {
  late final _nameController = TextEditingController(text: widget.habit.name);
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
    final provider = editHabitControllerProvider(widget.habit);
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
              label: 'Güncelle',
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
                          AppSnackbar.show(context, message: 'Alışkanlık güncellendi', isSuccess: true);
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
