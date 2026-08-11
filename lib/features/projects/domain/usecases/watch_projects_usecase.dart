import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// Projects Screen listesi (SCREENS.md §4.7) tarafından tüketilir.
class WatchProjectsUseCase {
  const WatchProjectsUseCase(this._repository);

  final ProjectRepository _repository;

  Stream<List<Project>> call({ProjectStatus? status}) => _repository.watchProjects(status: status);
}
