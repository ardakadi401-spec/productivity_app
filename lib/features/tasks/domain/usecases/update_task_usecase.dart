import '../../../../core/errors/result.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase {
  const UpdateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Result<Task>> call(Task task) => _repository.updateTask(task);
}
