import 'package:isar_community/isar.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/tag_local_model.dart';

/// Isar üzerinden Tag CRUD ve reaktif sorgular — ARCHITECTURE.md §6.4
/// offline-first akışının "önce yerele yaz/oku" katmanı.
class TagLocalDatasource {
  TagLocalDatasource(this._isar);

  final Isar _isar;

  Stream<List<TagLocalModel>> watchTags() {
    return _guardSync(() => _isar.tagLocalModels.where().watch(fireImmediately: true));
  }

  Future<List<TagLocalModel>> getPendingSync() async {
    try {
      return await _isar.tagLocalModels
          .filter()
          .not()
          .syncStatusEqualTo(TagSyncStatusLocal.synced)
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> putTag(TagLocalModel model) async {
    try {
      await _isar.writeTxn(() => _isar.tagLocalModels.put(model));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Stream<T> _guardSync<T>(Stream<T> Function() query) {
    try {
      return query();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
