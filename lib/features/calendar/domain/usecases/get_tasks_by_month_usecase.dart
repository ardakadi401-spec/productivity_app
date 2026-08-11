import '../../../tasks/domain/entities/task_filter.dart';
import '../../../tasks/domain/usecases/watch_tasks_usecase.dart';
import '../entities/calendar_event.dart';

/// Calendar Screen'in aylık grid bölümü (SCREENS.md §4.13, COMPONENTS.md
/// §8.2 "Etkinlik İçeren" Day Cell durumu) — hangi günlerde görev olduğunu
/// işaretlemek için kullanılır.
///
/// ROADMAP.md FAZ 7 riski "aylık görünümde çok sayıda görev olan günlerde
/// performans sorunu" için önerilen mitigasyon (yalnızca görünen ay
/// aralığının sorgulanması) burada ay bazlı client-side filtrelemeyle
/// karşılanır — kişisel kullanım ölçeğinde (`ARCHITECTURE.md` §12.4),
/// Isar zaten tüm `isDeleted=false` görevleri bellekte tuttuğundan
/// (`TaskRepositoryImpl.watchTasks`), burada ek bir sorgu maliyeti yoktur;
/// yalnızca Calendar'ın kendi tarafında ay filtresi uygulanır.
class GetTasksByMonthUseCase {
  const GetTasksByMonthUseCase(this._watchTasksUseCase);

  final WatchTasksUseCase _watchTasksUseCase;

  Stream<List<CalendarEvent>> call(DateTime month) {
    return _watchTasksUseCase(filter: TaskFilter.none).map(
      (tasks) => tasks
          .where(
            (t) => t.dueDate != null && t.dueDate!.year == month.year && t.dueDate!.month == month.month,
          )
          .map(CalendarEvent.fromTask)
          .toList(),
    );
  }
}
