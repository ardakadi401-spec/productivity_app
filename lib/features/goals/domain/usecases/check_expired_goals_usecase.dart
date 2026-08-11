import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_filter.dart';
import '../../../tasks/domain/usecases/watch_tasks_usecase.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

/// ROADMAP.md FAZ 8 "Dönem sonu otomatik arşivleme" — dönemi dolmuş
/// (`periodEndDate` geçmişte kalmış) `inProgress` hedefleri tarar ve
/// `achieved`/`missed` olarak işaretler.
///
/// ROADMAP'in belirttiği "çift mekanizma" (hem periyodik hem uygulama
/// açılışında) riskini karşılamak için bu UseCase iki ayrı çağrı noktasından
/// tetiklenir: `GoalListController` (Goals Screen her açıldığında) ve
/// Dashboard'un öne çıkan hedef provider'ı (uygulama açılışında, Dashboard
/// ilk ekran olduğundan) — bkz. `goal_providers.dart`. Çağrı idempotenttir
/// (süresi geçmiş hedef yoksa no-op).
///
/// ARCHITECTURE.md §4 — Goals, Tasks Domain'ine (`WatchTasksUseCase`) tek
/// yönlü, salt okunur bağımlıdır (yalnızca `linkedTasks` tipi hedeflerin
/// başarı durumunu belirlemek için).
class CheckExpiredGoalsUseCase {
  const CheckExpiredGoalsUseCase(this._goalRepository, this._watchTasksUseCase);

  final GoalRepository _goalRepository;
  final WatchTasksUseCase _watchTasksUseCase;

  Future<void> call() async {
    final goals = await _goalRepository.watchGoals().first;
    final now = DateTime.now();
    final expired = goals
        .where((g) => g.status == GoalStatus.inProgress && g.periodEndDate.isBefore(now))
        .toList();
    if (expired.isEmpty) return;

    final needsTasks = expired.any((g) => g.progressType == GoalProgressType.linkedTasks);
    final tasks = needsTasks ? await _watchTasksUseCase(filter: TaskFilter.none).first : const <Task>[];

    for (final goal in expired) {
      final achieved = _isAchieved(goal, tasks);
      await _goalRepository.setGoalStatus(
        goal.goalId,
        status: achieved ? GoalStatus.achieved : GoalStatus.missed,
      );
    }
  }

  bool _isAchieved(Goal goal, List<Task> allTasks) {
    if (goal.progressType == GoalProgressType.manual) {
      return (goal.manualProgress ?? 0) >= 100;
    }
    if (goal.linkedTaskIds.isEmpty) return false;
    final linked = allTasks.where((t) => goal.linkedTaskIds.contains(t.taskId));
    return linked.isNotEmpty && linked.every((t) => t.isCompleted);
  }
}
