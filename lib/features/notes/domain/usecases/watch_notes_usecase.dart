import '../entities/note.dart';
import '../entities/note_filter.dart';
import '../repositories/note_repository.dart';

/// Notes Screen listesi (SCREENS.md §4.18) ve Project/Task Detail'in bağlı
/// not listesi tarafından tüketilir.
class WatchNotesUseCase {
  const WatchNotesUseCase(this._repository);

  final NoteRepository _repository;

  Stream<List<Note>> call({NoteFilter filter = NoteFilter.none}) =>
      _repository.watchNotes(filter: filter);
}
