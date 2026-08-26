import '../../../../core/errors/result.dart';
import '../repositories/vault_folder_repository.dart';

class DeleteVaultFolderUseCase {
  const DeleteVaultFolderUseCase(this._repository);
  final VaultFolderRepository _repository;
  Future<Result<void>> call(String folderId) => _repository.deleteVaultFolder(folderId);
}
