import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// DATABASE.md §14.3 — not içeriği (content) maksimum 10.000 karakter.
const noteContentMaxLength = 10000;

class CreateNoteUseCase {
  const CreateNoteUseCase(this._repository);

  final NoteRepository _repository;

  Future<Result<Note>> call(Note note) async {
    final content = note.content;
    if (content != null && content.length > noteContentMaxLength) {
      return const Err(
        ValidationFailure('Not içeriği $noteContentMaxLength karakteri aşamaz.'),
      );
    }
    return _repository.createNote(note);
  }
}
