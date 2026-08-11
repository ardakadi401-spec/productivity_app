import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type;
import 'package:isar_community/isar.dart';

part 'project_local_model.g.dart';

/// `users/{userId}/projects/{projectId}` — DATABASE.md Bölüm 3 ve Bölüm 12.1
/// ("Isar, Firestore koleksiyonlarını 1:1 aynalar") gereği HEM yerel Isar
/// koleksiyonu HEM Firestore serileştirmesi tek bir modelde toplanır
/// (TaskLocalModel ile birebir aynı desen). `id` Isar'ın kendi otomatik
/// artan birincil anahtarıdır; `projectId` Firestore doküman ID'sidir.
@collection
class ProjectLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String projectId;

  late String title;
  String? description;

  /// Hex kod (örn. `#FF8A8A`).
  late String color;
  String? icon;

  @Enumerated(EnumType.name)
  late ProjectStatusLocal status;

  late int taskCount;
  late int completedTaskCount;
  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isDeleted;
  DateTime? deletedAt;

  // --- Isar-only senkronizasyon meta alanları — DATABASE.md §12.2 ---
  @Enumerated(EnumType.name)
  late ProjectSyncStatusLocal syncStatus;
  DateTime? lastSyncedAt;
  late DateTime localUpdatedAt;

  Map<String, dynamic> toFirestoreJson() {
    return {
      'projectId': projectId,
      'title': title,
      'description': description,
      'color': color,
      'icon': icon,
      'status': status.name,
      'taskCount': taskCount,
      'completedTaskCount': completedTaskCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
    };
  }

  static ProjectLocalModel fromFirestoreData(String projectId, Map<String, dynamic> data) {
    return ProjectLocalModel()
      ..projectId = projectId
      ..title = data['title'] as String
      ..description = data['description'] as String?
      ..color = data['color'] as String
      ..icon = data['icon'] as String?
      ..status = ProjectStatusLocal.values.byName(data['status'] as String)
      ..taskCount = data['taskCount'] as int? ?? 0
      ..completedTaskCount = data['completedTaskCount'] as int? ?? 0
      ..createdAt = (data['createdAt'] as Timestamp).toDate()
      ..updatedAt = (data['updatedAt'] as Timestamp).toDate()
      ..isDeleted = data['isDeleted'] as bool? ?? false
      ..deletedAt = (data['deletedAt'] as Timestamp?)?.toDate()
      ..syncStatus = ProjectSyncStatusLocal.synced
      ..lastSyncedAt = DateTime.now()
      ..localUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
  }
}

enum ProjectStatusLocal { active, archived }

/// DATABASE.md §12.2 — kaydın senkronizasyon durumu. `TaskLocalModel`'daki
/// `SyncStatusLocal` ile şema olarak birebir aynıdır fakat Isar
/// koleksiyonları arasında tip paylaşımı yapılamadığından (her koleksiyon
/// kendi şemasını taşır) ve `IsarService`'in her iki modeli birden import
/// ettiği düşünüldüğünde isim çakışmasını önlemek için ayrı adlandırılır.
enum ProjectSyncStatusLocal { synced, pendingCreate, pendingUpdate, pendingDelete, error }
