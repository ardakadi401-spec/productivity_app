import '../entities/pomodoro_session.dart';
import '../repositories/pomodoro_repository.dart';

/// ROADMAP.md FAZ 12 — Statistics'in dönemsel agregasyonu (tamamlanan
/// oturum sayısı, toplam odaklanma süresi) tarafından tüketilir.
class GetPomodoroSessionsInRangeUseCase {
  const GetPomodoroSessionsInRangeUseCase(this._repository);

  final PomodoroRepository _repository;

  Future<List<PomodoroSession>> call(DateTime start, DateTime end) =>
      _repository.getSessionsInRange(start, end);
}
