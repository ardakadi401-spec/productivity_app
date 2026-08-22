import '../../../projects/domain/usecases/watch_projects_usecase.dart';
import '../../../tasks/domain/entities/task_filter.dart';
import '../../../tasks/domain/usecases/watch_tasks_usecase.dart';
import '../entities/note_filter.dart';
import '../repositories/note_repository.dart';

/// ROADMAP.md FAZ 10 riski: "Not-Proje/Görev bağlama ilişkisinin çift yönlü
/// tutarlılığı" — DATABASE.md §11.3 "Bir Proje silindiğinde, ona bağlı
/// Task'ların `projectId` alanı null'a çekilir" ilkesinin Notes tarafındaki
/// karşılığı. Task'lar soft-delete edilebildiğinden (Projects yalnızca
/// arşivlenir, silinmez — FAZ 6 kararı) burada yalnızca `taskId`/`projectId`
/// artık **var olmayan** (soft-delete edilmiş) bir kayda işaret eden notlar
/// taranır ve referansları temizlenir.
///
/// ARCHITECTURE.md §4 — Notes, Tasks ve Projects Domain'ine tek yönlü, salt
/// okunur bağımlıdır. Goals'ın `CheckExpiredGoalsUseCase`'iyle aynı desen:
/// Notes Screen açıldığında (`NoteListController`) tetiklenir, idempotenttir.
class CleanupOrphanedNoteLinksUseCase {
  const CleanupOrphanedNoteLinksUseCase(this._noteRepository, this._watchTasksUseCase, this._watchProjectsUseCase);

  final NoteRepository _noteRepository;
  final WatchTasksUseCase _watchTasksUseCase;
  final WatchProjectsUseCase _watchProjectsUseCase;

  Future<void> call() async {
    final notes = await _noteRepository.watchNotes(filter: NoteFilter.none).first;
    final linkedNotes = notes.where((n) => n.projectId != null || n.taskId != null).toList();
    if (linkedNotes.isEmpty) return;

    final needsTasks = linkedNotes.any((n) => n.taskId != null);
    final needsProjects = linkedNotes.any((n) => n.projectId != null);

    final taskIds = needsTasks
        ? (await _watchTasksUseCase(filter: TaskFilter.none).first).map((t) => t.taskId).toSet()
        : const <String>{};
    final projectIds = needsProjects
        ? (await _watchProjectsUseCase().first).map((p) => p.projectId).toSet()
        : const <String>{};

    for (final note in linkedNotes) {
      final taskGone = note.taskId != null && !taskIds.contains(note.taskId);
      final projectGone = note.projectId != null && !projectIds.contains(note.projectId);
      if (!taskGone && !projectGone) continue;

      await _noteRepository.setLink(
        note.noteId,
        clearTaskId: taskGone,
        clearProjectId: projectGone,
      );
    }
  }
}
