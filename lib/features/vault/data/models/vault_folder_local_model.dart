import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type;
import 'package:isar_community/isar.dart';

part 'vault_folder_local_model.g.dart';

/// `users/{userId}/vaultFolders/{folderId}` — VaultItemLocalModel ile aynı
/// desen. Klasör adı ŞİFRELENMEZ (yalnızca `password`/`notes` gibi asıl
/// gizli içerik şifrelenir — bkz. `VaultEncryptionService` doc yorumu);
/// `title`/not başlığı gibi diğer feature'lardaki metadata alanlarıyla aynı
/// muameleyi görür.
@collection
class VaultFolderLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String folderId;

  late String name;

  /// `null` → köke ait klasör. Filtreleme Repository katmanında bellek içi
  /// uygulanır (Notes/Projects ile aynı desen).
  @Index()
  String? parentFolderId;

  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isDeleted;
  DateTime? deletedAt;

  // --- Isar-only senkronizasyon meta alanları — DATABASE.md §12.2 ---
  @Enumerated(EnumType.name)
  late VaultFolderSyncStatusLocal syncStatus;
  DateTime? lastSyncedAt;
  late DateTime localUpdatedAt;

  Map<String, dynamic> toFirestoreJson() {
    return {
      'folderId': folderId,
      'name': name,
      'parentFolderId': parentFolderId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
    };
  }

  static VaultFolderLocalModel fromFirestoreData(String folderId, Map<String, dynamic> data) {
    return VaultFolderLocalModel()
      ..folderId = folderId
      ..name = data['name'] as String
      ..parentFolderId = data['parentFolderId'] as String?
      ..createdAt = (data['createdAt'] as Timestamp).toDate()
      ..updatedAt = (data['updatedAt'] as Timestamp).toDate()
      ..isDeleted = data['isDeleted'] as bool? ?? false
      ..deletedAt = (data['deletedAt'] as Timestamp?)?.toDate()
      ..syncStatus = VaultFolderSyncStatusLocal.synced
      ..lastSyncedAt = DateTime.now()
      ..localUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
  }
}

/// DATABASE.md §12.2 — diğer feature'ların aynı isimli enum'larıyla şema
/// olarak birebir aynıdır fakat isim çakışmasını önlemek için ayrı
/// adlandırılır.
enum VaultFolderSyncStatusLocal { synced, pendingCreate, pendingUpdate, pendingDelete, error }
