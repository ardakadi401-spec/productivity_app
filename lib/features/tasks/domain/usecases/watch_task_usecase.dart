import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Task Detail Screen tarafından tüketilir.
class WatchTaskUseCase {
  const WatchTaskUseCase(this._repository);

  final TaskRepository _repository;

  Stream<Task?> call(String taskId) => _repository.watchTask(taskId);
}
