import '../../../tasks/domain/entities/task_filter.dart';
import '../../../tasks/domain/usecases/watch_tasks_usecase.dart';
import '../entities/calendar_event.dart';

/// Calendar Screen'in günlük ajanda bölümü (SCREENS.md §4.13) — Tasks'ın
/// dışa açık `WatchTasksUseCase`'i üzerinden, doğrudan Data erişimi olmadan
/// (ARCHITECTURE.md §4.1 "Dashboard → GetTodayTasksUseCase" örneğiyle aynı
/// desen). Calendar'ın kendi Data/Repository katmanı yoktur.
class GetTasksByDateUseCase {
  const GetTasksByDateUseCase(this._watchTasksUseCase);

  final WatchTasksUseCase _watchTasksUseCase;

  Stream<List<CalendarEvent>> call(DateTime date) {
    return _watchTasksUseCase(filter: TaskFilter(dueOnDate: date)).map(
      (tasks) => tasks.map(CalendarEvent.fromTask).toList(),
    );
  }
}
