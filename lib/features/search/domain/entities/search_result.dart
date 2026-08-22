import '../../../habits/domain/entities/habit.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../tasks/domain/entities/task.dart';

/// Search'ün kendi kavramı — Tasks/Projects/Notes/Habits'in farklı Domain
/// entity'lerini tek, ekranın anlayacağı ortak bir temsile indirger.
/// Calendar'ın `CalendarEvent`'i ile aynı ilke ("düzleştirilmiş, yalnızca
/// primitive alanlı birleşik temsil" — Domain-to-Domain okuma, hiçbir
/// feature'ın Presentation katmanına bağımlı olmadan).
class SearchResult {
  const SearchResult({required this.id, required this.title, required this.type, this.subtitle});

  final String id;
  final String title;
  final SearchResultType type;

  /// Önceden çözümlenmiş, kısa ikincil metin (örn. görev açıklaması, not
  /// içeriği) — biçimlendirme yapılmaz, yalnızca ilgili entity'nin ham
  /// metin alanı taşınır.
  final String? subtitle;

  factory SearchResult.fromTask(Task task) => SearchResult(
        id: task.taskId,
        title: task.title,
        type: SearchResultType.task,
        subtitle: task.description,
      );

  factory SearchResult.fromProject(Project project) => SearchResult(
        id: project.projectId,
        title: project.title,
        type: SearchResultType.project,
        subtitle: project.description,
      );

  factory SearchResult.fromNote(Note note) => SearchResult(
        id: note.noteId,
        title: note.title,
        type: SearchResultType.note,
        subtitle: note.content,
      );

  factory SearchResult.fromHabit(Habit habit) =>
      SearchResult(id: habit.habitId, title: habit.name, type: SearchResultType.habit);
}

enum SearchResultType { task, project, note, habit }
