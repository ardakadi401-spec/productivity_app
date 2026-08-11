import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/exceptions/app_exceptions.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/features/goals/data/datasources/local/goal_local_datasource.dart';
import 'package:productivity_app/features/goals/data/datasources/remote/goal_remote_datasource.dart';
import 'package:productivity_app/features/goals/data/models/goal_local_model.dart';
import 'package:productivity_app/features/goals/data/repositories/goal_repository_impl.dart';
import 'package:productivity_app/features/goals/domain/entities/goal.dart';

class _MockLocal extends Mock implements GoalLocalDatasource {}

class _MockRemote extends Mock implements GoalRemoteDatasource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

Goal _goal({String goalId = 'g1'}) => Goal(
      goalId: goalId,
      title: 'Hedef',
      periodType: GoalPeriodType.daily,
      periodStartDate: DateTime(2026, 1, 1),
      periodEndDate: DateTime(2026, 1, 1, 23, 59, 59),
      progressType: GoalProgressType.manual,
      manualProgress: 0,
      status: GoalStatus.inProgress,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

GoalLocalModel _model({
  String goalId = 'g1',
  GoalSyncStatusLocal syncStatus = GoalSyncStatusLocal.pendingCreate,
  GoalStatusLocal status = GoalStatusLocal.inProgress,
}) {
  final now = DateTime(2026, 1, 1);
  return GoalLocalModel()
    ..goalId = goalId
    ..title = 'Hedef'
    ..periodType = GoalPeriodTypeLocal.daily
    ..periodStartDate = now
    ..periodEndDate = DateTime(2026, 1, 1, 23, 59, 59)
    ..progressType = GoalProgressTypeLocal.manual
    ..manualProgress = 0
    ..status = status
    ..createdAt = now
    ..updatedAt = now
    ..isDeleted = false
    ..syncStatus = syncStatus
    ..localUpdatedAt = now;
}

void main() {
  late _MockLocal local;
  late _MockRemote remote;
  late _MockConnectivity connectivity;
  late GoalRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_model());
  });

  setUp(() {
    local = _MockLocal();
    remote = _MockRemote();
    connectivity = _MockConnectivity();
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    when(() => local.getPendingSync()).thenAnswer((_) async => []);
    repository = GoalRepositoryImpl(local, remote, connectivity);
  });

  group('createGoal', () {
    test('bağlantı yokken yalnızca yerele pendingCreate ile yazar, remote çağrılmaz', () async {
      when(() => local.putGoal(any())).thenAnswer((_) async {});

      final result = await repository.createGoal(_goal());

      expect(result, isA<Ok<Goal>>());
      final captured = verify(() => local.putGoal(captureAny())).captured.single as GoalLocalModel;
      expect(captured.syncStatus, GoalSyncStatusLocal.pendingCreate);
      verifyNever(() => remote.setGoal(any()));
    });

    test('bağlantı varken yerele yazar, remote\'a gönderir, ardından synced işaretler', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putGoal(any())).thenAnswer((_) async {});
      when(() => remote.setGoal(any())).thenAnswer((_) async {});

      await repository.createGoal(_goal());

      verify(() => remote.setGoal(any())).called(1);
      final calls = verify(() => local.putGoal(captureAny())).captured.cast<GoalLocalModel>();
      expect(calls.last.syncStatus, GoalSyncStatusLocal.synced);
    });

    test('remote gönderimi başarısız olursa kayıt pending kalır ama Ok döner', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putGoal(any())).thenAnswer((_) async {});
      when(() => remote.setGoal(any())).thenThrow(const NetworkException('boom'));

      final result = await repository.createGoal(_goal());

      expect(result, isA<Ok<Goal>>());
      final calls = verify(() => local.putGoal(captureAny())).captured.cast<GoalLocalModel>();
      expect(calls.last.syncStatus, GoalSyncStatusLocal.pendingCreate);
    });

    test('yerel yazma CacheException fırlatırsa Err(CacheFailure) döner', () async {
      when(() => local.putGoal(any())).thenThrow(const CacheException('disk dolu'));

      final result = await repository.createGoal(_goal());

      expect(result, isA<Err<Goal>>());
      final failure = (result as Err).failure;
      expect(failure, isA<CacheFailure>());
      expect(failure.message, 'disk dolu');
    });
  });

  group('setManualProgress', () {
    test('manualProgress alanını günceller', () async {
      when(() => local.getByGoalId('g1')).thenAnswer((_) async => _model());
      when(() => local.putGoal(any())).thenAnswer((_) async {});

      final result = await repository.setManualProgress('g1', progress: 75);

      expect(result, isA<Ok<Goal>>());
      final captured = verify(() => local.putGoal(captureAny())).captured.single as GoalLocalModel;
      expect(captured.manualProgress, 75);
    });

    test('kayıt bulunamazsa CacheFailure döner', () async {
      when(() => local.getByGoalId('missing')).thenAnswer((_) async => null);

      final result = await repository.setManualProgress('missing', progress: 50);

      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('setGoalStatus', () {
    test('achieved olarak işaretler', () async {
      when(() => local.getByGoalId('g1')).thenAnswer((_) async => _model());
      when(() => local.putGoal(any())).thenAnswer((_) async {});

      final result = await repository.setGoalStatus('g1', status: GoalStatus.achieved);

      expect(result, isA<Ok<Goal>>());
      final captured = verify(() => local.putGoal(captureAny())).captured.single as GoalLocalModel;
      expect(captured.status, GoalStatusLocal.achieved);
    });
  });

  group('watchGoals filtreleme', () {
    test('periodType verilmezse tüm hedefleri döner', () async {
      final daily = _model(goalId: 'd');
      final weekly = _model(goalId: 'w')..periodType = GoalPeriodTypeLocal.weekly;
      when(() => local.watchGoals()).thenAnswer((_) => Stream.value([daily, weekly]));

      final result = await repository.watchGoals().first;

      expect(result.map((g) => g.goalId), ['d', 'w']);
    });

    test('periodType verilirse yalnızca eşleşenleri döner', () async {
      final daily = _model(goalId: 'd');
      final weekly = _model(goalId: 'w')..periodType = GoalPeriodTypeLocal.weekly;
      when(() => local.watchGoals()).thenAnswer((_) => Stream.value([daily, weekly]));

      final result = await repository.watchGoals(periodType: GoalPeriodType.weekly).first;

      expect(result.map((g) => g.goalId), ['w']);
    });
  });
}
