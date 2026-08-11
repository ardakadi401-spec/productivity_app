import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/goals/domain/entities/goal.dart';
import 'package:productivity_app/features/goals/domain/repositories/goal_repository.dart';
import 'package:productivity_app/features/goals/domain/usecases/check_expired_goals_usecase.dart';
import 'package:productivity_app/features/goals/domain/usecases/create_goal_usecase.dart';
import 'package:productivity_app/features/goals/domain/usecases/update_goal_progress_usecase.dart';
import 'package:productivity_app/features/goals/domain/usecases/update_goal_usecase.dart';
import 'package:productivity_app/features/goals/domain/usecases/watch_goal_usecase.dart';
import 'package:productivity_app/features/goals/domain/usecases/watch_goals_usecase.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/domain/usecases/watch_tasks_usecase.dart';

Goal _goal({
  String goalId = 'g1',
  GoalStatus status = GoalStatus.inProgress,
  DateTime? periodEndDate,
  GoalProgressType progressType = GoalProgressType.manual,
  int? manualProgress,
  List<String> linkedTaskIds = const [],
}) =>
    Goal(
      goalId: goalId,
      title: 'Örnek hedef',
      periodType: GoalPeriodType.daily,
      periodStartDate: DateTime(2026, 1, 1),
      periodEndDate: periodEndDate ?? DateTime(2026, 1, 1, 23, 59, 59),
      progressType: progressType,
      manualProgress: manualProgress,
      linkedTaskIds: linkedTaskIds,
      status: status,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _FakeGoalRepository implements GoalRepository {
  Result<Goal>? goalResult;
  List<Goal> watchGoalsResult = const [];
  Goal? watchGoalResult;

  GoalPeriodType? lastPeriodFilter;
  String? lastWatchedGoalId;
  Goal? lastCreatedGoal;
  Goal? lastUpdatedGoal;
  ({String goalId, int progress})? lastProgressArgs;
  final List<({String goalId, GoalStatus status})> statusCalls = [];

  @override
  String newGoalId() => 'generated-goal-id';

  @override
  Stream<List<Goal>> watchGoals({GoalPeriodType? periodType}) {
    lastPeriodFilter = periodType;
    return Stream.value(watchGoalsResult);
  }

  @override
  Stream<Goal?> watchGoal(String goalId) {
    lastWatchedGoalId = goalId;
    return Stream.value(watchGoalResult);
  }

  @override
  Future<Result<Goal>> createGoal(Goal goal) async {
    lastCreatedGoal = goal;
    return goalResult!;
  }

  @override
  Future<Result<Goal>> updateGoal(Goal goal) async {
    lastUpdatedGoal = goal;
    return goalResult!;
  }

  @override
  Future<Result<Goal>> setManualProgress(String goalId, {required int progress}) async {
    lastProgressArgs = (goalId: goalId, progress: progress);
    return goalResult!;
  }

  @override
  Future<Result<Goal>> setGoalStatus(String goalId, {required GoalStatus status}) async {
    statusCalls.add((goalId: goalId, status: status));
    return goalResult!;
  }
}

Task _task({String taskId = 't1', bool isCompleted = false}) => Task(
      taskId: taskId,
      title: 'Görev',
      priority: TaskPriority.medium,
      status: isCompleted ? TaskStatus.completed : TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _FakeTaskRepository implements TaskRepository {
  List<Task> tasksResult = const [];

  @override
  String newTaskId() => 'id';
  @override
  String newSubTaskId(String taskId) => 'id';
  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => Stream.value(tasksResult);
  @override
  Stream<Task?> watchTask(String taskId) => const Stream.empty();
  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => const Stream.empty();
  @override
  Stream<List<Task>> watchTodayTasks() => const Stream.empty();
  @override
  Future<Result<Task>> createTask(Task task) => throw UnimplementedError();
  @override
  Future<Result<Task>> updateTask(Task task) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteTask(String taskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> setTaskCompleted(String taskId, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<Result<SubTask>> addSubTask(SubTask subTask) => throw UnimplementedError();
  @override
  Future<Result<void>> setSubTaskCompleted(String subtaskId, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<Result<Task>> recalculateTaskProgress(String taskId) => throw UnimplementedError();
}

void main() {
  late _FakeGoalRepository repo;

  setUp(() => repo = _FakeGoalRepository());

  test('CreateGoalUseCase hedefi repository\'ye iletir', () async {
    repo.goalResult = Ok(_goal());
    final result = await CreateGoalUseCase(repo).call(_goal());
    expect(repo.lastCreatedGoal?.goalId, 'g1');
    expect(result, isA<Ok<Goal>>());
  });

  test('UpdateGoalUseCase hedefi repository\'ye iletir', () async {
    repo.goalResult = Ok(_goal());
    await UpdateGoalUseCase(repo).call(_goal());
    expect(repo.lastUpdatedGoal?.goalId, 'g1');
  });

  test('UpdateGoalProgressUseCase 0-100 aralığına sıkıştırır (clamp)', () async {
    repo.goalResult = Ok(_goal());
    await UpdateGoalProgressUseCase(repo).call('g1', progress: 150);
    expect(repo.lastProgressArgs, (goalId: 'g1', progress: 100));

    await UpdateGoalProgressUseCase(repo).call('g1', progress: -10);
    expect(repo.lastProgressArgs, (goalId: 'g1', progress: 0));
  });

  test('WatchGoalsUseCase periodType filtresini iletir', () async {
    repo.watchGoalsResult = [_goal()];
    await WatchGoalsUseCase(repo).call(periodType: GoalPeriodType.weekly).first;
    expect(repo.lastPeriodFilter, GoalPeriodType.weekly);
  });

  test('WatchGoalUseCase goalId\'yi iletir', () async {
    repo.watchGoalResult = _goal();
    await WatchGoalUseCase(repo).call('g1').first;
    expect(repo.lastWatchedGoalId, 'g1');
  });

  test('Err durumunda usecase Err\'i olduğu gibi döndürür', () async {
    repo.goalResult = const Err(CacheFailure('boom'));
    final result = await CreateGoalUseCase(repo).call(_goal());
    expect(result, isA<Err<Goal>>());
  });

  group('CheckExpiredGoalsUseCase', () {
    test('dönemi dolmamış inProgress hedeflere dokunmaz', () async {
      repo.goalResult = Ok(_goal());
      repo.watchGoalsResult = [_goal(periodEndDate: DateTime.now().add(const Duration(days: 1)))];
      final taskRepo = _FakeTaskRepository();

      await CheckExpiredGoalsUseCase(repo, WatchTasksUseCase(taskRepo)).call();

      expect(repo.statusCalls, isEmpty);
    });

    test('manuel ilerlemesi %100 olan, dönemi dolmuş hedef achieved olarak işaretlenir', () async {
      repo.goalResult = Ok(_goal());
      repo.watchGoalsResult = [
        _goal(
          periodEndDate: DateTime.now().subtract(const Duration(days: 1)),
          manualProgress: 100,
        ),
      ];
      final taskRepo = _FakeTaskRepository();

      await CheckExpiredGoalsUseCase(repo, WatchTasksUseCase(taskRepo)).call();

      expect(repo.statusCalls, [(goalId: 'g1', status: GoalStatus.achieved)]);
    });

    test('manuel ilerlemesi %100\'ün altında, dönemi dolmuş hedef missed olarak işaretlenir', () async {
      repo.goalResult = Ok(_goal());
      repo.watchGoalsResult = [
        _goal(
          periodEndDate: DateTime.now().subtract(const Duration(days: 1)),
          manualProgress: 40,
        ),
      ];
      final taskRepo = _FakeTaskRepository();

      await CheckExpiredGoalsUseCase(repo, WatchTasksUseCase(taskRepo)).call();

      expect(repo.statusCalls, [(goalId: 'g1', status: GoalStatus.missed)]);
    });

    test(
      'linkedTasks tipi: tüm bağlı görevler tamamlandığında achieved (unit test — ROADMAP FAZ 8 kriteri)',
      () async {
        repo.goalResult = Ok(_goal());
        repo.watchGoalsResult = [
          _goal(
            periodEndDate: DateTime.now().subtract(const Duration(days: 1)),
            progressType: GoalProgressType.linkedTasks,
            linkedTaskIds: const ['t1', 't2'],
          ),
        ];
        final taskRepo = _FakeTaskRepository()
          ..tasksResult = [
            _task(taskId: 't1', isCompleted: true),
            _task(taskId: 't2', isCompleted: true),
          ];

        await CheckExpiredGoalsUseCase(repo, WatchTasksUseCase(taskRepo)).call();

        expect(repo.statusCalls, [(goalId: 'g1', status: GoalStatus.achieved)]);
      },
    );

    test('linkedTasks tipi: bir görev tamamlanmamışsa missed', () async {
      repo.goalResult = Ok(_goal());
      repo.watchGoalsResult = [
        _goal(
          periodEndDate: DateTime.now().subtract(const Duration(days: 1)),
          progressType: GoalProgressType.linkedTasks,
          linkedTaskIds: const ['t1', 't2'],
        ),
      ];
      final taskRepo = _FakeTaskRepository()
        ..tasksResult = [
          _task(taskId: 't1', isCompleted: true),
          _task(taskId: 't2'),
        ];

      await CheckExpiredGoalsUseCase(repo, WatchTasksUseCase(taskRepo)).call();

      expect(repo.statusCalls, [(goalId: 'g1', status: GoalStatus.missed)]);
    });

    test(
      'uygulama o gün hiç açılmasa bile bir sonraki açılışta (tek call) doğru arşivlenir',
      () async {
        repo.goalResult = Ok(_goal());
        // Dönemi 10 gün önce dolmuş, kullanıcı 10 gündür uygulamayı açmamış
        // senaryosu — usecase yalnızca "şu an"a göre kontrol eder.
        repo.watchGoalsResult = [
          _goal(
            periodEndDate: DateTime.now().subtract(const Duration(days: 10)),
            manualProgress: 100,
          ),
        ];
        final taskRepo = _FakeTaskRepository();

        await CheckExpiredGoalsUseCase(repo, WatchTasksUseCase(taskRepo)).call();

        expect(repo.statusCalls, [(goalId: 'g1', status: GoalStatus.achieved)]);
      },
    );

    test('achieved/missed durumundaki hedeflere tekrar dokunmaz (idempotent)', () async {
      repo.watchGoalsResult = [
        _goal(
          status: GoalStatus.achieved,
          periodEndDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      final taskRepo = _FakeTaskRepository();

      await CheckExpiredGoalsUseCase(repo, WatchTasksUseCase(taskRepo)).call();

      expect(repo.statusCalls, isEmpty);
    });
  });
}
