import '../../domain/entities/sub_task.dart';
import '../models/sub_task_local_model.dart';
import '../models/task_local_model.dart' show SyncStatusLocal;

class SubTaskMapper {
  SubTaskMapper._();

  static SubTask toEntity(SubTaskLocalModel model) {
    return SubTask(
      subtaskId: model.subtaskId,
      taskId: model.taskId,
      title: model.title,
      isCompleted: model.isCompleted,
      order: model.order,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static SubTaskLocalModel fromEntity(
    SubTask subTask, {
    required SyncStatusLocal syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return SubTaskLocalModel()
      ..subtaskId = subTask.subtaskId
      ..taskId = subTask.taskId
      ..title = subTask.title
      ..isCompleted = subTask.isCompleted
      ..order = subTask.order
      ..createdAt = subTask.createdAt
      ..updatedAt = subTask.updatedAt
      ..syncStatus = syncStatus
      ..lastSyncedAt = lastSyncedAt
      ..localUpdatedAt = subTask.updatedAt;
  }
}
