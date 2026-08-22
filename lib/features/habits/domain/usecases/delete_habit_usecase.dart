import '../../../../core/errors/result.dart';
import '../repositories/habit_repository.dart';

class DeleteHabitUseCase {
  const DeleteHabitUseCase(this._repository);

  final HabitRepository _repository;

  Future<Result<void>> call(String habitId) => _repository.deleteHabit(habitId);
}
