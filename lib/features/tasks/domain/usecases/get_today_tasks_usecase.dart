import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Dashboard'un "Bugünkü Görevler" bölümü tarafından tüketilir
/// (ARCHITECTURE.md §4.1 örneği: "Dashboard → GetTodayTasksUseCase").
class GetTodayTasksUseCase {
  const GetTodayTasksUseCase(this._repository);

  final TaskRepository _repository;

  Stream<List<Task>> call() => _repository.watchTodayTasks();
}
