import '../../../../core/errors/result.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class CompleteTaskUseCase {
  const CompleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Result<Task>> call(String taskId, {required bool isCompleted}) =>
      _repository.setTaskCompleted(taskId, isCompleted: isCompleted);
}
