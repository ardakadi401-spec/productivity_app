import 'package:isar_community/isar.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/vault_item_local_model.dart';

/// Isar üzerinden VaultItem CRUD ve reaktif sorgular — Note/Project ile aynı
/// desen.
class VaultLocalDatasource {
  VaultLocalDatasource(this._isar);

  final Isar _isar;

  Stream<List<VaultItemLocalModel>> watchVaultItems() {
    return _guardSync(
      () => _isar.vaultItemLocalModels.filter().isDeletedEqualTo(false).watch(fireImmediately: true),
    );
  }

  Stream<VaultItemLocalModel?> watchVaultItem(String itemId) {
    return _guardSync(
      () => _isar.vaultItemLocalModels
          .filter()
          .itemIdEqualTo(itemId)
          .watch(fireImmediately: true)
          .map((results) => results.isEmpty ? null : results.first),
    );
  }

  Future<VaultItemLocalModel?> getByItemId(String itemId) async {
    try {
      return await _isar.vaultItemLocalModels.filter().itemIdEqualTo(itemId).findFirst();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<List<VaultItemLocalModel>> getPendingSync() async {
    try {
      return await _isar.vaultItemLocalModels
          .filter()
          .not()
          .syncStatusEqualTo(VaultItemSyncStatusLocal.synced)
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> putVaultItem(VaultItemLocalModel model) async {
    try {
      await _isar.writeTxn(() => _isar.vaultItemLocalModels.put(model));
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
