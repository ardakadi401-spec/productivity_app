import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/core/theme/app_theme_mode.dart';
import 'package:productivity_app/core/theme/theme_mode_provider.dart';
import 'package:productivity_app/features/notification/domain/entities/notification_request.dart';
import 'package:productivity_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:productivity_app/features/notification/presentation/providers/notification_providers.dart';
import 'package:productivity_app/features/settings/domain/entities/notification_preferences.dart';
import 'package:productivity_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:productivity_app/features/settings/presentation/pages/settings_page.dart';
import 'package:productivity_app/features/settings/presentation/providers/settings_providers.dart';

/// ROADMAP.md FAZ 13 — "Settings tercih senaryolarını test et." Gerçek
/// Isar/Firestore'a dokunmadan `settingsRepositoryProvider`/
/// `notificationRepositoryProvider`'ı sahte implementasyonlarla override
/// eden Settings Screen widget testleri.
class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository([NotificationPreferences initial = NotificationPreferences.defaults])
      : current = initial,
        _controller = StreamController<NotificationPreferences>.broadcast();

  NotificationPreferences current;
  final StreamController<NotificationPreferences> _controller;
  final List<NotificationPreferences> updateCalls = [];

  // `StreamController.broadcast()` yeni abonelere geçmiş eventleri TEKRAR
  // OYNATMAZ — provider yalnızca widget build edildiğinde abone olduğundan,
  // kurucuda senkron olarak eklenen bir ilk değer kaybolur. `Stream.multi`
  // her yeni dinleyiciye `current`'ı taze olarak iletir (bkz.
  // `FakeAuthRepository.authStateChanges` ile aynı desen).
  @override
  Stream<NotificationPreferences> watchNotificationPreferences() =>
      Stream<NotificationPreferences>.multi((controller) {
        controller.add(current);
        final subscription = _controller.stream.listen(controller.add);
        controller.onCancel = subscription.cancel;
      });

  @override
  Future<Result<void>> updateNotificationPreferences(NotificationPreferences preferences) async {
    updateCalls.add(preferences);
    current = preferences;
    _controller.add(preferences);
    return const Ok(null);
  }
}

class _FakeNotificationRepository implements NotificationRepository {
  bool permissionGranted = true;

  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => permissionGranted;
  @override
  Future<void> scheduleNotification(NotificationRequest request) async {}
  @override
  Future<void> cancelNotification(int id) async {}
  @override
  Stream<String> get notificationTaps => const Stream.empty();
  @override
  Future<String?> getLaunchPayload() async => null;
}

Widget _wrapWithNotificationFakes(_FakeSettingsRepository settings, _FakeNotificationRepository notification) {
  return ProviderScope(
    overrides: [
      settingsRepositoryProvider.overrideWithValue(settings),
      notificationRepositoryProvider.overrideWithValue(notification),
    ],
    child: MaterialApp(theme: AppTheme.light, home: const SettingsPage()),
  );
}

void main() {
  testWidgets('SettingsPage tema seçeneklerini gösterir ve gerçekten state\'i değiştirir', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const SettingsPage()),
      ),
    );

    expect(find.text('Sistem'), findsOneWidget);
    expect(find.text('Açık'), findsOneWidget);
    expect(find.text('Koyu'), findsOneWidget);
    expect(find.text('AMOLED'), findsOneWidget);
    expect(container.read(themeModeProvider), AppThemeMode.system);

    await tester.tap(find.text('AMOLED'));
    await tester.pump();

    expect(container.read(themeModeProvider), AppThemeMode.amoled);
  });

  group('Bildirimler bölümü (ROADMAP FAZ 13)', () {
    testWidgets('genel anahtar kapatıldığında tür bazlı anahtarlar görsel olarak devre dışı kalır', (
      tester,
    ) async {
      final settings = _FakeSettingsRepository();
      final notification = _FakeNotificationRepository();
      await tester.pumpWidget(_wrapWithNotificationFakes(settings, notification));
      await tester.pumpAndSettle();

      SwitchListTile taskTile() =>
          tester.widget<SwitchListTile>(find.widgetWithText(SwitchListTile, 'Görev Hatırlatmaları'));

      expect(taskTile().onChanged, isNotNull);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Bildirimleri Etkinleştir'));
      await tester.pumpAndSettle();

      expect(settings.updateCalls.last.notificationsEnabled, isFalse);
      expect(taskTile().onChanged, isNull);
    });

    testWidgets(
      'genel anahtar açılırken bildirim izni reddedilirse kullanıcı bilgilendirilir, tercih yine de kaydedilir',
      (tester) async {
        final settings = _FakeSettingsRepository(
          const NotificationPreferences(
            notificationsEnabled: false,
            taskRemindersEnabled: true,
            habitRemindersEnabled: true,
            pomodoroNotificationsEnabled: true,
          ),
        );
        final notification = _FakeNotificationRepository()..permissionGranted = false;
        await tester.pumpWidget(_wrapWithNotificationFakes(settings, notification));
        await tester.pumpAndSettle();

        // `pumpAndSettle` kullanılmaz: SnackBar zamanlı (`AppAnimationDurations
        // .snackbarVisible`) otomatik kapanır — `pumpAndSettle` sahte saati bu
        // sürenin ötesine kadar ilerletip SnackBar'ı kaybolmuş halde bırakır.
        // Yalnızca dokunma + async izin kontrolünün tamamlanması için yeterli
        // sayıda tekil `pump()` kullanılır.
        await tester.tap(find.widgetWithText(SwitchListTile, 'Bildirimleri Etkinleştir'));
        await tester.pump();
        await tester.pump();

        expect(
          find.text(
            'Bildirim izni verilmedi — sistem ayarlarından izin vermeden bildirimler gösterilemez.',
          ),
          findsOneWidget,
        );
        expect(settings.updateCalls.last.notificationsEnabled, isTrue);
      },
    );

    testWidgets('tür bazlı bir anahtarı değiştirmek yalnızca o alanı günceller', (tester) async {
      final settings = _FakeSettingsRepository();
      final notification = _FakeNotificationRepository();
      await tester.pumpWidget(_wrapWithNotificationFakes(settings, notification));
      await tester.pumpAndSettle();

      final habitTile = find.widgetWithText(SwitchListTile, 'Alışkanlık Hatırlatmaları');
      await tester.ensureVisible(habitTile);
      await tester.pumpAndSettle();
      await tester.tap(habitTile);
      await tester.pumpAndSettle();

      final updated = settings.updateCalls.single;
      expect(updated.habitRemindersEnabled, isFalse);
      expect(updated.notificationsEnabled, isTrue);
      expect(updated.taskRemindersEnabled, isTrue);
      expect(updated.pomodoroNotificationsEnabled, isTrue);
    });
  });
}
