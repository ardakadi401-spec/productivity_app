import '../entities/pomodoro_session.dart';
import '../repositories/pomodoro_repository.dart';

/// Task Detail Screen'in oturum geçmişi (SCREENS.md §4.10) tarafından
/// tüketilir.
class WatchPomodoroSessionsByTaskUseCase {
  const WatchPomodoroSessionsByTaskUseCase(this._repository);

  final PomodoroRepository _repository;

  Stream<List<PomodoroSession>> call(String taskId) => _repository.watchSessionsByTask(taskId);
}
