import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../datasources/local/tag_local_datasource.dart';
import '../datasources/remote/tag_remote_datasource.dart';
import '../mappers/tag_mapper.dart';
import '../models/tag_local_model.dart';

/// ARCHITECTURE.md §6.4 / §8 offline-first akışının somutlaşması — diğer
/// feature'larla aynı desen, minimal tutulmuş (yalnızca oluşturma/listeleme).
///
/// FAZ 14 — `SyncableRepository`'yi de implemente eder. Tags'in bilinçli
/// minimal kapsamı (yalnızca create/list, update/delete YOK) bu FAZ'da
/// GENİŞLETİLMEDİ; `syncPending()` yalnızca mevcut pendingCreate akışını
/// flush eder.
class TagRepositoryImpl implements TagRepository, SyncableRepository {
  TagRepositoryImpl(this._local, this._remote, this._connectivity) {
    unawaited(_syncFromRemote());
  }

  final TagLocalDatasource _local;
  final TagRemoteDatasource _remote;
  final ConnectivityService _connectivity;

  @override
  String newTagId() => _remote.newTagId();

  @override
  Stream<List<Tag>> watchTags() {
    return _local.watchTags().map((models) => models.map(TagMapper.toEntity).toList());
  }

  @override
  Future<Result<Tag>> createTag(Tag tag) => _guard(() async {
        final model = TagMapper.fromEntity(tag, syncStatus: TagSyncStatusLocal.pendingCreate);
        await _local.putTag(model);
        await _trySyncTag(model);
        return TagMapper.toEntity(model);
      });

  Future<void> _trySyncTag(TagLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _remote.setTag(model);
      model
        ..syncStatus = TagSyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _local.putTag(model);
    } catch (_) {
      // pending kalır.
    }
  }

  Future<void> _syncFromRemote() async {
    if (!await _connectivity.isConnected) return;
    try {
      final remoteTags = await _remote.fetchAllTags();
      for (final remoteTag in remoteTags) {
        await _local.putTag(remoteTag);
      }
      await syncPending();
    } catch (_) {
      // Sessiz — bir sonraki repository örneklenmesinde tekrar denenir.
    }
  }

  /// FAZ 14 — merkezi `SyncCoordinator` tarafından, bağlantı offline→online
  /// geçtiğinde çağrılır. Yalnızca yerelde `pending*` durumda kalan
  /// etiketleri Firestore'a göndermeyi dener; `_syncFromRemote` içindeki tek
  /// seferlik "uzaktan çek" adımını TEKRARLAMAZ.
  @override
  Future<void> syncPending() async {
    if (!await _connectivity.isConnected) return;
    try {
      final pending = await _local.getPendingSync();
      for (final model in pending) {
        await _trySyncTag(model);
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
