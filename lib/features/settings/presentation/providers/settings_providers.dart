import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/isar_provider.dart';
import '../../data/datasources/local/settings_local_datasource.dart';
import '../../data/datasources/remote/settings_remote_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/update_notification_preferences_usecase.dart';
import '../../domain/usecases/watch_notification_preferences_usecase.dart';

// --- Service / Data katmanı — ARCHITECTURE.md §5.2 ---

final settingsLocalDatasourceProvider = Provider<SettingsLocalDatasource>((ref) {
  return SettingsLocalDatasource(ref.watch(isarProvider));
});

final settingsRemoteDatasourceProvider = Provider<SettingsRemoteDatasource>((ref) {
  return SettingsRemoteDatasource();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    ref.watch(settingsLocalDatasourceProvider),
    ref.watch(settingsRemoteDatasourceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

// --- Domain katmanı (UseCase provider'ları) ---

final watchNotificationPreferencesUseCaseProvider = Provider<WatchNotificationPreferencesUseCase>((ref) {
  return WatchNotificationPreferencesUseCase(ref.watch(settingsRepositoryProvider));
});

final updateNotificationPreferencesUseCaseProvider = Provider<UpdateNotificationPreferencesUseCase>((ref) {
  return UpdateNotificationPreferencesUseCase(ref.watch(settingsRepositoryProvider));
});

// --- Presentation katmanı — reaktif okuma provider'ı ---

/// Settings Screen'in "Bildirimler" bölümü.
final notificationPreferencesProvider = StreamProvider.autoDispose<NotificationPreferences>((ref) {
  return ref.watch(watchNotificationPreferencesUseCaseProvider).call();
});
