import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/isar_provider.dart';
import '../../data/datasources/local/vault_folder_local_datasource.dart';
import '../../data/datasources/local/vault_local_datasource.dart';
import '../../data/datasources/remote/vault_folder_remote_datasource.dart';
import '../../data/datasources/remote/vault_remote_datasource.dart';
import '../../data/mappers/vault_item_mapper.dart';
import '../../data/repositories/vault_folder_repository_impl.dart';
import '../../data/repositories/vault_repository_impl.dart';
import '../../data/services/vault_encryption_service.dart';
import '../../domain/entities/vault_folder.dart';
import '../../domain/entities/vault_item.dart';
import '../../domain/repositories/vault_folder_repository.dart';
import '../../domain/repositories/vault_repository.dart';
import '../../domain/usecases/create_vault_folder_usecase.dart';
import '../../domain/usecases/create_vault_item_usecase.dart';
import '../../domain/usecases/delete_vault_folder_usecase.dart';
import '../../domain/usecases/delete_vault_item_usecase.dart';
import '../../domain/usecases/rename_vault_folder_usecase.dart';
import '../../domain/usecases/update_vault_item_usecase.dart';
import '../../domain/usecases/watch_vault_folder_usecase.dart';
import '../../domain/usecases/watch_vault_folders_usecase.dart';
import '../../domain/usecases/watch_vault_item_usecase.dart';
import '../../domain/usecases/watch_vault_items_usecase.dart';

// --- Service / Data katmanı — ARCHITECTURE.md §5.2 ---

final vaultEncryptionServiceProvider = Provider<VaultEncryptionService>((ref) {
  return VaultEncryptionService();
});

final vaultItemMapperProvider = Provider<VaultItemMapper>((ref) {
  return VaultItemMapper(ref.watch(vaultEncryptionServiceProvider));
});

final vaultLocalDatasourceProvider = Provider<VaultLocalDatasource>((ref) {
  return VaultLocalDatasource(ref.watch(isarProvider));
});

final vaultRemoteDatasourceProvider = Provider<VaultRemoteDatasource>((ref) {
  return VaultRemoteDatasource();
});

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  return VaultRepositoryImpl(
    ref.watch(vaultLocalDatasourceProvider),
    ref.watch(vaultRemoteDatasourceProvider),
    ref.watch(connectivityServiceProvider),
    ref.watch(vaultItemMapperProvider),
  );
});

final vaultFolderLocalDatasourceProvider = Provider<VaultFolderLocalDatasource>((ref) {
  return VaultFolderLocalDatasource(ref.watch(isarProvider));
});

final vaultFolderRemoteDatasourceProvider = Provider<VaultFolderRemoteDatasource>((ref) {
  return VaultFolderRemoteDatasource();
});

final vaultFolderRepositoryProvider = Provider<VaultFolderRepository>((ref) {
  return VaultFolderRepositoryImpl(
    ref.watch(vaultFolderLocalDatasourceProvider),
    ref.watch(vaultFolderRemoteDatasourceProvider),
    ref.watch(vaultLocalDatasourceProvider),
    ref.watch(vaultRemoteDatasourceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

// --- Domain katmanı (UseCase provider'ları) ---

final watchVaultItemsUseCaseProvider = Provider<WatchVaultItemsUseCase>((ref) {
  return WatchVaultItemsUseCase(ref.watch(vaultRepositoryProvider));
});

final watchVaultItemUseCaseProvider = Provider<WatchVaultItemUseCase>((ref) {
  return WatchVaultItemUseCase(ref.watch(vaultRepositoryProvider));
});

final createVaultItemUseCaseProvider = Provider<CreateVaultItemUseCase>((ref) {
  return CreateVaultItemUseCase(ref.watch(vaultRepositoryProvider));
});

final updateVaultItemUseCaseProvider = Provider<UpdateVaultItemUseCase>((ref) {
  return UpdateVaultItemUseCase(ref.watch(vaultRepositoryProvider));
});

final deleteVaultItemUseCaseProvider = Provider<DeleteVaultItemUseCase>((ref) {
  return DeleteVaultItemUseCase(ref.watch(vaultRepositoryProvider));
});

final watchVaultFoldersUseCaseProvider = Provider<WatchVaultFoldersUseCase>((ref) {
  return WatchVaultFoldersUseCase(ref.watch(vaultFolderRepositoryProvider));
});

final watchVaultFolderUseCaseProvider = Provider<WatchVaultFolderUseCase>((ref) {
  return WatchVaultFolderUseCase(ref.watch(vaultFolderRepositoryProvider));
});

final createVaultFolderUseCaseProvider = Provider<CreateVaultFolderUseCase>((ref) {
  return CreateVaultFolderUseCase(ref.watch(vaultFolderRepositoryProvider));
});

final renameVaultFolderUseCaseProvider = Provider<RenameVaultFolderUseCase>((ref) {
  return RenameVaultFolderUseCase(ref.watch(vaultFolderRepositoryProvider));
});

final deleteVaultFolderUseCaseProvider = Provider<DeleteVaultFolderUseCase>((ref) {
  return DeleteVaultFolderUseCase(ref.watch(vaultFolderRepositoryProvider));
});

// --- Presentation katmanı — reaktif okuma provider'ları ---

/// `folderId == null` → kasanın kök seviyesi.
final vaultListProvider = StreamProvider.autoDispose.family<List<VaultItem>, String?>((
  ref,
  folderId,
) {
  return ref.watch(watchVaultItemsUseCaseProvider).call(folderId: folderId);
});

final vaultItemDetailProvider = StreamProvider.autoDispose.family<VaultItem?, String>((ref, itemId) {
  return ref.watch(watchVaultItemUseCaseProvider).call(itemId);
});

/// `parentFolderId == null` → kasanın kök seviyesindeki klasörler.
final vaultFolderListProvider = StreamProvider.autoDispose.family<List<VaultFolder>, String?>((
  ref,
  parentFolderId,
) {
  return ref.watch(watchVaultFoldersUseCaseProvider).call(parentFolderId: parentFolderId);
});

final vaultFolderDetailProvider = StreamProvider.autoDispose.family<VaultFolder?, String>((
  ref,
  folderId,
) {
  return ref.watch(watchVaultFolderUseCaseProvider).call(folderId);
});
