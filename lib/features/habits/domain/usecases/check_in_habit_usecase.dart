import '../../../../core/errors/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Habits Screen / Habit Detail Screen'deki Completion Button eylemi
/// (COMPONENTS.md §9.3, PRD "2–3 dokunuş kuralı" — tek dokunuşla check-in).
class CheckInHabitUseCase {
  const CheckInHabitUseCase(this._repository);

  final HabitRepository _repository;

  Future<Result<Habit>> call(String habitId, DateTime date, {required bool isCompleted}) =>
      _repository.setCheckIn(habitId, date, isCompleted: isCompleted);
}
