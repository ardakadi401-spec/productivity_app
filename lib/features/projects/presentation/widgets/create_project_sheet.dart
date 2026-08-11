import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../domain/entities/project.dart';
import '../controllers/create_project_controller.dart';
import 'project_form_fields.dart';

/// Projects Screen'in FAB'ı ve boş durum eylemi tarafından çağrılır —
/// SCREENS.md §6.3 akışının tamamı: Bottom Sheet açılır, proje oluşturulunca
/// kapanır ve Project Detail Screen'e otomatik geçiş yapılır.
Future<void> showCreateProjectSheet(BuildContext context) {
  return AppBottomSheet.show<void>(
    context,
    child: CreateProjectSheet(
      onCreated: (project) {
        context.push(RoutePaths.projectDetail.replaceFirst(':projectId', project.projectId));
      },
    ),
  );
}

/// Yeni Proje Bottom Sheet — SCREENS.md §6.3 "Projects Screen (FAB) → Yeni
/// Proje Bottom Sheet (ad, renk/ikon, açıklama) → Oluştur → ... → Project
/// Detail Screen'e otomatik geçiş". [onCreated], sheet kapatıldıktan sonra
/// çağıran sayfanın Project Detail'e yönlendirmesi için oluşturulan projeyi
/// döndürür.
class CreateProjectSheet extends ConsumerStatefulWidget {
  const CreateProjectSheet({super.key, required this.onCreated});

  final ValueChanged<Project> onCreated;

  @override
  ConsumerState<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends ConsumerState<CreateProjectSheet> {
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
      _titleError = _titleController.text.trim().isEmpty ? 'Proje adı boş olamaz.' : null;
    });
    return _titleError == null;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createProjectControllerProvider);
    final controller = ref.read(createProjectControllerProvider.notifier);

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
                      case Ok(:final value):
                        Navigator.of(context).pop();
                        widget.onCreated(value);
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
