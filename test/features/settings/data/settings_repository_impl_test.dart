import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/exceptions/app_exceptions.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/features/settings/data/datasources/local/settings_local_datasource.dart';
import 'package:productivity_app/features/settings/data/datasources/remote/settings_remote_datasource.dart';
import 'package:productivity_app/features/settings/data/models/settings_local_model.dart';
import 'package:productivity_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:productivity_app/core/theme/app_theme_mode.dart';
import 'package:productivity_app/features/settings/domain/entities/notification_preferences.dart';
import 'package:productivity_app/features/settings/domain/entities/pomodoro_duration_settings.dart';

class _MockLocal extends Mock implements SettingsLocalDatasource {}

class _MockRemote extends Mock implements SettingsRemoteDatasource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

SettingsLocalModel _model({
  bool notificationsEnabled = true,
  String themeMode = 'system',
  int pomodoroWorkDurationMinutes = 25,
  int pomodoroBreakDurationMinutes = 5,
  SettingsSyncStatusLocal syncStatus = SettingsSyncStatusLocal.synced,
}) {
  final now = DateTime(2026, 1, 1);
  return SettingsLocalModel()
    ..notificationsEnabled = notificationsEnabled
    ..taskRemindersEnabled = true
    ..habitRemindersEnabled = true
    ..pomodoroNotificationsEnabled = true
    ..themeMode = themeMode
    ..pomodoroWorkDurationMinutes = pomodoroWorkDurationMinutes
    ..pomodoroBreakDurationMinutes = pomodoroBreakDurationMinutes
    ..syncStatus = syncStatus
    ..localUpdatedAt = now;
}

void main() {
  late _MockLocal local;
  late _MockRemote remote;
  late _MockConnectivity connectivity;
  late SettingsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_model());
  });

  setUp(() {
    local = _MockLocal();
    remote = _MockRemote();
    connectivity = _MockConnectivity();
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    when(() => local.get()).thenAnswer((_) async => _model());
    repository = SettingsRepositoryImpl(local, remote, connectivity);
  });

  test('watchNotificationPreferences kayıt yoksa varsayılanları döner', () async {
    when(() => local.watch()).thenAnswer((_) => Stream.value(null));

    final result = await repository.watchNotificationPreferences().first;

    expect(result.notificationsEnabled, NotificationPreferences.defaults.notificationsEnabled);
  });

  test('watchNotificationPreferences yerel kaydı entity\'ye eşler', () async {
    when(() => local.watch()).thenAnswer((_) => Stream.value(_model(notificationsEnabled: false)));

    final result = await repository.watchNotificationPreferences().first;

    expect(result.notificationsEnabled, isFalse);
  });

  group('updateNotificationPreferences', () {
    test('bağlantı yokken yalnızca yerele pendingUpdate ile yazar, remote çağrılmaz', () async {
      when(() => local.put(any())).thenAnswer((_) async {});

      final result = await repository.updateNotificationPreferences(NotificationPreferences.defaults);

      expect(result, isA<Ok<void>>());
      final captured = verify(() => local.put(captureAny())).captured.single as SettingsLocalModel;
      expect(captured.syncStatus, SettingsSyncStatusLocal.pendingUpdate);
      verifyNever(() => remote.updatePreferences(any()));
    });

    test('bağlantı varken yerele yazar, remote\'a gönderir, ardından synced işaretler', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.put(any())).thenAnswer((_) async {});
      when(() => remote.updatePreferences(any())).thenAnswer((_) async {});

      await repository.updateNotificationPreferences(NotificationPreferences.defaults);

      verify(() => remote.updatePreferences(any())).called(1);
      final calls = verify(() => local.put(captureAny())).captured.cast<SettingsLocalModel>();
      expect(calls.last.syncStatus, SettingsSyncStatusLocal.synced);
    });

    test('remote gönderimi başarısız olursa kayıt pending kalır ama Ok döner', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.put(any())).thenAnswer((_) async {});
      when(() => remote.updatePreferences(any())).thenThrow(const NetworkException('boom'));

      final result = await repository.updateNotificationPreferences(NotificationPreferences.defaults);

      expect(result, isA<Ok<void>>());
      final calls = verify(() => local.put(captureAny())).captured.cast<SettingsLocalModel>();
      expect(calls.last.syncStatus, SettingsSyncStatusLocal.pendingUpdate);
    });

    test('yerel yazma CacheException fırlatırsa Err(CacheFailure) döner', () async {
      when(() => local.put(any())).thenThrow(const CacheException('disk dolu'));

      final result = await repository.updateNotificationPreferences(NotificationPreferences.defaults);

      expect(result, isA<Err<void>>());
      expect((result as Err).failure, isA<CacheFailure>());
    });

    test('mevcut themeMode\'u sıfırlamaz/kaybetmez (read-modify-write regresyonu)', () async {
      when(() => local.get()).thenAnswer((_) async => _model(themeMode: 'amoled'));
      when(() => local.put(any())).thenAnswer((_) async {});

      await repository.updateNotificationPreferences(NotificationPreferences.defaults);

      final captured = verify(() => local.put(captureAny())).captured.single as SettingsLocalModel;
      expect(captured.themeMode, 'amoled');
    });
  });

  group('watchThemeMode', () {
    test('kayıt yoksa system döner', () async {
      when(() => local.watch()).thenAnswer((_) => Stream.value(null));

      final result = await repository.watchThemeMode().first;

      expect(result, AppThemeMode.system);
    });

    test('yerel kaydı AppThemeMode\'a eşler', () async {
      when(() => local.watch()).thenAnswer((_) => Stream.value(_model(themeMode: 'amoled')));

      final result = await repository.watchThemeMode().first;

      expect(result, AppThemeMode.amoled);
    });
  });

  group('updateThemeMode', () {
    test('mevcut bildirim tercihlerini sıfırlamaz/kaybetmez, yalnızca themeMode\'u değiştirir', () async {
      when(() => local.get()).thenAnswer((_) async => _model(notificationsEnabled: false));
      when(() => local.put(any())).thenAnswer((_) async {});

      final result = await repository.updateThemeMode(AppThemeMode.dark);

      expect(result, isA<Ok<void>>());
      final captured = verify(() => local.put(captureAny())).captured.single as SettingsLocalModel;
      expect(captured.themeMode, 'dark');
      expect(captured.notificationsEnabled, isFalse);
    });
  });

  group('watchPomodoroDurationSettings', () {
    test('kayıt yoksa varsayılanları (25/5) döner', () async {
      when(() => local.watch()).thenAnswer((_) => Stream.value(null));

      final result = await repository.watchPomodoroDurationSettings().first;

      expect(result.workMinutes, PomodoroDurationSettings.defaults.workMinutes);
      expect(result.breakMinutes, PomodoroDurationSettings.defaults.breakMinutes);
    });

    test('yerel kaydı PomodoroDurationSettings\'e eşler', () async {
      when(() => local.watch()).thenAnswer(
        (_) => Stream.value(_model(pomodoroWorkDurationMinutes: 45, pomodoroBreakDurationMinutes: 15)),
      );

      final result = await repository.watchPomodoroDurationSettings().first;

      expect(result.workMinutes, 45);
      expect(result.breakMinutes, 15);
    });
  });

  group('updatePomodoroDurationSettings', () {
    test('mevcut temayı sıfırlamaz/kaybetmez, yalnızca süreleri değiştirir', () async {
      when(() => local.get()).thenAnswer((_) async => _model(themeMode: 'amoled'));
      when(() => local.put(any())).thenAnswer((_) async {});

      final result = await repository.updatePomodoroDurationSettings(
        const PomodoroDurationSettings(workMinutes: 45, breakMinutes: 15),
      );

      expect(result, isA<Ok<void>>());
      final captured = verify(() => local.put(captureAny())).captured.single as SettingsLocalModel;
      expect(captured.pomodoroWorkDurationMinutes, 45);
      expect(captured.pomodoroBreakDurationMinutes, 15);
      expect(captured.themeMode, 'amoled');
    });
  });

  group('syncPending — FAZ 14 (SyncCoordinator giriş noktası)', () {
    test('offline durumda hiçbir şey yapmaz', () async {
      await Future<void>.delayed(Duration.zero);

      await repository.syncPending();

      verifyNever(() => remote.updatePreferences(any()));
    });

    test('yerel kayıt zaten synced ise hiçbir şey göndermez', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.get()).thenAnswer((_) async => _model(syncStatus: SettingsSyncStatusLocal.synced));

      await repository.syncPending();

      verifyNever(() => remote.updatePreferences(any()));
    });

    test('yerel kayıt pendingUpdate ise online olduğunda gönderir ve synced yapar', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: SettingsSyncStatusLocal.pendingUpdate);
      when(() => local.get()).thenAnswer((_) async => pendingModel);
      when(() => remote.updatePreferences(any())).thenAnswer((_) async {});
      when(() => local.put(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verify(() => remote.updatePreferences(pendingModel)).called(1);
      final captured = verify(() => local.put(captureAny())).captured.single as SettingsLocalModel;
      expect(captured.syncStatus, SettingsSyncStatusLocal.synced);
    });

    test('remote gönderimi hata verirse kayıt pending kalır', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: SettingsSyncStatusLocal.pendingUpdate);
      when(() => local.get()).thenAnswer((_) async => pendingModel);
      when(() => remote.updatePreferences(any())).thenThrow(const NetworkException('boom'));

      await repository.syncPending();

      verifyNever(() => local.put(any()));
      expect(pendingModel.syncStatus, SettingsSyncStatusLocal.pendingUpdate);
    });
  });
}
