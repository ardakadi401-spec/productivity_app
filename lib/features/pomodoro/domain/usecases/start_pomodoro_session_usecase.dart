import '../../../../core/errors/result.dart';
import '../entities/pomodoro_session.dart';
import '../repositories/pomodoro_repository.dart';

class StartPomodoroSessionUseCase {
  const StartPomodoroSessionUseCase(this._repository);

  final PomodoroRepository _repository;

  Future<Result<PomodoroSession>> call(PomodoroSession session) => _repository.createSession(session);
}
