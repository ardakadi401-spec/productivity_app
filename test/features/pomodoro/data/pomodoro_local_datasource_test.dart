import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:productivity_app/features/pomodoro/data/datasources/local/pomodoro_local_datasource.dart';
import 'package:productivity_app/features/pomodoro/data/models/pomodoro_session_local_model.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late PomodoroLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('isar_pomodoro_test');
    isar = await Isar.open([PomodoroSessionLocalModelSchema], directory: tempDir.path);
    datasource = PomodoroLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  PomodoroSessionLocalModel session({
    String sessionId = 'p1',
    String? taskId,
    PomodoroSessionTypeLocal type = PomodoroSessionTypeLocal.work,
    bool isCompleted = false,
    PomodoroSyncStatusLocal syncStatus = PomodoroSyncStatusLocal.pendingCreate,
    DateTime? startedAt,
  }) {
    final now = startedAt ?? DateTime(2026, 1, 1);
    return PomodoroSessionLocalModel()
      ..sessionId = sessionId
      ..taskId = taskId
      ..type = type
      ..plannedDurationSeconds = 25 * 60
      ..actualDurationSeconds = 0
      ..startedAt = now
      ..isCompleted = isCompleted
      ..syncStatus = syncStatus
      ..localUpdatedAt = now;
  }

  test('putSession sonrası getBySessionId aynı kaydı döner', () async {
    await datasource.putSession(session());
    final result = await datasource.getBySessionId('p1');
    expect(result?.sessionId, 'p1');
  });

  test('putSession aynı sessionId ile tekrar çağrılırsa (replace:true) günceller, çoğaltmaz', () async {
    await datasource.putSession(session());
    final updated = session()..isCompleted = true;
    await datasource.putSession(updated);

    final all = await isar.pomodoroSessionLocalModels.where().findAll();
    expect(all, hasLength(1));
    expect(all.first.isCompleted, isTrue);
  });

  test('watchSessionsByTask yalnızca eşleşen taskId kayıtlarını, en yeniden eskiye döner', () async {
    await datasource.putSession(
      session(sessionId: 'p1', taskId: 't1', startedAt: DateTime(2026, 1, 1)),
    );
    await datasource.putSession(
      session(sessionId: 'p2', taskId: 't2', startedAt: DateTime(2026, 1, 2)),
    );
    await datasource.putSession(
      session(sessionId: 'p3', taskId: 't1', startedAt: DateTime(2026, 1, 3)),
    );

    final result = await datasource.watchSessionsByTask('t1').first;

    expect(result.map((s) => s.sessionId), ['p3', 'p1']);
  });

  test('getPendingSync yalnızca synced olmayan kayıtları döner', () async {
    await datasource.putSession(session(sessionId: 'p1', syncStatus: PomodoroSyncStatusLocal.synced));
    await datasource.putSession(
      session(sessionId: 'p2', syncStatus: PomodoroSyncStatusLocal.pendingCreate),
    );

    final pending = await datasource.getPendingSync();

    expect(pending.map((s) => s.sessionId), ['p2']);
  });

  group('getSessionsInRange — Statistics agregasyonu', () {
    test('TÜM görevler genelinde (görev filtresi olmadan), aralık dışını eler, tarihe göre sıralı döner', () async {
      await datasource.putSession(session(sessionId: 'p1', taskId: 't1', startedAt: DateTime(2026, 3, 2)));
      await datasource.putSession(session(sessionId: 'p2', taskId: null, startedAt: DateTime(2026, 3, 1)));
      await datasource.putSession(session(sessionId: 'p3', taskId: 't2', startedAt: DateTime(2026, 2, 20)));
      await datasource.putSession(session(sessionId: 'p4', taskId: 't1', startedAt: DateTime(2026, 3, 10)));

      final result = await datasource.getSessionsInRange(
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 7, 23, 59, 59),
      );

      expect(result.map((s) => s.sessionId), ['p2', 'p1']);
    });

    test('aralık sınırları kapsayıcıdır (start/end dahil)', () async {
      await datasource.putSession(session(sessionId: 'p1', startedAt: DateTime(2026, 3, 1)));
      await datasource.putSession(session(sessionId: 'p2', startedAt: DateTime(2026, 3, 7)));

      final result = await datasource.getSessionsInRange(DateTime(2026, 3, 1), DateTime(2026, 3, 7));

      expect(result, hasLength(2));
    });

    test('eşleşen kayıt yoksa boş liste döner', () async {
      final result =
          await datasource.getSessionsInRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31));
      expect(result, isEmpty);
    });
  });
}
