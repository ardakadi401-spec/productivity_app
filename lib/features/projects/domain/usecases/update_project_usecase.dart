import '../../../../core/errors/result.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class UpdateProjectUseCase {
  const UpdateProjectUseCase(this._repository);

  final ProjectRepository _repository;

  Future<Result<Project>> call(Project project) => _repository.updateProject(project);
}
