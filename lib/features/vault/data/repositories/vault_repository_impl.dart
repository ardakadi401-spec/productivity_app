import 'dart:async';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../domain/entities/vault_item.dart';
import '../../domain/repositories/vault_repository.dart';
import '../datasources/local/vault_local_datasource.dart';
import '../datasources/remote/vault_remote_datasource.dart';
import '../mappers/vault_item_mapper.dart';
import '../models/vault_item_local_model.dart';

/// ARCHITECTURE.md §6.4 / §8 offline-first akışının somutlaşması —
/// Notes/Projects ile birebir aynı desen; ek olarak `password`/`notes`
/// alanları yerele/uzağa yazılmadan önce [VaultItemMapper] üzerinden
/// şifrelenir.
///
/// `SyncableRepository`'yi de implemente eder — merkezi `SyncCoordinator`,
/// bağlantı offline→online geçtiğinde `syncPending()`'i çağırabilir.
class VaultRepositoryImpl implements VaultRepository, SyncableRepository {
  VaultRepositoryImpl(this._local, this._remote, this._connectivity, this._mapper) {
    unawaited(_syncFromRemote());
  }

  final VaultLocalDatasource _local;
  final VaultRemoteDatasource _remote;
  final ConnectivityService _connectivity;
  final VaultItemMapper _mapper;

  @override
  String newVaultItemId() => _remote.newVaultItemId();

  @override
  Stream<List<VaultItem>> watchVaultItems({String? folderId}) {
    return _local.watchVaultItems().map(
          (models) => models
              .where((m) => m.folderId == folderId)
              .map(_mapper.toEntity)
              .toList(),
        );
  }

  @override
  Stream<VaultItem?> watchVaultItem(String itemId) {
    return _local.watchVaultItem(itemId).map((m) => m == null ? null : _mapper.toEntity(m));
  }

  @override
  Future<Result<VaultItem>> createVaultItem(VaultItem item) => _guard(() async {
        final model = _mapper.fromEntity(item, syncStatus: VaultItemSyncStatusLocal.pendingCreate);
        await _local.putVaultItem(model);
        await _trySyncVaultItem(model);
        return _mapper.toEntity(model);
      });

  @override
  Future<Result<VaultItem>> updateVaultItem(VaultItem item) => _guard(() async {
        final model = _mapper.fromEntity(item, syncStatus: VaultItemSyncStatusLocal.pendingUpdate);
        await _local.putVaultItem(model);
        await _trySyncVaultItem(model);
        return _mapper.toEntity(model);
      });

  @override
  Future<Result<void>> deleteVaultItem(String itemId) => _guard(() async {
        final existing = await _local.getByItemId(itemId);
        if (existing == null) throw const CacheException('Kasa kaydı bulunamadı.');
        final now = DateTime.now();
        existing
          ..isDeleted = true
          ..deletedAt = now
          ..updatedAt = now
          ..localUpdatedAt = now
          ..syncStatus = VaultItemSyncStatusLocal.pendingDelete;
        await _local.putVaultItem(existing);
        await _trySyncVaultItem(existing);
      });

  Future<void> _trySyncVaultItem(VaultItemLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _remote.setVaultItem(model);
      model
        ..syncStatus = VaultItemSyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _local.putVaultItem(model);
    } catch (_) {
      // pending kalır.
    }
  }

  Future<void> _syncFromRemote() async {
    if (!await _connectivity.isConnected) return;
    try {
      final remoteItems = await _remote.fetchAllVaultItems();
      for (final remoteItem in remoteItems) {
        final local = await _local.getByItemId(remoteItem.itemId);
        if (local == null || remoteItem.updatedAt.isAfter(local.localUpdatedAt)) {
          await _local.putVaultItem(remoteItem);
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
        await _trySyncVaultItem(model);
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
