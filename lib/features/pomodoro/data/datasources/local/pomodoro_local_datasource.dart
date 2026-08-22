import 'package:isar_community/isar.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/pomodoro_session_local_model.dart';

/// Isar üzerinden PomodoroSession CRUD ve reaktif sorgular —
/// ARCHITECTURE.md §6.4 offline-first akışının "önce yerele yaz/oku"
/// katmanı. Bu koleksiyonda soft delete/silme akışı yok (DATABASE §13.4
/// istisnası), bu yüzden `watchSessionsByTask` herhangi bir `isDeleted`
/// filtresi taşımaz.
class PomodoroLocalDatasource {
  PomodoroLocalDatasource(this._isar);

  final Isar _isar;

  Stream<List<PomodoroSessionLocalModel>> watchSessionsByTask(String taskId) {
    return _guardSync(
      () => _isar.pomodoroSessionLocalModels
          .filter()
          .taskIdEqualTo(taskId)
          .sortByStartedAtDesc()
          .watch(fireImmediately: true),
    );
  }

  /// Statistics'in dönemsel agregasyonu için — TÜM oturumlar genelinde
  /// (görev bazlı filtre olmadan), `startedAt` tarih aralığındaki kayıtları
  /// TEK bir sorguda döner (ROADMAP.md FAZ 12 "N+1 sorgudan kaçının"
  /// kararı). Mevcut `watchSessionsByTask` davranışını değiştirmez.
  Future<List<PomodoroSessionLocalModel>> getSessionsInRange(DateTime start, DateTime end) async {
    try {
      return await _isar.pomodoroSessionLocalModels
          .filter()
          .startedAtBetween(start, end)
          .sortByStartedAt()
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<PomodoroSessionLocalModel?> getBySessionId(String sessionId) async {
    try {
      return await _isar.pomodoroSessionLocalModels.filter().sessionIdEqualTo(sessionId).findFirst();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<List<PomodoroSessionLocalModel>> getPendingSync() async {
    try {
      return await _isar.pomodoroSessionLocalModels
          .filter()
          .not()
          .syncStatusEqualTo(PomodoroSyncStatusLocal.synced)
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> putSession(PomodoroSessionLocalModel model) async {
    try {
      await _isar.writeTxn(() => _isar.pomodoroSessionLocalModels.put(model));
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
