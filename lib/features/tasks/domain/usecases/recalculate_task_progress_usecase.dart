import '../../../../core/errors/result.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// STATE_MANAGEMENT.md §5.3 — bir alt görev tamamlandığında/eklendiğinde,
/// üst görevin ilerleme sayaçlarını yeniden hesaplamak için
/// `CompleteSubTaskUseCase`'in ardından sırayla çağrılır.
class RecalculateTaskProgressUseCase {
  const RecalculateTaskProgressUseCase(this._repository);

  final TaskRepository _repository;

  Future<Result<Task>> call(String taskId) => _repository.recalculateTaskProgress(taskId);
}
