import '../../../../core/errors/result.dart';
import '../entities/vault_item.dart';
import '../repositories/vault_repository.dart';

class CreateVaultItemUseCase {
  const CreateVaultItemUseCase(this._repository);
  final VaultRepository _repository;
  Future<Result<VaultItem>> call(VaultItem item) => _repository.createVaultItem(item);
}
