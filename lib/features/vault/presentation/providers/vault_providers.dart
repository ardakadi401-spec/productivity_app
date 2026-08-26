import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/isar_provider.dart';
import '../../data/datasources/local/vault_local_datasource.dart';
import '../../data/datasources/remote/vault_remote_datasource.dart';
import '../../data/mappers/vault_item_mapper.dart';
import '../../data/repositories/vault_repository_impl.dart';
import '../../data/services/vault_encryption_service.dart';
import '../../domain/entities/vault_item.dart';
import '../../domain/repositories/vault_repository.dart';
import '../../domain/usecases/create_vault_item_usecase.dart';
import '../../domain/usecases/delete_vault_item_usecase.dart';
import '../../domain/usecases/update_vault_item_usecase.dart';
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

// --- Presentation katmanı — reaktif okuma provider'ları ---

final vaultListProvider = StreamProvider.autoDispose<List<VaultItem>>((ref) {
  return ref.watch(watchVaultItemsUseCaseProvider).call();
});

final vaultItemDetailProvider = StreamProvider.autoDispose.family<VaultItem?, String>((ref, itemId) {
  return ref.watch(watchVaultItemUseCaseProvider).call(itemId);
});
