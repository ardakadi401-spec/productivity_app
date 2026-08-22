import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
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
import 'package:productivity_app/features/search/domain/entities/search_result.dart';
import 'package:productivity_app/features/search/domain/usecases/search_usecase.dart';
import 'package:productivity_app/features/search/presentation/controllers/search_controller.dart';
import 'package:productivity_app/features/search/presentation/controllers/recent_searches_controller.dart';
import 'package:productivity_app/features/search/presentation/providers/search_providers.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/domain/usecases/watch_tasks_usecase.dart';

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

/// Gerçek `SearchUseCase`'in cross-feature eşleme mantığını tekrar test
/// etmek yerine (bkz. `search_usecase_test.dart`), controller'ın
/// debounce/filtre/sayfalama orkestrasyonunu izole test etmek için `call()`
/// geçersiz kılınır — çağrı sayısı ve son argümanlar izlenir.
class _SpySearchUseCase extends SearchUseCase {
  _SpySearchUseCase()
      : super(
          WatchTasksUseCase(_StubTaskRepository()),
          WatchProjectsUseCase(_StubProjectRepository()),
          WatchNotesUseCase(_StubNoteRepository()),
          WatchHabitsUseCase(_StubHabitRepository()),
        );

  int callCount = 0;
  List<({String query, SearchResultType? type, bool todayOnly})> calls = [];
  List<SearchResult> results = List.generate(
    45,
    (i) => SearchResult(id: 't$i', title: 'Sonuç $i', type: SearchResultType.task),
  );
  Object? errorToThrow;

  @override
  Future<List<SearchResult>> call({required String query, SearchResultType? type, bool todayOnly = false}) async {
    callCount++;
    calls.add((query: query, type: type, todayOnly: todayOnly));
    if (errorToThrow != null) throw errorToThrow!;
    return results;
  }
}

void main() {
  late _SpySearchUseCase spy;
  late ProviderContainer container;

  setUp(() {
    spy = _SpySearchUseCase();
    container = ProviderContainer(overrides: [searchUseCaseProvider.overrideWithValue(spy)]);
    // `searchControllerProvider` autoDispose'dur — kalıcı bir dinleyici
    // olmadan `container.read` sonrası hemen dispose edilir ve debounce
    // Timer'ı ateşlenmeden iptal olur. Testler boyunca canlı tutmak için
    // kalıcı bir dinleyici kaydedilir (standart Riverpod autoDispose test
    // deseni).
    container.listen(searchControllerProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  SearchController controller() => container.read(searchControllerProvider.notifier);

  test('debounce: hızlı ardışık setQuery çağrıları yalnızca bir kez arama tetikler', () async {
    controller().setQuery('a');
    controller().setQuery('ab');
    controller().setQuery('abc');

    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(spy.callCount, 1);
    expect(spy.calls.single.query, 'abc');
  });

  test('boş sorgu debounce beklemeden anında sonucu temizler, UseCase çağrılmaz', () async {
    controller().setQuery('abc');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    spy.callCount = 0;

    controller().setQuery('');

    expect(container.read(searchControllerProvider).resultsAsync.value, isEmpty);
    expect(spy.callCount, 0);
  });

  test('tür filtresi ve bugün filtresi UseCase\'e doğru iletilir', () async {
    controller().setQuery('abc');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    controller().setTypeFilter(SearchResultType.note);
    controller().setTodayOnly(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(spy.calls.last.type, SearchResultType.note);
    expect(spy.calls.last.todayOnly, isTrue);
  });

  test('sayfalama: ilk 20 sonuç gösterilir, loadMore() 20 daha ekler', () async {
    controller().setQuery('abc');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(container.read(searchControllerProvider).visibleResults, hasLength(20));
    expect(container.read(searchControllerProvider).hasMore, isTrue);

    controller().loadMore();

    expect(container.read(searchControllerProvider).visibleResults, hasLength(40));
    expect(container.read(searchControllerProvider).hasMore, isTrue);

    controller().loadMore();

    expect(container.read(searchControllerProvider).visibleResults, hasLength(45));
    expect(container.read(searchControllerProvider).hasMore, isFalse);
  });

  test('filtre değişince sayfalama sıfırlanır', () async {
    controller().setQuery('abc');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    controller().loadMore();
    expect(container.read(searchControllerProvider).visibleCount, 40);

    controller().setTypeFilter(SearchResultType.task);
    expect(container.read(searchControllerProvider).visibleCount, 20);
  });

  test('başarılı arama sonucu son aramalar geçmişine eklenir', () async {
    controller().setQuery('elma');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(container.read(recentSearchesControllerProvider), contains('elma'));
  });

  test('UseCase hata fırlatırsa AsyncValue.error\'a düşer, çökme olmaz', () async {
    spy.errorToThrow = Exception('boom');
    controller().setQuery('abc');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(container.read(searchControllerProvider).resultsAsync.hasError, isTrue);
  });
}
