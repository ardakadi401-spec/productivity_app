import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/goals/domain/entities/goal.dart';
import 'package:productivity_app/features/goals/domain/repositories/goal_repository.dart';
import 'package:productivity_app/features/goals/presentation/providers/goal_providers.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

class _FakeGoalRepository implements GoalRepository {
  Goal? goal;

  @override
  String newGoalId() => 'id';
  @override
  Stream<List<Goal>> watchGoals({GoalPeriodType? periodType}) => Stream.value(const []);
  @override
  Stream<Goal?> watchGoal(String goalId) => Stream.value(goal);
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

/// Gerçek `TaskRepositoryImpl`'in Isar üzerinden sunduğu canlı/reaktif
/// `watchTasks()` davranışını taklit eder — tek seferlik `Stream.value`
/// yerine, testin zaman içinde birden fazla değer göndermesine izin veren
/// bir `StreamController` kullanır (bir görev tamamlandığında Isar
/// stream'inin yeniden tetiklenmesiyle birebir aynı senaryo).
class _FakeTaskRepository implements TaskRepository {
  final _controller = StreamController<List<Task>>.broadcast();

  void emit(List<Task> tasks) => _controller.add(tasks);

  @override
  String newTaskId() => 'id';
  @override
  String newSubTaskId(String taskId) => 'id';
  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => _controller.stream;
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
  Future<Result<void>> deleteSubTask(String subtaskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> recalculateTaskProgress(String taskId) => throw UnimplementedError();
}

Task _task(String id, {required bool isCompleted}) => Task(
      taskId: id,
      title: 'Görev $id',
      priority: TaskPriority.medium,
      status: isCompleted ? TaskStatus.completed : TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Goal _linkedGoal(List<String> linkedTaskIds) => Goal(
      goalId: 'g1',
      title: 'Bağlı görev hedefi',
      periodType: GoalPeriodType.weekly,
      periodStartDate: DateTime(2026, 1, 1),
      periodEndDate: DateTime(2026, 1, 7, 23, 59, 59),
      progressType: GoalProgressType.linkedTasks,
      linkedTaskIds: linkedTaskIds,
      status: GoalStatus.inProgress,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

/// `goalProgressProvider` önce `goalDetailProvider`nin çözülmesini bekler
/// (ilk `build()` sırasında `goal` henüz `null`sa `Stream.empty()` döner);
/// bu, birkaç mikro-görev turu gerektirir — tek bir `Duration.zero` yetmez.
Future<void> _settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test(
    'linkedTasks hedefinde bağlı görev tamamlandığında ilerleme yüzdesi doğru güncellenir (unit test — ROADMAP FAZ 8)',
    () async {
      final goalRepo = _FakeGoalRepository()..goal = _linkedGoal(['t1', 't2']);
      final taskRepo = _FakeTaskRepository();

      final container = ProviderContainer(
        overrides: [
          goalRepositoryProvider.overrideWithValue(goalRepo),
          taskRepositoryProvider.overrideWithValue(taskRepo),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(taskRepo._controller.close);

      final values = <double>[];
      container.listen(goalProgressProvider('g1'), (previous, next) {
        final value = next.valueOrNull;
        if (value != null) values.add(value);
      }, fireImmediately: true);
      // goalDetailProvider'ın çözülüp goalProgressProvider'ın tasks
      // stream'ine abone olmasını bekle — aksi halde ilk emit() kaybolur.
      await _settle();

      taskRepo.emit([_task('t1', isCompleted: false), _task('t2', isCompleted: false)]);
      await _settle();
      expect(values.last, 0.0);

      taskRepo.emit([_task('t1', isCompleted: true), _task('t2', isCompleted: false)]);
      await _settle();
      expect(values.last, 0.5);

      taskRepo.emit([_task('t1', isCompleted: true), _task('t2', isCompleted: true)]);
      await _settle();
      expect(values.last, 1.0);
    },
  );

  test('manuel ilerleme tipinde goalProgressProvider doğrudan manualProgress\'i yansıtır', () async {
    final goalRepo = _FakeGoalRepository()
      ..goal = Goal(
        goalId: 'g2',
        title: 'Manuel hedef',
        periodType: GoalPeriodType.daily,
        periodStartDate: DateTime(2026, 1, 1),
        periodEndDate: DateTime(2026, 1, 1, 23, 59, 59),
        progressType: GoalProgressType.manual,
        manualProgress: 65,
        status: GoalStatus.inProgress,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

    final container = ProviderContainer(
      overrides: [goalRepositoryProvider.overrideWithValue(goalRepo)],
    );
    addTearDown(container.dispose);

    double? value;
    container.listen(goalProgressProvider('g2'), (previous, next) {
      value = next.valueOrNull;
    }, fireImmediately: true);
    await _settle();

    expect(value, 0.65);
  });
}
