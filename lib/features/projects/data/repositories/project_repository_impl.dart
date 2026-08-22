import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/local/project_local_datasource.dart';
import '../datasources/remote/project_remote_datasource.dart';
import '../mappers/project_mapper.dart';
import '../models/project_local_model.dart';

/// ARCHITECTURE.md §6.4 / §8 offline-first akışının somutlaşması —
/// `TaskRepositoryImpl` ile birebir aynı desen: her yazma önce Isar'a
/// (anında, `pendingX` işaretiyle) yazılır, bağlantı varsa arka planda
/// Firestore'a gönderilir.
///
/// FAZ 14 — `SyncableRepository`'yi de implemente eder. NOT: PRD.md §233/§370
/// gereği Projects'te manuel silme YOKTUR (yalnızca arşivleme) — bu, FAZ 14
/// kapsamında da eklenmedi; `syncPending()` yalnızca mevcut pendingCreate/
/// pendingUpdate akışını flush eder.
class ProjectRepositoryImpl implements ProjectRepository, SyncableRepository {
  ProjectRepositoryImpl(this._local, this._remote, this._connectivity) {
    unawaited(_syncFromRemote());
  }

  final ProjectLocalDatasource _local;
  final ProjectRemoteDatasource _remote;
  final ConnectivityService _connectivity;

  @override
  String newProjectId() => _remote.newProjectId();

  @override
  Stream<List<Project>> watchProjects({ProjectStatus? status}) {
    return _local.watchProjects().map(
          (models) => models
              .where((m) => status == null || m.status.name == status.name)
              .map(ProjectMapper.toEntity)
              .toList(),
        );
  }

  @override
  Stream<Project?> watchProject(String projectId) {
    return _local
        .watchProject(projectId)
        .map((m) => m == null ? null : ProjectMapper.toEntity(m));
  }

  @override
  Future<Result<Project>> createProject(Project project) => _guard(() async {
        final model =
            ProjectMapper.fromEntity(project, syncStatus: ProjectSyncStatusLocal.pendingCreate);
        await _local.putProject(model);
        await _trySyncProject(model);
        return ProjectMapper.toEntity(model);
      });

  @override
  Future<Result<Project>> updateProject(Project project) => _guard(() async {
        final model =
            ProjectMapper.fromEntity(project, syncStatus: ProjectSyncStatusLocal.pendingUpdate);
        await _local.putProject(model);
        await _trySyncProject(model);
        return ProjectMapper.toEntity(model);
      });

  @override
  Future<Result<Project>> setProjectArchived(String projectId, {required bool isArchived}) =>
      _guard(() async {
        final existing = await _local.getByProjectId(projectId);
        if (existing == null) throw const CacheException('Proje bulunamadı.');
        final now = DateTime.now();
        existing
          ..status = isArchived ? ProjectStatusLocal.archived : ProjectStatusLocal.active
          ..updatedAt = now
          ..localUpdatedAt = now
          ..syncStatus = ProjectSyncStatusLocal.pendingUpdate;
        await _local.putProject(existing);
        await _trySyncProject(existing);
        return ProjectMapper.toEntity(existing);
      });

  @override
  Future<Result<Project>> updateProjectProgress(
    String projectId, {
    required int taskCount,
    required int completedTaskCount,
  }) =>
      _guard(() async {
        final existing = await _local.getByProjectId(projectId);
        if (existing == null) throw const CacheException('Proje bulunamadı.');
        final now = DateTime.now();
        existing
          ..taskCount = taskCount
          ..completedTaskCount = completedTaskCount
          ..updatedAt = now
          ..localUpdatedAt = now
          ..syncStatus = ProjectSyncStatusLocal.pendingUpdate;
        await _local.putProject(existing);
        await _trySyncProject(existing);
        return ProjectMapper.toEntity(existing);
      });

  /// Bağlantı varsa Firestore'a gönderir; başarısız olursa sessizce
  /// `pending` bırakır (ARCHITECTURE.md §8.2).
  Future<void> _trySyncProject(ProjectLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _remote.setProject(model);
      model
        ..syncStatus = ProjectSyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _local.putProject(model);
    } catch (_) {
      // pending kalır.
    }
  }

  /// DATABASE.md §12.4 — bir kerelik uzaktan çekme + Last-Write-Wins eşleme,
  /// ardından yerelde hâlâ `pending*` olan kayıtları göndermeyi dener.
  Future<void> _syncFromRemote() async {
    if (!await _connectivity.isConnected) return;
    try {
      final remoteProjects = await _remote.fetchAllProjects();
      for (final remoteProject in remoteProjects) {
        final local = await _local.getByProjectId(remoteProject.projectId);
        if (local == null || remoteProject.updatedAt.isAfter(local.localUpdatedAt)) {
          await _local.putProject(remoteProject);
        }
      }
      await syncPending();
    } catch (_) {
      // Sessiz — bir sonraki repository örneklenmesinde tekrar denenir.
    }
  }

  /// FAZ 14 — merkezi `SyncCoordinator` tarafından, bağlantı offline→online
  /// geçtiğinde çağrılır. Yalnızca yerelde `pending*` durumda kalan projeleri
  /// Firestore'a göndermeyi dener; `_syncFromRemote` içindeki tek seferlik
  /// "uzaktan çek + LWW eşle" adımını TEKRARLAMAZ.
  @override
  Future<void> syncPending() async {
    if (!await _connectivity.isConnected) return;
    try {
      final pending = await _local.getPendingSync();
      for (final model in pending) {
        await _trySyncProject(model);
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
