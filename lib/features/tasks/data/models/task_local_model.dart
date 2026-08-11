import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type;
import 'package:isar_community/isar.dart';

part 'task_local_model.g.dart';

/// `users/{userId}/tasks/{taskId}` — DATABASE.md Bölüm 4 ve Bölüm 12.1
/// ("Isar, Firestore koleksiyonlarını 1:1 aynalar") gereği HEM yerel Isar
/// koleksiyonu HEM Firestore serileştirmesi tek bir modelde toplanır (ayrı
/// bir "remote model" gereksiz çoğaltma olurdu — alanlar zaten birebir
/// aynı). `id` Isar'ın kendi otomatik artan birincil anahtarıdır; `taskId`
/// Firestore doküman ID'sidir ve benzersiz indekslenir.
@collection
class TaskLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String taskId;

  late String title;
  String? description;

  @Enumerated(EnumType.name)
  late TaskPriorityLocal priority;

  @Enumerated(EnumType.name)
  late TaskStatusLocal status;

  DateTime? dueDate;

  /// `HH:mm` formatında.
  String? dueTime;

  /// İlişkili proje referansı (opsiyonel) — DATABASE.md §4.2.
  String? projectId;
  String? categoryId;
  List<String> tagIds = const [];

  RecurrenceRuleEmbedded? recurrenceRule;

  late int subtaskCount;
  late int completedSubtaskCount;
  DateTime? completedAt;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isDeleted;
  DateTime? deletedAt;

  // --- Isar-only senkronizasyon meta alanları — DATABASE.md §12.2 ---
  @Enumerated(EnumType.name)
  late SyncStatusLocal syncStatus;
  DateTime? lastSyncedAt;
  late DateTime localUpdatedAt;

  Map<String, dynamic> toFirestoreJson() {
    return {
      'taskId': taskId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'dueTime': dueTime,
      'projectId': projectId,
      'categoryId': categoryId,
      'tagIds': tagIds,
      'recurrenceRule': recurrenceRule?.toFirestoreJson(),
      'subtaskCount': subtaskCount,
      'completedSubtaskCount': completedSubtaskCount,
      'completedAt': completedAt == null ? null : Timestamp.fromDate(completedAt!),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
    };
  }

  static TaskLocalModel fromFirestoreData(String taskId, Map<String, dynamic> data) {
    final recurrenceMap = data['recurrenceRule'] as Map<String, dynamic>?;
    return TaskLocalModel()
      ..taskId = taskId
      ..title = data['title'] as String
      ..description = data['description'] as String?
      ..priority = TaskPriorityLocal.values.byName(data['priority'] as String)
      ..status = TaskStatusLocal.values.byName(data['status'] as String)
      ..dueDate = (data['dueDate'] as Timestamp?)?.toDate()
      ..dueTime = data['dueTime'] as String?
      ..projectId = data['projectId'] as String?
      ..categoryId = data['categoryId'] as String?
      ..tagIds = List<String>.from(data['tagIds'] as List? ?? const [])
      ..recurrenceRule =
          recurrenceMap == null ? null : RecurrenceRuleEmbedded.fromFirestoreJson(recurrenceMap)
      ..subtaskCount = data['subtaskCount'] as int? ?? 0
      ..completedSubtaskCount = data['completedSubtaskCount'] as int? ?? 0
      ..completedAt = (data['completedAt'] as Timestamp?)?.toDate()
      ..createdAt = (data['createdAt'] as Timestamp).toDate()
      ..updatedAt = (data['updatedAt'] as Timestamp).toDate()
      ..isDeleted = data['isDeleted'] as bool? ?? false
      ..deletedAt = (data['deletedAt'] as Timestamp?)?.toDate()
      ..syncStatus = SyncStatusLocal.synced
      ..lastSyncedAt = DateTime.now()
      ..localUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
  }
}

enum TaskPriorityLocal { low, medium, high }

enum TaskStatusLocal { pending, completed }

/// DATABASE.md §12.2 — kaydın senkronizasyon durumu.
enum SyncStatusLocal { synced, pendingCreate, pendingUpdate, pendingDelete, error }

/// DATABASE.md §4.3 — yalnızca veri modeli seviyesinde (UI zorunlu değil).
@embedded
class RecurrenceRuleEmbedded {
  @Enumerated(EnumType.name)
  RecurrenceFrequencyLocal? frequency;
  int interval = 1;
  List<int>? daysOfWeek;
  DateTime? endDate;

  Map<String, dynamic> toFirestoreJson() {
    return {
      'frequency': frequency?.name,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
    };
  }

  static RecurrenceRuleEmbedded fromFirestoreJson(Map<String, dynamic> data) {
    return RecurrenceRuleEmbedded()
      ..frequency = data['frequency'] == null
          ? null
          : RecurrenceFrequencyLocal.values.byName(data['frequency'] as String)
      ..interval = data['interval'] as int? ?? 1
      ..daysOfWeek =
          data['daysOfWeek'] == null ? null : List<int>.from(data['daysOfWeek'] as List)
      ..endDate = (data['endDate'] as Timestamp?)?.toDate();
  }
}

enum RecurrenceFrequencyLocal { daily, weekly, monthly }
