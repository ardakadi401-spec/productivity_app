import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/notes/data/models/note_local_model.dart';

/// `NoteLocalModel.toFirestoreJson()`/`fromFirestoreData()` — ROADMAP.md
/// FAZ 16 coverage denetiminde %0 bulundu (bkz.
/// `task_local_model_test.dart` ile aynı gerekçe).
NoteLocalModel _fullModel() => NoteLocalModel()
  ..noteId = 'n1'
  ..title = 'Alışveriş Listesi'
  ..content = 'Süt, ekmek'
  ..color = '#FF8A8A'
  ..projectId = 'p1'
  ..taskId = 't1'
  ..tagIds = ['tag1']
  ..isPinned = true
  ..createdAt = DateTime(2026, 1, 1)
  ..updatedAt = DateTime(2026, 1, 2)
  ..isDeleted = false
  ..deletedAt = null
  ..syncStatus = NoteSyncStatusLocal.pendingUpdate
  ..lastSyncedAt = DateTime(2026, 1, 1)
  ..localUpdatedAt = DateTime(2026, 1, 2);

void main() {
  test('toFirestoreJson doğru anahtarlarla ve Timestamp\'e çevirerek üretir', () {
    final json = _fullModel().toFirestoreJson();

    expect(json['noteId'], 'n1');
    expect(json['title'], 'Alışveriş Listesi');
    expect(json['content'], 'Süt, ekmek');
    expect(json['color'], '#FF8A8A');
    expect(json['projectId'], 'p1');
    expect(json['taskId'], 't1');
    expect(json['tagIds'], ['tag1']);
    expect(json['isPinned'], isTrue);
    expect(json['createdAt'], Timestamp.fromDate(DateTime(2026, 1, 1)));
    expect(json['isDeleted'], isFalse);
    expect(json['deletedAt'], isNull);
  });

  test('fromFirestoreData -> toFirestoreJson round-trip tüm alanları korur', () {
    final original = _fullModel();
    final roundTripped = NoteLocalModel.fromFirestoreData(original.noteId, original.toFirestoreJson());

    expect(roundTripped.noteId, original.noteId);
    expect(roundTripped.title, original.title);
    expect(roundTripped.content, original.content);
    expect(roundTripped.color, original.color);
    expect(roundTripped.projectId, original.projectId);
    expect(roundTripped.taskId, original.taskId);
    expect(roundTripped.tagIds, original.tagIds);
    expect(roundTripped.isPinned, original.isPinned);
    expect(roundTripped.createdAt, original.createdAt);
    expect(roundTripped.updatedAt, original.updatedAt);
    expect(roundTripped.isDeleted, original.isDeleted);
    expect(roundTripped.syncStatus, NoteSyncStatusLocal.synced);
  });

  test('opsiyonel alanlar eksik geldiğinde varsayılanlar kullanılır', () {
    final data = {
      'title': 'Minimal Not',
      'content': null,
      'color': null,
      'projectId': null,
      'taskId': null,
      // 'tagIds'/'isPinned'/'isDeleted' kasıtlı olarak eksik.
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'deletedAt': null,
    };

    final model = NoteLocalModel.fromFirestoreData('n2', data);

    expect(model.tagIds, isEmpty);
    expect(model.isPinned, isFalse);
    expect(model.isDeleted, isFalse);
  });
}
