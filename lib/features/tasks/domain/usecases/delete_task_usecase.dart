import '../../../../core/errors/result.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Result<void>> call(String taskId) => _repository.deleteTask(taskId);
}
