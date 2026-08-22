import '../../../../core/errors/result.dart';
import '../entities/statistics_snapshot.dart';

/// Data katmanının uyması gereken sözleşme — ARCHITECTURE.md Bölüm 6.2.
///
/// Statistics'in KENDİ verisi (statisticsSnapshots koleksiyonu) için bu
/// repository vardır; Tasks/Habits/Pomodoro/Goals verisine erişim ise bu
/// repository ÜZERİNDEN DEĞİL, o feature'ların kendi Domain UseCase'leri
/// üzerinden salt okunur yapılır (STATE_MANAGEMENT.md §2 satır 10 "kendi
/// repository'si yok" — bu yalnızca diğer feature'lar için geçerlidir).
abstract interface class StatisticsSnapshotRepository {
  /// [start]–[end] (kapsayıcı, gün bazlı) aralığındaki mevcut snapshot'ları
  /// tek seferlik döner — eksik günler için `saveSnapshot` çağıranın
  /// sorumluluğundadır (self-healing, `GetPeriodStatsUseCase`).
  Future<List<StatisticsSnapshot>> getSnapshotsInRange(DateTime start, DateTime end);

  /// Bir günün snapshot'ını immutable olarak kaydeder (`snapshotId` tarihten
  /// deterministik türetilir — diğer feature'ların rastgele ID tahsisinden
  /// farklı olarak burada `newXId()` yoktur).
  Future<Result<StatisticsSnapshot>> saveSnapshot(StatisticsSnapshot snapshot);
}
