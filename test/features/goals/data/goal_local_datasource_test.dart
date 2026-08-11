import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:productivity_app/features/goals/data/datasources/local/goal_local_datasource.dart';
import 'package:productivity_app/features/goals/data/models/goal_local_model.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late GoalLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('isar_goal_test');
    isar = await Isar.open([GoalLocalModelSchema], directory: tempDir.path);
    datasource = GoalLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  GoalLocalModel goal({
    String goalId = 'g1',
    bool isDeleted = false,
    GoalSyncStatusLocal syncStatus = GoalSyncStatusLocal.pendingCreate,
  }) {
    final now = DateTime(2026, 1, 1);
    return GoalLocalModel()
      ..goalId = goalId
      ..title = 'Hedef $goalId'
      ..periodType = GoalPeriodTypeLocal.daily
      ..periodStartDate = now
      ..periodEndDate = DateTime(2026, 1, 1, 23, 59, 59)
      ..progressType = GoalProgressTypeLocal.manual
      ..manualProgress = 0
      ..status = GoalStatusLocal.inProgress
      ..createdAt = now
      ..updatedAt = now
      ..isDeleted = isDeleted
      ..syncStatus = syncStatus
      ..localUpdatedAt = now;
  }

  test('putGoal sonrası getByGoalId aynı kaydı döner', () async {
    await datasource.putGoal(goal());
    final result = await datasource.getByGoalId('g1');
    expect(result?.title, 'Hedef g1');
  });

  test('putGoal aynı goalId ile tekrar çağrılırsa (replace:true) günceller, çoğaltmaz', () async {
    await datasource.putGoal(goal());
    final updated = goal()..title = 'Güncellendi';
    await datasource.putGoal(updated);

    final all = await isar.goalLocalModels.where().findAll();
    expect(all, hasLength(1));
    expect(all.first.title, 'Güncellendi');
  });

  test('watchGoals yalnızca isDeleted=false kayıtları döner', () async {
    await datasource.putGoal(goal(goalId: 'g1'));
    await datasource.putGoal(goal(goalId: 'g2', isDeleted: true));

    final result = await datasource.watchGoals().first;

    expect(result.map((g) => g.goalId), ['g1']);
  });

  test('watchGoal belirli bir goalId\'yi izler, kayıt yoksa null döner', () async {
    final beforeResult = await datasource.watchGoal('missing').first;
    expect(beforeResult, isNull);

    await datasource.putGoal(goal(goalId: 'g1'));
    final afterResult = await datasource.watchGoal('g1').first;
    expect(afterResult?.goalId, 'g1');
  });

  test('getPendingSync yalnızca synced olmayan kayıtları döner', () async {
    await datasource.putGoal(goal(goalId: 'g1', syncStatus: GoalSyncStatusLocal.synced));
    await datasource.putGoal(goal(goalId: 'g2', syncStatus: GoalSyncStatusLocal.pendingCreate));

    final pending = await datasource.getPendingSync();

    expect(pending.map((g) => g.goalId), ['g2']);
  });
}
