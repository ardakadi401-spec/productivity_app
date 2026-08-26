import '../entities/vault_item.dart';
import '../repositories/vault_repository.dart';

class WatchVaultItemUseCase {
  const WatchVaultItemUseCase(this._repository);
  final VaultRepository _repository;
  Stream<VaultItem?> call(String itemId) => _repository.watchVaultItem(itemId);
}
