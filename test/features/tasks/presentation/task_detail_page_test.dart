import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/notes/domain/entities/note.dart';
import 'package:productivity_app/features/notes/domain/entities/note_filter.dart';
import 'package:productivity_app/features/notes/domain/repositories/note_repository.dart';
import 'package:productivity_app/features/notes/presentation/providers/note_providers.dart';
import 'package:productivity_app/features/pomodoro/domain/entities/pomodoro_session.dart';
import 'package:productivity_app/features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'package:productivity_app/features/pomodoro/presentation/providers/pomodoro_providers.dart';
import 'package:productivity_app/features/projects/domain/entities/project.dart';
import 'package:productivity_app/features/projects/domain/repositories/project_repository.dart';
import 'package:productivity_app/features/projects/presentation/providers/project_providers.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/pages/task_detail_page.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

/// Task Detail Screen (SCREENS.md §4.10), ROADMAP.md FAZ 16 "kritik ekranlar
/// için widget test kapsamının tamamlanması" — bu ekran daha önce hiç test
/// edilmemişti (coverage denetiminde %0 bulundu).
class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository(Task? initial) : task = initial;

  Task? task;
  List<SubTask> subTasks = [];
  bool deleteCalled = false;
  final List<SubTask> addedSubTasks = [];
  final _taskController = StreamController<Task?>.broadcast();
  final _subTasksController = StreamController<List<SubTask>>.broadcast();

  @override
  String newTaskId() => 'new-task-id';
  @override
  String newSubTaskId(String taskId) => 'st-${subTasks.length + 1}';

  @override
  Stream<Task?> watchTask(String taskId) => Stream<Task?>.multi((controller) {
        controller.add(task);
        final sub = _taskController.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => Stream<List<SubTask>>.multi((controller) {
        controller.add(subTasks);
        final sub = _subTasksController.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => const Stream.empty();
  @override
  Stream<List<Task>> watchTodayTasks() => const Stream.empty();

  @override
  Future<Result<Task>> createTask(Task t) => throw UnimplementedError();
  @override
  Future<Result<Task>> updateTask(Task t) => throw UnimplementedError();

  @override
  Future<Result<void>> deleteTask(String taskId) async {
    deleteCalled = true;
    return const Ok(null);
  }

  @override
  Future<Result<Task>> setTaskCompleted(String taskId, {required bool isCompleted}) async {
    task = task!.copyWith(status: isCompleted ? TaskStatus.completed : TaskStatus.pending);
    _taskController.add(task);
    return Ok(task!);
  }

  @override
  Future<Result<SubTask>> addSubTask(SubTask subTask) async {
    addedSubTasks.add(subTask);
    subTasks = [...subTasks, subTask];
    _subTasksController.add(subTasks);
    return Ok(subTask);
  }

  @override
  Future<Result<void>> setSubTaskCompleted(String subtaskId, {required bool isCompleted}) async {
    subTasks = [
      for (final s in subTasks)
        if (s.subtaskId == subtaskId) s.copyWith(isCompleted: isCompleted) else s,
    ];
    _subTasksController.add(subTasks);
    return const Ok(null);
  }

  @override
  Future<Result<void>> deleteSubTask(String subtaskId) async {
    subTasks = subTasks.where((s) => s.subtaskId != subtaskId).toList();
    _subTasksController.add(subTasks);
    return const Ok(null);
  }

  @override
  Future<Result<Task>> recalculateTaskProgress(String taskId) => throw UnimplementedError();
}

class _EmptyNoteRepository implements NoteRepository {
  @override
  String newNoteId() => 'n1';
  @override
  Stream<List<Note>> watchNotes({NoteFilter filter = NoteFilter.none}) => Stream.value(const []);
  @override
  Stream<Note?> watchNote(String noteId) => Stream.value(null);
  @override
  Future<Result<Note>> createNote(Note note) => throw UnimplementedError();
  @override
  Future<Result<Note>> updateNote(Note note) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteNote(String noteId) => throw UnimplementedError();
  @override
  Future<Result<Note>> setPinned(String noteId, {required bool isPinned}) =>
      throw UnimplementedError();
  @override
  Future<Result<Note>> setLink(
    String noteId, {
    String? projectId,
    bool clearProjectId = false,
    String? taskId,
    bool clearTaskId = false,
  }) =>
      throw UnimplementedError();
}

class _EmptyPomodoroRepository implements PomodoroRepository {
  @override
  String newSessionId() => 'p1';
  @override
  Stream<List<PomodoroSession>> watchSessionsByTask(String taskId) => Stream.value(const []);
  @override
  Future<Result<PomodoroSession>> createSession(PomodoroSession session) =>
      throw UnimplementedError();
  @override
  Future<Result<PomodoroSession>> completeSession(
    String sessionId, {
    required Duration actualDuration,
    required bool isCompleted,
  }) =>
      throw UnimplementedError();
  @override
  Future<Result<PomodoroSession>> linkSessionToTask(
    String sessionId, {
    String? taskId,
    bool clearTaskId = false,
  }) =>
      throw UnimplementedError();
  @override
  Future<List<PomodoroSession>> getSessionsInRange(DateTime start, DateTime end) async => const [];
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
}

Task _task({
  String taskId = 't1',
  TaskStatus status = TaskStatus.pending,
  int subtaskCount = 0,
  int completedSubtaskCount = 0,
}) =>
    Task(
      taskId: taskId,
      title: 'Rapor Hazırla',
      priority: TaskPriority.medium,
      status: status,
      subtaskCount: subtaskCount,
      completedSubtaskCount: completedSubtaskCount,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

/// Silme akışı `context.pop()` çağırdığından (go_router), gerçek bir
/// `GoRouter` ile "liste -> detay" yığını kurulur — yalnızca `MaterialApp`
/// kullanmak `GoRouter not found` hatasına yol açar.
Future<GoRouter> _pumpWithRouter(
  WidgetTester tester, {
  required _FakeTaskRepository taskRepository,
}) async {
  final router = GoRouter(
    initialLocation: '/list',
    routes: [
      GoRoute(path: '/list', builder: (_, _) => const Scaffold(body: Text('Görev Listesi'))),
      GoRoute(
        path: '/detail',
        builder: (_, _) => const TaskDetailPage(taskId: 't1'),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(taskRepository),
        noteRepositoryProvider.overrideWithValue(_EmptyNoteRepository()),
        pomodoroRepositoryProvider.overrideWithValue(_EmptyPomodoroRepository()),
        projectRepositoryProvider.overrideWithValue(_EmptyProjectRepository()),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  router.push('/detail');
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('görev bulunamazsa "Bu görev artık mevcut değil." gösterir', (tester) async {
    await _pumpWithRouter(tester, taskRepository: _FakeTaskRepository(null));

    expect(find.text('Bu görev artık mevcut değil.'), findsOneWidget);
  });

  testWidgets('görev verisi render olur (başlık, alt görev sayacı)', (tester) async {
    await _pumpWithRouter(
      tester,
      taskRepository: _FakeTaskRepository(
        _task(subtaskCount: 2, completedSubtaskCount: 1),
      ),
    );

    expect(find.text('Rapor Hazırla'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
  });

  testWidgets('başlığa dokununca tamamlanma durumu tersine döner', (tester) async {
    final repository = _FakeTaskRepository(_task());
    await _pumpWithRouter(tester, taskRepository: repository);

    expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

    await tester.tap(find.text('Rapor Hazırla'));
    await tester.pumpAndSettle();

    expect(repository.task!.isCompleted, isTrue);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('Sil -> Vazgeç: repository çağrılmaz, ekranda kalınır', (tester) async {
    final repository = _FakeTaskRepository(_task());
    await _pumpWithRouter(tester, taskRepository: repository);

    await tester.tap(find.byTooltip('Sil'));
    await tester.pumpAndSettle();
    expect(find.text('Görevi Sil'), findsOneWidget);

    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    expect(repository.deleteCalled, isFalse);
    expect(find.text('Rapor Hazırla'), findsOneWidget);
  });

  testWidgets('Sil -> Onayla: repository.deleteTask çağrılır ve bir önceki ekrana dönülür', (
    tester,
  ) async {
    final repository = _FakeTaskRepository(_task());
    await _pumpWithRouter(tester, taskRepository: repository);

    await tester.tap(find.byTooltip('Sil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sil').last);
    await tester.pumpAndSettle();

    expect(repository.deleteCalled, isTrue);
    expect(find.text('Görev Listesi'), findsOneWidget);
  });

  testWidgets('alt görev eklendiğinde listede görünür', (tester) async {
    final repository = _FakeTaskRepository(_task());
    await _pumpWithRouter(tester, taskRepository: repository);

    expect(find.text('Alt görev eklenmedi'), findsOneWidget);

    await tester.tap(find.text('Alt Görev Ekle'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Sunum hazırla');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(repository.addedSubTasks.single.title, 'Sunum hazırla');
    expect(find.text('Sunum hazırla'), findsOneWidget);
  });

  testWidgets('bir alt görev işaretlenince controller.toggleSubTaskCompleted çağrılır', (
    tester,
  ) async {
    final repository = _FakeTaskRepository(_task(subtaskCount: 1))
      ..subTasks = [
        SubTask(
          subtaskId: 's1',
          taskId: 't1',
          title: 'Taslak yaz',
          isCompleted: false,
          order: 0,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ];
    await _pumpWithRouter(tester, taskRepository: repository);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();

    expect(repository.subTasks.single.isCompleted, isTrue);
  });

  testWidgets(
    'alt görev sola kaydırılıp onaylanınca controller.deleteSubTask çağrılır ve listeden kaldırılır',
    (tester) async {
      final repository = _FakeTaskRepository(_task(subtaskCount: 1))
        ..subTasks = [
          SubTask(
            subtaskId: 's1',
            taskId: 't1',
            title: 'Taslak yaz',
            isCompleted: false,
            order: 0,
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        ];
      await _pumpWithRouter(tester, taskRepository: repository);

      await tester.drag(find.text('Taslak yaz'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Alt Görevi Sil'), findsOneWidget);

      await tester.tap(find.text('Sil').last);
      await tester.pumpAndSettle();

      expect(repository.subTasks, isEmpty);
      expect(find.text('Taslak yaz'), findsNothing);
    },
  );
}
