import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type;
import 'package:isar_community/isar.dart';

part 'habit_record_local_model.g.dart';

/// `users/{userId}/habits/{habitId}/habitRecords/{recordId}` — DATABASE.md
/// Bölüm 6.3. `recordId` (`yyyy-MM-dd`) yalnızca kendi üst alışkanlığı
/// içinde benzersizdir (Firestore alt koleksiyonu), Isar'ın düz koleksiyon
/// yapısında global benzersizlik için [compositeKey] (`habitId::recordId`)
/// kullanılır — `TaskLocalModel.taskId` ile aynı `@Index(unique: true,
/// replace: true)` deseni, yalnızca anahtar composite.
///
/// DATABASE.md §13.4 istisnası gereği soft delete YOKTUR (salt geçmiş-kaydı
/// niteliğinde) — `isDeleted`/`deletedAt` alanları bilinçli olarak
/// bulunmaz; bir check-in geri alındığında kayıt kalıcı olarak silinir.
@collection
class HabitRecordLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String compositeKey;

  @Index()
  late String habitId;

  /// `yyyy-MM-dd`.
  late String recordId;

  /// Saat bileşeni sıfırlanmış gün.
  late DateTime date;
  late bool isCompleted;
  DateTime? completedAt;

  // --- Isar-only senkronizasyon meta alanları — DATABASE.md §12.2 ---
  @Enumerated(EnumType.name)
  late HabitRecordSyncStatusLocal syncStatus;
  DateTime? lastSyncedAt;
  late DateTime localUpdatedAt;

  static String buildCompositeKey(String habitId, String recordId) => '$habitId::$recordId';

  Map<String, dynamic> toFirestoreJson() {
    return {
      'recordId': recordId,
      'date': Timestamp.fromDate(date),
      'isCompleted': isCompleted,
      'completedAt': completedAt == null ? null : Timestamp.fromDate(completedAt!),
    };
  }

  static HabitRecordLocalModel fromFirestoreData(
    String habitId,
    String recordId,
    Map<String, dynamic> data,
  ) {
    return HabitRecordLocalModel()
      ..compositeKey = buildCompositeKey(habitId, recordId)
      ..habitId = habitId
      ..recordId = recordId
      ..date = (data['date'] as Timestamp).toDate()
      ..isCompleted = data['isCompleted'] as bool? ?? false
      ..completedAt = (data['completedAt'] as Timestamp?)?.toDate()
      ..syncStatus = HabitRecordSyncStatusLocal.synced
      ..lastSyncedAt = DateTime.now()
      ..localUpdatedAt = (data['date'] as Timestamp).toDate();
  }
}

/// DATABASE.md §12.2 — kaydın senkronizasyon durumu (`pendingDelete` burada
/// "sil" anlamına gelir; `HabitRecord`'da soft delete olmadığından bu durum
/// yalnızca offline'ken silinip henüz Firestore'a iletilmemiş kayıtları
/// işaretlemek için anlıktır, kalıcı bir alan değeri değildir).
enum HabitRecordSyncStatusLocal { synced, pendingCreate, pendingDelete, error }
