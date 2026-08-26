import '../../../../core/errors/result.dart';
import '../entities/vault_folder.dart';
import '../repositories/vault_folder_repository.dart';

class RenameVaultFolderUseCase {
  const RenameVaultFolderUseCase(this._repository);
  final VaultFolderRepository _repository;
  Future<Result<VaultFolder>> call(String folderId, String name) =>
      _repository.renameVaultFolder(folderId, name);
}
