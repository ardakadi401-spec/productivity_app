import 'task.dart';

/// Tasks Screen filtre/sıralama chip grubu — SCREENS.md §4.9, ROADMAP.md
/// FAZ 5/6 "Task Filters (öncelik, tarih, proje)". `projectId` FAZ 6 ile
/// aktive edildi (proje bazlı filtreleme).
class TaskFilter {
  const TaskFilter({
    this.priority,
    this.dueOnDate,
    this.projectId,
    this.includeCompleted = true,
  });

  final TaskPriority? priority;

  /// Yalnızca bu takvim gününe (saat bilgisi yok sayılır) `dueDate`'i denk
  /// gelen görevler.
  final DateTime? dueOnDate;
  final String? projectId;
  final bool includeCompleted;

  static const none = TaskFilter();
}
