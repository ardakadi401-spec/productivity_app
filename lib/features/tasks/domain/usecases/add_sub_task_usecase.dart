import '../../../../core/errors/result.dart';
import '../entities/sub_task.dart';
import '../repositories/task_repository.dart';

class AddSubTaskUseCase {
  const AddSubTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Result<SubTask>> call(SubTask subTask) => _repository.addSubTask(subTask);
}
