import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../domain/entities/pomodoro_session.dart';
import '../../domain/repositories/pomodoro_repository.dart';
import '../datasources/local/pomodoro_local_datasource.dart';
import '../datasources/remote/pomodoro_remote_datasource.dart';
import '../mappers/pomodoro_session_mapper.dart';
import '../models/pomodoro_session_local_model.dart';

/// ARCHITECTURE.md §6.4 / §8 offline-first akışının somutlaşması —
/// Tasks/Projects/Goals/Habits/Notes ile birebir aynı desen.
///
/// FAZ 14 — `SyncableRepository`'yi de implemente eder. NOT: PomodoroSession
/// geçmiş-kaydı niteliğindedir (DATABASE.md §13.4 istisnası) — soft/hard
/// delete akışı yoktur ve bu FAZ'da eklenmedi; `syncPending()` yalnızca
/// mevcut pendingCreate/pendingUpdate akışını flush eder.
class PomodoroRepositoryImpl implements PomodoroRepository, SyncableRepository {
  PomodoroRepositoryImpl(this._local, this._remote, this._connectivity) {
    unawaited(_syncFromRemote());
  }

  final PomodoroLocalDatasource _local;
  final PomodoroRemoteDatasource _remote;
  final ConnectivityService _connectivity;

  @override
  String newSessionId() => _remote.newSessionId();

  @override
  Stream<List<PomodoroSession>> watchSessionsByTask(String taskId) {
    return _local
        .watchSessionsByTask(taskId)
        .map((models) => models.map(PomodoroSessionMapper.toEntity).toList());
  }

  @override
  Future<Result<PomodoroSession>> createSession(PomodoroSession session) => _guard(() async {
        final model =
            PomodoroSessionMapper.fromEntity(session, syncStatus: PomodoroSyncStatusLocal.pendingCreate);
        await _local.putSession(model);
        await _trySyncSession(model);
        return PomodoroSessionMapper.toEntity(model);
      });

  @override
  Future<Result<PomodoroSession>> completeSession(
    String sessionId, {
    required Duration actualDuration,
    required bool isCompleted,
  }) =>
      _guard(() async {
        final existing = await _local.getBySessionId(sessionId);
        if (existing == null) throw const CacheException('Oturum bulunamadı.');
        final now = DateTime.now();
        existing
          ..actualDurationSeconds = actualDuration.inSeconds
          ..isCompleted = isCompleted
          ..completedAt = now
          ..localUpdatedAt = now
          ..syncStatus = PomodoroSyncStatusLocal.pendingUpdate;
        await _local.putSession(existing);
        await _trySyncSession(existing);
        return PomodoroSessionMapper.toEntity(existing);
      });

  @override
  Future<Result<PomodoroSession>> linkSessionToTask(
    String sessionId, {
    String? taskId,
    bool clearTaskId = false,
  }) =>
      _guard(() async {
        final existing = await _local.getBySessionId(sessionId);
        if (existing == null) throw const CacheException('Oturum bulunamadı.');
        final now = DateTime.now();
        existing
          ..taskId = clearTaskId ? null : (taskId ?? existing.taskId)
          ..localUpdatedAt = now
          ..syncStatus = PomodoroSyncStatusLocal.pendingUpdate;
        await _local.putSession(existing);
        await _trySyncSession(existing);
        return PomodoroSessionMapper.toEntity(existing);
      });

  @override
  Future<List<PomodoroSession>> getSessionsInRange(DateTime start, DateTime end) async {
    final models = await _local.getSessionsInRange(start, end);
    return models.map(PomodoroSessionMapper.toEntity).toList();
  }

  Future<void> _trySyncSession(PomodoroSessionLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _remote.setSession(model);
      model
        ..syncStatus = PomodoroSyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _local.putSession(model);
    } catch (_) {
      // pending kalır.
    }
  }

  Future<void> _syncFromRemote() async {
    if (!await _connectivity.isConnected) return;
    try {
      final remoteSessions = await _remote.fetchAllSessions();
      for (final remoteSession in remoteSessions) {
        final local = await _local.getBySessionId(remoteSession.sessionId);
        if (local == null || remoteSession.localUpdatedAt.isAfter(local.localUpdatedAt)) {
          await _local.putSession(remoteSession);
        }
      }
      await syncPending();
    } catch (_) {
      // Sessiz — bir sonraki repository örneklenmesinde tekrar denenir.
    }
  }

  /// FAZ 14 — merkezi `SyncCoordinator` tarafından, bağlantı offline→online
  /// geçtiğinde çağrılır. Yalnızca yerelde `pending*` durumda kalan
  /// oturumları Firestore'a göndermeyi dener; `_syncFromRemote` içindeki tek
  /// seferlik "uzaktan çek + LWW eşle" adımını TEKRARLAMAZ.
  @override
  Future<void> syncPending() async {
    if (!await _connectivity.isConnected) return;
    try {
      final pending = await _local.getPendingSync();
      for (final model in pending) {
        await _trySyncSession(model);
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
