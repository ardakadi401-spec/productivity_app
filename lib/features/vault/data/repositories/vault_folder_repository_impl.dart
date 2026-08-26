import 'dart:async';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../domain/entities/vault_folder.dart';
import '../../domain/repositories/vault_folder_repository.dart';
import '../datasources/local/vault_folder_local_datasource.dart';
import '../datasources/local/vault_local_datasource.dart';
import '../datasources/remote/vault_folder_remote_datasource.dart';
import '../datasources/remote/vault_remote_datasource.dart';
import '../mappers/vault_folder_mapper.dart';
import '../models/vault_folder_local_model.dart';
import '../models/vault_item_local_model.dart';

/// `VaultRepositoryImpl` ile aynı offline-first desen. Ek olarak, klasör
/// silme gerçek bir dosya sistemi klasörü gibi REKÜRSİF davranır (bkz.
/// [deleteVaultFolder]) — bu yüzden aynı feature içindeki kardeş
/// datasource'lara (`VaultLocalDatasource`/`VaultRemoteDatasource`) de
/// bağımlıdır. Bu, ARCHITECTURE.md §10.2'nin yasakladığı bir CROSS-FEATURE
/// bağımlılık DEĞİLDİR — VaultItem ve VaultFolder aynı `vault` feature'ının
/// iki iç içe geçmiş kavramıdır (Task/SubTask, Habit/HabitRecord ile aynı
/// "bir feature, birden çok Isar koleksiyonu" deseni).
class VaultFolderRepositoryImpl implements VaultFolderRepository, SyncableRepository {
  VaultFolderRepositoryImpl(
    this._local,
    this._remote,
    this._itemLocal,
    this._itemRemote,
    this._connectivity,
  ) {
    unawaited(_syncFromRemote());
  }

  final VaultFolderLocalDatasource _local;
  final VaultFolderRemoteDatasource _remote;
  final VaultLocalDatasource _itemLocal;
  final VaultRemoteDatasource _itemRemote;
  final ConnectivityService _connectivity;

  @override
  String newVaultFolderId() => _remote.newVaultFolderId();

  @override
  Stream<List<VaultFolder>> watchVaultFolders({String? parentFolderId}) {
    return _local.watchVaultFolders().map(
          (models) => models
              .where((m) => m.parentFolderId == parentFolderId)
              .map(VaultFolderMapper.toEntity)
              .toList(),
        );
  }

  @override
  Stream<VaultFolder?> watchVaultFolder(String folderId) {
    return _local.watchVaultFolder(folderId).map((m) => m == null ? null : VaultFolderMapper.toEntity(m));
  }

  @override
  Future<Result<VaultFolder>> createVaultFolder(VaultFolder folder) => _guard(() async {
        final model =
            VaultFolderMapper.fromEntity(folder, syncStatus: VaultFolderSyncStatusLocal.pendingCreate);
        await _local.putVaultFolder(model);
        await _trySyncVaultFolder(model);
        return VaultFolderMapper.toEntity(model);
      });

  @override
  Future<Result<VaultFolder>> renameVaultFolder(String folderId, String name) => _guard(() async {
        final existing = await _local.getByFolderId(folderId);
        if (existing == null) throw const CacheException('Klasör bulunamadı.');
        final now = DateTime.now();
        existing
          ..name = name
          ..updatedAt = now
          ..localUpdatedAt = now
          ..syncStatus = VaultFolderSyncStatusLocal.pendingUpdate;
        await _local.putVaultFolder(existing);
        await _trySyncVaultFolder(existing);
        return VaultFolderMapper.toEntity(existing);
      });

  /// Silinecek klasörden başlayarak TÜM alt ağacı (rekürsif alt klasörler +
  /// bu klasörlerin içindeki tüm kayıtlar) bulur ve hepsini tek tek
  /// soft-delete eder — gerçek bir "klasörü sil" davranışı.
  @override
  Future<Result<void>> deleteVaultFolder(String folderId) => _guard(() async {
        final root = await _local.getByFolderId(folderId);
        if (root == null) throw const CacheException('Klasör bulunamadı.');

        final allFolders = await _local.getAll();
        final descendantIds = <String>{folderId};
        var growing = true;
        while (growing) {
          growing = false;
          for (final folder in allFolders) {
            if (folder.parentFolderId != null &&
                descendantIds.contains(folder.parentFolderId) &&
                !descendantIds.contains(folder.folderId)) {
              descendantIds.add(folder.folderId);
              growing = true;
            }
          }
        }

        final now = DateTime.now();
        for (final id in descendantIds) {
          final folder = id == folderId ? root : allFolders.firstWhere((f) => f.folderId == id);
          folder
            ..isDeleted = true
            ..deletedAt = now
            ..updatedAt = now
            ..localUpdatedAt = now
            ..syncStatus = VaultFolderSyncStatusLocal.pendingDelete;
          await _local.putVaultFolder(folder);
          await _trySyncVaultFolder(folder);
        }

        final allItems = await _itemLocal.getAll();
        for (final item in allItems) {
          if (item.folderId == null || !descendantIds.contains(item.folderId)) continue;
          item
            ..isDeleted = true
            ..deletedAt = now
            ..updatedAt = now
            ..localUpdatedAt = now
            ..syncStatus = VaultItemSyncStatusLocal.pendingDelete;
          await _itemLocal.putVaultItem(item);
          await _trySyncVaultItem(item);
        }
      });

  Future<void> _trySyncVaultFolder(VaultFolderLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _remote.setVaultFolder(model);
      model
        ..syncStatus = VaultFolderSyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _local.putVaultFolder(model);
    } catch (_) {
      // pending kalır.
    }
  }

  Future<void> _trySyncVaultItem(VaultItemLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _itemRemote.setVaultItem(model);
      model
        ..syncStatus = VaultItemSyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _itemLocal.putVaultItem(model);
    } catch (_) {
      // pending kalır.
    }
  }

  Future<void> _syncFromRemote() async {
    if (!await _connectivity.isConnected) return;
    try {
      final remoteFolders = await _remote.fetchAllVaultFolders();
      for (final remoteFolder in remoteFolders) {
        final local = await _local.getByFolderId(remoteFolder.folderId);
        if (local == null || remoteFolder.updatedAt.isAfter(local.localUpdatedAt)) {
          await _local.putVaultFolder(remoteFolder);
        }
      }
      await syncPending();
    } catch (_) {
      // Sessiz — bir sonraki repository örneklenmesinde tekrar denenir.
    }
  }

  @override
  Future<void> syncPending() async {
    if (!await _connectivity.isConnected) return;
    try {
      final pending = await _local.getPendingSync();
      for (final model in pending) {
        await _trySyncVaultFolder(model);
      }
    } catch (_) {
      // Sessiz — pending kayıtlar bir sonraki tetikleyicide tekrar denenir.
    }
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on AppException catch (e) {
      return Err(_mapToFailure(e));
    }
  }

  Failure _mapToFailure(AppException exception) {
    return switch (exception) {
      CacheException(:final message) => CacheFailure(message),
      NetworkException() => const NetworkFailure('Bağlantını kontrol edip tekrar dene.'),
      AuthException() => const AuthFailure('Oturum bulunamadı, lütfen tekrar giriş yap.'),
      _ => UnknownFailure(exception.message),
    };
  }
}
