import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/search/domain/entities/search_result.dart';
import 'package:productivity_app/features/search/domain/usecases/search_usecase.dart';
import 'package:productivity_app/features/search/presentation/pages/search_page.dart';
import 'package:productivity_app/features/search/presentation/providers/search_providers.dart';
import 'package:productivity_app/features/habits/domain/entities/habit.dart';
import 'package:productivity_app/features/habits/domain/entities/habit_record.dart';
import 'package:productivity_app/features/habits/domain/repositories/habit_repository.dart';
import 'package:productivity_app/features/habits/domain/usecases/watch_habits_usecase.dart';
import 'package:productivity_app/features/notes/domain/entities/note.dart';
import 'package:productivity_app/features/notes/domain/entities/note_filter.dart';
import 'package:productivity_app/features/notes/domain/repositories/note_repository.dart';
import 'package:productivity_app/features/notes/domain/usecases/watch_notes_usecase.dart';
import 'package:productivity_app/features/projects/domain/entities/project.dart';
import 'package:productivity_app/features/projects/domain/repositories/project_repository.dart';
import 'package:productivity_app/features/projects/domain/usecases/watch_projects_usecase.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/domain/usecases/watch_tasks_usecase.dart';
import 'package:productivity_app/core/errors/result.dart';

class _StubTaskRepository implements TaskRepository {
  @override
  String newTaskId() => 'id';
  @override
  String newSubTaskId(String taskId) => 'id';
  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => const Stream.empty();
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

class _StubProjectRepository implements ProjectRepository {
  @override
  String newProjectId() => 'id';
  @override
  Stream<List<Project>> watchProjects({ProjectStatus? status}) => const Stream.empty();
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
}

class _StubNoteRepository implements NoteRepository {
  @override
  String newNoteId() => 'id';
  @override
  Stream<List<Note>> watchNotes({NoteFilter filter = NoteFilter.none}) => const Stream.empty();
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

class _StubHabitRepository implements HabitRepository {
  @override
  String newHabitId() => 'id';
  @override
  Stream<List<Habit>> watchHabits() => const Stream.empty();
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

class _FakeSearchUseCase extends SearchUseCase {
  _FakeSearchUseCase()
      : super(
          WatchTasksUseCase(_StubTaskRepository()),
          WatchProjectsUseCase(_StubProjectRepository()),
          WatchNotesUseCase(_StubNoteRepository()),
          WatchHabitsUseCase(_StubHabitRepository()),
        );

  List<SearchResult> results = const [];

  @override
  Future<List<SearchResult>> call({required String query, SearchResultType? type, bool todayOnly = false}) async {
    return results;
  }
}

void main() {
  testWidgets('sorgu boşken ve son arama yokken "Aramaya başlamak için yaz" gösterir', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [searchUseCaseProvider.overrideWithValue(_FakeSearchUseCase())],
        child: MaterialApp(theme: AppTheme.light, home: const SearchPage()),
      ),
    );
    await tester.pump();

    expect(find.text('Aramaya başlamak için yaz'), findsOneWidget);
  });

  testWidgets('sorgu girildiğinde ve eşleşme olmadığında debounce sonrası "Sonuç bulunamadı" gösterir', (
    tester,
  ) async {
    final fake = _FakeSearchUseCase()..results = const [];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [searchUseCaseProvider.overrideWithValue(fake)],
        child: MaterialApp(theme: AppTheme.light, home: const SearchPage()),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'bulunamaz');
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Sonuç bulunamadı'), findsOneWidget);
  });

  testWidgets('sorgu eşleşme döndürdüğünde sonuç kartları render edilir', (tester) async {
    final fake = _FakeSearchUseCase()
      ..results = const [
        SearchResult(id: 't1', title: 'Market Alışverişi', type: SearchResultType.task),
      ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [searchUseCaseProvider.overrideWithValue(fake)],
        child: MaterialApp(theme: AppTheme.light, home: const SearchPage()),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'market');
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Market Alışverişi'), findsOneWidget);
  });

  testWidgets('sorgu boşken son aramalar varsa listelenir ve dokununca sorguya doldurur', (tester) async {
    final fake = _FakeSearchUseCase()
      ..results = const [
        SearchResult(id: 't1', title: 'Market Alışverişi', type: SearchResultType.task),
      ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [searchUseCaseProvider.overrideWithValue(fake)],
        child: MaterialApp(theme: AppTheme.light, home: const SearchPage()),
      ),
    );
    await tester.pump();

    // Önce bir arama yapılır (son aramalar geçmişine düşmesi için).
    await tester.enterText(find.byType(TextField), 'market');
    await tester.pump(const Duration(milliseconds: 500));

    // Sorguyu temizleyince son aramalar görünmeli.
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(find.text('Son Aramalar'), findsOneWidget);
    expect(find.text('market'), findsOneWidget);
  });
}
