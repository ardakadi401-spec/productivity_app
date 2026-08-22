import '../../../../core/errors/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class CreateHabitUseCase {
  const CreateHabitUseCase(this._repository);

  final HabitRepository _repository;

  Future<Result<Habit>> call(Habit habit) => _repository.createHabit(habit);
}
