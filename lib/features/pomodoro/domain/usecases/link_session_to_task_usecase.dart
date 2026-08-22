import '../../../../core/errors/result.dart';
import '../entities/pomodoro_session.dart';
import '../repositories/pomodoro_repository.dart';

class LinkSessionToTaskUseCase {
  const LinkSessionToTaskUseCase(this._repository);

  final PomodoroRepository _repository;

  Future<Result<PomodoroSession>> call(
    String sessionId, {
    String? taskId,
    bool clearTaskId = false,
  }) =>
      _repository.linkSessionToTask(sessionId, taskId: taskId, clearTaskId: clearTaskId);
}
