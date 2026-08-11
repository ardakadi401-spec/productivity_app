import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:productivity_app/features/tasks/data/datasources/local/task_local_datasource.dart';
import 'package:productivity_app/features/tasks/data/models/sub_task_local_model.dart';
import 'package:productivity_app/features/tasks/data/models/task_local_model.dart';

/// İlk Isar entegrasyon testi (FAZ 5 planı) — gerçek bir Isar örneği,
/// geçici bir dizinde açılır ve her testten sonra diskten silinerek kapatılır.
void main() {
  late Directory tempDir;
  late Isar isar;
  late TaskLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('isar_task_test');
    isar = await Isar.open(
      [TaskLocalModelSchema, SubTaskLocalModelSchema],
      directory: tempDir.path,
    );
    datasource = TaskLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  TaskLocalModel task({
    String taskId = 't1',
    bool isDeleted = false,
    SyncStatusLocal syncStatus = SyncStatusLocal.pendingCreate,
  }) {
    final now = DateTime(2026, 1, 1);
    return TaskLocalModel()
      ..taskId = taskId
      ..title = 'Görev $taskId'
      ..priority = TaskPriorityLocal.medium
      ..status = TaskStatusLocal.pending
      ..subtaskCount = 0
      ..completedSubtaskCount = 0
      ..createdAt = now
      ..updatedAt = now
      ..isDeleted = isDeleted
      ..syncStatus = syncStatus
      ..localUpdatedAt = now;
  }

  SubTaskLocalModel subTask({String subtaskId = 's1', String taskId = 't1', int order = 0}) {
    final now = DateTime(2026, 1, 1);
    return SubTaskLocalModel()
      ..subtaskId = subtaskId
      ..taskId = taskId
      ..title = 'Alt görev $subtaskId'
      ..isCompleted = false
      ..order = order
      ..createdAt = now
      ..updatedAt = now
      ..syncStatus = SyncStatusLocal.pendingCreate
      ..localUpdatedAt = now;
  }

  test('putTask sonrası getByTaskId aynı kaydı döner', () async {
    await datasource.putTask(task());
    final result = await datasource.getByTaskId('t1');
    expect(result?.title, 'Görev t1');
  });

  test('putTask aynı taskId ile tekrar çağrılırsa (replace:true) günceller, çoğaltmaz', () async {
    await datasource.putTask(task());
    final updated = task()..title = 'Güncellendi';
    await datasource.putTask(updated);

    final all = await isar.taskLocalModels.where().findAll();
    expect(all, hasLength(1));
    expect(all.first.title, 'Güncellendi');
  });

  test('watchTasks yalnızca isDeleted=false kayıtları döner', () async {
    await datasource.putTask(task(taskId: 't1'));
    await datasource.putTask(task(taskId: 't2', isDeleted: true));

    final result = await datasource.watchTasks().first;

    expect(result.map((t) => t.taskId), ['t1']);
  });

  test('watchTask belirli bir taskId\'yi izler, kayıt yoksa null döner', () async {
    final beforeResult = await datasource.watchTask('missing').first;
    expect(beforeResult, isNull);

    await datasource.putTask(task(taskId: 't1'));
    final afterResult = await datasource.watchTask('t1').first;
    expect(afterResult?.taskId, 't1');
  });

  test('getPendingSync yalnızca synced olmayan kayıtları döner', () async {
    await datasource.putTask(task(taskId: 't1', syncStatus: SyncStatusLocal.synced));
    await datasource.putTask(task(taskId: 't2', syncStatus: SyncStatusLocal.pendingCreate));

    final pending = await datasource.getPendingSync();

    expect(pending.map((t) => t.taskId), ['t2']);
  });

  test('putSubTask + getSubTasks, order\'a göre sıralı döner', () async {
    await datasource.putSubTask(subTask(subtaskId: 's2', order: 2));
    await datasource.putSubTask(subTask(subtaskId: 's1', order: 1));

    final result = await datasource.getSubTasks('t1');

    expect(result.map((s) => s.subtaskId), ['s1', 's2']);
  });

  test('watchSubTasks yalnızca ilgili taskId\'nin alt görevlerini döner', () async {
    await datasource.putSubTask(subTask(subtaskId: 's1', taskId: 't1'));
    await datasource.putSubTask(subTask(subtaskId: 's2', taskId: 't2'));

    final result = await datasource.watchSubTasks('t1').first;

    expect(result.map((s) => s.subtaskId), ['s1']);
  });

  test('getSubTaskById eşleşen kaydı döner', () async {
    await datasource.putSubTask(subTask(subtaskId: 's1'));
    final result = await datasource.getSubTaskById('s1');
    expect(result?.subtaskId, 's1');
  });
}
