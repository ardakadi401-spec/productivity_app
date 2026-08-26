import '../../domain/entities/vault_item.dart';
import '../models/vault_item_local_model.dart';
import '../services/vault_encryption_service.dart';

/// NoteMapper vb. diğer mapper'lardan farklı olarak statik DEĞİLDİR —
/// `password`/`notes` alanlarını şifrelemek/çözmek için `VaultEncryptionService`
/// örneğine ihtiyaç duyar (Domain katmanı yine de şifreleme detayından
/// bağımsız kalır, bu bağımlılık yalnızca Data katmanında yaşar).
class VaultItemMapper {
  const VaultItemMapper(this._encryption);

  final VaultEncryptionService _encryption;

  VaultItem toEntity(VaultItemLocalModel model) {
    return VaultItem(
      itemId: model.itemId,
      title: model.title,
      category: VaultItemCategory.values.byName(model.category.name),
      folderId: model.folderId,
      username: model.username,
      password: model.encryptedPassword == null ? null : _encryption.decrypt(model.encryptedPassword!),
      url: model.url,
      notes: model.encryptedNotes == null ? null : _encryption.decrypt(model.encryptedNotes!),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Yeni bir [VaultItemLocalModel] oluşturur — `Isar.autoIncrement` `id`
  /// hariç tüm alanlar entity'den ve senkronizasyon meta bilgisinden
  /// doldurulur.
  VaultItemLocalModel fromEntity(
    VaultItem item, {
    required VaultItemSyncStatusLocal syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return VaultItemLocalModel()
      ..itemId = item.itemId
      ..title = item.title
      ..category = VaultItemCategoryLocal.values.byName(item.category.name)
      ..folderId = item.folderId
      ..username = item.username
      ..encryptedPassword = item.password == null ? null : _encryption.encrypt(item.password!)
      ..url = item.url
      ..encryptedNotes = item.notes == null ? null : _encryption.encrypt(item.notes!)
      ..createdAt = item.createdAt
      ..updatedAt = item.updatedAt
      ..isDeleted = false
      ..syncStatus = syncStatus
      ..lastSyncedAt = lastSyncedAt
      ..localUpdatedAt = item.updatedAt;
  }
}
