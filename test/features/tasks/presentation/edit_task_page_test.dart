import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/projects/domain/entities/project.dart';
import 'package:productivity_app/features/projects/domain/repositories/project_repository.dart';
import 'package:productivity_app/features/projects/presentation/providers/project_providers.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/pages/edit_task_page.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

/// Edit Task Screen (SCREENS.md §4.12), ROADMAP.md FAZ 16 — coverage
/// denetiminde %0 bulunan bir ekran.
class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository(Task? initial) : task = initial;

  Task? task;
  Task? lastUpdated;
  final _controller = StreamController<Task?>.broadcast();

  @override
  String newTaskId() => 't1';
  @override
  String newSubTaskId(String taskId) => 's1';

  @override
  Stream<Task?> watchTask(String taskId) => Stream<Task?>.multi((controller) {
        controller.add(task);
        final sub = _controller.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => Stream.value(const []);
  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => Stream.value(const []);
  @override
  Stream<List<Task>> watchTodayTasks() => Stream.value(const []);
  @override
  Future<Result<Task>> createTask(Task t) => throw UnimplementedError();

  @override
  Future<Result<Task>> updateTask(Task t) async {
    lastUpdated = t;
    task = t;
    _controller.add(t);
    return Ok(t);
  }

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

class _EmptyProjectRepository implements ProjectRepository {
  @override
  String newProjectId() => 'pr1';
  @override
  Stream<List<Project>> watchProjects({ProjectStatus? status}) => Stream.value(const []);
  @override
  Stream<Project?> watchProject(String projectId) => Stream.value(null);
  @override
  Future<Result<Project>> createProject(Project project) => throw UnimplementedError();
  @override
  Future<Result<Project>> updateProject(Project project) => throw UnimplementedError();
  @override
  Future<Result<Project>> setProjectArchived(String projectId, {required bool isArchived}) =>
      throw UnimplementedError();
  @override
  Future<Result<Project>> updateProjectProgress(
    String projectId, {
    required int taskCount,
    required int completedTaskCount,
  }) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> deleteProject(String projectId) => throw UnimplementedError();
}

Task _task({
  String taskId = 't1',
  String title = 'Rapor Hazırla',
  TaskPriority priority = TaskPriority.medium,
}) =>
    Task(
      taskId: taskId,
      title: title,
      priority: priority,
      status: TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

/// Kaydetme akışı `context.pop()` çağırdığından gerçek bir `GoRouter`
/// gerekir (`task_detail_page_test.dart`'taki aynı gerekçe). Form (AppBar +
/// alanlar) varsayılan 800x600 test görünümünden taşabildiğinden görünüm
/// büyütülür (`create_task_page_test.dart`'taki aynı gerekçe).
Future<GoRouter> _pumpWithRouter(
  WidgetTester tester, {
  required _FakeTaskRepository taskRepository,
  Task? initialTask,
}) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: '/detail',
    routes: [
      GoRoute(path: '/detail', builder: (_, _) => const Scaffold(body: Text('Görev Detayı'))),
      GoRoute(
        path: '/edit',
        builder: (_, _) => EditTaskPage(taskId: 't1', initialTask: initialTask),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(taskRepository),
        projectRepositoryProvider.overrideWithValue(_EmptyProjectRepository()),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  router.push('/edit');
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('initialTask verilmez ve görev bulunamazsa "Bu görev artık mevcut değil." gösterir', (
    tester,
  ) async {
    await _pumpWithRouter(tester, taskRepository: _FakeTaskRepository(null));

    expect(find.text('Bu görev artık mevcut değil.'), findsOneWidget);
  });

  testWidgets('initialTask verilirse form doğrudan mevcut değerlerle render olur', (tester) async {
    await _pumpWithRouter(
      tester,
      taskRepository: _FakeTaskRepository(_task()),
      initialTask: _task(),
    );

    expect(find.widgetWithText(TextField, 'Rapor Hazırla'), findsOneWidget);
  });

  testWidgets('boş başlıkla güncellemeye çalışınca doğrulama hatası gösterir, repository çağrılmaz', (
    tester,
  ) async {
    final repository = _FakeTaskRepository(_task());
    await _pumpWithRouter(tester, taskRepository: repository, initialTask: _task());

    await tester.enterText(find.widgetWithText(TextField, 'Rapor Hazırla'), '');
    await tester.pump();
    await tester.tap(find.text('Görevi Güncelle'));
    await tester.pump();

    expect(find.text('Görev başlığı boş olamaz.'), findsOneWidget);
    expect(repository.lastUpdated, isNull);
  });

  testWidgets('geçerli başlıkla güncelleyince updateTask çağrılır ve bir önceki ekrana dönülür', (
    tester,
  ) async {
    final repository = _FakeTaskRepository(_task());
    await _pumpWithRouter(tester, taskRepository: repository, initialTask: _task());

    await tester.enterText(find.widgetWithText(TextField, 'Rapor Hazırla'), 'Güncellenmiş rapor');
    await tester.pump();
    await tester.tap(find.text('Görevi Güncelle'));
    await tester.pumpAndSettle();

    expect(repository.lastUpdated?.title, 'Güncellenmiş rapor');
    expect(find.text('Görev Detayı'), findsOneWidget);
  });
}
