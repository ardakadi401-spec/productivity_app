import '../../domain/entities/statistics_snapshot.dart';
import '../models/statistics_snapshot_local_model.dart';

class StatisticsSnapshotMapper {
  StatisticsSnapshotMapper._();

  static StatisticsSnapshot toEntity(StatisticsSnapshotLocalModel model) {
    return StatisticsSnapshot(
      date: model.date,
      tasksCompleted: model.tasksCompleted,
      tasksCreated: model.tasksCreated,
      habitsCompletedCount: model.habitsCompletedCount,
      habitsTotalCount: model.habitsTotalCount,
      pomodoroSessionsCompleted: model.pomodoroSessionsCompleted,
      pomodoroTotalMinutes: model.pomodoroTotalMinutes,
      createdAt: model.createdAt,
    );
  }

  static StatisticsSnapshotLocalModel fromEntity(
    StatisticsSnapshot snapshot, {
    required StatisticsSyncStatusLocal syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return StatisticsSnapshotLocalModel()
      ..snapshotId = snapshot.snapshotId
      ..date = snapshot.date
      ..tasksCompleted = snapshot.tasksCompleted
      ..tasksCreated = snapshot.tasksCreated
      ..habitsCompletedCount = snapshot.habitsCompletedCount
      ..habitsTotalCount = snapshot.habitsTotalCount
      ..pomodoroSessionsCompleted = snapshot.pomodoroSessionsCompleted
      ..pomodoroTotalMinutes = snapshot.pomodoroTotalMinutes
      ..createdAt = snapshot.createdAt
      ..syncStatus = syncStatus
      ..lastSyncedAt = lastSyncedAt
      ..localUpdatedAt = snapshot.createdAt;
  }
}
