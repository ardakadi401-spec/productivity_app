import '../../../../core/errors/result.dart';
import '../repositories/task_repository.dart';

class DeleteSubTaskUseCase {
  const DeleteSubTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Result<void>> call(String subtaskId) => _repository.deleteSubTask(subtaskId);
}
