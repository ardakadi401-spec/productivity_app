import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/domain/usecases/add_sub_task_usecase.dart';
import 'package:productivity_app/features/tasks/domain/usecases/complete_sub_task_usecase.dart';
import 'package:productivity_app/features/tasks/domain/usecases/complete_task_usecase.dart';
import 'package:productivity_app/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:productivity_app/features/tasks/domain/usecases/delete_sub_task_usecase.dart';
import 'package:productivity_app/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:productivity_app/features/tasks/domain/usecases/get_today_tasks_usecase.dart';
import 'package:productivity_app/features/tasks/domain/usecases/recalculate_task_progress_usecase.dart';
import 'package:productivity_app/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:productivity_app/features/tasks/domain/usecases/watch_sub_tasks_usecase.dart';
import 'package:productivity_app/features/tasks/domain/usecases/watch_task_usecase.dart';
import 'package:productivity_app/features/tasks/domain/usecases/watch_tasks_usecase.dart';

Task _task({String taskId = 't1'}) => Task(
      taskId: taskId,
      title: 'Örnek görev',
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

SubTask _subTask({String subtaskId = 's1', String taskId = 't1'}) => SubTask(
      subtaskId: subtaskId,
      taskId: taskId,
      title: 'Örnek alt görev',
      isCompleted: false,
      order: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _FakeTaskRepository implements TaskRepository {
  Result<Task>? taskResult;
  Result<void>? voidResult;
  Result<SubTask>? subTaskResult;
  List<Task> watchTasksResult = const [];
  List<Task> todayTasksResult = const [];
  Task? watchTaskResult;
  List<SubTask> watchSubTasksResult = const [];

  TaskFilter? lastFilter;
  String? lastWatchedTaskId;
  String? lastWatchedSubTasksTaskId;
  Task? lastCreatedTask;
  Task? lastUpdatedTask;
  String? lastDeletedTaskId;
  ({String taskId, bool isCompleted})? lastCompleteArgs;
  SubTask? lastAddedSubTask;
  ({String subtaskId, bool isCompleted})? lastCompleteSubTaskArgs;
  String? lastRecalculatedTaskId;
  String? lastDeletedSubTaskId;

  @override
  String newTaskId() => 'generated-task-id';

  @override
  String newSubTaskId(String taskId) => 'generated-subtask-id';

  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) {
    lastFilter = filter;
    return Stream.value(watchTasksResult);
  }

  @override
  Stream<Task?> watchTask(String taskId) {
    lastWatchedTaskId = taskId;
    return Stream.value(watchTaskResult);
  }

  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) {
    lastWatchedSubTasksTaskId = taskId;
    return Stream.value(watchSubTasksResult);
  }

  @override
  Stream<List<Task>> watchTodayTasks() => Stream.value(todayTasksResult);

  @override
  Future<Result<Task>> createTask(Task task) async {
    lastCreatedTask = task;
    return taskResult!;
  }

  @override
  Future<Result<Task>> updateTask(Task task) async {
    lastUpdatedTask = task;
    return taskResult!;
  }

  @override
  Future<Result<void>> deleteTask(String taskId) async {
    lastDeletedTaskId = taskId;
    return voidResult!;
  }

  @override
  Future<Result<Task>> setTaskCompleted(String taskId, {required bool isCompleted}) async {
    lastCompleteArgs = (taskId: taskId, isCompleted: isCompleted);
    return taskResult!;
  }

  @override
  Future<Result<SubTask>> addSubTask(SubTask subTask) async {
    lastAddedSubTask = subTask;
    return subTaskResult!;
  }

  @override
  Future<Result<void>> setSubTaskCompleted(String subtaskId, {required bool isCompleted}) async {
    lastCompleteSubTaskArgs = (subtaskId: subtaskId, isCompleted: isCompleted);
    return voidResult!;
  }

  @override
  Future<Result<void>> deleteSubTask(String subtaskId) async {
    lastDeletedSubTaskId = subtaskId;
    return voidResult!;
  }

  @override
  Future<Result<Task>> recalculateTaskProgress(String taskId) async {
    lastRecalculatedTaskId = taskId;
    return taskResult!;
  }
}

void main() {
  late _FakeTaskRepository repo;

  setUp(() => repo = _FakeTaskRepository());

  test('CreateTaskUseCase görevi repository\'ye iletir', () async {
    repo.taskResult = Ok(_task());
    final result = await CreateTaskUseCase(repo).call(_task());
    expect(repo.lastCreatedTask?.taskId, 't1');
    expect(result, isA<Ok<Task>>());
  });

  test('UpdateTaskUseCase görevi repository\'ye iletir', () async {
    repo.taskResult = Ok(_task());
    await UpdateTaskUseCase(repo).call(_task());
    expect(repo.lastUpdatedTask?.taskId, 't1');
  });

  test('DeleteTaskUseCase taskId\'yi iletir', () async {
    repo.voidResult = const Ok(null);
    await DeleteTaskUseCase(repo).call('t1');
    expect(repo.lastDeletedTaskId, 't1');
  });

  test('DeleteSubTaskUseCase subtaskId\'yi iletir', () async {
    repo.voidResult = const Ok(null);
    await DeleteSubTaskUseCase(repo).call('s1');
    expect(repo.lastDeletedSubTaskId, 's1');
  });

  test('CompleteTaskUseCase isCompleted argümanını iletir', () async {
    repo.taskResult = Ok(_task());
    await CompleteTaskUseCase(repo).call('t1', isCompleted: true);
    expect(repo.lastCompleteArgs, (taskId: 't1', isCompleted: true));
  });

  test('AddSubTaskUseCase alt görevi iletir', () async {
    repo.subTaskResult = Ok(_subTask());
    await AddSubTaskUseCase(repo).call(_subTask());
    expect(repo.lastAddedSubTask?.subtaskId, 's1');
  });

  test('CompleteSubTaskUseCase argümanları iletir', () async {
    repo.voidResult = const Ok(null);
    await CompleteSubTaskUseCase(repo).call('s1', isCompleted: true);
    expect(repo.lastCompleteSubTaskArgs, (subtaskId: 's1', isCompleted: true));
  });

  test('RecalculateTaskProgressUseCase taskId\'yi iletir', () async {
    repo.taskResult = Ok(_task());
    await RecalculateTaskProgressUseCase(repo).call('t1');
    expect(repo.lastRecalculatedTaskId, 't1');
  });

  test('GetTodayTasksUseCase watchTodayTasks\'ı sarmalar', () async {
    repo.todayTasksResult = [_task()];
    final result = await GetTodayTasksUseCase(repo).call().first;
    expect(result, hasLength(1));
  });

  test('WatchTasksUseCase filtreyi iletir', () async {
    repo.watchTasksResult = [_task()];
    const filter = TaskFilter(priority: TaskPriority.high);
    await WatchTasksUseCase(repo).call(filter: filter).first;
    expect(repo.lastFilter, filter);
  });

  test('WatchTaskUseCase taskId\'yi iletir', () async {
    repo.watchTaskResult = _task();
    await WatchTaskUseCase(repo).call('t1').first;
    expect(repo.lastWatchedTaskId, 't1');
  });

  test('WatchSubTasksUseCase taskId\'yi iletir', () async {
    repo.watchSubTasksResult = [_subTask()];
    await WatchSubTasksUseCase(repo).call('t1').first;
    expect(repo.lastWatchedSubTasksTaskId, 't1');
  });

  test('Err durumunda usecase Err\'i olduğu gibi döndürür', () async {
    repo.taskResult = const Err(CacheFailure('boom'));
    final result = await CreateTaskUseCase(repo).call(_task());
    expect(result, isA<Err<Task>>());
  });
}
