import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_theme_mode.dart';
import '../repositories/settings_repository.dart';

/// Kullanıcının Ayarlar ekranında seçtiği temayı kalıcı hale getirir —
/// oturum içi anlık değişim `themeModeProvider` üzerinden zaten çalışır;
/// bu UseCase yalnızca kalıcılığı (yerel + Firestore) ekler.
class UpdateThemeModeUseCase {
  const UpdateThemeModeUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Result<void>> call(AppThemeMode mode) => _repository.updateThemeMode(mode);
}
