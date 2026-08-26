import '../../../../core/errors/result.dart';
import '../entities/pomodoro_duration_settings.dart';
import '../repositories/settings_repository.dart';

/// Kullanıcının Ayarlar ekranında seçtiği Pomodoro varsayılan sürelerini
/// kalıcı hale getirir — yalnızca YENİ oturumları etkiler, o an devam eden
/// bir Pomodoro oturumuna geriye dönük uygulanmaz.
class UpdatePomodoroDurationSettingsUseCase {
  const UpdatePomodoroDurationSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Result<void>> call(PomodoroDurationSettings settings) =>
      _repository.updatePomodoroDurationSettings(settings);
}
