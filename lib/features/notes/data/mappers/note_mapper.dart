import '../../domain/entities/note.dart';
import '../models/note_local_model.dart';

class NoteMapper {
  NoteMapper._();

  static Note toEntity(NoteLocalModel model) {
    return Note(
      noteId: model.noteId,
      title: model.title,
      content: model.content,
      color: model.color,
      projectId: model.projectId,
      taskId: model.taskId,
      tagIds: model.tagIds,
      isPinned: model.isPinned,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Yeni bir [NoteLocalModel] oluşturur — `Isar.autoIncrement` `id` hariç
  /// tüm alanlar entity'den ve senkronizasyon meta bilgisinden doldurulur.
  static NoteLocalModel fromEntity(
    Note note, {
    required NoteSyncStatusLocal syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return NoteLocalModel()
      ..noteId = note.noteId
      ..title = note.title
      ..content = note.content
      ..color = note.color
      ..projectId = note.projectId
      ..taskId = note.taskId
      ..tagIds = note.tagIds
      ..isPinned = note.isPinned
      ..createdAt = note.createdAt
      ..updatedAt = note.updatedAt
      ..isDeleted = false
      ..syncStatus = syncStatus
      ..lastSyncedAt = lastSyncedAt
      ..localUpdatedAt = note.updatedAt;
  }
}
