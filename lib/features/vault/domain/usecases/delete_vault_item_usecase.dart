import '../../../../core/errors/result.dart';
import '../repositories/vault_repository.dart';

class DeleteVaultItemUseCase {
  const DeleteVaultItemUseCase(this._repository);
  final VaultRepository _repository;
  Future<Result<void>> call(String itemId) => _repository.deleteVaultItem(itemId);
}
