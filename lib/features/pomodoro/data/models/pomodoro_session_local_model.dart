import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type;
import 'package:isar_community/isar.dart';

part 'pomodoro_session_local_model.g.dart';

/// `users/{userId}/pomodoroSessions/{sessionId}` — DATABASE.md Bölüm 9 ve
/// Bölüm 12.1 gereği HEM yerel Isar koleksiyonu HEM Firestore
/// serileştirmesi tek bir modelde toplanır (diğer feature'larla aynı
/// desen). Süreler saniye (int) olarak saklanır (DATABASE §9.2).
///
/// DATABASE.md §13.4 istisnası gereği soft delete YOKTUR (salt geçmiş-kaydı
/// niteliğinde, `HabitRecord` ile aynı ilke) — `isDeleted`/`deletedAt`
/// alanları bilinçli olarak bulunmaz, silme akışı yok.
@collection
class PomodoroSessionLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String sessionId;

  @Index()
  String? taskId;

  @Enumerated(EnumType.name)
  late PomodoroSessionTypeLocal type;

  late int plannedDurationSeconds;
  late int actualDurationSeconds;
  late DateTime startedAt;
  DateTime? completedAt;
  late bool isCompleted;

  // --- Isar-only senkronizasyon meta alanları — DATABASE.md §12.2 ---
  @Enumerated(EnumType.name)
  late PomodoroSyncStatusLocal syncStatus;
  DateTime? lastSyncedAt;
  late DateTime localUpdatedAt;

  Map<String, dynamic> toFirestoreJson() {
    return {
      'sessionId': sessionId,
      'taskId': taskId,
      'type': type == PomodoroSessionTypeLocal.work ? 'work' : 'break',
      'plannedDuration': plannedDurationSeconds,
      'actualDuration': actualDurationSeconds,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt == null ? null : Timestamp.fromDate(completedAt!),
      'isCompleted': isCompleted,
    };
  }

  static PomodoroSessionLocalModel fromFirestoreData(String sessionId, Map<String, dynamic> data) {
    return PomodoroSessionLocalModel()
      ..sessionId = sessionId
      ..taskId = data['taskId'] as String?
      ..type = (data['type'] as String? ?? 'work') == 'work'
          ? PomodoroSessionTypeLocal.work
          : PomodoroSessionTypeLocal.breakTime
      ..plannedDurationSeconds = data['plannedDuration'] as int? ?? 0
      ..actualDurationSeconds = data['actualDuration'] as int? ?? 0
      ..startedAt = (data['startedAt'] as Timestamp).toDate()
      ..completedAt = (data['completedAt'] as Timestamp?)?.toDate()
      ..isCompleted = data['isCompleted'] as bool? ?? false
      ..syncStatus = PomodoroSyncStatusLocal.synced
      ..lastSyncedAt = DateTime.now()
      ..localUpdatedAt = (data['startedAt'] as Timestamp).toDate();
  }
}

enum PomodoroSessionTypeLocal { work, breakTime }

/// DATABASE.md §12.2 — kaydın senkronizasyon durumu. Diğer feature'ların
/// aynı isimli enum'larıyla şema olarak birebir aynıdır fakat
/// `IsarService`'in tüm modelleri birden import ettiği düşünüldüğünde isim
/// çakışmasını önlemek için ayrı adlandırılır. `pendingDelete` yok — bu
/// koleksiyonda silme akışı yok.
enum PomodoroSyncStatusLocal { synced, pendingCreate, pendingUpdate, error }
