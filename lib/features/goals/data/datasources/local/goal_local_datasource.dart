import 'package:isar_community/isar.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/goal_local_model.dart';

/// Isar üzerinden Goal CRUD ve reaktif sorgular — ARCHITECTURE.md §6.4
/// offline-first akışının "önce yerele yaz/oku" katmanı. Tüm metotlar
/// `CacheException` fırlatır (Isar I/O hatası — ARCHITECTURE.md §7.4).
class GoalLocalDatasource {
  GoalLocalDatasource(this._isar);

  final Isar _isar;

  Stream<List<GoalLocalModel>> watchGoals() {
    return _guardSync(
      () => _isar.goalLocalModels.filter().isDeletedEqualTo(false).watch(fireImmediately: true),
    );
  }

  Stream<GoalLocalModel?> watchGoal(String goalId) {
    return _guardSync(
      () => _isar.goalLocalModels
          .filter()
          .goalIdEqualTo(goalId)
          .watch(fireImmediately: true)
          .map((results) => results.isEmpty ? null : results.first),
    );
  }

  Future<GoalLocalModel?> getByGoalId(String goalId) async {
    try {
      return await _isar.goalLocalModels.filter().goalIdEqualTo(goalId).findFirst();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<List<GoalLocalModel>> getPendingSync() async {
    try {
      return await _isar.goalLocalModels
          .filter()
          .not()
          .syncStatusEqualTo(GoalSyncStatusLocal.synced)
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> putGoal(GoalLocalModel model) async {
    try {
      await _isar.writeTxn(() => _isar.goalLocalModels.put(model));
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
