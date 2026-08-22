import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/pomodoro/domain/entities/pomodoro_session.dart';
import 'package:productivity_app/features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'package:productivity_app/features/pomodoro/domain/usecases/complete_pomodoro_session_usecase.dart';
import 'package:productivity_app/features/pomodoro/domain/usecases/get_pomodoro_sessions_in_range_usecase.dart';
import 'package:productivity_app/features/pomodoro/domain/usecases/link_session_to_task_usecase.dart';
import 'package:productivity_app/features/pomodoro/domain/usecases/start_pomodoro_session_usecase.dart';
import 'package:productivity_app/features/pomodoro/domain/usecases/watch_pomodoro_sessions_by_task_usecase.dart';

PomodoroSession _session({
  String sessionId = 'p1',
  PomodoroSessionType type = PomodoroSessionType.work,
  String? taskId,
}) =>
    PomodoroSession(
      sessionId: sessionId,
      taskId: taskId,
      type: type,
      plannedDuration: const Duration(minutes: 25),
      actualDuration: Duration.zero,
      startedAt: DateTime(2026, 1, 1),
      isCompleted: false,
    );

class _FakePomodoroRepository implements PomodoroRepository {
  Result<PomodoroSession>? sessionResult;
  List<PomodoroSession> watchByTaskResult = const [];

  PomodoroSession? lastCreatedSession;
  ({String sessionId, Duration actualDuration, bool isCompleted})? lastCompleteArgs;
  ({String sessionId, String? taskId, bool clearTaskId})? lastLinkArgs;
  String? lastWatchedTaskId;

  @override
  String newSessionId() => 'generated-session-id';

  @override
  Stream<List<PomodoroSession>> watchSessionsByTask(String taskId) {
    lastWatchedTaskId = taskId;
    return Stream.value(watchByTaskResult);
  }

  @override
  Future<Result<PomodoroSession>> createSession(PomodoroSession session) async {
    lastCreatedSession = session;
    return sessionResult!;
  }

  @override
  Future<Result<PomodoroSession>> completeSession(
    String sessionId, {
    required Duration actualDuration,
    required bool isCompleted,
  }) async {
    lastCompleteArgs = (sessionId: sessionId, actualDuration: actualDuration, isCompleted: isCompleted);
    return sessionResult!;
  }

  @override
  Future<Result<PomodoroSession>> linkSessionToTask(
    String sessionId, {
    String? taskId,
    bool clearTaskId = false,
  }) async {
    lastLinkArgs = (sessionId: sessionId, taskId: taskId, clearTaskId: clearTaskId);
    return sessionResult!;
  }

  List<PomodoroSession> rangeResult = const [];
  ({DateTime start, DateTime end})? lastRangeArgs;

  @override
  Future<List<PomodoroSession>> getSessionsInRange(DateTime start, DateTime end) async {
    lastRangeArgs = (start: start, end: end);
    return rangeResult;
  }
}

void main() {
  late _FakePomodoroRepository repo;

  setUp(() => repo = _FakePomodoroRepository());

  test('StartPomodoroSessionUseCase oturumu repository\'ye iletir', () async {
    repo.sessionResult = Ok(_session());
    final result = await StartPomodoroSessionUseCase(repo).call(_session());
    expect(repo.lastCreatedSession?.sessionId, 'p1');
    expect(result, isA<Ok<PomodoroSession>>());
  });

  test('CompletePomodoroSessionUseCase actualDuration/isCompleted argümanlarını iletir', () async {
    repo.sessionResult = Ok(_session());
    await CompletePomodoroSessionUseCase(repo)
        .call('p1', actualDuration: const Duration(minutes: 12), isCompleted: false);

    expect(
      repo.lastCompleteArgs,
      (sessionId: 'p1', actualDuration: const Duration(minutes: 12), isCompleted: false),
    );
  });

  test('LinkSessionToTaskUseCase clear bayrağını iletir', () async {
    repo.sessionResult = Ok(_session());
    await LinkSessionToTaskUseCase(repo).call('p1', clearTaskId: true);

    expect(repo.lastLinkArgs, (sessionId: 'p1', taskId: null, clearTaskId: true));
  });

  test('WatchPomodoroSessionsByTaskUseCase taskId\'yi iletir', () async {
    repo.watchByTaskResult = [_session(taskId: 't1')];
    final result = await WatchPomodoroSessionsByTaskUseCase(repo).call('t1').first;

    expect(repo.lastWatchedTaskId, 't1');
    expect(result, hasLength(1));
  });

  test('GetPomodoroSessionsInRangeUseCase start/end argümanlarını iletir', () async {
    final start = DateTime(2026, 1, 1);
    final end = DateTime(2026, 1, 7, 23, 59, 59);
    repo.rangeResult = [_session()];

    final result = await GetPomodoroSessionsInRangeUseCase(repo).call(start, end);

    expect(repo.lastRangeArgs, (start: start, end: end));
    expect(result, hasLength(1));
  });

  test('Err durumunda usecase Err\'i olduğu gibi döndürür', () async {
    repo.sessionResult = const Err(CacheFailure('boom'));
    final result = await StartPomodoroSessionUseCase(repo).call(_session());
    expect(result, isA<Err<PomodoroSession>>());
  });
}
