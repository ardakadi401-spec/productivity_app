import '../../../../core/errors/result.dart';
import '../repositories/project_repository.dart';

/// Project Detail Screen'deki kalıcı silme eylemi — Task/Note/Habit'te
/// zaten var olan "sil + geri alınamaz onayı" desenine Projects'i de
/// katar. `ArchiveProjectUseCase`'in yerini almaz, onu tamamlar (bkz.
/// `ProjectRepositoryImpl` doc notu).
class DeleteProjectUseCase {
  const DeleteProjectUseCase(this._repository);

  final ProjectRepository _repository;

  Future<Result<void>> call(String projectId) => _repository.deleteProject(projectId);
}
