import '../../../../core/errors/result.dart';
import '../entities/vault_folder.dart';
import '../repositories/vault_folder_repository.dart';

class CreateVaultFolderUseCase {
  const CreateVaultFolderUseCase(this._repository);
  final VaultFolderRepository _repository;
  Future<Result<VaultFolder>> call(VaultFolder folder) => _repository.createVaultFolder(folder);
}
