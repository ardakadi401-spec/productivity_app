import '../../domain/entities/project.dart';
import '../models/project_local_model.dart';

class ProjectMapper {
  ProjectMapper._();

  static Project toEntity(ProjectLocalModel model) {
    return Project(
      projectId: model.projectId,
      title: model.title,
      description: model.description,
      color: model.color,
      icon: model.icon,
      status: _statusToEntity(model.status),
      taskCount: model.taskCount,
      completedTaskCount: model.completedTaskCount,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Yeni bir [ProjectLocalModel] oluşturur — `Isar.autoIncrement` `id`
  /// hariç tüm alanlar entity'den ve senkronizasyon meta bilgisinden
  /// doldurulur.
  static ProjectLocalModel fromEntity(
    Project project, {
    required ProjectSyncStatusLocal syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return ProjectLocalModel()
      ..projectId = project.projectId
      ..title = project.title
      ..description = project.description
      ..color = project.color
      ..icon = project.icon
      ..status = _statusToLocal(project.status)
      ..taskCount = project.taskCount
      ..completedTaskCount = project.completedTaskCount
      ..createdAt = project.createdAt
      ..updatedAt = project.updatedAt
      ..isDeleted = false
      ..syncStatus = syncStatus
      ..lastSyncedAt = lastSyncedAt
      ..localUpdatedAt = project.updatedAt;
  }

  static ProjectStatus _statusToEntity(ProjectStatusLocal s) => switch (s) {
        ProjectStatusLocal.active => ProjectStatus.active,
        ProjectStatusLocal.archived => ProjectStatus.archived,
      };

  static ProjectStatusLocal _statusToLocal(ProjectStatus s) => switch (s) {
        ProjectStatus.active => ProjectStatusLocal.active,
        ProjectStatus.archived => ProjectStatusLocal.archived,
      };
}
