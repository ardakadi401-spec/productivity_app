import '../../../../core/errors/result.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class CreateTaskUseCase {
  const CreateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Result<Task>> call(Task task) => _repository.createTask(task);
}
