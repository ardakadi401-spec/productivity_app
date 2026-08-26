import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/habits/domain/entities/habit.dart';
import 'package:productivity_app/features/habits/domain/repositories/habit_repository.dart';
import 'package:productivity_app/features/habits/domain/entities/habit_record.dart';
import 'package:productivity_app/features/habits/domain/usecases/watch_habits_usecase.dart';
import 'package:productivity_app/features/notes/domain/entities/note.dart';
import 'package:productivity_app/features/notes/domain/entities/note_filter.dart';
import 'package:productivity_app/features/notes/domain/repositories/note_repository.dart';
import 'package:productivity_app/features/notes/domain/usecases/watch_notes_usecase.dart';
import 'package:productivity_app/features/projects/domain/entities/project.dart';
import 'package:productivity_app/features/projects/domain/repositories/project_repository.dart';
import 'package:productivity_app/features/projects/domain/usecases/watch_projects_usecase.dart';
import 'package:productivity_app/features/search/domain/entities/search_result.dart';
import 'package:productivity_app/features/search/domain/usecases/search_usecase.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/domain/usecases/watch_tasks_usecase.dart';

class _FakeTaskRepository implements TaskRepository {
  List<Task> tasks = const [];
  @override
  String newTaskId() => 'id';
  @override
  String newSubTaskId(String taskId) => 'id';
  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => Stream.value(tasks);
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

class _FakeProjectRepository implements ProjectRepository {
  List<Project> projects = const [];
  @override
  String newProjectId() => 'id';
  @override
  Stream<List<Project>> watchProjects({ProjectStatus? status}) => Stream.value(projects);
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

class _FakeNoteRepository implements NoteRepository {
  List<Note> notes = const [];
  @override
  String newNoteId() => 'id';
  @override
  Stream<List<Note>> watchNotes({NoteFilter filter = NoteFilter.none}) => Stream.value(notes);
  @override
  Stream<Note?> watchNote(String noteId) => const Stream.empty();
  @override
  Future<Result<Note>> createNote(Note note) => throw UnimplementedError();
  @override
  Future<Result<Note>> updateNote(Note note) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteNote(String noteId) => throw UnimplementedError();
  @override
  Future<Result<Note>> setPinned(String noteId, {required bool isPinned}) => throw UnimplementedError();
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

class _FakeHabitRepository implements HabitRepository {
  List<Habit> habits = const [];
  @override
  String newHabitId() => 'id';
  @override
  Stream<List<Habit>> watchHabits() => Stream.value(habits);
  @override
  Stream<Habit?> watchHabit(String habitId) => const Stream.empty();
  @override
  Stream<List<HabitRecord>> watchHabitRecords(String habitId) => const Stream.empty();
  @override
  Future<Result<Habit>> createHabit(Habit habit) => throw UnimplementedError();
  @override
  Future<Result<Habit>> updateHabit(Habit habit) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteHabit(String habitId) => throw UnimplementedError();
  @override
  Future<Result<Habit>> setCheckIn(String habitId, DateTime date, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<List<HabitRecord>> getRecordsInRange(DateTime start, DateTime end) async => const [];
}

Task _task({String taskId = 't1', String title = 'Görev', String? description, DateTime? dueDate}) => Task(
      taskId: taskId,
      title: title,
      description: description,
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      dueDate: dueDate,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Project _project({String projectId = 'p1', String title = 'Proje', String? description}) => Project(
      projectId: projectId,
      title: title,
      description: description,
      color: '#FF8A8A',
      status: ProjectStatus.active,
      taskCount: 0,
      completedTaskCount: 0,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Note _note({String noteId = 'n1', String title = 'Not', String? content, DateTime? updatedAt}) => Note(
      noteId: noteId,
      title: title,
      content: content,
      isPinned: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: updatedAt ?? DateTime(2026, 1, 1),
    );

Habit _habit({String habitId = 'h1', String name = 'Alışkanlık'}) => Habit(
      habitId: habitId,
      name: name,
      color: '#FF8A8A',
      targetFrequency: HabitTargetFrequency.daily,
      currentStreak: 0,
      longestStreak: 0,
      status: HabitStatus.active,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  late _FakeTaskRepository taskRepo;
  late _FakeProjectRepository projectRepo;
  late _FakeNoteRepository noteRepo;
  late _FakeHabitRepository habitRepo;

  SearchUseCase buildUseCase() => SearchUseCase(
        WatchTasksUseCase(taskRepo),
        WatchProjectsUseCase(projectRepo),
        WatchNotesUseCase(noteRepo),
        WatchHabitsUseCase(habitRepo),
      );

  setUp(() {
    taskRepo = _FakeTaskRepository();
    projectRepo = _FakeProjectRepository();
    noteRepo = _FakeNoteRepository();
    habitRepo = _FakeHabitRepository();
  });

  test('boş sorgu hiçbir feature\'ı sorgulamadan boş liste döner', () async {
    final result = await buildUseCase().call(query: '   ');
    expect(result, isEmpty);
  });

  test('dört feature\'ın da başlık/isim alanında büyük/küçük harf duyarsız arama yapar', () async {
    taskRepo.tasks = [_task(title: 'Market Alışverişi')];
    projectRepo.projects = [_project(title: 'Market Uygulaması')];
    noteRepo.notes = [_note(title: 'Market Listesi')];
    habitRepo.habits = [_habit(name: 'Markete Yürüyerek Git')];

    final result = await buildUseCase().call(query: 'MARKET');

    expect(result, hasLength(4));
    expect(result.map((r) => r.type).toSet(), {
      SearchResultType.task,
      SearchResultType.project,
      SearchResultType.note,
      SearchResultType.habit,
    });
  });

  test('görev açıklaması ve not içeriği de aranır (yalnızca başlık değil)', () async {
    taskRepo.tasks = [_task(title: 'Alakasız', description: 'süt al')];
    noteRepo.notes = [_note(title: 'Alakasız', content: 'süt fiyatları arttı')];

    final result = await buildUseCase().call(query: 'süt');

    expect(result, hasLength(2));
  });

  test('eşleşmeyen kayıtlar sonuca dahil edilmez', () async {
    taskRepo.tasks = [_task(title: 'Alakasız görev')];

    final result = await buildUseCase().call(query: 'bulunmaz');

    expect(result, isEmpty);
  });

  test('tür filtresi verilirse yalnızca o türde arama yapılır', () async {
    taskRepo.tasks = [_task(title: 'ortak kelime')];
    noteRepo.notes = [_note(title: 'ortak kelime')];

    final result = await buildUseCase().call(query: 'ortak', type: SearchResultType.task);

    expect(result, hasLength(1));
    expect(result.single.type, SearchResultType.task);
  });

  test('todayOnly yalnızca bugüne ait tarih alanı olan sonuçları döner (Task/Note)', () async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    taskRepo.tasks = [
      _task(taskId: 't1', title: 'bugünkü görev', dueDate: today),
      _task(taskId: 't2', title: 'dünkü görev', dueDate: yesterday),
      _task(taskId: 't3', title: 'tarihsiz görev'),
    ];

    final result = await buildUseCase().call(query: 'görev', todayOnly: true);

    expect(result, hasLength(1));
    expect(result.single.id, 't1');
  });

  test('todayOnly, tarih kavramı olmayan türleri (Project/Habit) etkilemez', () async {
    projectRepo.projects = [_project(title: 'zaman bağımsız proje')];
    habitRepo.habits = [_habit(name: 'zaman bağımsız alışkanlık')];

    final result = await buildUseCase().call(query: 'zaman bağımsız', todayOnly: true);

    expect(result, hasLength(2));
  });

  test(
    'ROADMAP FAZ 12 test noktası — büyük veri setinde (500+ görev/proje/not/alışkanlık) '
    'arama makul sürede (1 saniye altında) sonuç döner',
    () async {
      taskRepo.tasks = [
        for (var i = 0; i < 500; i++) _task(taskId: 't$i', title: 'Görev $i market alışverişi'),
      ];
      projectRepo.projects = [
        for (var i = 0; i < 500; i++) _project(projectId: 'p$i', title: 'Proje $i market'),
      ];
      noteRepo.notes = [
        for (var i = 0; i < 500; i++) _note(noteId: 'n$i', title: 'Not $i market listesi'),
      ];
      habitRepo.habits = [
        for (var i = 0; i < 500; i++) _habit(habitId: 'h$i', name: 'Alışkanlık $i markete gitme'),
      ];

      final stopwatch = Stopwatch()..start();
      final result = await buildUseCase().call(query: 'market');
      stopwatch.stop();

      expect(result, hasLength(2000));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: '2000 kayıtta arama 1 saniyeyi aştı: ${stopwatch.elapsedMilliseconds}ms',
      );
    },
  );
}
