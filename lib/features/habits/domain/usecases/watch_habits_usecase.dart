import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

/// Habits Screen listesi (SCREENS.md §4.15) ve Dashboard'un "Alışkanlıklar"
/// bölümü (ARCHITECTURE.md §4.1 örneğiyle aynı desen) tarafından tüketilir.
class WatchHabitsUseCase {
  const WatchHabitsUseCase(this._repository);

  final HabitRepository _repository;

  Stream<List<Habit>> call() => _repository.watchHabits();
}
