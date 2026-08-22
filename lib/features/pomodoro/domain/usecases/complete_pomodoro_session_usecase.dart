import '../../../../core/errors/result.dart';
import '../entities/pomodoro_session.dart';
import '../repositories/pomodoro_repository.dart';

class CompletePomodoroSessionUseCase {
  const CompletePomodoroSessionUseCase(this._repository);

  final PomodoroRepository _repository;

  Future<Result<PomodoroSession>> call(
    String sessionId, {
    required Duration actualDuration,
    required bool isCompleted,
  }) =>
      _repository.completeSession(sessionId, actualDuration: actualDuration, isCompleted: isCompleted);
}
