import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/notes/domain/entities/note.dart';
import 'package:productivity_app/features/notes/domain/entities/note_filter.dart';
import 'package:productivity_app/features/notes/domain/repositories/note_repository.dart';
import 'package:productivity_app/features/notes/presentation/providers/note_providers.dart';
import 'package:productivity_app/features/projects/domain/entities/project.dart';
import 'package:productivity_app/features/projects/domain/repositories/project_repository.dart';
import 'package:productivity_app/features/projects/presentation/pages/project_detail_page.dart';
import 'package:productivity_app/features/projects/presentation/providers/project_providers.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

/// Project Detail Screen (SCREENS.md §4.8), ROADMAP.md FAZ 16 — coverage
/// denetiminde %0 bulunan bir ekran.
class _FakeProjectRepository implements ProjectRepository {
  _FakeProjectRepository(Project? initial) : project = initial;

  Project? project;
  Project? lastUpdated;
  ({bool isArchived})? lastArchiveCall;
  final _controller = StreamController<Project?>.broadcast();

  @override
  String newProjectId() => 'new-id';

  @override
  Stream<Project?> watchProject(String projectId) => Stream<Project?>.multi((controller) {
        controller.add(project);
        final sub = _controller.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Stream<List<Project>> watchProjects({ProjectStatus? status}) => Stream.value(const []);

  @override
  Future<Result<Project>> createProject(Project p) => throw UnimplementedError();
  @override
  Future<Result<Project>> updateProject(Project p) async {
    lastUpdated = p;
    project = p;
    _controller.add(project);
    return Ok(p);
  }

  @override
  Future<Result<Project>> setProjectArchived(String projectId, {required bool isArchived}) async {
    lastArchiveCall = (isArchived: isArchived);
    project = project!.copyWith(status: isArchived ? ProjectStatus.archived : ProjectStatus.active);
    _controller.add(project);
    return Ok(project!);
  }

  @override
  Future<Result<Project>> updateProjectProgress(
    String projectId, {
    required int taskCount,
    required int completedTaskCount,
  }) async {
    // `ProjectDetailController.build` bu UseCase'i proje null olsa bile
    // `projectTaskStatsProvider`'ı dinlemeye başladığı an tetikler — gerçek
    // repository'de bu durumda güncellenecek bir belge bulunamaz.
    final current = project;
    if (current == null) return const Err(CacheFailure('Proje bulunamadı.'));
    return Ok(current);
  }

  bool deleteCalled = false;
  Result<void> deleteResult = const Ok(null);

  @override
  Future<Result<void>> deleteProject(String projectId) async {
    deleteCalled = true;
    if (deleteResult is Ok<void>) {
      project = null;
      _controller.add(null);
    }
    return deleteResult;
  }
}

/// `ProjectDetailPage` sayaçları `Project.taskCount`/`completedTaskCount`
/// alanlarını DEĞİL, `projectTaskStatsProvider`'ın görev akışından canlı
/// hesapladığı değerleri kullanır (bkz. `project_providers.dart` — statik
/// alanlar yalnızca ilk değer gelene kadarki kısa an için yedektir). Bu
/// yüzden sahte repository, testin beklediği sayaçlarla eşleşen gerçek
/// görevler döndürmelidir.
class _EmptyTaskRepository implements TaskRepository {
  _EmptyTaskRepository({this.tasks = const []});

  final List<Task> tasks;

  @override
  String newTaskId() => 't1';
  @override
  String newSubTaskId(String taskId) => 's1';
  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => Stream.value(
        filter.projectId == null
            ? tasks
            : tasks.where((t) => t.projectId == filter.projectId).toList(),
      );
  @override
  Stream<Task?> watchTask(String taskId) => Stream.value(null);
  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => Stream.value(const []);
  @override
  Stream<List<Task>> watchTodayTasks() => Stream.value(const []);
  @override
  Future<Result<Task>> createTask(Task t) => throw UnimplementedError();
  @override
  Future<Result<Task>> updateTask(Task t) => throw UnimplementedError();
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

Project _project({
  String projectId = 'p1',
  ProjectStatus status = ProjectStatus.active,
  int taskCount = 0,
  int completedTaskCount = 0,
}) =>
    Project(
      projectId: projectId,
      title: 'Web Sitesi Yenileme',
      color: '#FF8A8A',
      status: status,
      taskCount: taskCount,
      completedTaskCount: completedTaskCount,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Task _task({
  String taskId = 't1',
  String? projectId = 'p1',
  bool isCompleted = false,
}) =>
    Task(
      taskId: taskId,
      title: 'Görev $taskId',
      priority: TaskPriority.medium,
      status: isCompleted ? TaskStatus.completed : TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      projectId: projectId,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Future<void> _pump(
  WidgetTester tester, {
  required _FakeProjectRepository projectRepository,
  List<Task> tasks = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectRepositoryProvider.overrideWithValue(projectRepository),
        taskRepositoryProvider.overrideWithValue(_EmptyTaskRepository(tasks: tasks)),
        noteRepositoryProvider.overrideWithValue(_EmptyNoteRepository()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const ProjectDetailPage(projectId: 'p1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Silme akışı `context.pop()` çağırdığından (go_router), gerçek bir
/// `GoRouter` ile "liste -> detay" yığını kurulur (bkz. aynı gerekçe
/// `task_detail_page_test.dart`'ta) — yalnızca `MaterialApp` kullanmak
/// `GoRouter not found` hatasına yol açar.
Future<GoRouter> _pumpWithRouter(
  WidgetTester tester, {
  required _FakeProjectRepository projectRepository,
}) async {
  final router = GoRouter(
    initialLocation: '/list',
    routes: [
      GoRoute(path: '/list', builder: (_, _) => const Scaffold(body: Text('Proje Listesi'))),
      GoRoute(path: '/detail', builder: (_, _) => const ProjectDetailPage(projectId: 'p1')),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectRepositoryProvider.overrideWithValue(projectRepository),
        taskRepositoryProvider.overrideWithValue(_EmptyTaskRepository()),
        noteRepositoryProvider.overrideWithValue(_EmptyNoteRepository()),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  router.push('/detail');
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('proje bulunamazsa "Bu proje artık mevcut değil." gösterir', (tester) async {
    await _pump(tester, projectRepository: _FakeProjectRepository(null));

    expect(find.text('Bu proje artık mevcut değil.'), findsOneWidget);
  });

  testWidgets('proje verisi render olur (başlık, görev sayacı)', (tester) async {
    await _pump(
      tester,
      projectRepository: _FakeProjectRepository(
        _project(taskCount: 4, completedTaskCount: 1),
      ),
      tasks: [
        _task(taskId: 't1', isCompleted: true),
        _task(taskId: 't2'),
        _task(taskId: 't3'),
        _task(taskId: 't4'),
      ],
    );

    // AppBar başlığı + gövde başlığı olmak üzere iki kez görünür.
    expect(find.text('Web Sitesi Yenileme'), findsWidgets);
    expect(find.text('1/4 görev'), findsOneWidget);
  });

  testWidgets('0 görevli projede bölme hatası olmadan 0/0 gösterir', (tester) async {
    await _pump(tester, projectRepository: _FakeProjectRepository(_project()));

    expect(find.text('0/0 görev'), findsOneWidget);
  });

  testWidgets('Arşivle -> Vazgeç: repository çağrılmaz', (tester) async {
    final repository = _FakeProjectRepository(_project());
    await _pump(tester, projectRepository: repository);

    await tester.tap(find.byTooltip('Arşivle'));
    await tester.pumpAndSettle();
    expect(find.text('Projeyi Arşivle'), findsOneWidget);

    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    expect(repository.lastArchiveCall, isNull);
  });

  testWidgets('Arşivle -> Onayla: setProjectArchived(isArchived:true) çağrılır, başarı mesajı gösterilir', (
    tester,
  ) async {
    final repository = _FakeProjectRepository(_project());
    await _pump(tester, projectRepository: repository);

    await tester.tap(find.byTooltip('Arşivle'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arşivle').last);
    await tester.pump();

    expect(repository.lastArchiveCall, (isArchived: true));
    expect(find.text('Proje arşivlendi'), findsOneWidget);
  });

  testWidgets('arşivlenmiş projede buton "Arşivden Çıkar" akışını tetikler', (tester) async {
    final repository = _FakeProjectRepository(_project(status: ProjectStatus.archived));
    await _pump(tester, projectRepository: repository);

    await tester.tap(find.byTooltip('Arşivle'));
    await tester.pumpAndSettle();
    expect(find.text('Arşivden Çıkar'), findsWidgets);

    await tester.tap(find.text('Aktif Et'));
    await tester.pump();

    expect(repository.lastArchiveCall, (isArchived: false));
  });

  testWidgets('Sil -> Vazgeç: deleteProject çağrılmaz, ekranda kalınır', (tester) async {
    final repository = _FakeProjectRepository(_project());
    await _pumpWithRouter(tester, projectRepository: repository);

    await tester.tap(find.byTooltip('Sil'));
    await tester.pumpAndSettle();
    expect(find.text('Projeyi Sil'), findsOneWidget);

    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    expect(repository.deleteCalled, isFalse);
    expect(find.text('Web Sitesi Yenileme'), findsWidgets);
  });

  testWidgets('Sil -> Onayla: deleteProject çağrılır ve bir önceki ekrana dönülür', (tester) async {
    final repository = _FakeProjectRepository(_project());
    await _pumpWithRouter(tester, projectRepository: repository);

    await tester.tap(find.byTooltip('Sil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sil').last);
    await tester.pumpAndSettle();

    expect(repository.deleteCalled, isTrue);
    expect(find.text('Proje Listesi'), findsOneWidget);
  });

  testWidgets('Düzenle ikonuna dokununca mevcut başlıkla EditProjectSheet açılır', (tester) async {
    // EditProjectSheet varsayılan 800x600 test görünümünde taşıyor
    // (create_task_page_test.dart'taki aynı gerekçe).
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeProjectRepository(_project());
    await _pump(tester, projectRepository: repository);

    await tester.tap(find.byTooltip('Düzenle'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Web Sitesi Yenileme'), findsOneWidget);
  });

  testWidgets('EditProjectSheet\'te başlık güncellenip Güncelle basılınca updateProject çağrılır', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeProjectRepository(_project());
    await _pump(tester, projectRepository: repository);

    await tester.tap(find.byTooltip('Düzenle'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Web Sitesi Yenileme'),
      'Web Sitesi Yenileme v2',
    );
    await tester.pump();
    await tester.tap(find.text('Güncelle'));
    await tester.pumpAndSettle();

    expect(repository.lastUpdated?.title, 'Web Sitesi Yenileme v2');
    expect(find.text('Proje güncellendi'), findsOneWidget);
  });
}
