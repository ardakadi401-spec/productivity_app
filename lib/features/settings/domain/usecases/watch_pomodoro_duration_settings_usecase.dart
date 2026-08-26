import '../entities/pomodoro_duration_settings.dart';
import '../repositories/settings_repository.dart';

/// Kalıcı Pomodoro varsayılan sürelerinin (DATABASE.md §2.3
/// `pomodoroWorkDuration`/`pomodoroBreakDuration`) reaktif okuması —
/// Settings Screen'in "Pomodoro" bölümü ve `PomodoroTimerController.build()`
/// (yeni oturum başlangıç değeri) tarafından tüketilir.
class WatchPomodoroDurationSettingsUseCase {
  const WatchPomodoroDurationSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Stream<PomodoroDurationSettings> call() => _repository.watchPomodoroDurationSettings();
}
