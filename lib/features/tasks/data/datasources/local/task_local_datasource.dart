import 'package:isar_community/isar.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/sub_task_local_model.dart';
import '../../models/task_local_model.dart';

/// Isar üzerinden Task + SubTask CRUD ve reaktif sorgular — ARCHITECTURE.md
/// §6.4 offline-first akışının "önce yerele yaz/oku" katmanı. Tüm metotlar
/// `CacheException` fırlatır (Isar I/O hatası — ARCHITECTURE.md §7.4).
class TaskLocalDatasource {
  TaskLocalDatasource(this._isar);

  final Isar _isar;

  Stream<List<TaskLocalModel>> watchTasks() {
    return _guardSync(
      () => _isar.taskLocalModels
          .filter()
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true),
    );
  }

  Stream<TaskLocalModel?> watchTask(String taskId) {
    return _guardSync(
      () => _isar.taskLocalModels
          .filter()
          .taskIdEqualTo(taskId)
          .watch(fireImmediately: true)
          .map((results) => results.isEmpty ? null : results.first),
    );
  }

  Stream<List<SubTaskLocalModel>> watchSubTasks(String taskId) {
    return _guardSync(
      () => _isar.subTaskLocalModels
          .filter()
          .taskIdEqualTo(taskId)
          .sortByOrder()
          .watch(fireImmediately: true),
    );
  }

  Future<TaskLocalModel?> getByTaskId(String taskId) async {
    try {
      return await _isar.taskLocalModels.filter().taskIdEqualTo(taskId).findFirst();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<List<TaskLocalModel>> getPendingSync() async {
    try {
      return await _isar.taskLocalModels
          .filter()
          .not()
          .syncStatusEqualTo(SyncStatusLocal.synced)
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> putTask(TaskLocalModel model) async {
    try {
      await _isar.writeTxn(() => _isar.taskLocalModels.put(model));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<List<SubTaskLocalModel>> getSubTasks(String taskId) async {
    try {
      return await _isar.subTaskLocalModels
          .filter()
          .taskIdEqualTo(taskId)
          .sortByOrder()
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> putSubTask(SubTaskLocalModel model) async {
    try {
      await _isar.writeTxn(() => _isar.subTaskLocalModels.put(model));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<SubTaskLocalModel?> getSubTaskById(String subtaskId) async {
    try {
      return await _isar.subTaskLocalModels.filter().subtaskIdEqualTo(subtaskId).findFirst();
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
