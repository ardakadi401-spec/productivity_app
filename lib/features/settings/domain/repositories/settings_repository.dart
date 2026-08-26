import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_theme_mode.dart';
import '../entities/notification_preferences.dart';

/// Data katmanının uyması gereken sözleşme — ARCHITECTURE.md Bölüm 6.2.
/// Bildirim tercihlerinin yanı sıra tema tercihinin (DATABASE.md §2.3
/// `themeMode`) kalıcılığını da kapsar — kilit tercihi kasıtlı olarak HARİÇ
/// tutulur (bkz. `LockRepositoryImpl` doc notu: PIN/kilit durumu hiçbir
/// zaman Firestore'a senkronize edilmez, tamamen cihaz-yerel kalır).
abstract interface class SettingsRepository {
  Stream<NotificationPreferences> watchNotificationPreferences();

  Future<Result<void>> updateNotificationPreferences(NotificationPreferences preferences);

  Stream<AppThemeMode> watchThemeMode();

  Future<Result<void>> updateThemeMode(AppThemeMode mode);
}
