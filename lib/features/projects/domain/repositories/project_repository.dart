import '../../../../core/errors/result.dart';
import '../entities/project.dart';

/// Data katmanının uyması gereken sözleşme — ARCHITECTURE.md Bölüm 6.2.
///
/// Okuma metotları `Stream` döner (STATE_MANAGEMENT.md §5.2 — Isar üzerinden
/// reaktif). Yazma metotları ARCHITECTURE.md §7.3 gereği `Result` döner.
abstract interface class ProjectRepository {
  /// Ağ çağrısı yapmadan yeni bir proje ID'si tahsis eder (Firestore
  /// client-side doküman ID — offline de çalışır).
  String newProjectId();

  Stream<List<Project>> watchProjects({ProjectStatus? status});

  Stream<Project?> watchProject(String projectId);

  Future<Result<Project>> createProject(Project project);

  Future<Result<Project>> updateProject(Project project);

  Future<Result<Project>> setProjectArchived(String projectId, {required bool isArchived});

  /// `taskCount`/`completedTaskCount` denormalize alanlarını dışarıdan
  /// (Tasks Domain UseCase'i üzerinden hesaplanmış) verilen değerlerle
  /// günceller — DATABASE.md §15.4 "atomic counter update" ile aynı desen
  /// (bkz. Tasks'ın `recalculateTaskProgress`'i).
  Future<Result<Project>> updateProjectProgress(
    String projectId, {
    required int taskCount,
    required int completedTaskCount,
  });
}
