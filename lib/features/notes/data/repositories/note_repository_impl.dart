import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_filter.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/local/note_local_datasource.dart';
import '../datasources/remote/note_remote_datasource.dart';
import '../mappers/note_mapper.dart';
import '../models/note_local_model.dart';

/// ARCHITECTURE.md §6.4 / §8 offline-first akışının somutlaşması —
/// Tasks/Projects/Goals/Habits ile birebir aynı desen.
///
/// FAZ 14 — `SyncableRepository`'yi de implemente eder (Tasks/Habits'teki
/// desenle birebir aynı): merkezi `SyncCoordinator`, bağlantı offline→online
/// geçtiğinde `syncPending()`'i çağırabilir. `NoteRepository` (Domain)
/// BİLEREK değiştirilmedi.
class NoteRepositoryImpl implements NoteRepository, SyncableRepository {
  NoteRepositoryImpl(this._local, this._remote, this._connectivity) {
    unawaited(_syncFromRemote());
  }

  final NoteLocalDatasource _local;
  final NoteRemoteDatasource _remote;
  final ConnectivityService _connectivity;

  @override
  String newNoteId() => _remote.newNoteId();

  @override
  Stream<List<Note>> watchNotes({NoteFilter filter = NoteFilter.none}) {
    return _local.watchNotes().map(
          (models) => _applyFilter(models, filter).map(NoteMapper.toEntity).toList(),
        );
  }

  @override
  Stream<Note?> watchNote(String noteId) {
    return _local.watchNote(noteId).map((m) => m == null ? null : NoteMapper.toEntity(m));
  }

  @override
  Future<Result<Note>> createNote(Note note) => _guard(() async {
        final model = NoteMapper.fromEntity(note, syncStatus: NoteSyncStatusLocal.pendingCreate);
        await _local.putNote(model);
        await _trySyncNote(model);
        return NoteMapper.toEntity(model);
      });

  @override
  Future<Result<Note>> updateNote(Note note) => _guard(() async {
        final model = NoteMapper.fromEntity(note, syncStatus: NoteSyncStatusLocal.pendingUpdate);
        await _local.putNote(model);
        await _trySyncNote(model);
        return NoteMapper.toEntity(model);
      });

  @override
  Future<Result<void>> deleteNote(String noteId) => _guard(() async {
        final existing = await _local.getByNoteId(noteId);
        if (existing == null) throw const CacheException('Not bulunamadı.');
        final now = DateTime.now();
        existing
          ..isDeleted = true
          ..deletedAt = now
          ..updatedAt = now
          ..localUpdatedAt = now
          ..syncStatus = NoteSyncStatusLocal.pendingDelete;
        await _local.putNote(existing);
        await _trySyncNote(existing);
      });

  @override
  Future<Result<Note>> setPinned(String noteId, {required bool isPinned}) => _guard(() async {
        final existing = await _local.getByNoteId(noteId);
        if (existing == null) throw const CacheException('Not bulunamadı.');
        final now = DateTime.now();
        existing
          ..isPinned = isPinned
          ..updatedAt = now
          ..localUpdatedAt = now
          ..syncStatus = NoteSyncStatusLocal.pendingUpdate;
        await _local.putNote(existing);
        await _trySyncNote(existing);
        return NoteMapper.toEntity(existing);
      });

  @override
  Future<Result<Note>> setLink(
    String noteId, {
    String? projectId,
    bool clearProjectId = false,
    String? taskId,
    bool clearTaskId = false,
  }) =>
      _guard(() async {
        final existing = await _local.getByNoteId(noteId);
        if (existing == null) throw const CacheException('Not bulunamadı.');
        final now = DateTime.now();
        existing
          ..projectId = clearProjectId ? null : (projectId ?? existing.projectId)
          ..taskId = clearTaskId ? null : (taskId ?? existing.taskId)
          ..updatedAt = now
          ..localUpdatedAt = now
          ..syncStatus = NoteSyncStatusLocal.pendingUpdate;
        await _local.putNote(existing);
        await _trySyncNote(existing);
        return NoteMapper.toEntity(existing);
      });

  List<NoteLocalModel> _applyFilter(List<NoteLocalModel> models, NoteFilter filter) {
    return models.where((m) {
      if (filter.projectId != null && m.projectId != filter.projectId) return false;
      if (filter.taskId != null && m.taskId != filter.taskId) return false;
      if (filter.tagIds.isNotEmpty && !filter.tagIds.any((tagId) => m.tagIds.contains(tagId))) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _trySyncNote(NoteLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _remote.setNote(model);
      model
        ..syncStatus = NoteSyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _local.putNote(model);
    } catch (_) {
      // pending kalır.
    }
  }

  Future<void> _syncFromRemote() async {
    if (!await _connectivity.isConnected) return;
    try {
      final remoteNotes = await _remote.fetchAllNotes();
      for (final remoteNote in remoteNotes) {
        final local = await _local.getByNoteId(remoteNote.noteId);
        if (local == null || remoteNote.updatedAt.isAfter(local.localUpdatedAt)) {
          await _local.putNote(remoteNote);
        }
      }
      await syncPending();
    } catch (_) {
      // Sessiz — bir sonraki repository örneklenmesinde tekrar denenir.
    }
  }

  /// FAZ 14 — merkezi `SyncCoordinator` tarafından, bağlantı offline→online
  /// geçtiğinde çağrılır. Yalnızca yerelde `pending*` durumda kalan notları
  /// Firestore'a göndermeyi dener; `_syncFromRemote` içindeki tek seferlik
  /// "uzaktan çek + LWW eşle" adımını TEKRARLAMAZ.
  @override
  Future<void> syncPending() async {
    if (!await _connectivity.isConnected) return;
    try {
      final pending = await _local.getPendingSync();
      for (final model in pending) {
        await _trySyncNote(model);
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
