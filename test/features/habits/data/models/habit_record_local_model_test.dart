import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/habits/data/models/habit_record_local_model.dart';

/// `HabitRecordLocalModel.toFirestoreJson()`/`fromFirestoreData()`/
/// `buildCompositeKey()` — ROADMAP.md FAZ 16 coverage denetiminde neredeyse
/// %0 bulundu (yalnızca `compositeKey` inşası dolaylı olarak tetikleniyordu,
/// serileştirme mantığı hiç değil — bkz. `task_local_model_test.dart` ile
/// aynı gerekçe).
void main() {
  test('buildCompositeKey habitId ve recordId\'yi "::" ile birleştirir', () {
    expect(HabitRecordLocalModel.buildCompositeKey('h1', '2026-01-01'), 'h1::2026-01-01');
  });

  test('toFirestoreJson doğru anahtarlarla ve Timestamp\'e çevirerek üretir', () {
    final model = HabitRecordLocalModel()
      ..compositeKey = 'h1::2026-01-01'
      ..habitId = 'h1'
      ..recordId = '2026-01-01'
      ..date = DateTime(2026, 1, 1)
      ..isCompleted = true
      ..completedAt = DateTime(2026, 1, 1, 8, 30)
      ..syncStatus = HabitRecordSyncStatusLocal.pendingCreate
      ..lastSyncedAt = DateTime(2026, 1, 1)
      ..localUpdatedAt = DateTime(2026, 1, 1);

    final json = model.toFirestoreJson();

    expect(json['recordId'], '2026-01-01');
    expect(json['date'], Timestamp.fromDate(DateTime(2026, 1, 1)));
    expect(json['isCompleted'], isTrue);
    expect(json['completedAt'], Timestamp.fromDate(DateTime(2026, 1, 1, 8, 30)));
    expect(json.containsKey('habitId'), isFalse);
  });

  test('fromFirestoreData compositeKey\'i habitId+recordId\'den yeniden inşa eder', () {
    final data = {
      'recordId': '2026-01-02',
      'date': Timestamp.fromDate(DateTime(2026, 1, 2)),
      'isCompleted': false,
      'completedAt': null,
    };

    final model = HabitRecordLocalModel.fromFirestoreData('h1', '2026-01-02', data);

    expect(model.compositeKey, 'h1::2026-01-02');
    expect(model.habitId, 'h1');
    expect(model.recordId, '2026-01-02');
    expect(model.date, DateTime(2026, 1, 2));
    expect(model.isCompleted, isFalse);
    expect(model.completedAt, isNull);
    expect(model.syncStatus, HabitRecordSyncStatusLocal.synced);
  });

  test('isCompleted eksikse varsayılan false olur', () {
    final model = HabitRecordLocalModel.fromFirestoreData('h1', '2026-01-03', {
      'date': Timestamp.fromDate(DateTime(2026, 1, 3)),
    });

    expect(model.isCompleted, isFalse);
  });
}
