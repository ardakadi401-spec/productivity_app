import '../../../../core/errors/result.dart';
import '../entities/vault_item.dart';

abstract class VaultRepository {
  String newVaultItemId();
  Stream<List<VaultItem>> watchVaultItems();
  Stream<VaultItem?> watchVaultItem(String itemId);
  Future<Result<VaultItem>> createVaultItem(VaultItem item);
  Future<Result<VaultItem>> updateVaultItem(VaultItem item);
  Future<Result<void>> deleteVaultItem(String itemId);
}
