import '../../../../core/errors/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class SetNotePinnedUseCase {
  const SetNotePinnedUseCase(this._repository);

  final NoteRepository _repository;

  Future<Result<Note>> call(String noteId, {required bool isPinned}) =>
      _repository.setPinned(noteId, isPinned: isPinned);
}
