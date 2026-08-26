import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/notes/domain/entities/note.dart';
import 'package:productivity_app/features/notes/domain/entities/note_filter.dart';
import 'package:productivity_app/features/notes/domain/repositories/note_repository.dart';
import 'package:productivity_app/features/notes/domain/usecases/cleanup_orphaned_note_links_usecase.dart';
import 'package:productivity_app/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:productivity_app/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:productivity_app/features/notes/domain/usecases/link_note_to_project_or_task_usecase.dart';
import 'package:productivity_app/features/notes/domain/usecases/set_note_pinned_usecase.dart';
import 'package:productivity_app/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:productivity_app/features/notes/domain/usecases/watch_note_usecase.dart';
import 'package:productivity_app/features/notes/domain/usecases/watch_notes_usecase.dart';
import 'package:productivity_app/features/projects/domain/entities/project.dart';
import 'package:productivity_app/features/projects/domain/repositories/project_repository.dart';
import 'package:productivity_app/features/projects/domain/usecases/watch_projects_usecase.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/domain/usecases/watch_tasks_usecase.dart';

Note _note({
  String noteId = 'n1',
  String? projectId,
  String? taskId,
}) =>
    Note(
      noteId: noteId,
      title: 'Not $noteId',
      isPinned: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      projectId: projectId,
      taskId: taskId,
    );

class _FakeNoteRepository implements NoteRepository {
  Result<Note>? noteResult;
  List<Note> watchNotesResult = const [];
  Note? watchNoteResult;

  Note? lastCreatedNote;
  Note? lastUpdatedNote;
  String? lastDeletedNoteId;
  final List<({String noteId, bool isPinned})> pinnedCalls = [];
  final List<({String noteId, bool clearProjectId, bool clearTaskId})> linkCalls = [];

  @override
  String newNoteId() => 'generated-note-id';

  @override
  Stream<List<Note>> watchNotes({NoteFilter filter = NoteFilter.none}) => Stream.value(watchNotesResult);

  @override
  Stream<Note?> watchNote(String noteId) => Stream.value(watchNoteResult);

  @override
  Future<Result<Note>> createNote(Note note) async {
    lastCreatedNote = note;
    return noteResult!;
  }

  @override
  Future<Result<Note>> updateNote(Note note) async {
    lastUpdatedNote = note;
    return noteResult!;
  }

  @override
  Future<Result<void>> deleteNote(String noteId) async {
    lastDeletedNoteId = noteId;
    return const Ok(null);
  }

  @override
  Future<Result<Note>> setPinned(String noteId, {required bool isPinned}) async {
    pinnedCalls.add((noteId: noteId, isPinned: isPinned));
    return noteResult!;
  }

  @override
  Future<Result<Note>> setLink(
    String noteId, {
    String? projectId,
    bool clearProjectId = false,
    String? taskId,
    bool clearTaskId = false,
  }) async {
    linkCalls.add((noteId: noteId, clearProjectId: clearProjectId, clearTaskId: clearTaskId));
    return noteResult!;
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
  Future<Result<void>> deleteSubTask(String subtaskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> recalculateTaskProgress(String taskId) => throw UnimplementedError();
}

Project _project({String projectId = 'p1'}) => Project(
      projectId: projectId,
      title: 'Proje',
      color: '#FF8A8A',
      status: ProjectStatus.active,
      taskCount: 0,
      completedTaskCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _FakeProjectRepository implements ProjectRepository {
  List<Project> projectsResult = const [];

  @override
  String newProjectId() => 'id';
  @override
  Stream<List<Project>> watchProjects({ProjectStatus? status}) => Stream.value(projectsResult);
  @override
  Stream<Project?> watchProject(String projectId) => const Stream.empty();
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

void main() {
  late _FakeNoteRepository repo;

  setUp(() => repo = _FakeNoteRepository());

  test('CreateNoteUseCase notu repository\'ye iletir', () async {
    repo.noteResult = Ok(_note());
    final result = await CreateNoteUseCase(repo).call(_note());
    expect(repo.lastCreatedNote?.noteId, 'n1');
    expect(result, isA<Ok<Note>>());
  });

  test('UpdateNoteUseCase notu repository\'ye iletir', () async {
    repo.noteResult = Ok(_note());
    await UpdateNoteUseCase(repo).call(_note());
    expect(repo.lastUpdatedNote?.noteId, 'n1');
  });

  group('Not içeriği maksimum uzunluk (DATABASE.md §14.3 — 10.000 karakter)', () {
    Note withContent(String? content) => Note(
          noteId: 'n1',
          title: 'Not',
          content: content,
          isPinned: false,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );

    test('CreateNoteUseCase 10.000 karakteri aşan içerikte ValidationFailure döner, repository çağrılmaz', () async {
      final result = await CreateNoteUseCase(repo).call(withContent('a' * (noteContentMaxLength + 1)));

      expect((result as Err).failure, isA<ValidationFailure>());
      expect(repo.lastCreatedNote, isNull);
    });

    test('CreateNoteUseCase tam olarak sınırdaki içerikte repository\'ye iletir', () async {
      repo.noteResult = Ok(_note());
      final result = await CreateNoteUseCase(repo).call(withContent('a' * noteContentMaxLength));

      expect(result, isA<Ok<Note>>());
      expect(repo.lastCreatedNote, isNotNull);
    });

    test('UpdateNoteUseCase 10.000 karakteri aşan içerikte ValidationFailure döner, repository çağrılmaz', () async {
      final result = await UpdateNoteUseCase(repo).call(withContent('a' * (noteContentMaxLength + 1)));

      expect((result as Err).failure, isA<ValidationFailure>());
      expect(repo.lastUpdatedNote, isNull);
    });

    test('null içerik (opsiyonel alan) her zaman geçerlidir', () async {
      repo.noteResult = Ok(_note());
      final result = await CreateNoteUseCase(repo).call(withContent(null));

      expect(result, isA<Ok<Note>>());
    });
  });

  test('DeleteNoteUseCase noteId\'yi iletir', () async {
    await DeleteNoteUseCase(repo).call('n1');
    expect(repo.lastDeletedNoteId, 'n1');
  });

  test('SetNotePinnedUseCase isPinned değerini iletir', () async {
    repo.noteResult = Ok(_note());
    await SetNotePinnedUseCase(repo).call('n1', isPinned: true);
    expect(repo.pinnedCalls, [(noteId: 'n1', isPinned: true)]);
  });

  test('LinkNoteToProjectOrTaskUseCase clear bayraklarını iletir', () async {
    repo.noteResult = Ok(_note());
    await LinkNoteToProjectOrTaskUseCase(repo).call('n1', clearProjectId: true, clearTaskId: false);
    expect(repo.linkCalls, [(noteId: 'n1', clearProjectId: true, clearTaskId: false)]);
  });

  test('WatchNotesUseCase filtreyi iletir', () async {
    repo.watchNotesResult = [_note()];
    final result = await WatchNotesUseCase(repo).call(filter: const NoteFilter(projectId: 'p1')).first;
    expect(result, hasLength(1));
  });

  test('WatchNoteUseCase noteId\'yi iletir', () async {
    repo.watchNoteResult = _note();
    final result = await WatchNoteUseCase(repo).call('n1').first;
    expect(result?.noteId, 'n1');
  });

  test('Err durumunda usecase Err\'i olduğu gibi döndürür', () async {
    repo.noteResult = const Err(CacheFailure('boom'));
    final result = await CreateNoteUseCase(repo).call(_note());
    expect(result, isA<Err<Note>>());
  });

  group('CleanupOrphanedNoteLinksUseCase', () {
    test('bağlantısı olmayan notlara dokunmaz', () async {
      repo.watchNotesResult = [_note(noteId: 'n1')];
      final taskRepo = _FakeTaskRepository();
      final projectRepo = _FakeProjectRepository();

      await CleanupOrphanedNoteLinksUseCase(
        repo,
        WatchTasksUseCase(taskRepo),
        WatchProjectsUseCase(projectRepo),
      ).call();

      expect(repo.linkCalls, isEmpty);
    });

    test('proje hala var olan bir nota dokunmaz', () async {
      repo.watchNotesResult = [_note(noteId: 'n1', projectId: 'p1')];
      final taskRepo = _FakeTaskRepository();
      final projectRepo = _FakeProjectRepository()..projectsResult = [_project(projectId: 'p1')];

      await CleanupOrphanedNoteLinksUseCase(
        repo,
        WatchTasksUseCase(taskRepo),
        WatchProjectsUseCase(projectRepo),
      ).call();

      expect(repo.linkCalls, isEmpty);
    });

    test('görev hala var olan bir nota dokunmaz', () async {
      repo.watchNotesResult = [_note(noteId: 'n1', taskId: 't1')];
      final taskRepo = _FakeTaskRepository()..tasksResult = [_task(taskId: 't1')];
      final projectRepo = _FakeProjectRepository();

      await CleanupOrphanedNoteLinksUseCase(
        repo,
        WatchTasksUseCase(taskRepo),
        WatchProjectsUseCase(projectRepo),
      ).call();

      expect(repo.linkCalls, isEmpty);
    });

    test('artık var olmayan bir projeye bağlı not — projectId temizlenir', () async {
      repo.noteResult = Ok(_note());
      repo.watchNotesResult = [_note(noteId: 'n1', projectId: 'silinmis-proje')];
      final taskRepo = _FakeTaskRepository();
      final projectRepo = _FakeProjectRepository();

      await CleanupOrphanedNoteLinksUseCase(
        repo,
        WatchTasksUseCase(taskRepo),
        WatchProjectsUseCase(projectRepo),
      ).call();

      expect(repo.linkCalls, [(noteId: 'n1', clearProjectId: true, clearTaskId: false)]);
    });

    test('artık var olmayan bir göreve bağlı not — taskId temizlenir', () async {
      repo.noteResult = Ok(_note());
      repo.watchNotesResult = [_note(noteId: 'n1', taskId: 'silinmis-gorev')];
      final taskRepo = _FakeTaskRepository();
      final projectRepo = _FakeProjectRepository();

      await CleanupOrphanedNoteLinksUseCase(
        repo,
        WatchTasksUseCase(taskRepo),
        WatchProjectsUseCase(projectRepo),
      ).call();

      expect(repo.linkCalls, [(noteId: 'n1', clearProjectId: false, clearTaskId: true)]);
    });

    test('hem proje hem görev bağlantısı silinmişse ikisi de tek çağrıda temizlenir', () async {
      repo.noteResult = Ok(_note());
      repo.watchNotesResult = [
        _note(noteId: 'n1', projectId: 'silinmis-proje', taskId: 'silinmis-gorev'),
      ];
      final taskRepo = _FakeTaskRepository();
      final projectRepo = _FakeProjectRepository();

      await CleanupOrphanedNoteLinksUseCase(
        repo,
        WatchTasksUseCase(taskRepo),
        WatchProjectsUseCase(projectRepo),
      ).call();

      expect(repo.linkCalls, [(noteId: 'n1', clearProjectId: true, clearTaskId: true)]);
    });

    test('not listesi boşsa Tasks/Projects hiç sorgulanmaz', () async {
      repo.watchNotesResult = const [];
      final taskRepo = _FakeTaskRepository();
      final projectRepo = _FakeProjectRepository();

      await CleanupOrphanedNoteLinksUseCase(
        repo,
        WatchTasksUseCase(taskRepo),
        WatchProjectsUseCase(projectRepo),
      ).call();

      expect(repo.linkCalls, isEmpty);
    });
  });
}
