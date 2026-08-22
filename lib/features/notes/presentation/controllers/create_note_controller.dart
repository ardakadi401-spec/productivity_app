import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/note.dart';
import '../providers/note_providers.dart';
import '../states/note_form_state.dart';

/// Project Detail / Task Detail Screen'lerin "Not Ekle" eylemiyle proje/görev
/// önceden bağlı gelinebilir (SCREENS.md §4.8/§4.10) — Tasks'ın
/// `CreateTaskInitialArgs` deseniyle aynı: tek bir record `family` argümanı.
typedef CreateNoteInitialArgs = ({String? projectId, String? taskId});

/// Yeni Not Ekranı (SCREENS.md §4.19).
class CreateNoteController extends AutoDisposeFamilyNotifier<NoteFormState, CreateNoteInitialArgs> {
  @override
  NoteFormState build(CreateNoteInitialArgs arg) =>
      NoteFormState(projectId: arg.projectId, taskId: arg.taskId);

  void setColor(String? color) {
    state = color == null ? state.copyWith(clearColor: true) : state.copyWith(color: color);
  }

  void setProjectId(String? projectId) {
    state = projectId == null
        ? state.copyWith(clearProjectId: true)
        : state.copyWith(projectId: projectId);
  }

  void setTaskId(String? taskId) {
    state = taskId == null ? state.copyWith(clearTaskId: true) : state.copyWith(taskId: taskId);
  }

  void toggleTag(String tagId) {
    final current = [...state.tagIds];
    if (!current.remove(tagId)) current.add(tagId);
    state = state.copyWith(tagIds: current);
  }

  void togglePinned() => state = state.copyWith(isPinned: !state.isPinned);

  /// Başlık boş-doğrulaması form widget'ında yapılır; buraya yalnızca
  /// geçerli veri ulaşır.
  Future<Result<Note>> save({required String title, String? content}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final repository = ref.read(noteRepositoryProvider);
    final now = DateTime.now();
    final note = Note(
      noteId: repository.newNoteId(),
      title: title.trim(),
      content: (content == null || content.trim().isEmpty) ? null : content,
      color: state.color,
      projectId: state.projectId,
      taskId: state.taskId,
      tagIds: state.tagIds,
      isPinned: state.isPinned,
      createdAt: now,
      updatedAt: now,
    );

    final result = await ref.read(createNoteUseCaseProvider).call(note);
    switch (result) {
      case Ok():
        state = state.copyWith(isSaving: false);
      case Err(:final failure):
        state = state.copyWith(isSaving: false, error: failure);
    }
    return result;
  }
}

final createNoteControllerProvider = NotifierProvider.autoDispose
    .family<CreateNoteController, NoteFormState, CreateNoteInitialArgs>(CreateNoteController.new);
