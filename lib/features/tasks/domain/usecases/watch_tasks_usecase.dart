import '../entities/task.dart';
import '../entities/task_filter.dart';
import '../repositories/task_repository.dart';

/// Tasks Screen listesi + Task Filters (SCREENS.md §4.9) tarafından
/// tüketilir.
class WatchTasksUseCase {
  const WatchTasksUseCase(this._repository);

  final TaskRepository _repository;

  Stream<List<Task>> call({TaskFilter filter = TaskFilter.none}) =>
      _repository.watchTasks(filter: filter);
}
