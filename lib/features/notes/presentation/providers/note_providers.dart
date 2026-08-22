import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/isar_provider.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../data/datasources/local/note_local_datasource.dart';
import '../../data/datasources/remote/note_remote_datasource.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_filter.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/cleanup_orphaned_note_links_usecase.dart';
import '../../domain/usecases/create_note_usecase.dart';
import '../../domain/usecases/delete_note_usecase.dart';
import '../../domain/usecases/link_note_to_project_or_task_usecase.dart';
import '../../domain/usecases/set_note_pinned_usecase.dart';
import '../../domain/usecases/update_note_usecase.dart';
import '../../domain/usecases/watch_note_usecase.dart';
import '../../domain/usecases/watch_notes_usecase.dart';

// --- Service / Data katmanı — ARCHITECTURE.md §5.2 ---

final noteLocalDatasourceProvider = Provider<NoteLocalDatasource>((ref) {
  return NoteLocalDatasource(ref.watch(isarProvider));
});

final noteRemoteDatasourceProvider = Provider<NoteRemoteDatasource>((ref) {
  return NoteRemoteDatasource();
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(
    ref.watch(noteLocalDatasourceProvider),
    ref.watch(noteRemoteDatasourceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

// --- Domain katmanı (UseCase provider'ları) ---

final watchNotesUseCaseProvider = Provider<WatchNotesUseCase>((ref) {
  return WatchNotesUseCase(ref.watch(noteRepositoryProvider));
});

final watchNoteUseCaseProvider = Provider<WatchNoteUseCase>((ref) {
  return WatchNoteUseCase(ref.watch(noteRepositoryProvider));
});

final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((ref) {
  return CreateNoteUseCase(ref.watch(noteRepositoryProvider));
});

final updateNoteUseCaseProvider = Provider<UpdateNoteUseCase>((ref) {
  return UpdateNoteUseCase(ref.watch(noteRepositoryProvider));
});

final deleteNoteUseCaseProvider = Provider<DeleteNoteUseCase>((ref) {
  return DeleteNoteUseCase(ref.watch(noteRepositoryProvider));
});

final setNotePinnedUseCaseProvider = Provider<SetNotePinnedUseCase>((ref) {
  return SetNotePinnedUseCase(ref.watch(noteRepositoryProvider));
});

final linkNoteToProjectOrTaskUseCaseProvider = Provider<LinkNoteToProjectOrTaskUseCase>((ref) {
  return LinkNoteToProjectOrTaskUseCase(ref.watch(noteRepositoryProvider));
});

/// ARCHITECTURE.md §4 — Notes, Tasks VE Projects Domain'ine tek yönlü, salt
/// okunur bağımlıdır (yalnızca artık var olmayan bağlantıları temizlemek
/// için).
final cleanupOrphanedNoteLinksUseCaseProvider = Provider<CleanupOrphanedNoteLinksUseCase>((ref) {
  return CleanupOrphanedNoteLinksUseCase(
    ref.watch(noteRepositoryProvider),
    ref.watch(watchTasksUseCaseProvider),
    ref.watch(watchProjectsUseCaseProvider),
  );
});

// --- Presentation katmanı — reaktif okuma provider'ları ---

/// Notes Screen listesi (SCREENS.md §4.18) — etiket filtresi değiştiğinde
/// yeniden dinlenir.
final noteListProvider = StreamProvider.autoDispose.family<List<Note>, NoteFilter>((ref, filter) {
  return ref.watch(watchNotesUseCaseProvider).call(filter: filter);
});

final noteDetailProvider = StreamProvider.autoDispose.family<Note?, String>((ref, noteId) {
  return ref.watch(watchNoteUseCaseProvider).call(noteId);
});

/// Project Detail Screen'in bağlı not listesi (SCREENS.md §4.8).
final notesByProjectProvider = StreamProvider.autoDispose.family<List<Note>, String>((
  ref,
  projectId,
) {
  return ref.watch(watchNotesUseCaseProvider).call(filter: NoteFilter(projectId: projectId));
});

/// Task Detail Screen'in bağlı not listesi (SCREENS.md §4.10).
final notesByTaskProvider = StreamProvider.autoDispose.family<List<Note>, String>((ref, taskId) {
  return ref.watch(watchNotesUseCaseProvider).call(filter: NoteFilter(taskId: taskId));
});
