import 'package:isar_community/isar.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/habit_local_model.dart';
import '../../models/habit_record_local_model.dart';

/// Isar üzerinden Habit + HabitRecord CRUD ve reaktif sorgular —
/// ARCHITECTURE.md §6.4 offline-first akışının "önce yerele yaz/oku"
/// katmanı. Tüm metotlar `CacheException` fırlatır (Isar I/O hatası —
/// ARCHITECTURE.md §7.4).
class HabitLocalDatasource {
  HabitLocalDatasource(this._isar);

  final Isar _isar;

  Stream<List<HabitLocalModel>> watchHabits() {
    return _guardSync(
      () => _isar.habitLocalModels.filter().isDeletedEqualTo(false).watch(fireImmediately: true),
    );
  }

  Stream<HabitLocalModel?> watchHabit(String habitId) {
    return _guardSync(
      () => _isar.habitLocalModels
          .filter()
          .habitIdEqualTo(habitId)
          .watch(fireImmediately: true)
          .map((results) => results.isEmpty ? null : results.first),
    );
  }

  Stream<List<HabitRecordLocalModel>> watchHabitRecords(String habitId) {
    return _guardSync(
      () => _isar.habitRecordLocalModels
          .filter()
          .habitIdEqualTo(habitId)
          .sortByDate()
          .watch(fireImmediately: true),
    );
  }

  Future<HabitLocalModel?> getByHabitId(String habitId) async {
    try {
      return await _isar.habitLocalModels.filter().habitIdEqualTo(habitId).findFirst();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<List<HabitRecordLocalModel>> getHabitRecords(String habitId) async {
    try {
      return await _isar.habitRecordLocalModels
          .filter()
          .habitIdEqualTo(habitId)
          .sortByDate()
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  /// Statistics'in dönemsel agregasyonu için — TÜM alışkanlıklar genelinde,
  /// tarih aralığındaki kayıtları TEK bir sorguda döner (habitId bazında N
  /// ayrı sorgu yapmaz, ROADMAP.md FAZ 12 "N+1 sorgudan kaçının" kararı).
  /// Mevcut `watchHabitRecords(habitId)`/`getHabitRecords(habitId)`
  /// davranışını değiştirmez, yalnızca ekler.
  Future<List<HabitRecordLocalModel>> getRecordsInRange(DateTime start, DateTime end) async {
    try {
      return await _isar.habitRecordLocalModels
          .filter()
          .dateBetween(start, end)
          .sortByDate()
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<List<HabitLocalModel>> getPendingSyncHabits() async {
    try {
      return await _isar.habitLocalModels
          .filter()
          .not()
          .syncStatusEqualTo(HabitSyncStatusLocal.synced)
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> putHabit(HabitLocalModel model) async {
    try {
      await _isar.writeTxn(() => _isar.habitLocalModels.put(model));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> putHabitRecord(HabitRecordLocalModel model) async {
    try {
      await _isar.writeTxn(() => _isar.habitRecordLocalModels.put(model));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> deleteHabitRecord(String compositeKey) async {
    try {
      await _isar.writeTxn(
        () => _isar.habitRecordLocalModels.filter().compositeKeyEqualTo(compositeKey).deleteAll(),
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> deleteHabitRecordsForHabit(String habitId) async {
    try {
      await _isar.writeTxn(
        () => _isar.habitRecordLocalModels.filter().habitIdEqualTo(habitId).deleteAll(),
      );
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
