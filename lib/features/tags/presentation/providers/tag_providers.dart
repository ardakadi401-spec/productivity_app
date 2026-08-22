import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/isar_provider.dart';
import '../../data/datasources/local/tag_local_datasource.dart';
import '../../data/datasources/remote/tag_remote_datasource.dart';
import '../../data/repositories/tag_repository_impl.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/usecases/create_tag_usecase.dart';
import '../../domain/usecases/watch_tags_usecase.dart';

// --- Service / Data katmanı — ARCHITECTURE.md §5.2 ---

final tagLocalDatasourceProvider = Provider<TagLocalDatasource>((ref) {
  return TagLocalDatasource(ref.watch(isarProvider));
});

final tagRemoteDatasourceProvider = Provider<TagRemoteDatasource>((ref) {
  return TagRemoteDatasource();
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepositoryImpl(
    ref.watch(tagLocalDatasourceProvider),
    ref.watch(tagRemoteDatasourceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

// --- Domain katmanı (UseCase provider'ları) ---

final watchTagsUseCaseProvider = Provider<WatchTagsUseCase>((ref) {
  return WatchTagsUseCase(ref.watch(tagRepositoryProvider));
});

final createTagUseCaseProvider = Provider<CreateTagUseCase>((ref) {
  return CreateTagUseCase(ref.watch(tagRepositoryProvider));
});

// --- Presentation katmanı — reaktif okuma provider'ı ---

final tagListProvider = StreamProvider.autoDispose<List<Tag>>((ref) {
  return ref.watch(watchTagsUseCaseProvider).call();
});
