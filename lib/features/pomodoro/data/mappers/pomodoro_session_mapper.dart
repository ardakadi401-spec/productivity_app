import '../../domain/entities/pomodoro_session.dart';
import '../models/pomodoro_session_local_model.dart';

class PomodoroSessionMapper {
  PomodoroSessionMapper._();

  static PomodoroSession toEntity(PomodoroSessionLocalModel model) {
    return PomodoroSession(
      sessionId: model.sessionId,
      taskId: model.taskId,
      type: _typeToEntity(model.type),
      plannedDuration: Duration(seconds: model.plannedDurationSeconds),
      actualDuration: Duration(seconds: model.actualDurationSeconds),
      startedAt: model.startedAt,
      completedAt: model.completedAt,
      isCompleted: model.isCompleted,
    );
  }

  /// Yeni bir [PomodoroSessionLocalModel] oluşturur — `Isar.autoIncrement`
  /// `id` hariç tüm alanlar entity'den ve senkronizasyon meta bilgisinden
  /// doldurulur.
  static PomodoroSessionLocalModel fromEntity(
    PomodoroSession session, {
    required PomodoroSyncStatusLocal syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return PomodoroSessionLocalModel()
      ..sessionId = session.sessionId
      ..taskId = session.taskId
      ..type = _typeToLocal(session.type)
      ..plannedDurationSeconds = session.plannedDuration.inSeconds
      ..actualDurationSeconds = session.actualDuration.inSeconds
      ..startedAt = session.startedAt
      ..completedAt = session.completedAt
      ..isCompleted = session.isCompleted
      ..syncStatus = syncStatus
      ..lastSyncedAt = lastSyncedAt
      ..localUpdatedAt = session.completedAt ?? session.startedAt;
  }

  static PomodoroSessionType _typeToEntity(PomodoroSessionTypeLocal t) => switch (t) {
        PomodoroSessionTypeLocal.work => PomodoroSessionType.work,
        PomodoroSessionTypeLocal.breakTime => PomodoroSessionType.breakTime,
      };

  static PomodoroSessionTypeLocal _typeToLocal(PomodoroSessionType t) => switch (t) {
        PomodoroSessionType.work => PomodoroSessionTypeLocal.work,
        PomodoroSessionType.breakTime => PomodoroSessionTypeLocal.breakTime,
      };
}
