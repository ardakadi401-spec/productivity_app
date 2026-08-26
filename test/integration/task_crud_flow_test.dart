import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/app/app.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/authentication/presentation/providers/auth_providers.dart';
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
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

import '../features/authentication/fake_auth_repository.dart';

/// ROADMAP.md FAZ 16 tamamlanma kriteri — "Kritik kullanıcı akışlarının
/// (... görev CRUD ...) her biri için en az bir entegrasyon testi mevcut."
/// `FOLDER_STRUCTURE.md` §14.3 gereği senaryo bazlı organize edilir:
/// Dashboard'dan gerçek `ProductivityApp` + gerçek `GoRouter` üzerinden
/// "Görev Ekle" ile başlayıp Tasks listesine ve tamamlama eylemine kadar
/// uçtan uca akış, yalnızca Repository sınırında (gerçek Isar/Firestore
/// yerine) sahte implementasyonlarla izole edilerek doğrulanır.
class _FakeTaskRepository implements TaskRepository {
  List<Task> tasks = [];
  final _controller = StreamController<List<Task>>.broadcast();

  @override
  String newTaskId() => 'new-task-id';
  @override
  String newSubTaskId(String taskId) => 'st1';

  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) =>
      Stream<List<Task>>.multi((controller) {
        controller.add(tasks);
        final sub = _controller.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Stream<Task?> watchTask(String taskId) => Stream<Task?>.multi((controller) {
        controller.add(tasks.where((t) => t.taskId == taskId).firstOrNull);
        final sub = _controller.stream.listen(
          (all) => controller.add(all.where((t) => t.taskId == taskId).firstOrNull),
        );
        controller.onCancel = sub.cancel;
      });

  @override
  Stream<List<Task>> watchTodayTasks() => Stream.value(const []);
  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => Stream.value(const []);

  @override
  Future<Result<Task>> createTask(Task task) async {
    tasks = [...tasks, task];
    _controller.add(tasks);
    return Ok(task);
  }

  @override
  Future<Result<Task>> updateTask(Task task) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteTask(String taskId) => throw UnimplementedError();

  @override
  Future<Result<Task>> setTaskCompleted(String taskId, {required bool isCompleted}) async {
    final updated = tasks
        .firstWhere((t) => t.taskId == taskId)
        .copyWith(status: isCompleted ? TaskStatus.completed : TaskStatus.pending);
    tasks = [
      for (final t in tasks) if (t.taskId == taskId) updated else t,
    ];
    _controller.add(tasks);
    return Ok(updated);
  }

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

Widget _wrap({
  required FakeAuthRepository auth,
  required _FakeTaskRepository taskRepository,
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      taskRepositoryProvider.overrideWithValue(taskRepository),
      projectRepositoryProvider.overrideWithValue(_EmptyProjectRepository()),
      noteRepositoryProvider.overrideWithValue(_EmptyNoteRepository()),
      pomodoroRepositoryProvider.overrideWithValue(_EmptyPomodoroRepository()),
    ],
    child: const ProductivityApp(),
  );
}

void main() {
  testWidgets(
    'Dashboard "Görev Ekle" -> form doldur -> kaydet -> Tasks listesinde görünür -> '
    'tamamlanmış işaretlenir',
    (tester) async {
      // Create Task formu (AppBar + alanlar + taslak alt görev listesi)
      // varsayılan 800x600 test görünümünden taşıyor
      // (create_task_page_test.dart'taki aynı gerekçe).
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final auth = FakeAuthRepository()..authStateValue = testUser;
      final taskRepository = _FakeTaskRepository();
      await tester.pumpWidget(_wrap(auth: auth, taskRepository: taskRepository));
      await tester.pumpAndSettle();

      // 1) Dashboard'dan "Görev Ekle" ile Create Task ekranına gerçek router
      // push'u.
      await tester.tap(find.text('Görev Ekle'));
      await tester.pumpAndSettle();
      expect(find.text('Yeni Görev'), findsOneWidget);

      // 2) Formu doldur ve kaydet.
      await tester.enterText(find.byType(TextField).first, 'Sunum hazırla');
      await tester.pump();
      await tester.tap(find.text('Görevi Kaydet'));
      await tester.pumpAndSettle();

      expect(taskRepository.tasks.single.title, 'Sunum hazırla');

      // 3) Projeler & Görevler sekmesinin Görevler alt sekmesinde görev
      // gerçekten listeleniyor mu?
      await tester.tap(find.text('Projeler'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Görevler'));
      await tester.pumpAndSettle();
      expect(find.text('Sunum hazırla'), findsOneWidget);

      // 4) Karta dokunarak tamamlandı işaretle -> repository'ye gerçekten
      // yansıyor mu?
      await tester.tap(find.text('Sunum hazırla'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sunum hazırla'));
      await tester.pumpAndSettle();

      expect(taskRepository.tasks.single.isCompleted, isTrue);
    },
  );
}
