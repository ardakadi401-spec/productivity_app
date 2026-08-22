import '../../../../core/errors/result.dart';
import '../entities/notification_preferences.dart';
import '../repositories/settings_repository.dart';

class UpdateNotificationPreferencesUseCase {
  const UpdateNotificationPreferencesUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Result<void>> call(NotificationPreferences preferences) =>
      _repository.updateNotificationPreferences(preferences);
}
