import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/statistics/data/models/statistics_snapshot_local_model.dart';

/// `StatisticsSnapshotLocalModel.toFirestoreJson()`/`fromFirestoreData()` —
/// ROADMAP.md FAZ 16 coverage denetiminde %0 bulundu (bkz.
/// `task_local_model_test.dart` ile aynı gerekçe).
StatisticsSnapshotLocalModel _fullModel() => StatisticsSnapshotLocalModel()
  ..snapshotId = '2026-01-01'
  ..date = DateTime(2026, 1, 1)
  ..tasksCompleted = 5
  ..tasksCreated = 8
  ..habitsCompletedCount = 2
  ..habitsTotalCount = 3
  ..pomodoroSessionsCompleted = 4
  ..pomodoroTotalMinutes = 100
  ..createdAt = DateTime(2026, 1, 1, 23, 59)
  ..syncStatus = StatisticsSyncStatusLocal.pendingCreate
  ..lastSyncedAt = DateTime(2026, 1, 1)
  ..localUpdatedAt = DateTime(2026, 1, 1);

void main() {
  test('toFirestoreJson sabit "daily" periodType ile doğru anahtarları üretir', () {
    final json = _fullModel().toFirestoreJson();

    expect(json['snapshotId'], '2026-01-01');
    expect(json['periodType'], 'daily');
    expect(json['date'], Timestamp.fromDate(DateTime(2026, 1, 1)));
    expect(json['tasksCompleted'], 5);
    expect(json['tasksCreated'], 8);
    expect(json['habitsCompletedCount'], 2);
    expect(json['habitsTotalCount'], 3);
    expect(json['pomodoroSessionsCompleted'], 4);
    expect(json['pomodoroTotalMinutes'], 100);
  });

  test('fromFirestoreData -> toFirestoreJson round-trip tüm sayaçları korur', () {
    final original = _fullModel();
    final roundTripped =
        StatisticsSnapshotLocalModel.fromFirestoreData(original.snapshotId, original.toFirestoreJson());

    expect(roundTripped.snapshotId, original.snapshotId);
    expect(roundTripped.date, original.date);
    expect(roundTripped.tasksCompleted, original.tasksCompleted);
    expect(roundTripped.tasksCreated, original.tasksCreated);
    expect(roundTripped.habitsCompletedCount, original.habitsCompletedCount);
    expect(roundTripped.habitsTotalCount, original.habitsTotalCount);
    expect(roundTripped.pomodoroSessionsCompleted, original.pomodoroSessionsCompleted);
    expect(roundTripped.pomodoroTotalMinutes, original.pomodoroTotalMinutes);
    expect(roundTripped.syncStatus, StatisticsSyncStatusLocal.synced);
  });

  test('sayaç alanları eksik geldiğinde 0 varsayılır', () {
    final model = StatisticsSnapshotLocalModel.fromFirestoreData('2026-01-02', {
      'date': Timestamp.fromDate(DateTime(2026, 1, 2)),
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
    });

    expect(model.tasksCompleted, 0);
    expect(model.tasksCreated, 0);
    expect(model.habitsCompletedCount, 0);
    expect(model.habitsTotalCount, 0);
    expect(model.pomodoroSessionsCompleted, 0);
    expect(model.pomodoroTotalMinutes, 0);
  });
}
