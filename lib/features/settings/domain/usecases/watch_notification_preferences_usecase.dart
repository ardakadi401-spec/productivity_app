import '../entities/notification_preferences.dart';
import '../repositories/settings_repository.dart';

/// Settings Screen'in "Bildirimler" bölümü VE Tasks/Habits/Pomodoro'nun
/// `ScheduleNotificationUseCase`'den önceki tercih kontrolü tarafından
/// tüketilir.
class WatchNotificationPreferencesUseCase {
  const WatchNotificationPreferencesUseCase(this._repository);

  final SettingsRepository _repository;

  Stream<NotificationPreferences> call() => _repository.watchNotificationPreferences();
}
