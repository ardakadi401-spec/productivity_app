import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type;
import 'package:isar_community/isar.dart';

part 'habit_local_model.g.dart';

/// `users/{userId}/habits/{habitId}` — DATABASE.md Bölüm 6.2 ve Bölüm 12.1
/// ("Isar, Firestore koleksiyonlarını 1:1 aynalar") gereği HEM yerel Isar
/// koleksiyonu HEM Firestore serileştirmesi tek bir modelde toplanır
/// (Task/Project/Goal ile birebir aynı desen).
@collection
class HabitLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String habitId;

  late String name;
  String? icon;
  late String color;

  @Enumerated(EnumType.name)
  late HabitTargetFrequencyLocal targetFrequency;
  List<int> targetDays = const [];

  /// `HH:mm` formatında.
  String? reminderTime;

  late int currentStreak;
  late int longestStreak;

  @Enumerated(EnumType.name)
  late HabitStatusLocal status;

  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isDeleted;
  DateTime? deletedAt;

  // --- Isar-only senkronizasyon meta alanları — DATABASE.md §12.2 ---
  @Enumerated(EnumType.name)
  late HabitSyncStatusLocal syncStatus;
  DateTime? lastSyncedAt;
  late DateTime localUpdatedAt;

  Map<String, dynamic> toFirestoreJson() {
    return {
      'habitId': habitId,
      'name': name,
      'icon': icon,
      'color': color,
      'targetFrequency': targetFrequency.name,
      'targetDays': targetDays,
      'reminderTime': reminderTime,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
    };
  }

  static HabitLocalModel fromFirestoreData(String habitId, Map<String, dynamic> data) {
    return HabitLocalModel()
      ..habitId = habitId
      ..name = data['name'] as String
      ..icon = data['icon'] as String?
      ..color = data['color'] as String
      ..targetFrequency = HabitTargetFrequencyLocal.values.byName(data['targetFrequency'] as String)
      ..targetDays = List<int>.from(data['targetDays'] as List? ?? const [])
      ..reminderTime = data['reminderTime'] as String?
      ..currentStreak = data['currentStreak'] as int? ?? 0
      ..longestStreak = data['longestStreak'] as int? ?? 0
      ..status = HabitStatusLocal.values.byName(data['status'] as String)
      ..createdAt = (data['createdAt'] as Timestamp).toDate()
      ..updatedAt = (data['updatedAt'] as Timestamp).toDate()
      ..isDeleted = data['isDeleted'] as bool? ?? false
      ..deletedAt = (data['deletedAt'] as Timestamp?)?.toDate()
      ..syncStatus = HabitSyncStatusLocal.synced
      ..lastSyncedAt = DateTime.now()
      ..localUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
  }
}

enum HabitTargetFrequencyLocal { daily, specificDays }

enum HabitStatusLocal { active, archived }

/// DATABASE.md §12.2 — kaydın senkronizasyon durumu. Diğer feature'ların
/// aynı isimli enum'larıyla şema olarak birebir aynıdır fakat
/// `IsarService`'in tüm modelleri birden import ettiği düşünüldüğünde isim
/// çakışmasını önlemek için ayrı adlandırılır.
enum HabitSyncStatusLocal { synced, pendingCreate, pendingUpdate, pendingDelete, error }
