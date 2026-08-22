import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class WatchHabitUseCase {
  const WatchHabitUseCase(this._repository);

  final HabitRepository _repository;

  Stream<Habit?> call(String habitId) => _repository.watchHabit(habitId);
}
