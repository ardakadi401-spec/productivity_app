import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type;
import 'package:isar_community/isar.dart';

part 'statistics_snapshot_local_model.g.dart';

/// `users/{userId}/statisticsSnapshots/{snapshotId}` — DATABASE.md Bölüm 10
/// ve Bölüm 12.1 gereği HEM yerel Isar koleksiyonu HEM Firestore
/// serileştirmesi tek bir modelde toplanır (diğer feature'larla aynı
/// desen). DATABASE §10.1'in "immutable" tanımı gereği `isDeleted`/güncelleme
/// akışı YOKTUR — yalnızca oluşturma.
@collection
class StatisticsSnapshotLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String snapshotId;

  @Index()
  late DateTime date;

  late int tasksCompleted;
  late int tasksCreated;
  late int habitsCompletedCount;
  late int habitsTotalCount;
  late int pomodoroSessionsCompleted;
  late int pomodoroTotalMinutes;
  late DateTime createdAt;

  // --- Isar-only senkronizasyon meta alanları — DATABASE.md §12.2 ---
  @Enumerated(EnumType.name)
  late StatisticsSyncStatusLocal syncStatus;
  DateTime? lastSyncedAt;
  late DateTime localUpdatedAt;

  Map<String, dynamic> toFirestoreJson() {
    return {
      'snapshotId': snapshotId,
      'periodType': 'daily',
      'date': Timestamp.fromDate(date),
      'tasksCompleted': tasksCompleted,
      'tasksCreated': tasksCreated,
      'habitsCompletedCount': habitsCompletedCount,
      'habitsTotalCount': habitsTotalCount,
      'pomodoroSessionsCompleted': pomodoroSessionsCompleted,
      'pomodoroTotalMinutes': pomodoroTotalMinutes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static StatisticsSnapshotLocalModel fromFirestoreData(String snapshotId, Map<String, dynamic> data) {
    return StatisticsSnapshotLocalModel()
      ..snapshotId = snapshotId
      ..date = (data['date'] as Timestamp).toDate()
      ..tasksCompleted = data['tasksCompleted'] as int? ?? 0
      ..tasksCreated = data['tasksCreated'] as int? ?? 0
      ..habitsCompletedCount = data['habitsCompletedCount'] as int? ?? 0
      ..habitsTotalCount = data['habitsTotalCount'] as int? ?? 0
      ..pomodoroSessionsCompleted = data['pomodoroSessionsCompleted'] as int? ?? 0
      ..pomodoroTotalMinutes = data['pomodoroTotalMinutes'] as int? ?? 0
      ..createdAt = (data['createdAt'] as Timestamp).toDate()
      ..syncStatus = StatisticsSyncStatusLocal.synced
      ..lastSyncedAt = DateTime.now()
      ..localUpdatedAt = (data['createdAt'] as Timestamp).toDate();
  }
}

/// DATABASE.md §12.2 — kaydın senkronizasyon durumu. `pendingUpdate`/
/// `pendingDelete` yok — bu koleksiyonda güncelleme/silme akışı yok
/// (immutable, yalnızca oluşturma).
enum StatisticsSyncStatusLocal { synced, pendingCreate, error }
