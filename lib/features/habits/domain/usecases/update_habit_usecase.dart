import '../../../../core/errors/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class UpdateHabitUseCase {
  const UpdateHabitUseCase(this._repository);

  final HabitRepository _repository;

  Future<Result<Habit>> call(Habit habit) => _repository.updateHabit(habit);
}
