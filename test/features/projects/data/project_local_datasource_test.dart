import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:productivity_app/features/projects/data/datasources/local/project_local_datasource.dart';
import 'package:productivity_app/features/projects/data/models/project_local_model.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late ProjectLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('isar_project_test');
    isar = await Isar.open([ProjectLocalModelSchema], directory: tempDir.path);
    datasource = ProjectLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  ProjectLocalModel project({
    String projectId = 'p1',
    bool isDeleted = false,
    ProjectSyncStatusLocal syncStatus = ProjectSyncStatusLocal.pendingCreate,
    ProjectStatusLocal status = ProjectStatusLocal.active,
  }) {
    final now = DateTime(2026, 1, 1);
    return ProjectLocalModel()
      ..projectId = projectId
      ..title = 'Proje $projectId'
      ..color = '#FF8A8A'
      ..status = status
      ..taskCount = 0
      ..completedTaskCount = 0
      ..createdAt = now
      ..updatedAt = now
      ..isDeleted = isDeleted
      ..syncStatus = syncStatus
      ..localUpdatedAt = now;
  }

  test('putProject sonrası getByProjectId aynı kaydı döner', () async {
    await datasource.putProject(project());
    final result = await datasource.getByProjectId('p1');
    expect(result?.title, 'Proje p1');
  });

  test('putProject aynı projectId ile tekrar çağrılırsa (replace:true) günceller, çoğaltmaz', () async {
    await datasource.putProject(project());
    final updated = project()..title = 'Güncellendi';
    await datasource.putProject(updated);

    final all = await isar.projectLocalModels.where().findAll();
    expect(all, hasLength(1));
    expect(all.first.title, 'Güncellendi');
  });

  test('watchProjects yalnızca isDeleted=false kayıtları döner', () async {
    await datasource.putProject(project(projectId: 'p1'));
    await datasource.putProject(project(projectId: 'p2', isDeleted: true));

    final result = await datasource.watchProjects().first;

    expect(result.map((p) => p.projectId), ['p1']);
  });

  test('watchProject belirli bir projectId\'yi izler, kayıt yoksa null döner', () async {
    final beforeResult = await datasource.watchProject('missing').first;
    expect(beforeResult, isNull);

    await datasource.putProject(project(projectId: 'p1'));
    final afterResult = await datasource.watchProject('p1').first;
    expect(afterResult?.projectId, 'p1');
  });

  test('getPendingSync yalnızca synced olmayan kayıtları döner', () async {
    await datasource.putProject(project(projectId: 'p1', syncStatus: ProjectSyncStatusLocal.synced));
    await datasource.putProject(
      project(projectId: 'p2', syncStatus: ProjectSyncStatusLocal.pendingCreate),
    );

    final pending = await datasource.getPendingSync();

    expect(pending.map((p) => p.projectId), ['p2']);
  });
}
