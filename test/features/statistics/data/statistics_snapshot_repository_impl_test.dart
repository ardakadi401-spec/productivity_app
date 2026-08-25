import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/exceptions/app_exceptions.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/features/statistics/data/datasources/local/statistics_snapshot_local_datasource.dart';
import 'package:productivity_app/features/statistics/data/datasources/remote/statistics_snapshot_remote_datasource.dart';
import 'package:productivity_app/features/statistics/data/models/statistics_snapshot_local_model.dart';
import 'package:productivity_app/features/statistics/data/repositories/statistics_snapshot_repository_impl.dart';
import 'package:productivity_app/features/statistics/domain/entities/statistics_snapshot.dart';

class _MockLocal extends Mock implements StatisticsSnapshotLocalDatasource {}

class _MockRemote extends Mock implements StatisticsSnapshotRemoteDatasource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

StatisticsSnapshot _snapshot({DateTime? date}) => StatisticsSnapshot(
      date: date ?? DateTime(2026, 1, 1),
      tasksCompleted: 3,
      tasksCreated: 2,
      habitsCompletedCount: 1,
      habitsTotalCount: 2,
      pomodoroSessionsCompleted: 4,
      pomodoroTotalMinutes: 100,
      createdAt: DateTime(2026, 1, 1),
    );

StatisticsSnapshotLocalModel _model({DateTime? date}) {
  final d = date ?? DateTime(2026, 1, 1);
  return StatisticsSnapshotLocalModel()
    ..snapshotId = StatisticsSnapshot.formatSnapshotId(d)
    ..date = d
    ..tasksCompleted = 3
    ..tasksCreated = 2
    ..habitsCompletedCount = 1
    ..habitsTotalCount = 2
    ..pomodoroSessionsCompleted = 4
    ..pomodoroTotalMinutes = 100
    ..createdAt = d
    ..syncStatus = StatisticsSyncStatusLocal.pendingCreate
    ..localUpdatedAt = d;
}

void main() {
  late _MockLocal local;
  late _MockRemote remote;
  late _MockConnectivity connectivity;
  late StatisticsSnapshotRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_model());
    registerFallbackValue(DateTime(2026, 1, 1));
  });

  setUp(() {
    local = _MockLocal();
    remote = _MockRemote();
    connectivity = _MockConnectivity();
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    when(() => local.getPendingSync()).thenAnswer((_) async => []);
    repository = StatisticsSnapshotRepositoryImpl(local, remote, connectivity);
  });

  group('saveSnapshot', () {
    test('bağlantı yokken yalnızca yerele pendingCreate ile yazar, remote çağrılmaz', () async {
      when(() => local.putSnapshot(any())).thenAnswer((_) async {});

      final result = await repository.saveSnapshot(_snapshot());

      expect(result, isA<Ok<StatisticsSnapshot>>());
      final captured =
          verify(() => local.putSnapshot(captureAny())).captured.single as StatisticsSnapshotLocalModel;
      expect(captured.syncStatus, StatisticsSyncStatusLocal.pendingCreate);
      verifyNever(() => remote.setSnapshot(any()));
    });

    test('bağlantı varken yerele yazar, remote\'a gönderir, ardından synced işaretler', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putSnapshot(any())).thenAnswer((_) async {});
      when(() => remote.setSnapshot(any())).thenAnswer((_) async {});

      await repository.saveSnapshot(_snapshot());

      verify(() => remote.setSnapshot(any())).called(1);
      final calls =
          verify(() => local.putSnapshot(captureAny())).captured.cast<StatisticsSnapshotLocalModel>();
      expect(calls.last.syncStatus, StatisticsSyncStatusLocal.synced);
    });

    test('yerel yazma CacheException fırlatırsa Err(CacheFailure) döner', () async {
      when(() => local.putSnapshot(any())).thenThrow(const CacheException('disk dolu'));

      final result = await repository.saveSnapshot(_snapshot());

      expect(result, isA<Err<StatisticsSnapshot>>());
      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('syncPending — FAZ 14 (SyncCoordinator giriş noktası + retention)', () {
    test('offline durumda pending gönderilmez ama yerel retention yine de çalışır', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => local.pruneSyncedOlderThan(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verifyNever(() => remote.setSnapshot(any()));
      verify(() => local.pruneSyncedOlderThan(any())).called(1);
    });

    test('pendingCreate kaydını online olduğunda gönderir, synced yapar ve retention uygular', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model();
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setSnapshot(any())).thenAnswer((_) async {});
      when(() => local.putSnapshot(any())).thenAnswer((_) async {});
      when(() => local.pruneSyncedOlderThan(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verify(() => remote.setSnapshot(pendingModel)).called(1);
      final captured =
          verify(() => local.putSnapshot(captureAny())).captured.single as StatisticsSnapshotLocalModel;
      expect(captured.syncStatus, StatisticsSyncStatusLocal.synced);
      // DATABASE.md §12.3 — yalnızca zaten `synced` ve pencereden eski
      // kayıtlar budanır; cutoff ~90 gün önce olmalı.
      final cutoff = verify(() => local.pruneSyncedOlderThan(captureAny())).captured.single as DateTime;
      expect(DateTime.now().difference(cutoff).inDays, closeTo(90, 1));
    });

    test('remote gönderimi hata verirse kayıt pending kalır (retention yine de dener)', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model();
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setSnapshot(any())).thenThrow(const NetworkException('boom'));
      when(() => local.pruneSyncedOlderThan(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verifyNever(() => local.putSnapshot(any()));
      expect(pendingModel.syncStatus, StatisticsSyncStatusLocal.pendingCreate);
    });
  });

  test('getSnapshotsInRange local datasource\'u entity\'ye eşleyerek döner', () async {
    when(() => local.getSnapshotsInRange(DateTime(2026, 1, 1), DateTime(2026, 1, 7)))
        .thenAnswer((_) async => [_model(date: DateTime(2026, 1, 3))]);

    final result = await repository.getSnapshotsInRange(DateTime(2026, 1, 1), DateTime(2026, 1, 7));

    expect(result, hasLength(1));
    expect(result.single.date, DateTime(2026, 1, 3));
  });

  group('getSnapshotsInRange — retention penceresi dışına düşen (90+ gün önce) aralıklar', () {
    test('bağlantı varsa Firestore\'dan çekip yerele geri yazar (arşiv veri kaybolmaz)', () async {
      final farStart = DateTime.now().subtract(const Duration(days: 200));
      final farEnd = DateTime.now().subtract(const Duration(days: 190));
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchSnapshotsInRange(farStart, farEnd))
          .thenAnswer((_) async => [_model(date: farStart)]);
      when(() => local.getBySnapshotId(any())).thenAnswer((_) async => null);
      when(() => local.putSnapshot(any())).thenAnswer((_) async {});
      when(() => local.getSnapshotsInRange(farStart, farEnd))
          .thenAnswer((_) async => [_model(date: farStart)]);

      final result = await repository.getSnapshotsInRange(farStart, farEnd);

      verify(() => remote.fetchSnapshotsInRange(farStart, farEnd)).called(1);
      verify(() => local.putSnapshot(any())).called(1);
      expect(result, hasLength(1));
    });

    test('bağlantı yoksa remote\'a hiç istek atmadan yalnızca yereldeki (varsa) sonuçla döner', () async {
      final farStart = DateTime.now().subtract(const Duration(days: 200));
      final farEnd = DateTime.now().subtract(const Duration(days: 190));
      when(() => connectivity.isConnected).thenAnswer((_) async => false);
      when(() => local.getSnapshotsInRange(farStart, farEnd)).thenAnswer((_) async => []);

      final result = await repository.getSnapshotsInRange(farStart, farEnd);

      verifyNever(() => remote.fetchSnapshotsInRange(any(), any()));
      expect(result, isEmpty);
    });
  });
}
