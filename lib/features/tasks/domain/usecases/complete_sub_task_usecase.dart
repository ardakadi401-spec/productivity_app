import '../../../../core/errors/result.dart';
import '../repositories/task_repository.dart';

class CompleteSubTaskUseCase {
  const CompleteSubTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<Result<void>> call(String subtaskId, {required bool isCompleted}) =>
      _repository.setSubTaskCompleted(subtaskId, isCompleted: isCompleted);
}
