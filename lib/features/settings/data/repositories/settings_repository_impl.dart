import 'dart:async';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../../../core/theme/app_theme_mode.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/settings_local_datasource.dart';
import '../datasources/remote/settings_remote_datasource.dart';
import '../models/settings_local_model.dart';

/// ARCHITECTURE.md §6.4 / §8 offline-first akışının somutlaşması — diğer
/// feature'larla aynı desen, tekil satıra uyarlanmış. Çakışma çözümü diğer
/// feature'ların `updatedAt` bazlı Last-Write-Wins'inden farklıdır (tek bir
/// ayar satırı için anlamsız); bunun yerine: yerelde bekleyen (pending)
/// bir değişiklik varsa uzaktaki asla üzerine yazmaz (kullanıcının henüz
/// senkronize olmamış tercihi kaybolmaz), yalnızca hiç yerel kayıt yoksa
/// (örn. yeni cihaz) uzaktan tohumlanır.
///
/// FAZ 14 — `SyncableRepository`'yi de implemente eder; `syncPending()`
/// bu özel "pending ise gönder" mantığını AYNEN korur (Settings için
/// `updatedAt`/LWW anlamsız olduğundan diğer feature'lardan farklı kalır,
/// bilerek).
class SettingsRepositoryImpl implements SettingsRepository, SyncableRepository {
  SettingsRepositoryImpl(this._local, this._remote, this._connectivity) {
    unawaited(_syncFromRemote());
  }

  final SettingsLocalDatasource _local;
  final SettingsRemoteDatasource _remote;
  final ConnectivityService _connectivity;

  @override
  Stream<NotificationPreferences> watchNotificationPreferences() {
    return _local.watch().map((model) => model == null ? NotificationPreferences.defaults : _toEntity(model));
  }

  @override
  Future<Result<void>> updateNotificationPreferences(NotificationPreferences preferences) => _guard(() async {
        final model = await _currentOrDefault();
        final updated = model.copyWith(
          notificationsEnabled: preferences.notificationsEnabled,
          taskRemindersEnabled: preferences.taskRemindersEnabled,
          habitRemindersEnabled: preferences.habitRemindersEnabled,
          pomodoroNotificationsEnabled: preferences.pomodoroNotificationsEnabled,
        );
        await _local.put(updated);
        await _trySyncSettings(updated);
      });

  @override
  Stream<AppThemeMode> watchThemeMode() {
    return _local.watch().map((model) => model == null ? AppThemeMode.system : _themeModeFromModel(model));
  }

  @override
  Future<Result<void>> updateThemeMode(AppThemeMode mode) => _guard(() async {
        final model = await _currentOrDefault();
        final updated = model.copyWith(themeMode: mode.name);
        await _local.put(updated);
        await _trySyncSettings(updated);
      });

  /// Tek satırlık ayar kaydını, hiç yoksa (ör. ilk açılış — henüz ne
  /// bildirim ne tema tercihi kaydedilmiş) tam varsayılanlarla döner —
  /// `copyWith`'in üzerine güvenle inşa edebileceği bir taban sağlar.
  Future<SettingsLocalModel> _currentOrDefault() async {
    return await _local.get() ?? SettingsLocalModel.fromFirestoreSettingsMap(const {});
  }

  NotificationPreferences _toEntity(SettingsLocalModel model) => NotificationPreferences(
        notificationsEnabled: model.notificationsEnabled,
        taskRemindersEnabled: model.taskRemindersEnabled,
        habitRemindersEnabled: model.habitRemindersEnabled,
        pomodoroNotificationsEnabled: model.pomodoroNotificationsEnabled,
      );

  AppThemeMode _themeModeFromModel(SettingsLocalModel model) {
    return AppThemeMode.values.firstWhere(
      (m) => m.name == model.themeMode,
      orElse: () => AppThemeMode.system,
    );
  }

  Future<void> _trySyncSettings(SettingsLocalModel model) async {
    if (!await _connectivity.isConnected) return;
    try {
      await _remote.updatePreferences(model);
      model
        ..syncStatus = SettingsSyncStatusLocal.synced
        ..lastSyncedAt = DateTime.now();
      await _local.put(model);
    } catch (_) {
      // pending kalır.
    }
  }

  Future<void> _syncFromRemote() async {
    if (!await _connectivity.isConnected) return;
    try {
      final existing = await _local.get();
      if (existing == null) {
        final remoteSettings = await _remote.fetchSettingsMap();
        if (remoteSettings != null) {
          await _local.put(SettingsLocalModel.fromFirestoreSettingsMap(remoteSettings));
        }
      } else {
        await syncPending();
      }
    } catch (_) {
      // Sessiz — bir sonraki repository örneklenmesinde tekrar denenir.
    }
  }

  /// FAZ 14 — merkezi `SyncCoordinator` tarafından, bağlantı offline→online
  /// geçtiğinde çağrılır. Yerelde tek satırlık ayar kaydı `synced` değilse
  /// göndermeyi dener; hiç yerel kayıt yoksa (ilk açılış tohumlaması)
  /// hiçbir şey yapmaz — o, yalnızca `_syncFromRemote`'un işidir.
  @override
  Future<void> syncPending() async {
    if (!await _connectivity.isConnected) return;
    try {
      final existing = await _local.get();
      if (existing != null && existing.syncStatus != SettingsSyncStatusLocal.synced) {
        await _trySyncSettings(existing);
      }
    } catch (_) {
      // Sessiz — pending kayıt bir sonraki tetikleyicide tekrar denenir.
    }
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on AppException catch (e) {
      return Err(_mapToFailure(e));
    }
  }

  Failure _mapToFailure(AppException exception) {
    return switch (exception) {
      CacheException(:final message) => CacheFailure(message),
      NetworkException() => const NetworkFailure('Bağlantını kontrol edip tekrar dene.'),
      AuthException() => const AuthFailure('Oturum bulunamadı, lütfen tekrar giriş yap.'),
      _ => UnknownFailure(exception.message),
    };
  }
}
