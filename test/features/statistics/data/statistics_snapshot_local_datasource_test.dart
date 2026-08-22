import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:productivity_app/features/statistics/data/datasources/local/statistics_snapshot_local_datasource.dart';
import 'package:productivity_app/features/statistics/data/models/statistics_snapshot_local_model.dart';
import 'package:productivity_app/features/statistics/domain/entities/statistics_snapshot.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late StatisticsSnapshotLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('isar_statistics_test');
    isar = await Isar.open([StatisticsSnapshotLocalModelSchema], directory: tempDir.path);
    datasource = StatisticsSnapshotLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  StatisticsSnapshotLocalModel snapshot({
    required DateTime date,
    StatisticsSyncStatusLocal syncStatus = StatisticsSyncStatusLocal.pendingCreate,
  }) {
    return StatisticsSnapshotLocalModel()
      ..snapshotId = StatisticsSnapshot.formatSnapshotId(date)
      ..date = date
      ..tasksCompleted = 1
      ..tasksCreated = 1
      ..habitsCompletedCount = 1
      ..habitsTotalCount = 1
      ..pomodoroSessionsCompleted = 1
      ..pomodoroTotalMinutes = 25
      ..createdAt = date
      ..syncStatus = syncStatus
      ..localUpdatedAt = date;
  }

  test('putSnapshot sonrası getBySnapshotId aynı kaydı döner', () async {
    await datasource.putSnapshot(snapshot(date: DateTime(2026, 1, 1)));
    final result = await datasource.getBySnapshotId('2026-01-01');
    expect(result?.tasksCompleted, 1);
  });

  test('aynı snapshotId ile tekrar put edilirse (replace:true) günceller, çoğaltmaz', () async {
    await datasource.putSnapshot(snapshot(date: DateTime(2026, 1, 1)));
    final updated = snapshot(date: DateTime(2026, 1, 1))..tasksCompleted = 99;
    await datasource.putSnapshot(updated);

    final all = await isar.statisticsSnapshotLocalModels.where().findAll();
    expect(all, hasLength(1));
    expect(all.first.tasksCompleted, 99);
  });

  test('getSnapshotsInRange aralık dışını eler, tarihe göre sıralı döner', () async {
    await datasource.putSnapshot(snapshot(date: DateTime(2026, 3, 2)));
    await datasource.putSnapshot(snapshot(date: DateTime(2026, 3, 1)));
    await datasource.putSnapshot(snapshot(date: DateTime(2026, 2, 20)));

    final result = await datasource.getSnapshotsInRange(DateTime(2026, 3, 1), DateTime(2026, 3, 7));

    expect(result.map((s) => s.date), [DateTime(2026, 3, 1), DateTime(2026, 3, 2)]);
  });

  test('getPendingSync yalnızca synced olmayan kayıtları döner', () async {
    await datasource.putSnapshot(
      snapshot(date: DateTime(2026, 1, 1), syncStatus: StatisticsSyncStatusLocal.synced),
    );
    await datasource.putSnapshot(
      snapshot(date: DateTime(2026, 1, 2), syncStatus: StatisticsSyncStatusLocal.pendingCreate),
    );

    final pending = await datasource.getPendingSync();

    expect(pending.map((s) => s.snapshotId), ['2026-01-02']);
  });
}
