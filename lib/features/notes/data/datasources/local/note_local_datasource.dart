import 'package:isar_community/isar.dart';

import '../../../../../core/exceptions/app_exceptions.dart';
import '../../models/note_local_model.dart';

/// Isar üzerinden Note CRUD ve reaktif sorgular — ARCHITECTURE.md §6.4
/// offline-first akışının "önce yerele yaz/oku" katmanı. Filtreleme
/// (projeye/göreve/etikete göre) Repository katmanında bellek içi uygulanır
/// (Task/Project ile aynı desen — kişisel kullanım ölçeğinde yeterli).
class NoteLocalDatasource {
  NoteLocalDatasource(this._isar);

  final Isar _isar;

  Stream<List<NoteLocalModel>> watchNotes() {
    return _guardSync(
      () => _isar.noteLocalModels.filter().isDeletedEqualTo(false).watch(fireImmediately: true),
    );
  }

  Stream<NoteLocalModel?> watchNote(String noteId) {
    return _guardSync(
      () => _isar.noteLocalModels
          .filter()
          .noteIdEqualTo(noteId)
          .watch(fireImmediately: true)
          .map((results) => results.isEmpty ? null : results.first),
    );
  }

  Future<NoteLocalModel?> getByNoteId(String noteId) async {
    try {
      return await _isar.noteLocalModels.filter().noteIdEqualTo(noteId).findFirst();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<List<NoteLocalModel>> getPendingSync() async {
    try {
      return await _isar.noteLocalModels
          .filter()
          .not()
          .syncStatusEqualTo(NoteSyncStatusLocal.synced)
          .findAll();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> putNote(NoteLocalModel model) async {
    try {
      await _isar.writeTxn(() => _isar.noteLocalModels.put(model));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Stream<T> _guardSync<T>(Stream<T> Function() query) {
    try {
      return query();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
