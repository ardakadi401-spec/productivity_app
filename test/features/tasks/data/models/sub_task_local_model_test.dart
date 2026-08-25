import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/tasks/data/models/sub_task_local_model.dart';
import 'package:productivity_app/features/tasks/data/models/task_local_model.dart';

/// `SubTaskLocalModel.toFirestoreJson()`/`fromFirestoreData()` — ROADMAP.md
/// FAZ 16 coverage denetiminde %0 bulundu (bkz. `task_local_model_test.dart`
/// ile aynı gerekçe).
SubTaskLocalModel _fullModel() => SubTaskLocalModel()
  ..subtaskId = 's1'
  ..taskId = 't1'
  ..title = 'Taslak yaz'
  ..isCompleted = true
  ..order = 2
  ..createdAt = DateTime(2026, 1, 1)
  ..updatedAt = DateTime(2026, 1, 2)
  ..isDeleted = false
  ..deletedAt = null
  ..syncStatus = SyncStatusLocal.pendingCreate
  ..lastSyncedAt = DateTime(2026, 1, 1)
  ..localUpdatedAt = DateTime(2026, 1, 2);

void main() {
  test('toFirestoreJson doğru anahtarlarla ve Timestamp\'e çevirerek üretir', () {
    final json = _fullModel().toFirestoreJson();

    expect(json['subtaskId'], 's1');
    expect(json['title'], 'Taslak yaz');
    expect(json['isCompleted'], isTrue);
    expect(json['order'], 2);
    expect(json['createdAt'], Timestamp.fromDate(DateTime(2026, 1, 1)));
    expect(json['updatedAt'], Timestamp.fromDate(DateTime(2026, 1, 2)));
    expect(json['isDeleted'], isFalse);
    expect(json['deletedAt'], isNull);
    expect(json.containsKey('taskId'), isFalse);
  });

  test('fromFirestoreData -> toFirestoreJson round-trip tüm alanları korur', () {
    final original = _fullModel();
    final roundTripped = SubTaskLocalModel.fromFirestoreData(
      original.taskId,
      original.subtaskId,
      original.toFirestoreJson(),
    );

    expect(roundTripped.subtaskId, original.subtaskId);
    expect(roundTripped.taskId, original.taskId);
    expect(roundTripped.title, original.title);
    expect(roundTripped.isCompleted, original.isCompleted);
    expect(roundTripped.order, original.order);
    expect(roundTripped.createdAt, original.createdAt);
    expect(roundTripped.updatedAt, original.updatedAt);
    expect(roundTripped.isDeleted, original.isDeleted);
    expect(roundTripped.syncStatus, SyncStatusLocal.synced);
  });

  test('opsiyonel alanlar eksik geldiğinde varsayılanlar kullanılır', () {
    final data = {
      'title': 'Minimal alt görev',
      // 'isCompleted'/'order'/'isDeleted' kasıtlı olarak eksik.
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    };

    final model = SubTaskLocalModel.fromFirestoreData('t1', 's2', data);

    expect(model.isCompleted, isFalse);
    expect(model.order, 0);
    expect(model.isDeleted, isFalse);
  });
}
