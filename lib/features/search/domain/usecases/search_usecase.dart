import '../../../habits/domain/usecases/watch_habits_usecase.dart';
import '../../../notes/domain/entities/note_filter.dart';
import '../../../notes/domain/usecases/watch_notes_usecase.dart';
import '../../../projects/domain/usecases/watch_projects_usecase.dart';
import '../../../tasks/domain/entities/task_filter.dart';
import '../../../tasks/domain/usecases/watch_tasks_usecase.dart';
import '../entities/search_result.dart';

/// ARCHITECTURE.md §4, #11 — Search; Tasks, Projects, Notes, Habits
/// Domain'ine tek yönlü, salt okunur bağımlıdır. Kendi repository'si yoktur
/// (STATE_MANAGEMENT.md §2 satır 11).
class SearchUseCase {
  const SearchUseCase(
    this._watchTasksUseCase,
    this._watchProjectsUseCase,
    this._watchNotesUseCase,
    this._watchHabitsUseCase,
  );

  final WatchTasksUseCase _watchTasksUseCase;
  final WatchProjectsUseCase _watchProjectsUseCase;
  final WatchNotesUseCase _watchNotesUseCase;
  final WatchHabitsUseCase _watchHabitsUseCase;

  /// [todayOnly] yalnızca bir tarih kavramı taşıyan türlere (Task'ın
  /// `dueDate`'i, Note'un `updatedAt`'i) uygulanır — Project/Habit'in
  /// anlamlı bir "bugün" alanı olmadığından bu filtre onları etkilemez,
  /// tür filtresiyle (SearchResultType) birlikte kullanılması beklenir.
  Future<List<SearchResult>> call({
    required String query,
    SearchResultType? type,
    bool todayOnly = false,
  }) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return const [];

    final results = <SearchResult>[];

    if (type == null || type == SearchResultType.task) {
      final tasks = await _watchTasksUseCase.call(filter: TaskFilter.none).first;
      results.addAll(
        tasks
            .where((t) => _matches(t.title, trimmed) || _matches(t.description, trimmed))
            .where((t) => !todayOnly || _isToday(t.dueDate))
            .map(SearchResult.fromTask),
      );
    }

    if (type == null || type == SearchResultType.project) {
      final projects = await _watchProjectsUseCase.call().first;
      results.addAll(
        projects
            .where((p) => _matches(p.title, trimmed) || _matches(p.description, trimmed))
            .map(SearchResult.fromProject),
      );
    }

    if (type == null || type == SearchResultType.note) {
      final notes = await _watchNotesUseCase.call(filter: NoteFilter.none).first;
      results.addAll(
        notes
            .where((n) => _matches(n.title, trimmed) || _matches(n.content, trimmed))
            .where((n) => !todayOnly || _isToday(n.updatedAt))
            .map(SearchResult.fromNote),
      );
    }

    if (type == null || type == SearchResultType.habit) {
      final habits = await _watchHabitsUseCase.call().first;
      results.addAll(habits.where((h) => _matches(h.name, trimmed)).map(SearchResult.fromHabit));
    }

    return results;
  }

  bool _matches(String? text, String query) => text != null && text.toLowerCase().contains(query);

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
