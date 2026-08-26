import '../../../../core/errors/result.dart';
import '../entities/vault_item.dart';

abstract class VaultRepository {
  String newVaultItemId();

  /// `folderId == null` → yalnızca kökteki (herhangi bir klasöre ait
  /// olmayan) kayıtlar. Filtreleme diğer feature'larla aynı desende
  /// (Notes/Projects) Repository katmanında bellek içi uygulanır.
  Stream<List<VaultItem>> watchVaultItems({String? folderId});
  Stream<VaultItem?> watchVaultItem(String itemId);
  Future<Result<VaultItem>> createVaultItem(VaultItem item);
  Future<Result<VaultItem>> updateVaultItem(VaultItem item);
  Future<Result<void>> deleteVaultItem(String itemId);
}
