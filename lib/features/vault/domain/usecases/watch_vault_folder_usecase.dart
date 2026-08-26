import '../entities/vault_folder.dart';
import '../repositories/vault_folder_repository.dart';

class WatchVaultFolderUseCase {
  const WatchVaultFolderUseCase(this._repository);
  final VaultFolderRepository _repository;
  Stream<VaultFolder?> call(String folderId) => _repository.watchVaultFolder(folderId);
}
