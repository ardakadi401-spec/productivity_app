import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/exceptions/app_exceptions.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';
import 'package:productivity_app/features/pomodoro/data/datasources/local/pomodoro_local_datasource.dart';
import 'package:productivity_app/features/pomodoro/data/datasources/remote/pomodoro_remote_datasource.dart';
import 'package:productivity_app/features/pomodoro/data/models/pomodoro_session_local_model.dart';
import 'package:productivity_app/features/pomodoro/data/repositories/pomodoro_repository_impl.dart';
import 'package:productivity_app/features/pomodoro/domain/entities/pomodoro_session.dart';

class _MockLocal extends Mock implements PomodoroLocalDatasource {}

class _MockRemote extends Mock implements PomodoroRemoteDatasource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

PomodoroSession _session({String sessionId = 'p1'}) => PomodoroSession(
      sessionId: sessionId,
      type: PomodoroSessionType.work,
      plannedDuration: const Duration(minutes: 25),
      actualDuration: Duration.zero,
      startedAt: DateTime(2026, 1, 1),
      isCompleted: false,
    );

PomodoroSessionLocalModel _model({
  String sessionId = 'p1',
  String? taskId,
  bool isCompleted = false,
  PomodoroSyncStatusLocal syncStatus = PomodoroSyncStatusLocal.pendingCreate,
}) {
  final now = DateTime(2026, 1, 1);
  return PomodoroSessionLocalModel()
    ..sessionId = sessionId
    ..taskId = taskId
    ..type = PomodoroSessionTypeLocal.work
    ..plannedDurationSeconds = 25 * 60
    ..actualDurationSeconds = 0
    ..startedAt = now
    ..isCompleted = isCompleted
    ..syncStatus = syncStatus
    ..localUpdatedAt = now;
}

void main() {
  late _MockLocal local;
  late _MockRemote remote;
  late _MockConnectivity connectivity;
  late PomodoroRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_model());
  });

  setUp(() {
    local = _MockLocal();
    remote = _MockRemote();
    connectivity = _MockConnectivity();
    when(() => connectivity.isConnected).thenAnswer((_) async => false);
    when(() => local.getPendingSync()).thenAnswer((_) async => []);
    repository = PomodoroRepositoryImpl(local, remote, connectivity);
  });

  group('createSession', () {
    test(
      'bağlantı yokken yalnızca yerele pendingCreate ile yazar, remote çağrılmaz '
      '(ROADMAP FAZ 11 "kill-safety" — oturum başlangıcında kalıcı kayıt)',
      () async {
        when(() => local.putSession(any())).thenAnswer((_) async {});

        final result = await repository.createSession(_session());

        expect(result, isA<Ok<PomodoroSession>>());
        final captured =
            verify(() => local.putSession(captureAny())).captured.single as PomodoroSessionLocalModel;
        expect(captured.syncStatus, PomodoroSyncStatusLocal.pendingCreate);
        expect(captured.isCompleted, isFalse);
        verifyNever(() => remote.setSession(any()));
      },
    );

    test('bağlantı varken yerele yazar, remote\'a gönderir, ardından synced işaretler', () async {
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      when(() => local.putSession(any())).thenAnswer((_) async {});
      when(() => remote.setSession(any())).thenAnswer((_) async {});

      await repository.createSession(_session());

      verify(() => remote.setSession(any())).called(1);
      final calls = verify(() => local.putSession(captureAny())).captured.cast<PomodoroSessionLocalModel>();
      expect(calls.last.syncStatus, PomodoroSyncStatusLocal.synced);
    });

    test('yerel yazma CacheException fırlatırsa Err(CacheFailure) döner', () async {
      when(() => local.putSession(any())).thenThrow(const CacheException('disk dolu'));

      final result = await repository.createSession(_session());

      expect(result, isA<Err<PomodoroSession>>());
      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('completeSession', () {
    test('actualDuration/isCompleted/completedAt günceller', () async {
      when(() => local.getBySessionId('p1')).thenAnswer((_) async => _model());
      when(() => local.putSession(any())).thenAnswer((_) async {});

      final result = await repository.completeSession(
        'p1',
        actualDuration: const Duration(minutes: 25),
        isCompleted: true,
      );

      expect(result, isA<Ok<PomodoroSession>>());
      final captured =
          verify(() => local.putSession(captureAny())).captured.single as PomodoroSessionLocalModel;
      expect(captured.actualDurationSeconds, 25 * 60);
      expect(captured.isCompleted, isTrue);
      expect(captured.completedAt, isNotNull);
    });

    test('erken iptalde isCompleted:false ile de kaydedilebilir (yarıda kalan oturum)', () async {
      when(() => local.getBySessionId('p1')).thenAnswer((_) async => _model());
      when(() => local.putSession(any())).thenAnswer((_) async {});

      final result = await repository.completeSession(
        'p1',
        actualDuration: const Duration(minutes: 7),
        isCompleted: false,
      );

      expect(result, isA<Ok<PomodoroSession>>());
      final captured =
          verify(() => local.putSession(captureAny())).captured.single as PomodoroSessionLocalModel;
      expect(captured.actualDurationSeconds, 7 * 60);
      expect(captured.isCompleted, isFalse);
    });

    test('kayıt bulunamazsa CacheFailure döner', () async {
      when(() => local.getBySessionId('missing')).thenAnswer((_) async => null);

      final result = await repository.completeSession(
        'missing',
        actualDuration: Duration.zero,
        isCompleted: false,
      );

      expect((result as Err).failure, isA<CacheFailure>());
    });
  });

  group('linkSessionToTask', () {
    test('taskId set eder', () async {
      when(() => local.getBySessionId('p1')).thenAnswer((_) async => _model());
      when(() => local.putSession(any())).thenAnswer((_) async {});

      await repository.linkSessionToTask('p1', taskId: 't1');

      final captured =
          verify(() => local.putSession(captureAny())).captured.single as PomodoroSessionLocalModel;
      expect(captured.taskId, 't1');
    });

    test('clearTaskId ile bağlantı temizlenir — görev silindiğinde geçmiş kayıt bozulmadan kalır', () async {
      when(() => local.getBySessionId('p1')).thenAnswer((_) async => _model(taskId: 't1'));
      when(() => local.putSession(any())).thenAnswer((_) async {});

      final result = await repository.linkSessionToTask('p1', clearTaskId: true);

      expect(result, isA<Ok<PomodoroSession>>());
      final captured =
          verify(() => local.putSession(captureAny())).captured.single as PomodoroSessionLocalModel;
      expect(captured.taskId, isNull);
    });
  });

  group('syncPending — FAZ 14 (SyncCoordinator giriş noktası)', () {
    test('offline durumda hiçbir şey yapmaz', () async {
      await Future<void>.delayed(Duration.zero);

      await repository.syncPending();

      verifyNever(() => remote.setSession(any()));
    });

    test('pendingUpdate kaydını online olduğunda gönderir ve synced yapar', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: PomodoroSyncStatusLocal.pendingUpdate);
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setSession(any())).thenAnswer((_) async {});
      when(() => local.putSession(any())).thenAnswer((_) async {});

      await repository.syncPending();

      verify(() => remote.setSession(pendingModel)).called(1);
      final captured =
          verify(() => local.putSession(captureAny())).captured.single as PomodoroSessionLocalModel;
      expect(captured.syncStatus, PomodoroSyncStatusLocal.synced);
    });

    test('remote gönderimi hata verirse kayıt pending kalır', () async {
      await Future<void>.delayed(Duration.zero);
      when(() => connectivity.isConnected).thenAnswer((_) async => true);
      final pendingModel = _model(syncStatus: PomodoroSyncStatusLocal.pendingUpdate);
      when(() => local.getPendingSync()).thenAnswer((_) async => [pendingModel]);
      when(() => remote.setSession(any())).thenThrow(const NetworkException('boom'));

      await repository.syncPending();

      verifyNever(() => local.putSession(any()));
      expect(pendingModel.syncStatus, PomodoroSyncStatusLocal.pendingUpdate);
    });
  });

  test('watchSessionsByTask local datasource\'u entity\'ye eşleyerek döner', () async {
    when(() => local.watchSessionsByTask('t1'))
        .thenAnswer((_) => Stream.value([_model(sessionId: 'p1', taskId: 't1')]));

    final result = await repository.watchSessionsByTask('t1').first;

    expect(result.map((s) => s.sessionId), ['p1']);
  });
}
