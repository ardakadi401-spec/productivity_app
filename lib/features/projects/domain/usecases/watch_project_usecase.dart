import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// Project Detail Screen (SCREENS.md §4.8) tarafından tüketilir; Tasks
/// feature'ının (opsiyonel bağlama) linkli görevin proje bilgisini göstermek
/// için de kullanır — ARCHITECTURE.md §4 bağımlılık tablosu "Tasks →
/// Projects (opsiyonel)".
class WatchProjectUseCase {
  const WatchProjectUseCase(this._repository);

  final ProjectRepository _repository;

  Stream<Project?> call(String projectId) => _repository.watchProject(projectId);
}
