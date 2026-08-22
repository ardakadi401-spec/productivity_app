import '../../../../core/errors/failure.dart';
import '../../domain/entities/note.dart';

/// Not oluşturma/düzenleme ekranının ortak durumu (SCREENS.md §4.19) —
/// Tasks/Habits/Goals'ın form state'leriyle aynı desen. `title`/`content`
/// burada TUTULMAZ — ikisi de widget'ın kendi `TextEditingController`'ında
/// yaşar (biçimlendirme araç çubuğunun imleç/seçim konumuna işaretçi
/// eklemesi gerektiğinden, bkz. `note_formatting.dart`); yalnızca kaydetme
/// sırasında `save(title:, content:)` parametresi olarak buraya ulaşır.
class NoteFormState {
  const NoteFormState({
    this.color,
    this.projectId,
    this.taskId,
    this.tagIds = const [],
    this.isPinned = false,
    this.isSaving = false,
    this.error,
  });

  /// Hex kod (opsiyonel) — Note Card'ın sol renk şeridi.
  final String? color;
  final String? projectId;
  final String? taskId;
  final List<String> tagIds;
  final bool isPinned;
  final bool isSaving;
  final Failure? error;

  factory NoteFormState.fromNote(Note note) {
    return NoteFormState(
      color: note.color,
      projectId: note.projectId,
      taskId: note.taskId,
      tagIds: note.tagIds,
      isPinned: note.isPinned,
    );
  }

  NoteFormState copyWith({
    String? color,
    bool clearColor = false,
    String? projectId,
    bool clearProjectId = false,
    String? taskId,
    bool clearTaskId = false,
    List<String>? tagIds,
    bool? isPinned,
    bool? isSaving,
    Failure? error,
    bool clearError = false,
  }) {
    return NoteFormState(
      color: clearColor ? null : (color ?? this.color),
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      tagIds: tagIds ?? this.tagIds,
      isPinned: isPinned ?? this.isPinned,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
