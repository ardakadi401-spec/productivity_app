import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/local/goal_local_datasource.dart';
import '../datasources/remote/goal_remote_datasource.dart';
import '../mappers/goal_mapper.dart';
import '../models/goal_local_model.dart';

/// ARCHITECTURE.md §6.4 / §8 offline-first akışının somutlaşması —
/// `TaskRepositoryImpl`/`ProjectRepositoryImpl` ile birebir aynı desen: her
/// yazma önce Isar'a (anında, `pendingX` işaretiyle) yazılır, bağlantı
/// varsa arka planda Firestore'a gönderilir.
///
/// FAZ 14 — `SyncableRepository`'yi de implemente eder. NOT: PRD.md §259-263
/// gereği Goals'ta manuel silme YOKTUR (yalnızca dönem sonu otomatik
/// arşivleme/`setGoalStatus`) — bu, FAZ 14 kapsamında da eklenmedi;
/// `syncPending()` yalnızca mevcut pendingCreate/pendingUpdate akışını
/// flush eder.
class GoalRepositoryImpl implements GoalRepository, SyncableRepository {
  GoalRepositoryImpl(this._local, this._remote, this._connectivity) {
    unawaited(_syncFromRemote());
  }

  final GoalLocalDatasource _local;
  final GoalRemoteDatasource _remote;
  final ConnectivityService _connectivity;

  @override
  String newGoalId() => _remote.newGoalId();

  @override
  Stream<List<Goal>> watchGoals({GoalPeriodType? periodType}) {
    return _local.watchGoals().map(
          (models) => models
              .where((m) => periodType == null || m.periodType.name == periodType.name)
              .map(GoalMapper.toEntity)
              .toList(),
        );
  }

  @override
  Stream<Goal?> watchGoal(String goalId) {
    return _local.watchGoal(goalId).map((m) => m == null ? null : GoalMapper.toEntity(m));
  }

  @override
  Future<Result<Goal>> createGoal(Goal goal) => _guard(() async {
        final model = GoalMapper.fromEntity(goal, syncStatus: GoalSyncStatusLocal.pendingCreate);
        await _local.putGoal(model);
        await _trySyncGoal(model);
        return GoalMapper.toEntity(model);
      });

  @override
  Future<Result<Goal>> updateGoal(Goal goal) => _guard(() async {
        final model = GoalMapper.fromEntity(goal, syncStatus: GoalSyncStatusLocal.pendingUpdate);
        await _local.putGoal(model);
        await _trySyncGoal(model);
        return GoalMapper.toEntity(model);
      });

  @override
  Future<Result<Goal>> setManualProgress(String goalId, {required int progress}) =>
      _guard(() async {
        final existing = await _local.getByGoalId(goalId);
        if (existing == null) throw const CacheException('Hedef bulunamadı.');
        final now = DateTime.now();
        existing
          ..manualProgress = progress
          ..updatedAt = now
          ..localUpdatedAt = now
          ..syncStatus = GoalSyncStatusLocal.pendingUpdate;
        await _local.putGoal(existing);
        await _trySyncGoal(existing);
        return GoalMapper.toEntity(existing);
      });

  @override
  Future<Result<Goal>> setGoalStatus(String goalId, {required GoalStatus status}) =>
      _guard(() async {
        final existing = await _local.getByGoalId(goalId);
        if (existing == null) throw const CacheException('Hedef bulunamadı.');
        final now = DateTime.now();
        existing
          ..status = _statusToLocal(status)
          ..updatedAt = now
          ..localUpdatedAt = now
          ..syncStatus = GoalSyncStatusLocal.pendingUpdate;
        await _local.putGoal(existing);
        await _trySyncGoal(existing);
        return GoalMapper.toEntity(existing);
      });

  GoalStatusLocal _statusToLocal(GoalStatus s) => switch (s) {
        GoalStatus.inProgress => GoalStatusLocal.inProgress,
        GoalStatus.achieved => GoalStatusLocal.achieved,
        GoalStatus.missed => GoalStatusLocal.missed,
      };

  /// Bağlantı varsa Firestore'a gönderir; başarısız olursa sessizce
  /// `pending` bırakır (ARCHITECTURE.md §8.2).
  Future<void> _trySyncGoal(GoalLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _remote.setGoal(model);
      model
        ..syncStatus = GoalSyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _local.putGoal(model);
    } catch (_) {
      // pending kalır.
    }
  }

  /// DATABASE.md §12.4 — bir kerelik uzaktan çekme + Last-Write-Wins eşleme,
  /// ardından yerelde hâlâ `pending*` olan kayıtları göndermeyi dener.
  Future<void> _syncFromRemote() async {
    if (!await _connectivity.isConnected) return;
    try {
      final remoteGoals = await _remote.fetchAllGoals();
      for (final remoteGoal in remoteGoals) {
        final local = await _local.getByGoalId(remoteGoal.goalId);
        if (local == null || remoteGoal.updatedAt.isAfter(local.localUpdatedAt)) {
          await _local.putGoal(remoteGoal);
        }
      }
      await syncPending();
    } catch (_) {
      // Sessiz — bir sonraki repository örneklenmesinde tekrar denenir.
    }
  }

  /// FAZ 14 — merkezi `SyncCoordinator` tarafından, bağlantı offline→online
  /// geçtiğinde çağrılır. Yalnızca yerelde `pending*` durumda kalan hedefleri
  /// Firestore'a göndermeyi dener; `_syncFromRemote` içindeki tek seferlik
  /// "uzaktan çek + LWW eşle" adımını TEKRARLAMAZ.
  @override
  Future<void> syncPending() async {
    if (!await _connectivity.isConnected) return;
    try {
      final pending = await _local.getPendingSync();
      for (final model in pending) {
        await _trySyncGoal(model);
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

void unawaited(Future<void> future) {}
