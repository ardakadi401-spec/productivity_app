import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:productivity_app/features/settings/data/datasources/local/settings_local_datasource.dart';
import 'package:productivity_app/features/settings/data/models/settings_local_model.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late SettingsLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('isar_settings_test');
    isar = await Isar.open([SettingsLocalModelSchema], directory: tempDir.path);
    datasource = SettingsLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  SettingsLocalModel model({
    bool notificationsEnabled = true,
    bool taskRemindersEnabled = true,
    bool habitRemindersEnabled = true,
    bool pomodoroNotificationsEnabled = true,
    String themeMode = 'system',
    SettingsSyncStatusLocal syncStatus = SettingsSyncStatusLocal.synced,
  }) {
    final now = DateTime(2026, 1, 1);
    return SettingsLocalModel()
      ..notificationsEnabled = notificationsEnabled
      ..taskRemindersEnabled = taskRemindersEnabled
      ..habitRemindersEnabled = habitRemindersEnabled
      ..pomodoroNotificationsEnabled = pomodoroNotificationsEnabled
      ..themeMode = themeMode
      ..syncStatus = syncStatus
      ..localUpdatedAt = now;
  }

  test('kayıt yokken get() null döner', () async {
    final result = await datasource.get();
    expect(result, isNull);
  });

  test('put sonrası get() aynı kaydı döner', () async {
    await datasource.put(model(taskRemindersEnabled: false));
    final result = await datasource.get();
    expect(result?.taskRemindersEnabled, isFalse);
  });

  test('tekrar put edilirse (tekil satır, id her zaman 0) günceller, çoğaltmaz', () async {
    await datasource.put(model());
    await datasource.put(model(habitRemindersEnabled: false));

    final all = await isar.settingsLocalModels.where().findAll();
    expect(all, hasLength(1));
    expect(all.first.habitRemindersEnabled, isFalse);
  });

  test('watch() ilk değeri anında yayınlar ve güncellemeleri izler', () async {
    final results = <SettingsLocalModel?>[];
    final subscription = datasource.watch().listen(results.add);

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(results, hasLength(1));
    expect(results.single, isNull);

    await datasource.put(model());
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(results, hasLength(2));
    expect(results.last?.notificationsEnabled, isTrue);

    await subscription.cancel();
  });

  test('toFirestoreSettingsPatch bildirim alt alanlarını VE themeMode\'u içerir (dot-path)', () {
    final m = model(
      notificationsEnabled: false,
      pomodoroNotificationsEnabled: false,
      themeMode: 'amoled',
    );
    final patch = m.toFirestoreSettingsPatch();

    expect(patch, {
      'settings.notificationsEnabled': false,
      'settings.taskRemindersEnabled': true,
      'settings.habitRemindersEnabled': true,
      'settings.pomodoroNotificationsEnabled': false,
      'settings.themeMode': 'amoled',
    });
  });

  test('fromFirestoreSettingsMap eksik alanlar için varsayılan true/system kullanır', () {
    final m = SettingsLocalModel.fromFirestoreSettingsMap({'notificationsEnabled': false});

    expect(m.notificationsEnabled, isFalse);
    expect(m.taskRemindersEnabled, isTrue);
    expect(m.habitRemindersEnabled, isTrue);
    expect(m.pomodoroNotificationsEnabled, isTrue);
    expect(m.themeMode, 'system');
    expect(m.syncStatus, SettingsSyncStatusLocal.synced);
  });

  test('copyWith yalnızca belirtilen alanları değiştirir, gerisini korur', () {
    final original = model(themeMode: 'dark', notificationsEnabled: true);
    final updated = original.copyWith(notificationsEnabled: false);

    expect(updated.notificationsEnabled, isFalse);
    expect(updated.themeMode, 'dark');
    expect(updated.syncStatus, SettingsSyncStatusLocal.pendingUpdate);
  });
}
