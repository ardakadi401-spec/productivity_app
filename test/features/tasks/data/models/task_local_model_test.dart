import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/tasks/data/models/task_local_model.dart';

/// `TaskLocalModel.toFirestoreJson()`/`fromFirestoreData()` — DATABASE.md
/// §12.1 serileştirme mantığı, ROADMAP.md FAZ 16 "Data katmanı hedef %70+"
/// kapsamındaki coverage denetiminde %0 bulundu (yalnızca gerçek Firestore'a
/// konuşan `RemoteDatasource` tarafından çağrıldığı için testlerde hiç
/// tetiklenmiyordu). `Timestamp` saf bir değer sınıfı olduğundan canlı
/// Firebase bağlantısı gerekmez.
TaskLocalModel _fullModel() => TaskLocalModel()
  ..taskId = 't1'
  ..title = 'Rapor Hazırla'
  ..description = 'Detaylı açıklama'
  ..priority = TaskPriorityLocal.high
  ..status = TaskStatusLocal.completed
  ..dueDate = DateTime(2026, 3, 10)
  ..dueTime = '14:30'
  ..projectId = 'p1'
  ..categoryId = 'c1'
  ..tagIds = ['tag1', 'tag2']
  ..recurrenceRule = (RecurrenceRuleEmbedded()
    ..frequency = RecurrenceFrequencyLocal.weekly
    ..interval = 2
    ..daysOfWeek = [1, 3]
    ..endDate = DateTime(2026, 12, 31))
  ..subtaskCount = 3
  ..completedSubtaskCount = 1
  ..completedAt = DateTime(2026, 3, 9)
  ..createdAt = DateTime(2026, 1, 1)
  ..updatedAt = DateTime(2026, 1, 2)
  ..isDeleted = false
  ..deletedAt = null
  ..syncStatus = SyncStatusLocal.pendingUpdate
  ..lastSyncedAt = DateTime(2026, 1, 1)
  ..localUpdatedAt = DateTime(2026, 1, 2);

void main() {
  test('toFirestoreJson tüm alanları doğru anahtarlarla ve Timestamp\'e çevirerek üretir', () {
    final json = _fullModel().toFirestoreJson();

    expect(json['taskId'], 't1');
    expect(json['title'], 'Rapor Hazırla');
    expect(json['description'], 'Detaylı açıklama');
    expect(json['priority'], 'high');
    expect(json['status'], 'completed');
    expect(json['dueDate'], Timestamp.fromDate(DateTime(2026, 3, 10)));
    expect(json['dueTime'], '14:30');
    expect(json['projectId'], 'p1');
    expect(json['categoryId'], 'c1');
    expect(json['tagIds'], ['tag1', 'tag2']);
    expect(json['recurrenceRule'], {
      'frequency': 'weekly',
      'interval': 2,
      'daysOfWeek': [1, 3],
      'endDate': Timestamp.fromDate(DateTime(2026, 12, 31)),
    });
    expect(json['subtaskCount'], 3);
    expect(json['completedSubtaskCount'], 1);
    expect(json['completedAt'], Timestamp.fromDate(DateTime(2026, 3, 9)));
    expect(json['isDeleted'], isFalse);
    expect(json['deletedAt'], isNull);
    // Senkronizasyon meta alanları (syncStatus/lastSyncedAt/localUpdatedAt)
    // yalnızca Isar-yerel olduğundan Firestore JSON'ına DAHİL EDİLMEZ.
    expect(json.containsKey('syncStatus'), isFalse);
  });

  test('fromFirestoreData -> toFirestoreJson round-trip tüm alanları korur', () {
    final original = _fullModel();
    final roundTripped = TaskLocalModel.fromFirestoreData(original.taskId, original.toFirestoreJson());

    expect(roundTripped.taskId, original.taskId);
    expect(roundTripped.title, original.title);
    expect(roundTripped.description, original.description);
    expect(roundTripped.priority, original.priority);
    expect(roundTripped.status, original.status);
    expect(roundTripped.dueDate, original.dueDate);
    expect(roundTripped.dueTime, original.dueTime);
    expect(roundTripped.projectId, original.projectId);
    expect(roundTripped.categoryId, original.categoryId);
    expect(roundTripped.tagIds, original.tagIds);
    expect(roundTripped.recurrenceRule?.frequency, original.recurrenceRule?.frequency);
    expect(roundTripped.recurrenceRule?.interval, original.recurrenceRule?.interval);
    expect(roundTripped.recurrenceRule?.daysOfWeek, original.recurrenceRule?.daysOfWeek);
    expect(roundTripped.recurrenceRule?.endDate, original.recurrenceRule?.endDate);
    expect(roundTripped.subtaskCount, original.subtaskCount);
    expect(roundTripped.completedSubtaskCount, original.completedSubtaskCount);
    expect(roundTripped.completedAt, original.completedAt);
    expect(roundTripped.createdAt, original.createdAt);
    expect(roundTripped.updatedAt, original.updatedAt);
    expect(roundTripped.isDeleted, original.isDeleted);
    expect(roundTripped.deletedAt, original.deletedAt);
    // `fromFirestoreData` senkronizasyon meta alanlarını KENDİ hesaplar
    // (uzaktan gelen veri "artık senkronize" kabul edilir).
    expect(roundTripped.syncStatus, SyncStatusLocal.synced);
  });

  test('opsiyonel alanlar eksik/null geldiğinde makul varsayılanlar kullanılır', () {
    final data = {
      'title': 'Minimal Görev',
      'description': null,
      'priority': 'low',
      'status': 'pending',
      'dueDate': null,
      'dueTime': null,
      'projectId': null,
      'categoryId': null,
      // 'tagIds' kasıtlı olarak eksik.
      'recurrenceRule': null,
      // 'subtaskCount'/'completedSubtaskCount' kasıtlı olarak eksik.
      'completedAt': null,
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      // 'isDeleted' kasıtlı olarak eksik.
      'deletedAt': null,
    };

    final model = TaskLocalModel.fromFirestoreData('t2', data);

    expect(model.tagIds, isEmpty);
    expect(model.subtaskCount, 0);
    expect(model.completedSubtaskCount, 0);
    expect(model.isDeleted, isFalse);
    expect(model.recurrenceRule, isNull);
    expect(model.dueDate, isNull);
  });
}
