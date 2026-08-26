import '../../domain/entities/vault_folder.dart';
import '../models/vault_folder_local_model.dart';

class VaultFolderMapper {
  VaultFolderMapper._();

  static VaultFolder toEntity(VaultFolderLocalModel model) {
    return VaultFolder(
      folderId: model.folderId,
      name: model.name,
      parentFolderId: model.parentFolderId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static VaultFolderLocalModel fromEntity(
    VaultFolder folder, {
    required VaultFolderSyncStatusLocal syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return VaultFolderLocalModel()
      ..folderId = folder.folderId
      ..name = folder.name
      ..parentFolderId = folder.parentFolderId
      ..createdAt = folder.createdAt
      ..updatedAt = folder.updatedAt
      ..isDeleted = false
      ..syncStatus = syncStatus
      ..lastSyncedAt = lastSyncedAt
      ..localUpdatedAt = folder.updatedAt;
  }
}
