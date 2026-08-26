import '../../../../core/errors/result.dart';
import '../entities/vault_item.dart';
import '../repositories/vault_repository.dart';

class UpdateVaultItemUseCase {
  const UpdateVaultItemUseCase(this._repository);
  final VaultRepository _repository;
  Future<Result<VaultItem>> call(VaultItem item) => _repository.updateVaultItem(item);
}
