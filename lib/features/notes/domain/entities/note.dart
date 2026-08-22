/// DATABASE.md Bölüm 8.2 — `users/{userId}/notes/{noteId}` alanlarının
/// Domain katmanı saf temsili (framework/Firebase/Isar bağımsız).
class Note {
  const Note({
    required this.noteId,
    required this.title,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
    this.content,
    this.color,
    this.projectId,
    this.taskId,
    this.tagIds = const [],
  });

  final String noteId;
  final String title;

  /// PRD §6.11 "basit biçimlendirme" — `**kalın**` ve `- madde işareti`
  /// düz metin işaretçileriyle taşınır (bkz. `note_formatting.dart`),
  /// zengin metin editörü/HTML/Delta formatı KULLANILMAZ.
  final String? content;

  /// Hex kod (opsiyonel) — Note Card'ın (COMPONENTS.md §4.7) sol renk şeridi.
  final String? color;

  /// Opsiyonel proje bağlantısı.
  final String? projectId;

  /// Opsiyonel görev bağlantısı.
  final String? taskId;
  final List<String> tagIds;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({
    String? title,
    String? content,
    bool clearContent = false,
    String? color,
    bool clearColor = false,
    String? projectId,
    bool clearProjectId = false,
    String? taskId,
    bool clearTaskId = false,
    List<String>? tagIds,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return Note(
      noteId: noteId,
      title: title ?? this.title,
      content: clearContent ? null : (content ?? this.content),
      color: clearColor ? null : (color ?? this.color),
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      tagIds: tagIds ?? this.tagIds,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
