import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_filter.dart';
import '../providers/note_providers.dart';

/// Notes Screen (SCREENS.md §4.18) — Isar'ın reaktif stream'ine doğrudan
/// abone olan controller; `family` argümanı aktif proje/görev/etiket
/// filtresini taşır.
///
/// `build()`, "çift yönlü referans temizliği" gereksinimini karşılayan
/// `CleanupOrphanedNoteLinksUseCase`'in tetikleyicisidir — Notes Screen her
/// açıldığında artık var olmayan proje/görev bağlantıları taranıp temizlenir
/// (Goals'ın `CheckExpiredGoalsUseCase` tetikleyicisiyle aynı desen).
class NoteListController extends AutoDisposeFamilyStreamNotifier<List<Note>, NoteFilter> {
  @override
  Stream<List<Note>> build(NoteFilter arg) {
    // Tasks/Projects yapılandırılmamışsa (örn. testte ilgili repository
    // provider'ları override edilmemişse) cleanup usecase'in cross-feature
    // Domain bağımlılığı senkron olarak fırlayabilir — bu, Notes listesinin
    // asıl stream'ini engellememeli (Goals/Calendar ile aynı koruma).
    try {
      unawaited(ref.read(cleanupOrphanedNoteLinksUseCaseProvider).call());
    } catch (_) {
      // Sessiz — bir sonraki açılışta tekrar denenir.
    }
    return ref.watch(watchNotesUseCaseProvider).call(filter: arg);
  }

  Future<Result<void>> togglePinned(String noteId, {required bool isPinned}) async {
    final result = await ref.read(setNotePinnedUseCaseProvider).call(noteId, isPinned: isPinned);
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }

  Future<Result<void>> deleteNote(String noteId) async {
    final result = await ref.read(deleteNoteUseCaseProvider).call(noteId);
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }
}

final noteListControllerProvider = StreamNotifierProvider.autoDispose
    .family<NoteListController, List<Note>, NoteFilter>(NoteListController.new);
