import '../../../../core/theme/app_theme_mode.dart';
import '../repositories/settings_repository.dart';

/// Kalıcı tema tercihinin (DATABASE.md §2.3 `themeMode`) reaktif okuması —
/// uygulama açılışında `core/theme/theme_mode_provider.dart`'daki oturum içi
/// `themeModeProvider`'ı hydrate etmek için tüketilir.
class WatchThemeModeUseCase {
  const WatchThemeModeUseCase(this._repository);

  final SettingsRepository _repository;

  Stream<AppThemeMode> call() => _repository.watchThemeMode();
}
