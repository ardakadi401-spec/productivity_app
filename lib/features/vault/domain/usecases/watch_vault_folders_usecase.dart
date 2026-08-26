import '../entities/vault_folder.dart';
import '../repositories/vault_folder_repository.dart';

class WatchVaultFoldersUseCase {
  const WatchVaultFoldersUseCase(this._repository);
  final VaultFolderRepository _repository;
  Stream<List<VaultFolder>> call({String? parentFolderId}) =>
      _repository.watchVaultFolders(parentFolderId: parentFolderId);
}
