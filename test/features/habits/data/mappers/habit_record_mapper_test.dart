import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/habits/data/mappers/habit_record_mapper.dart';
import 'package:productivity_app/features/habits/data/models/habit_record_local_model.dart';
import 'package:productivity_app/features/habits/domain/entities/habit_record.dart';

/// `HabitRecordMapper` — ROADMAP.md FAZ 16 coverage denetiminde düşük
/// bulundu (yalnızca `habit_local_datasource_test.dart` üzerinden dolaylı
/// olarak kısmi tetikleniyordu).
void main() {
  test('toEntity LocalModel alanlarını birebir HabitRecord\'a taşır', () {
    final model = HabitRecordLocalModel()
      ..compositeKey = 'h1::2026-01-01'
      ..habitId = 'h1'
      ..recordId = '2026-01-01'
      ..date = DateTime(2026, 1, 1)
      ..isCompleted = true
      ..completedAt = DateTime(2026, 1, 1, 8)
      ..syncStatus = HabitRecordSyncStatusLocal.synced
      ..lastSyncedAt = DateTime(2026, 1, 1)
      ..localUpdatedAt = DateTime(2026, 1, 1);

    final entity = HabitRecordMapper.toEntity(model);

    expect(entity.recordId, '2026-01-01');
    expect(entity.habitId, 'h1');
    expect(entity.date, DateTime(2026, 1, 1));
    expect(entity.isCompleted, isTrue);
    expect(entity.completedAt, DateTime(2026, 1, 1, 8));
  });

  test('fromEntity compositeKey\'i habitId+recordId\'den inşa eder ve senkronizasyon meta '
      'alanlarını parametrelerden atar', () {
    final record = HabitRecord(
      recordId: '2026-01-02',
      habitId: 'h1',
      date: DateTime(2026, 1, 2),
      isCompleted: false,
    );

    final model = HabitRecordMapper.fromEntity(
      record,
      syncStatus: HabitRecordSyncStatusLocal.pendingCreate,
      lastSyncedAt: DateTime(2026, 1, 3),
    );

    expect(model.compositeKey, 'h1::2026-01-02');
    expect(model.habitId, 'h1');
    expect(model.recordId, '2026-01-02');
    expect(model.date, DateTime(2026, 1, 2));
    expect(model.isCompleted, isFalse);
    expect(model.completedAt, isNull);
    expect(model.syncStatus, HabitRecordSyncStatusLocal.pendingCreate);
    expect(model.lastSyncedAt, DateTime(2026, 1, 3));
    expect(model.localUpdatedAt, record.date);
  });

  test('fromEntity -> toEntity round-trip alanları korur', () {
    final record = HabitRecord(
      recordId: '2026-01-03',
      habitId: 'h2',
      date: DateTime(2026, 1, 3),
      isCompleted: true,
      completedAt: null,
    );

    final roundTripped = HabitRecordMapper.toEntity(
      HabitRecordMapper.fromEntity(record, syncStatus: HabitRecordSyncStatusLocal.synced),
    );

    expect(roundTripped.recordId, record.recordId);
    expect(roundTripped.habitId, record.habitId);
    expect(roundTripped.date, record.date);
    expect(roundTripped.isCompleted, record.isCompleted);
    expect(roundTripped.completedAt, record.completedAt);
  });
}
