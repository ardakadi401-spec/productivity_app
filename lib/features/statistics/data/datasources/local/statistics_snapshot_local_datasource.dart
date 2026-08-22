import 'package:isar_community/isar.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/statistics_snapshot_local_model.dart';

/// Isar üzerinden StatisticsSnapshot okuma/yazma — ARCHITECTURE.md §6.4
/// offline-first akışının "önce yerele yaz/oku" katmanı. Bu koleksiyonda
/// güncelleme/silme akışı yok (immutable, DATABASE §10.1), bu yüzden yalnızca
/// `put` (ilk oluşturma) ve aralık sorgusu vardır.
class StatisticsSnapshotLocalDatasource {
  StatisticsSnapshotLocalDatasource(this._isar);

  final Isar _isar;

  Future<List<StatisticsSnapshotLocalModel>> getSnapshotsInRange(DateTime start, DateTime end) async {
    try {
      return await _isar.statisticsSnapshotLocalModels
          .filter()
          .dateBetween(start, end)
          .sortByDate()
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<StatisticsSnapshotLocalModel?> getBySnapshotId(String snapshotId) async {
    try {
      return await _isar.statisticsSnapshotLocalModels
          .filter()
          .snapshotIdEqualTo(snapshotId)
          .findFirst();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<List<StatisticsSnapshotLocalModel>> getPendingSync() async {
    try {
      return await _isar.statisticsSnapshotLocalModels
          .filter()
          .not()
          .syncStatusEqualTo(StatisticsSyncStatusLocal.synced)
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> putSnapshot(StatisticsSnapshotLocalModel model) async {
    try {
      await _isar.writeTxn(() => _isar.statisticsSnapshotLocalModels.put(model));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  /// DATABASE.md §12.3 — "son N dönem yerelde tutulur, daha eskisi talep
  /// üzerine Firestore'dan çekilir" retention sınırı. Yalnızca ZATEN
  /// senkronize (`synced`) kayıtlar silinir — Firestore'a henüz gönderilmemiş
  /// (`pendingCreate`/`error`) bir kayıt asla budanmaz, veri kaybı olmaz.
  Future<void> pruneSyncedOlderThan(DateTime cutoff) async {
    try {
      await _isar.writeTxn(
        () => _isar.statisticsSnapshotLocalModels
            .filter()
            .syncStatusEqualTo(StatisticsSyncStatusLocal.synced)
            .dateLessThan(cutoff)
            .deleteAll(),
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
