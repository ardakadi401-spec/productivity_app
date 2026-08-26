import 'package:cloud_firestore/cloud_firestore.dart' hide Index, Type;
import 'package:isar_community/isar.dart';

part 'vault_item_local_model.g.dart';

/// `users/{userId}/vaultItems/{itemId}` — Task/Project/Note ile birebir aynı
/// yerel Isar + Firestore serileştirme deseni. `encryptedPassword`/
/// `encryptedNotes` alanları HER ZAMAN şifreli metin taşır (bkz.
/// `VaultEncryptionService`) — hem yerelde hem Firestore'da düz metin asla
/// saklanmaz; yalnızca `title`/`username`/`url`/`category` liste görünümü
/// için düz metin kalır.
@collection
class VaultItemLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String itemId;

  late String title;

  @Enumerated(EnumType.name)
  late VaultItemCategoryLocal category;

  /// `null` → köke ait kayıt. Filtreleme diğer feature'larla aynı desende
  /// (Notes'un `projectId`/`taskId`'si gibi) Repository katmanında bellek içi
  /// uygulanır; bu yüzden burada bir Isar sorgu metodu ÜRETİLMEZ, yalnızca
  /// tutarlılık için indekslenir.
  @Index()
  String? folderId;

  String? username;
  String? encryptedPassword;
  String? url;
  String? encryptedNotes;

  late DateTime createdAt;
  late DateTime updatedAt;
  late bool isDeleted;
  DateTime? deletedAt;

  // --- Isar-only senkronizasyon meta alanları — DATABASE.md §12.2 ---
  @Enumerated(EnumType.name)
  late VaultItemSyncStatusLocal syncStatus;
  DateTime? lastSyncedAt;
  late DateTime localUpdatedAt;

  Map<String, dynamic> toFirestoreJson() {
    return {
      'itemId': itemId,
      'title': title,
      'category': category.name,
      'folderId': folderId,
      'username': username,
      'encryptedPassword': encryptedPassword,
      'url': url,
      'encryptedNotes': encryptedNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
    };
  }

  static VaultItemLocalModel fromFirestoreData(String itemId, Map<String, dynamic> data) {
    return VaultItemLocalModel()
      ..itemId = itemId
      ..title = data['title'] as String
      ..category = VaultItemCategoryLocal.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => VaultItemCategoryLocal.other,
      )
      ..folderId = data['folderId'] as String?
      ..username = data['username'] as String?
      ..encryptedPassword = data['encryptedPassword'] as String?
      ..url = data['url'] as String?
      ..encryptedNotes = data['encryptedNotes'] as String?
      ..createdAt = (data['createdAt'] as Timestamp).toDate()
      ..updatedAt = (data['updatedAt'] as Timestamp).toDate()
      ..isDeleted = data['isDeleted'] as bool? ?? false
      ..deletedAt = (data['deletedAt'] as Timestamp?)?.toDate()
      ..syncStatus = VaultItemSyncStatusLocal.synced
      ..lastSyncedAt = DateTime.now()
      ..localUpdatedAt = (data['updatedAt'] as Timestamp).toDate();
  }
}

enum VaultItemCategoryLocal { app, project, other }

/// DATABASE.md §12.2 — diğer feature'ların aynı isimli enum'larıyla şema
/// olarak birebir aynıdır fakat `IsarService`'in tüm modelleri birden import
/// ettiği düşünüldüğünde isim çakışmasını önlemek için ayrı adlandırılır.
enum VaultItemSyncStatusLocal { synced, pendingCreate, pendingUpdate, pendingDelete, error }
