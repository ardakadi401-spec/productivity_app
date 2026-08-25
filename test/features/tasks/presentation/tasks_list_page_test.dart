import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/pages/tasks_list_page.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

class _FakeTaskRepository implements TaskRepository {
  List<Task> tasks = const [];
  Object? watchTasksError;

  @override
  String newTaskId() => 'id';
  @override
  String newSubTaskId(String taskId) => 'id';

  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) {
    if (watchTasksError != null) return Stream.error(watchTasksError!);
    return Stream.value(tasks);
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
  Future<Result<void>> deleteSubTask(String subtaskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> recalculateTaskProgress(String taskId) => throw UnimplementedError();
}

Task _task(String id, String title) => Task(
      taskId: id,
      title: title,
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Widget _wrap(_FakeTaskRepository fake) {
  return ProviderScope(
    overrides: [taskRepositoryProvider.overrideWithValue(fake)],
    child: MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: TasksListPage()),
    ),
  );
}

void main() {
  testWidgets('görev listesi boşken "Henüz görev eklemedin" gösterir', (tester) async {
    await tester.pumpWidget(_wrap(_FakeTaskRepository()));
    await tester.pump();

    expect(find.text('Henüz görev eklemedin'), findsOneWidget);
    expect(find.text('Görev Ekle'), findsOneWidget);
  });

  testWidgets('görev listesi doluyken kartları render eder', (tester) async {
    final fake = _FakeTaskRepository()
      ..tasks = [_task('t1', 'Alışveriş yap'), _task('t2', 'Rapor yaz')];
    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    expect(find.text('Alışveriş yap'), findsOneWidget);
    expect(find.text('Rapor yaz'), findsOneWidget);
  });

  testWidgets('hata durumunda ErrorState + Tekrar Dene gösterir', (tester) async {
    final fake = _FakeTaskRepository()..watchTasksError = Exception('boom');
    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    expect(find.text('Tekrar Dene'), findsOneWidget);
  });
}
