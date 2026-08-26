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

  /// Kalıcı (soft-delete) silme — DATABASE.md §13.1 ile aynı desen
  /// (Task/Note/Habit'te zaten var olan). Bağlı görevler ETKİLENMEZ —
  /// `projectId` alanları olduğu gibi kalır; Task Detail'in proje rozeti
  /// zaten `null` bir proje karşısında sessizce gizlenir (bkz.
  /// `_LinkedProjectChip`), bu yüzden Projects → Tasks yazma bağımlılığı
  /// gerektiren bir cascade/unlink işlemine ihtiyaç yoktur (ARCHITECTURE.md
  /// §10.2 tek yönlü okuma kuralını korur).
  Future<Result<void>> deleteProject(String projectId);

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
