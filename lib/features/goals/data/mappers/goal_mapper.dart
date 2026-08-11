import '../../domain/entities/goal.dart';
import '../models/goal_local_model.dart';

class GoalMapper {
  GoalMapper._();

  static Goal toEntity(GoalLocalModel model) {
    return Goal(
      goalId: model.goalId,
      title: model.title,
      description: model.description,
      periodType: _periodTypeToEntity(model.periodType),
      periodStartDate: model.periodStartDate,
      periodEndDate: model.periodEndDate,
      linkedTaskIds: model.linkedTaskIds,
      progressType: _progressTypeToEntity(model.progressType),
      manualProgress: model.manualProgress,
      status: _statusToEntity(model.status),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Yeni bir [GoalLocalModel] oluşturur — `Isar.autoIncrement` `id` hariç
  /// tüm alanlar entity'den ve senkronizasyon meta bilgisinden doldurulur.
  static GoalLocalModel fromEntity(
    Goal goal, {
    required GoalSyncStatusLocal syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return GoalLocalModel()
      ..goalId = goal.goalId
      ..title = goal.title
      ..description = goal.description
      ..periodType = _periodTypeToLocal(goal.periodType)
      ..periodStartDate = goal.periodStartDate
      ..periodEndDate = goal.periodEndDate
      ..linkedTaskIds = goal.linkedTaskIds
      ..progressType = _progressTypeToLocal(goal.progressType)
      ..manualProgress = goal.manualProgress
      ..status = _statusToLocal(goal.status)
      ..createdAt = goal.createdAt
      ..updatedAt = goal.updatedAt
      ..isDeleted = false
      ..syncStatus = syncStatus
      ..lastSyncedAt = lastSyncedAt
      ..localUpdatedAt = goal.updatedAt;
  }

  static GoalPeriodType _periodTypeToEntity(GoalPeriodTypeLocal p) => switch (p) {
        GoalPeriodTypeLocal.daily => GoalPeriodType.daily,
        GoalPeriodTypeLocal.weekly => GoalPeriodType.weekly,
        GoalPeriodTypeLocal.monthly => GoalPeriodType.monthly,
      };

  static GoalPeriodTypeLocal _periodTypeToLocal(GoalPeriodType p) => switch (p) {
        GoalPeriodType.daily => GoalPeriodTypeLocal.daily,
        GoalPeriodType.weekly => GoalPeriodTypeLocal.weekly,
        GoalPeriodType.monthly => GoalPeriodTypeLocal.monthly,
      };

  static GoalProgressType _progressTypeToEntity(GoalProgressTypeLocal p) => switch (p) {
        GoalProgressTypeLocal.manual => GoalProgressType.manual,
        GoalProgressTypeLocal.linkedTasks => GoalProgressType.linkedTasks,
      };

  static GoalProgressTypeLocal _progressTypeToLocal(GoalProgressType p) => switch (p) {
        GoalProgressType.manual => GoalProgressTypeLocal.manual,
        GoalProgressType.linkedTasks => GoalProgressTypeLocal.linkedTasks,
      };

  static GoalStatus _statusToEntity(GoalStatusLocal s) => switch (s) {
        GoalStatusLocal.inProgress => GoalStatus.inProgress,
        GoalStatusLocal.achieved => GoalStatus.achieved,
        GoalStatusLocal.missed => GoalStatus.missed,
      };

  static GoalStatusLocal _statusToLocal(GoalStatus s) => switch (s) {
        GoalStatus.inProgress => GoalStatusLocal.inProgress,
        GoalStatus.achieved => GoalStatusLocal.achieved,
        GoalStatus.missed => GoalStatusLocal.missed,
      };
}
