import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/calendar/domain/entities/calendar_event.dart';
import 'package:productivity_app/features/calendar/domain/usecases/get_goals_by_date_usecase.dart';
import 'package:productivity_app/features/calendar/domain/usecases/get_tasks_by_date_usecase.dart';
import 'package:productivity_app/features/calendar/domain/usecases/get_tasks_by_month_usecase.dart';
import 'package:productivity_app/features/goals/domain/entities/goal.dart';
import 'package:productivity_app/features/goals/domain/repositories/goal_repository.dart';
import 'package:productivity_app/features/goals/domain/usecases/watch_goals_usecase.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/domain/usecases/watch_tasks_usecase.dart';

Task _task({
  String taskId = 't1',
  DateTime? dueDate,
  bool isCompleted = false,
}) =>
    Task(
      taskId: taskId,
      title: 'Görev $taskId',
      priority: TaskPriority.medium,
      status: isCompleted ? TaskStatus.completed : TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      dueDate: dueDate,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _FakeTaskRepository implements TaskRepository {
  List<Task> tasksResult = const [];
  TaskFilter? lastFilter;

  @override
  String newTaskId() => 'id';
  @override
  String newSubTaskId(String taskId) => 'id';

  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) {
    lastFilter = filter;
    return Stream.value(tasksResult);
  }

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

Goal _goal({
  String goalId = 'g1',
  required DateTime periodEndDate,
}) =>
    Goal(
      goalId: goalId,
      title: 'Hedef $goalId',
      periodType: GoalPeriodType.weekly,
      periodStartDate: DateTime(2026, 1, 1),
      periodEndDate: periodEndDate,
      progressType: GoalProgressType.manual,
      manualProgress: 50,
      status: GoalStatus.inProgress,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _FakeGoalRepository implements GoalRepository {
  List<Goal> goalsResult = const [];

  @override
  String newGoalId() => 'id';
  @override
  Stream<List<Goal>> watchGoals({GoalPeriodType? periodType}) => Stream.value(goalsResult);
  @override
  Stream<Goal?> watchGoal(String goalId) => const Stream.empty();
  @override
  Future<Result<Goal>> createGoal(Goal goal) => throw UnimplementedError();
  @override
  Future<Result<Goal>> updateGoal(Goal goal) => throw UnimplementedError();
  @override
  Future<Result<Goal>> setManualProgress(String goalId, {required int progress}) =>
      throw UnimplementedError();
  @override
  Future<Result<Goal>> setGoalStatus(String goalId, {required GoalStatus status}) =>
      throw UnimplementedError();
}

void main() {
  group('GetGoalsByDateUseCase', () {
    test('yalnızca periodEndDate\'i o güne denk gelen hedefleri döner (SCREENS §4.13)', () async {
      final repo = _FakeGoalRepository()
        ..goalsResult = [
          _goal(goalId: 'ends-today', periodEndDate: DateTime(2026, 3, 15, 23, 59, 59)),
          _goal(goalId: 'ends-later', periodEndDate: DateTime(2026, 3, 20, 23, 59, 59)),
        ];
      final useCase = GetGoalsByDateUseCase(WatchGoalsUseCase(repo));

      final result = await useCase.call(DateTime(2026, 3, 15)).first;

      expect(result.map((e) => e.id), ['ends-today']);
      expect(result.single.source, CalendarEventSource.goal);
    });

    test('o gün biten hedef yoksa boş liste döner', () async {
      final repo = _FakeGoalRepository()
        ..goalsResult = [_goal(periodEndDate: DateTime(2026, 3, 20, 23, 59, 59))];
      final useCase = GetGoalsByDateUseCase(WatchGoalsUseCase(repo));

      final result = await useCase.call(DateTime(2026, 3, 15)).first;

      expect(result, isEmpty);
    });
  });

  group('GetTasksByDateUseCase', () {
    test('seçili güne TaskFilter.dueOnDate ile filtreler ve CalendarEvent\'e eşler', () async {
      final repo = _FakeTaskRepository()
        ..tasksResult = [_task(dueDate: DateTime(2026, 3, 10))];
      final useCase = GetTasksByDateUseCase(WatchTasksUseCase(repo));

      final result = await useCase.call(DateTime(2026, 3, 10)).first;

      expect(repo.lastFilter?.dueOnDate, DateTime(2026, 3, 10));
      expect(result, hasLength(1));
      expect(result.single.source, CalendarEventSource.task);
    });

    test('görevi olmayan bir günde boş liste döner', () async {
      final repo = _FakeTaskRepository()..tasksResult = const [];
      final useCase = GetTasksByDateUseCase(WatchTasksUseCase(repo));

      final result = await useCase.call(DateTime(2026, 3, 11)).first;

      expect(result, isEmpty);
    });
  });

  group('GetTasksByMonthUseCase', () {
    test('yalnızca ilgili ay+yıla ait dueDate\'i olan görevleri döner', () async {
      final repo = _FakeTaskRepository()
        ..tasksResult = [
          _task(taskId: 'in-month', dueDate: DateTime(2026, 3, 5)),
          _task(taskId: 'other-month', dueDate: DateTime(2026, 4, 5)),
          _task(taskId: 'other-year', dueDate: DateTime(2025, 3, 5)),
          _task(taskId: 'no-due-date'),
        ];
      final useCase = GetTasksByMonthUseCase(WatchTasksUseCase(repo));

      final result = await useCase.call(DateTime(2026, 3, 1)).first;

      expect(result.map((e) => e.id), ['in-month']);
    });

    test('ay değiştiğinde farklı bir ay filtresiyle yeniden hesaplanır', () async {
      final repo = _FakeTaskRepository()
        ..tasksResult = [
          _task(taskId: 'march', dueDate: DateTime(2026, 3, 15)),
          _task(taskId: 'april', dueDate: DateTime(2026, 4, 15)),
        ];
      final useCase = GetTasksByMonthUseCase(WatchTasksUseCase(repo));

      final marchResult = await useCase.call(DateTime(2026, 3, 1)).first;
      final aprilResult = await useCase.call(DateTime(2026, 4, 1)).first;

      expect(marchResult.map((e) => e.id), ['march']);
      expect(aprilResult.map((e) => e.id), ['april']);
    });

    test('saat/dakika farkı ay eşleşmesini etkilemez (timezone/gün kayması korunumu)', () async {
      final repo = _FakeTaskRepository()
        ..tasksResult = [
          _task(taskId: 'late-night', dueDate: DateTime(2026, 3, 31, 23, 59)),
        ];
      final useCase = GetTasksByMonthUseCase(WatchTasksUseCase(repo));

      final result = await useCase.call(DateTime(2026, 3, 1)).first;

      expect(result.map((e) => e.id), ['late-night']);
    });
  });
}
