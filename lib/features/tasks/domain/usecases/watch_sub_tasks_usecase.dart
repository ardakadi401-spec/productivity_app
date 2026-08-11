import '../entities/sub_task.dart';
import '../repositories/task_repository.dart';

/// Task Detail Screen'in alt görev listesi tarafından tüketilir.
class WatchSubTasksUseCase {
  const WatchSubTasksUseCase(this._repository);

  final TaskRepository _repository;

  Stream<List<SubTask>> call(String taskId) => _repository.watchSubTasks(taskId);
}
