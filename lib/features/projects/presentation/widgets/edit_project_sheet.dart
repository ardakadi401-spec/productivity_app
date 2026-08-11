import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../domain/entities/project.dart';
import '../controllers/edit_project_controller.dart';
import 'project_form_fields.dart';

/// Proje düzenleme Bottom Sheet — Project Detail Screen'deki "Düzenle" ikon
/// eylemi (SCREENS.md §4.8), Yeni Proje Bottom Sheet ile aynı alan seti.
class EditProjectSheet extends ConsumerStatefulWidget {
  const EditProjectSheet({super.key, required this.project});

  final Project project;

  @override
  ConsumerState<EditProjectSheet> createState() => _EditProjectSheetState();
}

class _EditProjectSheetState extends ConsumerState<EditProjectSheet> {
  late final _titleController = TextEditingController(text: widget.project.title);
  late final _descriptionController =
      TextEditingController(text: widget.project.description ?? '');
  String? _titleError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty ? 'Proje adı boş olamaz.' : null;
    });
    return _titleError == null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = editProjectControllerProvider(widget.project);
    final formState = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectFormFields(
            titleController: _titleController,
            descriptionController: _descriptionController,
            titleError: _titleError,
            color: formState.color,
            onColorChanged: controller.setColor,
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
                        AppSnackbar.show(context, message: 'Proje güncellendi', isSuccess: true);
                        Navigator.of(context).pop();
                      case Err(:final failure):
                        AppSnackbar.show(context, message: failure.message);
                    }
                  },
          ),
        ],
      ),
    );
  }
}
