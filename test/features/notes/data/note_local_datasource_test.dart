import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:productivity_app/features/notes/data/datasources/local/note_local_datasource.dart';
import 'package:productivity_app/features/notes/data/models/note_local_model.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late NoteLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('isar_note_test');
    isar = await Isar.open([NoteLocalModelSchema], directory: tempDir.path);
    datasource = NoteLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  NoteLocalModel note({
    String noteId = 'n1',
    bool isDeleted = false,
    NoteSyncStatusLocal syncStatus = NoteSyncStatusLocal.pendingCreate,
  }) {
    final now = DateTime(2026, 1, 1);
    return NoteLocalModel()
      ..noteId = noteId
      ..title = 'Not $noteId'
      ..tagIds = const []
      ..isPinned = false
      ..createdAt = now
      ..updatedAt = now
      ..isDeleted = isDeleted
      ..syncStatus = syncStatus
      ..localUpdatedAt = now;
  }

  test('putNote sonrası getByNoteId aynı kaydı döner', () async {
    await datasource.putNote(note());
    final result = await datasource.getByNoteId('n1');
    expect(result?.title, 'Not n1');
  });

  test('putNote aynı noteId ile tekrar çağrılırsa (replace:true) günceller, çoğaltmaz', () async {
    await datasource.putNote(note());
    final updated = note()..title = 'Güncellendi';
    await datasource.putNote(updated);

    final all = await isar.noteLocalModels.where().findAll();
    expect(all, hasLength(1));
    expect(all.first.title, 'Güncellendi');
  });

  test('watchNotes yalnızca isDeleted=false kayıtları döner', () async {
    await datasource.putNote(note(noteId: 'n1'));
    await datasource.putNote(note(noteId: 'n2', isDeleted: true));

    final result = await datasource.watchNotes().first;

    expect(result.map((n) => n.noteId), ['n1']);
  });

  test('watchNote belirli bir noteId\'yi izler, kayıt yoksa null döner', () async {
    final beforeResult = await datasource.watchNote('missing').first;
    expect(beforeResult, isNull);

    await datasource.putNote(note(noteId: 'n1'));
    final afterResult = await datasource.watchNote('n1').first;
    expect(afterResult?.noteId, 'n1');
  });

  test('getPendingSync yalnızca synced olmayan kayıtları döner', () async {
    await datasource.putNote(note(noteId: 'n1', syncStatus: NoteSyncStatusLocal.synced));
    await datasource.putNote(note(noteId: 'n2', syncStatus: NoteSyncStatusLocal.pendingCreate));

    final pending = await datasource.getPendingSync();

    expect(pending.map((n) => n.noteId), ['n2']);
  });
}
