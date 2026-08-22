import '../entities/note.dart';
import '../repositories/note_repository.dart';

class WatchNoteUseCase {
  const WatchNoteUseCase(this._repository);

  final NoteRepository _repository;

  Stream<Note?> call(String noteId) => _repository.watchNote(noteId);
}
