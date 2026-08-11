import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/project.dart';
import '../providers/project_providers.dart';
import '../states/project_form_state.dart';

/// Yeni Proje Bottom Sheet (SCREENS.md §6.3) — Tasks'ın
/// `CreateTaskController`'ı ile aynı desen.
class CreateProjectController extends AutoDisposeNotifier<ProjectFormState> {
  @override
  ProjectFormState build() => const ProjectFormState();

  void setColor(String color) => state = state.copyWith(color: color);

  /// Başlık boş-doğrulaması Bottom Sheet içeriğinde yapılır; buraya yalnızca
  /// geçerli veri ulaşır (Create Task ile aynı kural).
  Future<Result<Project>> save({required String title, String? description}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final repository = ref.read(projectRepositoryProvider);
    final now = DateTime.now();
    final trimmedDescription = description?.trim();
    final project = Project(
      projectId: repository.newProjectId(),
      title: title.trim(),
      description: (trimmedDescription == null || trimmedDescription.isEmpty)
          ? null
          : trimmedDescription,
      color: state.color,
      status: ProjectStatus.active,
      taskCount: 0,
      completedTaskCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    final result = await ref.read(createProjectUseCaseProvider).call(project);
    switch (result) {
      case Ok():
        state = state.copyWith(isSaving: false);
      case Err(:final failure):
        state = state.copyWith(isSaving: false, error: failure);
    }
    return result;
  }
}

final createProjectControllerProvider =
    NotifierProvider.autoDispose<CreateProjectController, ProjectFormState>(
  CreateProjectController.new,
);
