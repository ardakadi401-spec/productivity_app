import '../../../../core/errors/result.dart';
import '../repositories/note_repository.dart';

class DeleteNoteUseCase {
  const DeleteNoteUseCase(this._repository);

  final NoteRepository _repository;

  Future<Result<void>> call(String noteId) => _repository.deleteNote(noteId);
}
