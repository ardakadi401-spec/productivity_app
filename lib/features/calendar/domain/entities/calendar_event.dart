import '../../../goals/domain/entities/goal.dart';
import '../../../tasks/domain/entities/task.dart';

/// Calendar'ın kendi kavramı (ROADMAP.md FAZ 7 "Calendar'ın kendi
/// CalendarEvent kavramı") — Tasks ve Goals'ın (FAZ 8 ile tamamlandı, bkz.
/// ROADMAP FAZ 7 notu) farklı Domain entity'lerini tek, ekranın anlayacağı
/// ortak bir temsile indirger. `source`, Event Card'ın (COMPONENTS.md §8.3)
/// "kaynak göstergesi" ikonunu belirlemek için taşınır.
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.source,
    this.time,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final DateTime date;

  /// `HH:mm` formatında, opsiyonel.
  final String? time;
  final CalendarEventSource source;
  final bool isCompleted;

  /// Yalnızca `dueDate` dolu olan Task'lar takvimde temsil edilebilir —
  /// çağıran taraf (`GetTasksByDateUseCase`/`GetTasksByMonthUseCase`) bunu
  /// zaten filtreler.
  factory CalendarEvent.fromTask(Task task) {
    return CalendarEvent(
      id: task.taskId,
      title: task.title,
      date: task.dueDate!,
      time: task.dueTime,
      source: CalendarEventSource.task,
      isCompleted: task.isCompleted,
    );
  }

  /// SCREENS.md §4.13 "Goal Card (o gün bitiyorsa)" — hedefin dönem bitiş
  /// gününde temsili. Hedefin kendi saat bilgisi olmadığından `time` boş
  /// kalır (Event Card zaman etiketini `--:--` gösterir).
  factory CalendarEvent.fromGoal(Goal goal) {
    return CalendarEvent(
      id: goal.goalId,
      title: goal.title,
      date: goal.periodEndDate,
      source: CalendarEventSource.goal,
      isCompleted: goal.status == GoalStatus.achieved,
    );
  }
}

enum CalendarEventSource { task, goal }
