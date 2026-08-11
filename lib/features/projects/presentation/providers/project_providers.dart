import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/isar_provider.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_filter.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../data/datasources/local/project_local_datasource.dart';
import '../../data/datasources/remote/project_remote_datasource.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/usecases/archive_project_usecase.dart';
import '../../domain/usecases/create_project_usecase.dart';
import '../../domain/usecases/recalculate_project_progress_usecase.dart';
import '../../domain/usecases/update_project_usecase.dart';
import '../../domain/usecases/watch_project_usecase.dart';
import '../../domain/usecases/watch_projects_usecase.dart';

// --- Service / Data katmanı — ARCHITECTURE.md §5.2 ---

final projectLocalDatasourceProvider = Provider<ProjectLocalDatasource>((ref) {
  return ProjectLocalDatasource(ref.watch(isarProvider));
});

final projectRemoteDatasourceProvider = Provider<ProjectRemoteDatasource>((ref) {
  return ProjectRemoteDatasource();
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(
    ref.watch(projectLocalDatasourceProvider),
    ref.watch(projectRemoteDatasourceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

// --- Domain katmanı (UseCase provider'ları) ---

final watchProjectsUseCaseProvider = Provider<WatchProjectsUseCase>((ref) {
  return WatchProjectsUseCase(ref.watch(projectRepositoryProvider));
});

final watchProjectUseCaseProvider = Provider<WatchProjectUseCase>((ref) {
  return WatchProjectUseCase(ref.watch(projectRepositoryProvider));
});

final createProjectUseCaseProvider = Provider<CreateProjectUseCase>((ref) {
  return CreateProjectUseCase(ref.watch(projectRepositoryProvider));
});

final updateProjectUseCaseProvider = Provider<UpdateProjectUseCase>((ref) {
  return UpdateProjectUseCase(ref.watch(projectRepositoryProvider));
});

final archiveProjectUseCaseProvider = Provider<ArchiveProjectUseCase>((ref) {
  return ArchiveProjectUseCase(ref.watch(projectRepositoryProvider));
});

/// ARCHITECTURE.md §4 — Projects, Tasks Domain'ine (`watchTasksUseCaseProvider`)
/// bağımlıdır (tek yönlü, salt okunur); yalnızca Projects'in kendi
/// `ProjectDetailController`'ı tarafından, denormalize `taskCount`/
/// `completedTaskCount` alanlarını arka planda güncel tutmak için çağrılır —
/// Tasks feature'ı bunun varlığından habersizdir (ARCHITECTURE.md §10.2
/// döngüsel bağımlılık önleme kuralı, hiçbir yazma işlemi feature sınırını
/// karşılıklı geçmez).
final recalculateProjectProgressUseCaseProvider = Provider<RecalculateProjectProgressUseCase>((
  ref,
) {
  return RecalculateProjectProgressUseCase(
    ref.watch(projectRepositoryProvider),
    ref.watch(watchTasksUseCaseProvider),
  );
});

// --- Presentation katmanı — reaktif okuma provider'ları ---

/// Projects Screen listesi (SCREENS.md §4.7) — Aktif/Arşivlenmiş filtresi
/// değiştiğinde yeniden dinlenir.
final projectListProvider = StreamProvider.autoDispose.family<List<Project>, ProjectStatus?>((
  ref,
  status,
) {
  return ref.watch(watchProjectsUseCaseProvider).call(status: status);
});

final projectDetailProvider = StreamProvider.autoDispose.family<Project?, String>((ref, projectId) {
  return ref.watch(watchProjectUseCaseProvider).call(projectId);
});

/// Bir projeye bağlı görevlerin CANLI sayımı — ARCHITECTURE.md §4.1 örneğiyle
/// birebir aynı desen (Projects → `WatchTasksUseCase`, salt okunur). Project
/// Card ve Project Detail, ilerleme yüzdesini `Project.taskCount`/
/// `completedTaskCount` (yalnızca son senkronize/yazılmış anlık görüntü)
/// yerine bu canlı akıştan gösterir — bu sayede görev eklenince/tamamlanınca
/// ekran, Tasks feature'ının hiçbir şey yapmasına gerek kalmadan (tek yönlü
/// bağımlılık, ARCHITECTURE.md §10.2 döngüsel bağımlılık önleme kuralı
/// ihlal edilmeden) anında güncellenir.
final projectTaskStatsProvider =
    StreamProvider.autoDispose.family<({int taskCount, int completedTaskCount}), String>((
  ref,
  projectId,
) {
  return ref.watch(watchTasksUseCaseProvider).call(filter: TaskFilter(projectId: projectId)).map(
        (tasks) => (
          taskCount: tasks.length,
          completedTaskCount: tasks.where((t) => t.isCompleted).length,
        ),
      );
});

/// Project Detail Screen'in bağlı görev listesi (SCREENS.md §4.8) —
/// ARCHITECTURE.md §4 Tamamlanma Kriteri "Tasks Domain UseCase'i üzerinden,
/// doğrudan Data erişimi olmadan".
final projectTasksProvider = StreamProvider.autoDispose.family<List<Task>, String>((
  ref,
  projectId,
) {
  return ref.watch(watchTasksUseCaseProvider).call(filter: TaskFilter(projectId: projectId));
});
