import 'dart:async';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../domain/entities/statistics_snapshot.dart';
import '../../domain/repositories/statistics_snapshot_repository.dart';
import '../datasources/local/statistics_snapshot_local_datasource.dart';
import '../datasources/remote/statistics_snapshot_remote_datasource.dart';
import '../mappers/statistics_snapshot_mapper.dart';
import '../models/statistics_snapshot_local_model.dart';

/// ARCHITECTURE.md §6.4 / §8 offline-first akışının somutlaşması — diğer
/// feature'larla aynı desen, immutable koleksiyona uyarlanmış (yalnızca
/// oluşturma, güncelleme/silme yok).
///
/// FAZ 14 — `SyncableRepository`'yi de implemente eder. `syncPending()`
/// ayrıca DATABASE.md §12.3'teki "son N dönem yerelde tutulur" retention
/// sınırını da (yalnızca zaten `synced` kayıtlar üzerinde) uygular —
/// immutable/CRUD-olmayan tasarım bozulmadan.
class StatisticsSnapshotRepositoryImpl implements StatisticsSnapshotRepository, SyncableRepository {
  StatisticsSnapshotRepositoryImpl(this._local, this._remote, this._connectivity) {
    unawaited(_syncFromRemote());
  }

  /// DATABASE.md §12.3 — "örn. son 90 gün" örneğiyle birebir.
  static const _retentionWindow = Duration(days: 90);

  final StatisticsSnapshotLocalDatasource _local;
  final StatisticsSnapshotRemoteDatasource _remote;
  final ConnectivityService _connectivity;

  @override
  Future<List<StatisticsSnapshot>> getSnapshotsInRange(DateTime start, DateTime end) async {
    // `_pruneOldSnapshots` retention penceresinin (90 gün) dışındaki
    // `synced` kayıtları yerelden siler — bu yüzden talep edilen aralık bu
    // pencerenin dışına taşıyorsa (kullanıcı gerçekten eski bir dönem
    // görüntülemek istiyorsa), yerelde eksik olabilecek kayıtlar Firestore'dan
    // isteğe bağlı olarak çekilip yerele geri yazılır — aksi halde bu veri
    // kalıcı olarak kaybolmuş gibi görünürdü (DATABASE.md §12.3'ün "arşiv"
    // niyetine aykırı olurdu).
    if (start.isBefore(DateTime.now().subtract(_retentionWindow)) && await _connectivity.isConnected) {
      try {
        final remoteSnapshots = await _remote.fetchSnapshotsInRange(start, end);
        for (final remoteSnapshot in remoteSnapshots) {
          final local = await _local.getBySnapshotId(remoteSnapshot.snapshotId);
          if (local == null) await _local.putSnapshot(remoteSnapshot);
        }
      } catch (_) {
        // Sessiz — yalnızca yerelde zaten var olan sonuçlarla devam edilir.
      }
    }
    final models = await _local.getSnapshotsInRange(start, end);
    return models.map(StatisticsSnapshotMapper.toEntity).toList();
  }

  @override
  Future<Result<StatisticsSnapshot>> saveSnapshot(StatisticsSnapshot snapshot) => _guard(() async {
        final model = StatisticsSnapshotMapper.fromEntity(
          snapshot,
          syncStatus: StatisticsSyncStatusLocal.pendingCreate,
        );
        await _local.putSnapshot(model);
        await _trySyncSnapshot(model);
        return StatisticsSnapshotMapper.toEntity(model);
      });

  Future<void> _trySyncSnapshot(StatisticsSnapshotLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _remote.setSnapshot(model);
      model
        ..syncStatus = StatisticsSyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _local.putSnapshot(model);
    } catch (_) {
      // pending kalır.
    }
  }

  Future<void> _syncFromRemote() async {
    if (!await _connectivity.isConnected) return;
    try {
      final remoteSnapshots = await _remote.fetchAllSnapshots();
      for (final remoteSnapshot in remoteSnapshots) {
        final local = await _local.getBySnapshotId(remoteSnapshot.snapshotId);
        // Immutable koleksiyon — yerelde zaten varsa üzerine yazmaya gerek
        // yok (LWW karşılaştırması gerekmez, tek bir sürüm zaten kesindir).
        if (local == null) {
          await _local.putSnapshot(remoteSnapshot);
        }
      }
      await syncPending();
    } catch (_) {
      // Sessiz — bir sonraki repository örneklenmesinde tekrar denenir.
    }
  }

  /// FAZ 14 — merkezi `SyncCoordinator` tarafından, bağlantı offline→online
  /// geçtiğinde çağrılır. Yerelde `pending*` durumda kalan snapshot'ları
  /// Firestore'a göndermeyi dener, ardından DATABASE.md §12.3 retention
  /// sınırını uygular (yalnızca zaten `synced` ve pencereden eski kayıtlar
  /// silinir — bağlantı olmasa da yerel bir işlemdir, güvenle çalışır).
  @override
  Future<void> syncPending() async {
    if (await _connectivity.isConnected) {
      try {
        final pending = await _local.getPendingSync();
        for (final model in pending) {
          await _trySyncSnapshot(model);
        }
      } catch (_) {
        // Sessiz — pending kayıtlar bir sonraki tetikleyicide tekrar denenir.
      }
    }
    await _pruneOldSnapshots();
  }

  Future<void> _pruneOldSnapshots() async {
    try {
      final cutoff = DateTime.now().subtract(_retentionWindow);
      await _local.pruneSyncedOlderThan(cutoff);
    } catch (_) {
      // Sessiz — yerel bakım işlemi, bir sonraki tetikleyicide tekrar denenir.
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
