import '../entities/habit_record.dart';
import '../repositories/habit_repository.dart';

/// ROADMAP.md FAZ 12 — Statistics'in dönemsel agregasyonu (tamamlanan
/// alışkanlık sayısı) tarafından tüketilir.
class GetHabitRecordsInRangeUseCase {
  const GetHabitRecordsInRangeUseCase(this._repository);

  final HabitRepository _repository;

  Future<List<HabitRecord>> call(DateTime start, DateTime end) =>
      _repository.getRecordsInRange(start, end);
}
