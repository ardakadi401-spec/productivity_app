import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type;
import 'package:isar_community/isar.dart';

import 'task_local_model.dart' show SyncStatusLocal;

part 'sub_task_local_model.g.dart';

/// `users/{userId}/tasks/{taskId}/subtasks/{subtaskId}` — DATABASE.md §5.
/// Ayrı Isar koleksiyonu (embedded array DEĞİL — §5.2), indekslenmiş
/// `taskId` alanıyla filtrelenir.
@collection
class SubTaskLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String subtaskId;

  @Index()
  late String taskId;

  late String title;
  late bool isCompleted;
  late int order;
  late DateTime createdAt;
  late DateTime updatedAt;

  /// DATABASE.md §13.1 — SubTasks, soft delete gerektiren koleksiyonlar
  /// listesindedir (Projects/Tasks/SubTasks/Habits/Goals/Notes ile aynı).
  late bool isDeleted;
  DateTime? deletedAt;

  @Enumerated(EnumType.name)
  late SyncStatusLocal syncStatus;
  DateTime? lastSyncedAt;
  late DateTime localUpdatedAt;

  Map<String, dynamic> toFirestoreJson() {
    return {
      'subtaskId': subtaskId,
      'title': title,
      'isCompleted': isCompleted,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
    };
  }

  static SubTaskLocalModel fromFirestoreData(
    String taskId,
    String subtaskId,
    Map<String, dynamic> data,
  ) {
    return SubTaskLocalModel()
      ..subtaskId = subtaskId
      ..taskId = taskId
      ..title = data['title'] as String
      ..isCompleted = data['isCompleted'] as bool? ?? false
      ..order = data['order'] as int? ?? 0
      ..createdAt = (data['createdAt'] as Timestamp).toDate()
      ..updatedAt = (data['updatedAt'] as Timestamp).toDate()
      ..isDeleted = data['isDeleted'] as bool? ?? false
      ..deletedAt = (data['deletedAt'] as Timestamp?)?.toDate()
      ..syncStatus = SyncStatusLocal.synced
      ..lastSyncedAt = DateTime.now()
      ..localUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
  }
}
