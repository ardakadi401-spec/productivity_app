import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme_mode.dart';
import 'package:productivity_app/core/theme/theme_mode_provider.dart';
import 'package:productivity_app/features/settings/domain/entities/notification_preferences.dart';
import 'package:productivity_app/features/settings/domain/entities/pomodoro_duration_settings.dart';
import 'package:productivity_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:productivity_app/features/settings/presentation/providers/settings_providers.dart';

/// Yalnızca `themeModeSyncProvider`'ın hydrate-et/kalıcılığa-yaz köprüsünü
/// izole test etmek için — bildirim tarafı kasıtlı olarak boş bırakılır.
class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository({AppThemeMode initial = AppThemeMode.system}) : _current = initial;

  AppThemeMode _current;
  final List<AppThemeMode> updateCalls = [];

  @override
  Stream<AppThemeMode> watchThemeMode() => Stream.value(_current);

  @override
  Future<Result<void>> updateThemeMode(AppThemeMode mode) async {
    updateCalls.add(mode);
    _current = mode;
    return const Ok(null);
  }

  @override
  Stream<NotificationPreferences> watchNotificationPreferences() => const Stream.empty();

  @override
  Future<Result<void>> updateNotificationPreferences(NotificationPreferences preferences) async =>
      const Ok(null);

  @override
  Stream<PomodoroDurationSettings> watchPomodoroDurationSettings() =>
      Stream.value(PomodoroDurationSettings.defaults);

  @override
  Future<Result<void>> updatePomodoroDurationSettings(PomodoroDurationSettings settings) async =>
      const Ok(null);
}

/// Bekleyen mikrotask zincirlerinin (Stream.value → .first → hydrate())
/// tamamen yerleşmesi için tek bir event-loop turu bekler.
Future<void> pump([int times = 1]) async {
  for (var i = 0; i < times; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('açılışta kalıcı temayı themeModeProvider\'a hydrate eder', () async {
    final fake = _FakeSettingsRepository(initial: AppThemeMode.amoled);
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), AppThemeMode.system);

    container.read(themeModeSyncProvider);
    await pump(3);

    expect(container.read(themeModeProvider), AppThemeMode.amoled);
  });

  test('hydrate sırasında setMode çağrısı kalıcılığa geri yazılmaz (ping-pong olmaz)', () async {
    final fake = _FakeSettingsRepository(initial: AppThemeMode.dark);
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    container.read(themeModeSyncProvider);
    await pump(3);

    expect(container.read(themeModeProvider), AppThemeMode.dark);
    expect(fake.updateCalls, isEmpty);
  });

  test('kullanıcı setMode çağırınca yeni tercih kalıcılığa yazılır', () async {
    final fake = _FakeSettingsRepository();
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    container.read(themeModeSyncProvider);
    await pump(3);

    container.read(themeModeProvider.notifier).setMode(AppThemeMode.light);
    await pump(2);

    expect(fake.updateCalls, [AppThemeMode.light]);
  });
}
