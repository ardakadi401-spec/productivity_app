import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/isar_provider.dart';
import '../../../../core/theme/app_theme_mode.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../data/datasources/local/settings_local_datasource.dart';
import '../../data/datasources/remote/settings_remote_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/update_notification_preferences_usecase.dart';
import '../../domain/usecases/update_theme_mode_usecase.dart';
import '../../domain/usecases/watch_notification_preferences_usecase.dart';
import '../../domain/usecases/watch_theme_mode_usecase.dart';

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

final watchThemeModeUseCaseProvider = Provider<WatchThemeModeUseCase>((ref) {
  return WatchThemeModeUseCase(ref.watch(settingsRepositoryProvider));
});

final updateThemeModeUseCaseProvider = Provider<UpdateThemeModeUseCase>((ref) {
  return UpdateThemeModeUseCase(ref.watch(settingsRepositoryProvider));
});

// --- Presentation katmanı — reaktif okuma provider'ı ---

/// Settings Screen'in "Bildirimler" bölümü.
final notificationPreferencesProvider = StreamProvider.autoDispose<NotificationPreferences>((ref) {
  return ref.watch(watchNotificationPreferencesUseCaseProvider).call();
});

/// Uygulama ömrü boyunca canlı tutulması gereken (autoDispose OLMAYAN) tek
/// yönlü köprü: kalıcı tema tercihini `core/theme/theme_mode_provider.dart`
/// içindeki oturum-içi `themeModeProvider`'a hydrate eder ve kullanıcının
/// sonraki her `setMode` çağrısını kalıcılığa geri yazar.
///
/// `core/theme/theme_mode_provider.dart`'ın kendi doc notunun öngördüğü gibi
/// bu köprü BURADA (Settings feature'ında) yaşar, Core'da değil — Core'un
/// Feature'lara bağımlı olmaması gerektiğinden (`ARCHITECTURE.md` Bölüm 15),
/// `themeModeProvider`ın kendisi `core/theme/` altında, cross-cutting UI
/// durumu olarak kalır; kalıcılık bağlantısını YALNIZCA bu, Core'a bağımlı
/// olmasına izin verilen Settings provider'ı kurar. `main.dart`'ta
/// `syncCoordinatorProvider` ile aynı desenle `container.read(...)`
/// edilerek aktive edilir.
final themeModeSyncProvider = Provider<void>((ref) {
  var hydrating = false;

  ref.listen<AppThemeMode>(themeModeProvider, (previous, next) {
    if (hydrating || previous == null || previous == next) return;
    unawaited(ref.read(updateThemeModeUseCaseProvider).call(next));
  });

  Future<void> hydrate() async {
    try {
      final stored = await ref.read(watchThemeModeUseCaseProvider).call().first;
      hydrating = true;
      ref.read(themeModeProvider.notifier).setMode(stored);
    } catch (_) {
      // Sessiz — okunamazsa varsayılan (Sistem) tema korunur.
    } finally {
      hydrating = false;
    }
  }

  unawaited(hydrate());
});
