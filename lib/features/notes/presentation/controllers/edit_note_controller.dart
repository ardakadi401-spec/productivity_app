import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/note.dart';
import '../providers/note_providers.dart';
import '../states/note_form_state.dart';

/// Not düzenleme — Create ile aynı alan seti, mevcut değerlerle önceden
/// doldurulmuş (Note Detail Screen'in tek ekranda oluşturma+düzenleme
/// birleşimi, SCREENS.md §4.19).
class EditNoteController extends AutoDisposeFamilyNotifier<NoteFormState, Note> {
  @override
  NoteFormState build(Note arg) => NoteFormState.fromNote(arg);

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

  Future<Result<Note>> save({required String title, String? content}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final updated = arg.copyWith(
      title: title.trim(),
      content: (content == null || content.trim().isEmpty) ? null : content,
      clearContent: content == null || content.trim().isEmpty,
      color: state.color,
      clearColor: state.color == null,
      projectId: state.projectId,
      clearProjectId: state.projectId == null,
      taskId: state.taskId,
      clearTaskId: state.taskId == null,
      tagIds: state.tagIds,
      isPinned: state.isPinned,
      updatedAt: DateTime.now(),
    );

    final result = await ref.read(updateNoteUseCaseProvider).call(updated);
    switch (result) {
      case Ok():
        state = state.copyWith(isSaving: false);
      case Err(:final failure):
        state = state.copyWith(isSaving: false, error: failure);
    }
    return result;
  }
}

final editNoteControllerProvider =
    NotifierProvider.autoDispose.family<EditNoteController, NoteFormState, Note>(
  EditNoteController.new,
);
