import 'package:isar_community/isar.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/vault_folder_local_model.dart';

/// Isar üzerinden VaultFolder CRUD ve reaktif sorgular — `VaultLocalDatasource`
/// ile aynı desen.
class VaultFolderLocalDatasource {
  VaultFolderLocalDatasource(this._isar);

  final Isar _isar;

  Stream<List<VaultFolderLocalModel>> watchVaultFolders() {
    return _guardSync(
      () =>
          _isar.vaultFolderLocalModels.filter().isDeletedEqualTo(false).watch(fireImmediately: true),
    );
  }

  Stream<VaultFolderLocalModel?> watchVaultFolder(String folderId) {
    return _guardSync(
      () => _isar.vaultFolderLocalModels
          .filter()
          .folderIdEqualTo(folderId)
          .watch(fireImmediately: true)
          .map((results) => results.isEmpty ? null : results.first),
    );
  }

  Future<VaultFolderLocalModel?> getByFolderId(String folderId) async {
    try {
      return await _isar.vaultFolderLocalModels.filter().folderIdEqualTo(folderId).findFirst();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  /// Yalnızca rekürsif klasör silme (cascade delete) akışı için — tüm
  /// (silinmemiş) klasör ağacını bellek içinde gezebilmek üzere.
  Future<List<VaultFolderLocalModel>> getAll() async {
    try {
      return await _isar.vaultFolderLocalModels.filter().isDeletedEqualTo(false).findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<List<VaultFolderLocalModel>> getPendingSync() async {
    try {
      return await _isar.vaultFolderLocalModels
          .filter()
          .not()
          .syncStatusEqualTo(VaultFolderSyncStatusLocal.synced)
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> putVaultFolder(VaultFolderLocalModel model) async {
    try {
      await _isar.writeTxn(() => _isar.vaultFolderLocalModels.put(model));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Stream<T> _guardSync<T>(Stream<T> Function() query) {
    try {
      return query();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
