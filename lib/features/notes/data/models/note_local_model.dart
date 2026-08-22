import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type;
import 'package:isar_community/isar.dart';

part 'note_local_model.g.dart';

/// `users/{userId}/notes/{noteId}` — DATABASE.md Bölüm 8.2 ve Bölüm 12.1
/// gereği HEM yerel Isar koleksiyonu HEM Firestore serileştirmesi tek bir
/// modelde toplanır (Task/Project/Goal/Habit ile birebir aynı desen).
@collection
class NoteLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String noteId;

  late String title;
  String? content;
  String? color;

  @Index()
  String? projectId;

  @Index()
  String? taskId;

  List<String> tagIds = const [];
  late bool isPinned;

  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isDeleted;
  DateTime? deletedAt;

  // --- Isar-only senkronizasyon meta alanları — DATABASE.md §12.2 ---
  @Enumerated(EnumType.name)
  late NoteSyncStatusLocal syncStatus;
  DateTime? lastSyncedAt;
  late DateTime localUpdatedAt;

  Map<String, dynamic> toFirestoreJson() {
    return {
      'noteId': noteId,
      'title': title,
      'content': content,
      'color': color,
      'projectId': projectId,
      'taskId': taskId,
      'tagIds': tagIds,
      'isPinned': isPinned,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
    };
  }

  static NoteLocalModel fromFirestoreData(String noteId, Map<String, dynamic> data) {
    return NoteLocalModel()
      ..noteId = noteId
      ..title = data['title'] as String
      ..content = data['content'] as String?
      ..color = data['color'] as String?
      ..projectId = data['projectId'] as String?
      ..taskId = data['taskId'] as String?
      ..tagIds = List<String>.from(data['tagIds'] as List? ?? const [])
      ..isPinned = data['isPinned'] as bool? ?? false
      ..createdAt = (data['createdAt'] as Timestamp).toDate()
      ..updatedAt = (data['updatedAt'] as Timestamp).toDate()
      ..isDeleted = data['isDeleted'] as bool? ?? false
      ..deletedAt = (data['deletedAt'] as Timestamp?)?.toDate()
      ..syncStatus = NoteSyncStatusLocal.synced
      ..lastSyncedAt = DateTime.now()
      ..localUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
  }
}

/// DATABASE.md §12.2 — kaydın senkronizasyon durumu. Diğer feature'ların
/// aynı isimli enum'larıyla şema olarak birebir aynıdır fakat
/// `IsarService`'in tüm modelleri birden import ettiği düşünüldüğünde isim
/// çakışmasını önlemek için ayrı adlandırılır.
enum NoteSyncStatusLocal { synced, pendingCreate, pendingUpdate, pendingDelete, error }
