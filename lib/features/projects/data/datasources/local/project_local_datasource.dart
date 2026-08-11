import 'package:isar_community/isar.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/project_local_model.dart';

/// Isar üzerinden Project CRUD ve reaktif sorgular — ARCHITECTURE.md §6.4
/// offline-first akışının "önce yerele yaz/oku" katmanı. Tüm metotlar
/// `CacheException` fırlatır (Isar I/O hatası — ARCHITECTURE.md §7.4).
class ProjectLocalDatasource {
  ProjectLocalDatasource(this._isar);

  final Isar _isar;

  Stream<List<ProjectLocalModel>> watchProjects() {
    return _guardSync(
      () => _isar.projectLocalModels
          .filter()
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true),
    );
  }

  Stream<ProjectLocalModel?> watchProject(String projectId) {
    return _guardSync(
      () => _isar.projectLocalModels
          .filter()
          .projectIdEqualTo(projectId)
          .watch(fireImmediately: true)
          .map((results) => results.isEmpty ? null : results.first),
    );
  }

  Future<ProjectLocalModel?> getByProjectId(String projectId) async {
    try {
      return await _isar.projectLocalModels.filter().projectIdEqualTo(projectId).findFirst();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<List<ProjectLocalModel>> getPendingSync() async {
    try {
      return await _isar.projectLocalModels
          .filter()
          .not()
          .syncStatusEqualTo(ProjectSyncStatusLocal.synced)
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> putProject(ProjectLocalModel model) async {
    try {
      await _isar.writeTxn(() => _isar.projectLocalModels.put(model));
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
