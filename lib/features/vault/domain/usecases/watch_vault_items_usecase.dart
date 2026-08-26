import '../entities/vault_item.dart';
import '../repositories/vault_repository.dart';

class WatchVaultItemsUseCase {
  const WatchVaultItemsUseCase(this._repository);
  final VaultRepository _repository;
  Stream<List<VaultItem>> call({String? folderId}) => _repository.watchVaultItems(folderId: folderId);
}
