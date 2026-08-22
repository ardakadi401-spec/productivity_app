import '../../../../core/errors/result.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// ROADMAP.md FAZ 10 "Yapılacak İşler" — Note Detail Screen'deki opsiyonel
/// proje/görev bağlama eylemi (SCREENS.md §4.19).
class LinkNoteToProjectOrTaskUseCase {
  const LinkNoteToProjectOrTaskUseCase(this._repository);

  final NoteRepository _repository;

  Future<Result<Note>> call(
    String noteId, {
    String? projectId,
    bool clearProjectId = false,
    String? taskId,
    bool clearTaskId = false,
  }) =>
      _repository.setLink(
        noteId,
        projectId: projectId,
        clearProjectId: clearProjectId,
        taskId: taskId,
        clearTaskId: clearTaskId,
      );
}
