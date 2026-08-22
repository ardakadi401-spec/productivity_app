import '../../../../core/errors/result.dart';
import '../entities/note.dart';
import '../entities/note_filter.dart';

/// Data katmanının uyması gereken sözleşme — ARCHITECTURE.md Bölüm 6.2.
abstract interface class NoteRepository {
  /// Ağ çağrısı yapmadan yeni bir not ID'si tahsis eder (Firestore
  /// client-side doküman ID — offline de çalışır).
  String newNoteId();

  Stream<List<Note>> watchNotes({NoteFilter filter = NoteFilter.none});

  Stream<Note?> watchNote(String noteId);

  Future<Result<Note>> createNote(Note note);

  Future<Result<Note>> updateNote(Note note);

  Future<Result<void>> deleteNote(String noteId);

  /// SCREENS.md §4.18 "notu sabitleme/sabit kaldırma (kaydırma hızlı
  /// eylemi)".
  Future<Result<Note>> setPinned(String noteId, {required bool isPinned});

  /// ROADMAP.md FAZ 10 `LinkNoteToProjectOrTaskUseCase` — proje/görev
  /// bağlantısını genel `updateNote`'tan ayrı, dedike bir yazma olarak
  /// tutar (Habits'in `setCheckIn`'i ile aynı ilke).
  Future<Result<Note>> setLink(
    String noteId, {
    String? projectId,
    bool clearProjectId = false,
    String? taskId,
    bool clearTaskId = false,
  });
}
