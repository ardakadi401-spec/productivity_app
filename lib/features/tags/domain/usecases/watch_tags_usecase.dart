import '../entities/tag.dart';
import '../repositories/tag_repository.dart';

/// Not oluşturma/düzenleme formundaki etiket seçici ve Notes Screen'in
/// etiket filtresi (SCREENS.md §4.18/§4.19) tarafından tüketilir.
class WatchTagsUseCase {
  const WatchTagsUseCase(this._repository);

  final TagRepository _repository;

  Stream<List<Tag>> call() => _repository.watchTags();
}
