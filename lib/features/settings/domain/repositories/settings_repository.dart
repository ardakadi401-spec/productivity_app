import '../../../../core/errors/result.dart';
import '../entities/notification_preferences.dart';

/// Data katmanının uyması gereken sözleşme — ARCHITECTURE.md Bölüm 6.2.
/// Bilinçli olarak minimal: yalnızca FAZ 13'ün ihtiyaç duyduğu bildirim
/// tercihleri kapsanır (kullanıcı talimatı) — tema/kilit tercihi kalıcılığı
/// FAZ 16 kapsamıdır (bkz. `core/theme/theme_mode_provider.dart` doc notu).
abstract interface class SettingsRepository {
  Stream<NotificationPreferences> watchNotificationPreferences();

  Future<Result<void>> updateNotificationPreferences(NotificationPreferences preferences);
}
