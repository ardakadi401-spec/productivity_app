import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/vault/domain/entities/vault_folder.dart';
import 'package:productivity_app/features/vault/domain/repositories/vault_folder_repository.dart';
import 'package:productivity_app/features/vault/domain/usecases/create_vault_folder_usecase.dart';
import 'package:productivity_app/features/vault/domain/usecases/delete_vault_folder_usecase.dart';
import 'package:productivity_app/features/vault/domain/usecases/rename_vault_folder_usecase.dart';
import 'package:productivity_app/features/vault/domain/usecases/watch_vault_folder_usecase.dart';
import 'package:productivity_app/features/vault/domain/usecases/watch_vault_folders_usecase.dart';

VaultFolder _folder({String folderId = 'f1', String? parentFolderId}) => VaultFolder(
      folderId: folderId,
      name: 'ELS İNŞAAT',
      parentFolderId: parentFolderId,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _FakeVaultFolderRepository implements VaultFolderRepository {
  Result<VaultFolder>? folderResult;
  Result<void>? deleteResult;
  List<VaultFolder> watchFoldersResult = const [];
  VaultFolder? watchFolderResult;

  VaultFolder? lastCreated;
  String? lastRenamedId;
  String? lastNewName;
  String? lastDeletedId;
  String? lastParentFilter;

  @override
  String newVaultFolderId() => 'generated-folder-id';

  @override
  Stream<List<VaultFolder>> watchVaultFolders({String? parentFolderId}) {
    lastParentFilter = parentFolderId;
    return Stream.value(watchFoldersResult);
  }

  @override
  Stream<VaultFolder?> watchVaultFolder(String folderId) => Stream.value(watchFolderResult);

  @override
  Future<Result<VaultFolder>> createVaultFolder(VaultFolder folder) async {
    lastCreated = folder;
    return folderResult!;
  }

  @override
  Future<Result<VaultFolder>> renameVaultFolder(String folderId, String name) async {
    lastRenamedId = folderId;
    lastNewName = name;
    return folderResult!;
  }

  @override
  Future<Result<void>> deleteVaultFolder(String folderId) async {
    lastDeletedId = folderId;
    return deleteResult!;
  }
}

void main() {
  late _FakeVaultFolderRepository repo;

  setUp(() => repo = _FakeVaultFolderRepository());

  test('WatchVaultFoldersUseCase parentFolderId\'yi iletir', () async {
    repo.watchFoldersResult = [_folder()];
    await WatchVaultFoldersUseCase(repo).call(parentFolderId: 'root').first;
    expect(repo.lastParentFilter, 'root');
  });

  test('WatchVaultFolderUseCase repository sonucunu iletir', () async {
    repo.watchFolderResult = _folder();
    final result = await WatchVaultFolderUseCase(repo).call('f1').first;
    expect(result?.folderId, 'f1');
  });

  test('CreateVaultFolderUseCase klasörü repository\'ye iletir', () async {
    repo.folderResult = Ok(_folder());
    final result = await CreateVaultFolderUseCase(repo).call(_folder());
    expect(repo.lastCreated?.folderId, 'f1');
    expect(result, isA<Ok<VaultFolder>>());
  });

  test('RenameVaultFolderUseCase folderId ve yeni adı iletir', () async {
    repo.folderResult = Ok(_folder());
    await RenameVaultFolderUseCase(repo).call('f1', 'Yeni Ad');
    expect(repo.lastRenamedId, 'f1');
    expect(repo.lastNewName, 'Yeni Ad');
  });

  test('DeleteVaultFolderUseCase folderId\'yi iletir', () async {
    repo.deleteResult = const Ok(null);
    await DeleteVaultFolderUseCase(repo).call('f1');
    expect(repo.lastDeletedId, 'f1');
  });
}
