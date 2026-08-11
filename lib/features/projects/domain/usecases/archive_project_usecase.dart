import '../../../../core/errors/result.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// Projects Screen/Project Detail Screen'deki arşivleme eylemi
/// (ROADMAP.md FAZ 6 "Proje arşivleme akışı") — geri alınabilir (tekrar
/// çağrıldığında `isArchived: false` ile arşivden çıkarır).
class ArchiveProjectUseCase {
  const ArchiveProjectUseCase(this._repository);

  final ProjectRepository _repository;

  Future<Result<Project>> call(String projectId, {required bool isArchived}) =>
      _repository.setProjectArchived(projectId, isArchived: isArchived);
}
