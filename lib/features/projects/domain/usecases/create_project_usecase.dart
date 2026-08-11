import '../../../../core/errors/result.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class CreateProjectUseCase {
  const CreateProjectUseCase(this._repository);

  final ProjectRepository _repository;

  Future<Result<Project>> call(Project project) => _repository.createProject(project);
}
