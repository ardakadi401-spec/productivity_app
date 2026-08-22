import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/exceptions/app_exceptions.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/features/habits/data/datasources/local/habit_local_datasource.dart';
import 'package:productivity_app/features/habits/data/datasources/remote/habit_remote_datasource.dart';
import 'package:productivity_app/features/habits/data/models/habit_local_model.dart';
import 'package:productivity_app/features/habits/data/models/habit_record_local_model.dart';
import 'package:productivity_app/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:productivity_app/features/habits/domain/entities/habit.dart';

class _MockLocal extends Mock implements HabitLocalDatasource {}

class _MockRemote extends Mock implements HabitRemoteDatasource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

Habit _habit({String habitId = 'h1'}) => Habit(
      habitId: habitId,
      name: 'Alışkanlık',
      color: '#FF8A8A',
      targetFrequency: HabitTargetFrequency.daily,
      currentStreak: 0,
      longestStreak: 0,
      status: HabitStatus.active,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

HabitLocalModel _model({
  String habitId = 'h1',
  HabitSyncStatusLocal syncStatus = HabitSyncStatusLocal.pendingCreate,
  int currentStreak = 0,
  int longestStreak = 0,
}) {
  final now = DateTime(2026, 1, 1);
  return HabitLocalModel()
    ..habitId = habitId
    ..name = 'Alışkanlık'
    ..color = '#FF8A8A'
    ..targetFrequency = HabitTargetFrequencyLocal.daily
    ..currentStreak = currentStreak
    ..longestStreak = longestStreak
    ..status = HabitStatusLocal.active
    ..createdAt = now
    ..updatedAt = now
    ..isDeleted = false
    ..syncStatus = syncStatus
    ..localUpdatedAt = now;
}

HabitRecordLocalModel _recordModel(String habitId, DateTime date, {bool isCompleted = true}) {
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

void main() {
  late _MockLocal local;
  late _MockRemote remote;
  late _MockConnectivity connectivity;
  late HabitRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_model());
    registerFallbackValue(_recordModel('h1', DateTime(2026, 1, 1)));
  });

  setUp(() {
    local = _MockLocal();
    remote = _MockRemote();
    connectivity = _MockConnectivity();
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    when(() => local.getPendingSyncHabits()).thenAnswer((_) async => []);
    repository = HabitRepositoryImpl(local, remote, connectivity);
  });

  group('createHabit', () {
    test('bağlantı yokken yalnızca yerele pendingCreate ile yazar, remote çağrılmaz', () async {
      when(() => local.putHabit(any())).thenAnswer((_) async {});

      final result = await repository.createHabit(_habit());

      expect(result, isA<Ok<Habit>>());
      final captured = verify(() => local.putHabit(captureAny())).captured.single as HabitLocalModel;
      expect(captured.syncStatus, HabitSyncStatusLocal.pendingCreate);
      verifyNever(() => remote.setHabit(any()));
    });

    test('bağlantı varken yerele yazar, remote\'a gönderir, ardından synced işaretler', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putHabit(any())).thenAnswer((_) async {});
      when(() => remote.setHabit(any())).thenAnswer((_) async {});

      await repository.createHabit(_habit());

      verify(() => remote.setHabit(any())).called(1);
      final calls = verify(() => local.putHabit(captureAny())).captured.cast<HabitLocalModel>();
      expect(calls.last.syncStatus, HabitSyncStatusLocal.synced);
    });

    test('yerel yazma CacheException fırlatırsa Err(CacheFailure) döner', () async {
      when(() => local.putHabit(any())).thenThrow(const CacheException('disk dolu'));

      final result = await repository.createHabit(_habit());

      expect(result, isA<Err<Habit>>());
      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('deleteHabit', () {
    test('mevcut kaydı soft-delete olarak işaretler ve syncStatus\'u pendingDelete yapar', () async {
      when(() => local.getByHabitId('h1')).thenAnswer((_) async => _model());
      when(() => local.putHabit(any())).thenAnswer((_) async {});

      final result = await repository.deleteHabit('h1');

      expect(result, isA<Ok<void>>());
      final captured = verify(() => local.putHabit(captureAny())).captured.single as HabitLocalModel;
      expect(captured.isDeleted, isTrue);
      expect(captured.deletedAt, isNotNull);
      expect(captured.syncStatus, HabitSyncStatusLocal.pendingDelete);
    });

    test('kayıt bulunamazsa CacheFailure döner', () async {
      when(() => local.getByHabitId('missing')).thenAnswer((_) async => null);

      final result = await repository.deleteHabit('missing');

      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('setCheckIn — isCompleted: true', () {
    // `HabitRepositoryImpl._recalculateStreak`, `CalculateStreakUseCase`'i
    // her zaman GERÇEK `DateTime.now()` referans alarak çağırır (check-in'e
    // iletilen tarihi değil) — bu yüzden test verisi "bugün"e göre kurulur.
    test('HabitRecord yazar ve streak\'i yeniden hesaplayıp Habit\'e denormalize eder', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final expectedRecordId =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      when(() => local.putHabitRecord(any())).thenAnswer((_) async {});
      when(() => local.getByHabitId('h1')).thenAnswer((_) async => _model());
      when(() => local.getHabitRecords('h1')).thenAnswer(
        (_) async => [_recordModel('h1', today)],
      );
      when(() => local.putHabit(any())).thenAnswer((_) async {});

      final result = await repository.setCheckIn('h1', today, isCompleted: true);

      expect(result, isA<Ok<Habit>>());
      final capturedRecord =
          verify(() => local.putHabitRecord(captureAny())).captured.single as HabitRecordLocalModel;
      expect(capturedRecord.isCompleted, isTrue);
      expect(capturedRecord.recordId, expectedRecordId);

      final capturedHabit = verify(() => local.putHabit(captureAny())).captured.single as HabitLocalModel;
      expect(capturedHabit.currentStreak, 1);
      expect(capturedHabit.longestStreak, 1);
    });
  });

  group('setCheckIn — isCompleted: false (geri alma)', () {
    test('kaydı kalıcı olarak siler ve streak\'i sıfıra günceller', () async {
      when(() => local.deleteHabitRecord(any())).thenAnswer((_) async {});
      when(() => local.getByHabitId('h1')).thenAnswer((_) async => _model(currentStreak: 1, longestStreak: 1));
      when(() => local.getHabitRecords('h1')).thenAnswer((_) async => []);
      when(() => local.putHabit(any())).thenAnswer((_) async {});

      final result = await repository.setCheckIn('h1', DateTime(2026, 1, 1), isCompleted: false);

      expect(result, isA<Ok<Habit>>());
      final expectedCompositeKey = HabitRecordLocalModel.buildCompositeKey('h1', '2026-01-01');
      verify(() => local.deleteHabitRecord(expectedCompositeKey)).called(1);

      final capturedHabit = verify(() => local.putHabit(captureAny())).captured.single as HabitLocalModel;
      expect(capturedHabit.currentStreak, 0);
    });

    test('bağlantı yokken remote silme denenmez', () async {
      when(() => local.deleteHabitRecord(any())).thenAnswer((_) async {});
      when(() => local.getByHabitId('h1')).thenAnswer((_) async => _model());
      when(() => local.getHabitRecords('h1')).thenAnswer((_) async => []);
      when(() => local.putHabit(any())).thenAnswer((_) async {});

      await repository.setCheckIn('h1', DateTime(2026, 1, 1), isCompleted: false);

      verifyNever(() => remote.deleteHabitRecord(any(), any()));
    });
  });

  group('syncPending — FAZ 14 ADIM 6 (SyncCoordinator giriş noktası)', () {
    test('offline durumda hiçbir şey yapmaz', () async {
      // setUp zaten connectivity.isConnected: false stub'ladı; kurucunun
      // arka plan `_syncFromRemote`'unun bu no-op'u tamamlaması için bekle.
      await Future<void>.delayed(Duration.zero);

      await repository.syncPending();

      verifyNever(() => remote.setHabit(any()));
    });

    test('pendingCreate kaydını online olduğunda gönderir ve synced yapar', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: HabitSyncStatusLocal.pendingCreate);
      when(() => local.getPendingSyncHabits()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setHabit(any())).thenAnswer((_) async {});
      when(() => local.putHabit(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verify(() => remote.setHabit(pendingModel)).called(1);
      final captured = verify(() => local.putHabit(captureAny())).captured.single as HabitLocalModel;
      expect(captured.syncStatus, HabitSyncStatusLocal.synced);
      expect(captured.lastSyncedAt, isNotNull);
    });

    test('pendingUpdate kaydını online olduğunda gönderir ve synced yapar', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: HabitSyncStatusLocal.pendingUpdate);
      when(() => local.getPendingSyncHabits()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setHabit(any())).thenAnswer((_) async {});
      when(() => local.putHabit(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verify(() => remote.setHabit(pendingModel)).called(1);
      final captured = verify(() => local.putHabit(captureAny())).captured.single as HabitLocalModel;
      expect(captured.syncStatus, HabitSyncStatusLocal.synced);
    });

    test('pendingDelete kaydını online olduğunda gönderir ve synced yapar (ADIM 2 düzeltmesi korunuyor)', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: HabitSyncStatusLocal.pendingDelete)
        ..isDeleted = true
        ..deletedAt = DateTime(2026, 1, 2);
      when(() => local.getPendingSyncHabits()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setHabit(any())).thenAnswer((_) async {});
      when(() => local.putHabit(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verify(() => remote.setHabit(pendingModel)).called(1);
      final captured = verify(() => local.putHabit(captureAny())).captured.single as HabitLocalModel;
      expect(captured.syncStatus, HabitSyncStatusLocal.synced);
      expect(captured.isDeleted, isTrue);
    });

    test('remote gönderimi hata verirse kayıt pending kalır, hiçbir istisna dışarı fırlamaz', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: HabitSyncStatusLocal.pendingUpdate);
      when(() => local.getPendingSyncHabits()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setHabit(any())).thenThrow(const NetworkException('boom'));

      await repository.syncPending();

      verifyNever(() => local.putHabit(any()));
      expect(pendingModel.syncStatus, HabitSyncStatusLocal.pendingUpdate);
    });
  });

  group('watchHabits', () {
    test('tüm alışkanlıkları döner', () async {
      final h1 = _model(habitId: 'a');
      final h2 = _model(habitId: 'b');
      when(() => local.watchHabits()).thenAnswer((_) => Stream.value([h1, h2]));

      final result = await repository.watchHabits().first;

      expect(result.map((h) => h.habitId), ['a', 'b']);
    });
  });
}
