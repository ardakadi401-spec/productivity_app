import '../../domain/entities/task.dart';
import '../models/task_local_model.dart';

class TaskMapper {
  TaskMapper._();

  static Task toEntity(TaskLocalModel model) {
    return Task(
      taskId: model.taskId,
      title: model.title,
      description: model.description,
      priority: _priorityToEntity(model.priority),
      status: _statusToEntity(model.status),
      dueDate: model.dueDate,
      dueTime: model.dueTime,
      projectId: model.projectId,
      categoryId: model.categoryId,
      tagIds: model.tagIds,
      recurrenceRule: model.recurrenceRule == null
          ? null
          : RecurrenceRule(
              frequency: _frequencyToEntity(model.recurrenceRule!.frequency),
              interval: model.recurrenceRule!.interval,
              daysOfWeek: model.recurrenceRule!.daysOfWeek,
              endDate: model.recurrenceRule!.endDate,
            ),
      subtaskCount: model.subtaskCount,
      completedSubtaskCount: model.completedSubtaskCount,
      completedAt: model.completedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Yeni bir [TaskLocalModel] oluşturur — `Isar.autoIncrement` `id` hariç
  /// tüm alanlar entity'den ve senkronizasyon meta bilgisinden doldurulur.
  static TaskLocalModel fromEntity(
    Task task, {
    required SyncStatusLocal syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return TaskLocalModel()
      ..taskId = task.taskId
      ..title = task.title
      ..description = task.description
      ..priority = _priorityToLocal(task.priority)
      ..status = _statusToLocal(task.status)
      ..dueDate = task.dueDate
      ..dueTime = task.dueTime
      ..projectId = task.projectId
      ..categoryId = task.categoryId
      ..tagIds = task.tagIds
      ..recurrenceRule = task.recurrenceRule == null
          ? null
          : (RecurrenceRuleEmbedded()
            ..frequency = _frequencyToLocal(task.recurrenceRule!.frequency)
            ..interval = task.recurrenceRule!.interval
            ..daysOfWeek = task.recurrenceRule!.daysOfWeek
            ..endDate = task.recurrenceRule!.endDate)
      ..subtaskCount = task.subtaskCount
      ..completedSubtaskCount = task.completedSubtaskCount
      ..completedAt = task.completedAt
      ..createdAt = task.createdAt
      ..updatedAt = task.updatedAt
      ..isDeleted = false
      ..syncStatus = syncStatus
      ..lastSyncedAt = lastSyncedAt
      ..localUpdatedAt = task.updatedAt;
  }

  static TaskPriority _priorityToEntity(TaskPriorityLocal p) => switch (p) {
        TaskPriorityLocal.low => TaskPriority.low,
        TaskPriorityLocal.medium => TaskPriority.medium,
        TaskPriorityLocal.high => TaskPriority.high,
      };

  static TaskPriorityLocal _priorityToLocal(TaskPriority p) => switch (p) {
        TaskPriority.low => TaskPriorityLocal.low,
        TaskPriority.medium => TaskPriorityLocal.medium,
        TaskPriority.high => TaskPriorityLocal.high,
      };

  static TaskStatus _statusToEntity(TaskStatusLocal s) => switch (s) {
        TaskStatusLocal.pending => TaskStatus.pending,
        TaskStatusLocal.completed => TaskStatus.completed,
      };

  static TaskStatusLocal _statusToLocal(TaskStatus s) => switch (s) {
        TaskStatus.pending => TaskStatusLocal.pending,
        TaskStatus.completed => TaskStatusLocal.completed,
      };

  static RecurrenceFrequency _frequencyToEntity(RecurrenceFrequencyLocal? f) => switch (f) {
        RecurrenceFrequencyLocal.weekly => RecurrenceFrequency.weekly,
        RecurrenceFrequencyLocal.monthly => RecurrenceFrequency.monthly,
        RecurrenceFrequencyLocal.daily || null => RecurrenceFrequency.daily,
      };

  static RecurrenceFrequencyLocal _frequencyToLocal(RecurrenceFrequency f) => switch (f) {
        RecurrenceFrequency.daily => RecurrenceFrequencyLocal.daily,
        RecurrenceFrequency.weekly => RecurrenceFrequencyLocal.weekly,
        RecurrenceFrequency.monthly => RecurrenceFrequencyLocal.monthly,
      };
}
