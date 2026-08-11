import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';
import '../states/project_form_state.dart';

/// Proje düzenleme formu — Create ile birebir aynı alan seti, mevcut
/// değerlerle önceden doldurulmuş (Tasks'ın `EditTaskController`'ı ile aynı
/// desen). `family` anahtarı olarak düzenlenecek projenin son okunan anlık
/// görüntüsü ([Project]) alınır.
class EditProjectController extends AutoDisposeFamilyNotifier<ProjectFormState, Project> {
  @override
  ProjectFormState build(Project arg) => ProjectFormState.fromProject(arg);

  void setColor(String color) => state = state.copyWith(color: color);

  Future<Result<Project>> save({required String title, String? description}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final trimmedDescription = description?.trim();
    final updated = arg.copyWith(
      title: title.trim(),
      description: trimmedDescription,
      clearDescription: trimmedDescription == null || trimmedDescription.isEmpty,
      color: state.color,
      updatedAt: DateTime.now(),
    );

    final result = await ref.read(updateProjectUseCaseProvider).call(updated);
    switch (result) {
      case Ok():
        state = state.copyWith(isSaving: false);
      case Err(:final failure):
        state = state.copyWith(isSaving: false, error: failure);
    }
    return result;
  }
}

final editProjectControllerProvider =
    NotifierProvider.autoDispose.family<EditProjectController, ProjectFormState, Project>(
  EditProjectController.new,
);
