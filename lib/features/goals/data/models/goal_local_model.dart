import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type;
import 'package:isar_community/isar.dart';

part 'goal_local_model.g.dart';

/// `users/{userId}/goals/{goalId}` — DATABASE.md Bölüm 7 ve Bölüm 12.1
/// ("Isar, Firestore koleksiyonlarını 1:1 aynalar") gereği HEM yerel Isar
/// koleksiyonu HEM Firestore serileştirmesi tek bir modelde toplanır
/// (TaskLocalModel/ProjectLocalModel ile birebir aynı desen).
@collection
class GoalLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String goalId;

  late String title;
  String? description;

  @Enumerated(EnumType.name)
  late GoalPeriodTypeLocal periodType;
  late DateTime periodStartDate;
  late DateTime periodEndDate;

  List<String> linkedTaskIds = const [];

  @Enumerated(EnumType.name)
  late GoalProgressTypeLocal progressType;
  int? manualProgress;

  @Enumerated(EnumType.name)
  late GoalStatusLocal status;

  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isDeleted;
  DateTime? deletedAt;

  // --- Isar-only senkronizasyon meta alanları — DATABASE.md §12.2 ---
  @Enumerated(EnumType.name)
  late GoalSyncStatusLocal syncStatus;
  DateTime? lastSyncedAt;
  late DateTime localUpdatedAt;

  Map<String, dynamic> toFirestoreJson() {
    return {
      'goalId': goalId,
      'title': title,
      'description': description,
      'periodType': periodType.name,
      'periodStartDate': Timestamp.fromDate(periodStartDate),
      'periodEndDate': Timestamp.fromDate(periodEndDate),
      'linkedTaskIds': linkedTaskIds,
      'progressType': progressType.name,
      'manualProgress': manualProgress,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
    };
  }

  static GoalLocalModel fromFirestoreData(String goalId, Map<String, dynamic> data) {
    return GoalLocalModel()
      ..goalId = goalId
      ..title = data['title'] as String
      ..description = data['description'] as String?
      ..periodType = GoalPeriodTypeLocal.values.byName(data['periodType'] as String)
      ..periodStartDate = (data['periodStartDate'] as Timestamp).toDate()
      ..periodEndDate = (data['periodEndDate'] as Timestamp).toDate()
      ..linkedTaskIds = List<String>.from(data['linkedTaskIds'] as List? ?? const [])
      ..progressType = GoalProgressTypeLocal.values.byName(data['progressType'] as String)
      ..manualProgress = data['manualProgress'] as int?
      ..status = GoalStatusLocal.values.byName(data['status'] as String)
      ..createdAt = (data['createdAt'] as Timestamp).toDate()
      ..updatedAt = (data['updatedAt'] as Timestamp).toDate()
      ..isDeleted = data['isDeleted'] as bool? ?? false
      ..deletedAt = (data['deletedAt'] as Timestamp?)?.toDate()
      ..syncStatus = GoalSyncStatusLocal.synced
      ..lastSyncedAt = DateTime.now()
      ..localUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
  }
}

enum GoalPeriodTypeLocal { daily, weekly, monthly }

enum GoalProgressTypeLocal { manual, linkedTasks }

enum GoalStatusLocal { inProgress, achieved, missed }

/// DATABASE.md §12.2 — kaydın senkronizasyon durumu. `TaskLocalModel`/
/// `ProjectLocalModel`'daki aynı isimli enum ile şema olarak birebir
/// aynıdır fakat `IsarService`'in tüm modelleri birden import ettiği
/// düşünüldüğünde isim çakışmasını önlemek için ayrı adlandırılır.
enum GoalSyncStatusLocal { synced, pendingCreate, pendingUpdate, pendingDelete, error }
