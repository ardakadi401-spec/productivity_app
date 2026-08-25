import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';
import 'create_note_usecase.dart' show noteContentMaxLength;

class UpdateNoteUseCase {
  const UpdateNoteUseCase(this._repository);

  final NoteRepository _repository;

  Future<Result<Note>> call(Note note) async {
    final content = note.content;
    if (content != null && content.length > noteContentMaxLength) {
      return const Err(
        ValidationFailure('Not içeriği $noteContentMaxLength karakteri aşamaz.'),
      );
    }
    return _repository.updateNote(note);
  }
}
