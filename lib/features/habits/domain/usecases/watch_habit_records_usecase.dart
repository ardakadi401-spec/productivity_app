import '../entities/habit_record.dart';
import '../repositories/habit_repository.dart';

/// Habit Detail Screen'in geçmiş check-in listesi (SCREENS.md §4.16)
/// tarafından tüketilir.
class WatchHabitRecordsUseCase {
  const WatchHabitRecordsUseCase(this._repository);

  final HabitRepository _repository;

  Stream<List<HabitRecord>> call(String habitId) => _repository.watchHabitRecords(habitId);
}
