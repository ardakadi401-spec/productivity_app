import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:productivity_app/features/tags/data/datasources/local/tag_local_datasource.dart';
import 'package:productivity_app/features/tags/data/models/tag_local_model.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late TagLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('isar_tag_test');
    isar = await Isar.open([TagLocalModelSchema], directory: tempDir.path);
    datasource = TagLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  TagLocalModel tag({
    String tagId = 't1',
    TagSyncStatusLocal syncStatus = TagSyncStatusLocal.pendingCreate,
  }) {
    final now = DateTime(2026, 1, 1);
    return TagLocalModel()
      ..tagId = tagId
      ..name = 'Etiket $tagId'
      ..color = '#FF8A8A'
      ..createdAt = now
      ..updatedAt = now
      ..syncStatus = syncStatus
      ..localUpdatedAt = now;
  }

  test('putTag sonrası watchTags aynı kaydı döner (Tag\'de isDeleted alanı yok)', () async {
    await datasource.putTag(tag());
    final result = await datasource.watchTags().first;
    expect(result.map((t) => t.name), ['Etiket t1']);
  });

  test('putTag aynı tagId ile tekrar çağrılırsa (replace:true) günceller, çoğaltmaz', () async {
    await datasource.putTag(tag());
    final updated = tag()..name = 'Güncellendi';
    await datasource.putTag(updated);

    final all = await isar.tagLocalModels.where().findAll();
    expect(all, hasLength(1));
    expect(all.first.name, 'Güncellendi');
  });

  test('getPendingSync yalnızca synced olmayan kayıtları döner', () async {
    await datasource.putTag(tag(tagId: 't1', syncStatus: TagSyncStatusLocal.synced));
    await datasource.putTag(tag(tagId: 't2', syncStatus: TagSyncStatusLocal.pendingCreate));

    final pending = await datasource.getPendingSync();

    expect(pending.map((t) => t.tagId), ['t2']);
  });
}
