import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:productivity_app/features/habits/data/datasources/local/habit_local_datasource.dart';
import 'package:productivity_app/features/habits/data/models/habit_local_model.dart';
import 'package:productivity_app/features/habits/data/models/habit_record_local_model.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late HabitLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('isar_habit_test');
    isar = await Isar.open([HabitLocalModelSchema, HabitRecordLocalModelSchema], directory: tempDir.path);
    datasource = HabitLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  HabitLocalModel habit({
    String habitId = 'h1',
    bool isDeleted = false,
    HabitSyncStatusLocal syncStatus = HabitSyncStatusLocal.pendingCreate,
  }) {
    final now = DateTime(2026, 1, 1);
    return HabitLocalModel()
      ..habitId = habitId
      ..name = 'Alışkanlık $habitId'
      ..color = '#FF8A8A'
      ..targetFrequency = HabitTargetFrequencyLocal.daily
      ..currentStreak = 0
      ..longestStreak = 0
      ..status = HabitStatusLocal.active
      ..createdAt = now
      ..updatedAt = now
      ..isDeleted = isDeleted
      ..syncStatus = syncStatus
      ..localUpdatedAt = now;
  }

  HabitRecordLocalModel record({
    String habitId = 'h1',
    required DateTime date,
    bool isCompleted = true,
  }) {
    final recordId = '${date.year}-${date.month}-${date.day}';
    final now = DateTime(2026, 1, 1);
    return HabitRecordLocalModel()
      ..compositeKey = HabitRecordLocalModel.buildCompositeKey(habitId, recordId)
      ..habitId = habitId
      ..recordId = recordId
      ..date = date
      ..isCompleted = isCompleted
      ..syncStatus = HabitRecordSyncStatusLocal.pendingCreate
      ..localUpdatedAt = now;
  }

  test('putHabit sonrası getByHabitId aynı kaydı döner', () async {
    await datasource.putHabit(habit());
    final result = await datasource.getByHabitId('h1');
    expect(result?.name, 'Alışkanlık h1');
  });

  test('putHabit aynı habitId ile tekrar çağrılırsa (replace:true) günceller, çoğaltmaz', () async {
    await datasource.putHabit(habit());
    final updated = habit()..name = 'Güncellendi';
    await datasource.putHabit(updated);

    final all = await isar.habitLocalModels.where().findAll();
    expect(all, hasLength(1));
    expect(all.first.name, 'Güncellendi');
  });

  test('watchHabits yalnızca isDeleted=false kayıtları döner', () async {
    await datasource.putHabit(habit(habitId: 'h1'));
    await datasource.putHabit(habit(habitId: 'h2', isDeleted: true));

    final result = await datasource.watchHabits().first;

    expect(result.map((h) => h.habitId), ['h1']);
  });

  test('getPendingSyncHabits yalnızca synced olmayan kayıtları döner', () async {
    await datasource.putHabit(habit(habitId: 'h1', syncStatus: HabitSyncStatusLocal.synced));
    await datasource.putHabit(habit(habitId: 'h2', syncStatus: HabitSyncStatusLocal.pendingCreate));

    final pending = await datasource.getPendingSyncHabits();

    expect(pending.map((h) => h.habitId), ['h2']);
  });

  test('putHabitRecord + getHabitRecords, tarihe göre sıralı döner', () async {
    await datasource.putHabitRecord(record(date: DateTime(2026, 3, 3)));
    await datasource.putHabitRecord(record(date: DateTime(2026, 3, 1)));
    await datasource.putHabitRecord(record(date: DateTime(2026, 3, 2)));

    final result = await datasource.getHabitRecords('h1');

    expect(result.map((r) => r.date), [DateTime(2026, 3, 1), DateTime(2026, 3, 2), DateTime(2026, 3, 3)]);
  });

  test('aynı compositeKey ile tekrar put edilirse (replace:true) günceller, çoğaltmaz', () async {
    await datasource.putHabitRecord(record(date: DateTime(2026, 3, 1), isCompleted: true));
    await datasource.putHabitRecord(record(date: DateTime(2026, 3, 1), isCompleted: false));

    final all = await isar.habitRecordLocalModels.where().findAll();
    expect(all, hasLength(1));
    expect(all.first.isCompleted, isFalse);
  });

  test('farklı alışkanlıkların aynı tarihli kayıtları çakışmaz (composite key izolasyonu)', () async {
    await datasource.putHabitRecord(record(habitId: 'h1', date: DateTime(2026, 3, 1)));
    await datasource.putHabitRecord(record(habitId: 'h2', date: DateTime(2026, 3, 1)));

    final all = await isar.habitRecordLocalModels.where().findAll();
    expect(all, hasLength(2));
  });

  test('deleteHabitRecord kaydı kalıcı olarak siler (soft delete yok)', () async {
    final r = record(date: DateTime(2026, 3, 1));
    await datasource.putHabitRecord(r);
    await datasource.deleteHabitRecord(r.compositeKey);

    final result = await datasource.getHabitRecords('h1');
    expect(result, isEmpty);
  });

  test('watchHabitRecords yalnızca ilgili habitId\'nin kayıtlarını döner', () async {
    await datasource.putHabitRecord(record(habitId: 'h1', date: DateTime(2026, 3, 1)));
    await datasource.putHabitRecord(record(habitId: 'h2', date: DateTime(2026, 3, 1)));

    final result = await datasource.watchHabitRecords('h1').first;

    expect(result.map((r) => r.habitId), ['h1']);
  });

  group('getRecordsInRange — Statistics agregasyonu', () {
    test('TÜM habit\'ler genelinde, aralık dışındaki kayıtları eler, aralıktakileri tarihe göre sıralı döner', () async {
      await datasource.putHabitRecord(record(habitId: 'h1', date: DateTime(2026, 3, 2)));
      await datasource.putHabitRecord(record(habitId: 'h2', date: DateTime(2026, 3, 1)));
      await datasource.putHabitRecord(record(habitId: 'h1', date: DateTime(2026, 2, 20)));
      await datasource.putHabitRecord(record(habitId: 'h1', date: DateTime(2026, 3, 10)));

      final result =
          await datasource.getRecordsInRange(DateTime(2026, 3, 1), DateTime(2026, 3, 7, 23, 59, 59));

      expect(result.map((r) => r.date), [DateTime(2026, 3, 1), DateTime(2026, 3, 2)]);
    });

    test('aralık sınırları kapsayıcıdır (start/end dahil)', () async {
      await datasource.putHabitRecord(record(habitId: 'h1', date: DateTime(2026, 3, 1)));
      await datasource.putHabitRecord(record(habitId: 'h1', date: DateTime(2026, 3, 7)));

      final result = await datasource.getRecordsInRange(DateTime(2026, 3, 1), DateTime(2026, 3, 7));

      expect(result, hasLength(2));
    });

    test('eşleşen kayıt yoksa boş liste döner', () async {
      final result = await datasource.getRecordsInRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31));
      expect(result, isEmpty);
    });
  });
}
