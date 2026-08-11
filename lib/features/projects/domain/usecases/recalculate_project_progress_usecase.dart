import '../../../../core/errors/result.dart';
import '../../../tasks/domain/entities/task_filter.dart';
import '../../../tasks/domain/usecases/watch_tasks_usecase.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

/// ARCHITECTURE.md §4 — Projects, Tasks'a yalnızca Domain sözleşmesi
/// (`WatchTasksUseCase`) üzerinden bağımlıdır; Tasks'ın Data katmanına asla
/// doğrudan erişilmez (ARCHITECTURE.md §4.1 "Dashboard → GetTodayTasksUseCase"
/// örneğiyle birebir aynı desen).
///
/// Bir görev oluşturulduğunda/tamamlandığında/silindiğinde/proje
/// değiştirdiğinde, Tasks Presentation katmanı (ör. `CreateTaskController`,
/// `TaskListController`) ilgili proje(ler) için bunu tetikler — Task'ların
/// alt görev ilerlemesini `RecalculateTaskProgressUseCase` ile kendi kendine
/// güncellemesiyle birebir aynı desen.
class RecalculateProjectProgressUseCase {
  const RecalculateProjectProgressUseCase(this._projectRepository, this._watchTasksUseCase);

  final ProjectRepository _projectRepository;
  final WatchTasksUseCase _watchTasksUseCase;

  Future<Result<Project>> call(String projectId) async {
    final tasks = await _watchTasksUseCase(filter: TaskFilter(projectId: projectId)).first;
    final taskCount = tasks.length;
    final completedTaskCount = tasks.where((t) => t.isCompleted).length;
    return _projectRepository.updateProjectProgress(
      projectId,
      taskCount: taskCount,
      completedTaskCount: completedTaskCount,
    );
  }
}
