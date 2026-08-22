import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type;
import 'package:isar_community/isar.dart';

part 'tag_local_model.g.dart';

/// `users/{userId}/tags/{tagId}` — DATABASE.md §1.5 ve §12.1 gereği HEM
/// yerel Isar koleksiyonu HEM Firestore serileştirmesi tek bir modelde
/// toplanır (diğer feature'larla aynı desen). Bilinçli olarak minimal:
/// `isDeleted` yok — DATABASE.md §13.4'ün soft-delete listesi Tags'ı
/// kapsamaz ve bu fazda silme akışı yok (yalnızca oluşturma/listeleme).
@collection
class TagLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String tagId;

  late String name;
  late String color;

  late DateTime createdAt;
  late DateTime updatedAt;

  // --- Isar-only senkronizasyon meta alanları — DATABASE.md §12.2 ---
  @Enumerated(EnumType.name)
  late TagSyncStatusLocal syncStatus;
  DateTime? lastSyncedAt;
  late DateTime localUpdatedAt;

  Map<String, dynamic> toFirestoreJson() {
    return {
      'tagId': tagId,
      'name': name,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static TagLocalModel fromFirestoreData(String tagId, Map<String, dynamic> data) {
    return TagLocalModel()
      ..tagId = tagId
      ..name = data['name'] as String
      ..color = data['color'] as String
      ..createdAt = (data['createdAt'] as Timestamp).toDate()
      ..updatedAt = (data['updatedAt'] as Timestamp).toDate()
      ..syncStatus = TagSyncStatusLocal.synced
      ..lastSyncedAt = DateTime.now()
      ..localUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
  }
}

/// DATABASE.md §12.2 — kaydın senkronizasyon durumu. Diğer feature'ların
/// aynı isimli enum'larıyla şema olarak birebir aynıdır fakat
/// `IsarService`'in tüm modelleri birden import ettiği düşünüldüğünde isim
/// çakışmasını önlemek için ayrı adlandırılır.
enum TagSyncStatusLocal { synced, pendingCreate, error }
