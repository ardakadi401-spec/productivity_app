import '../../../../core/errors/result.dart';
import '../entities/tag.dart';
import '../repositories/tag_repository.dart';

class CreateTagUseCase {
  const CreateTagUseCase(this._repository);

  final TagRepository _repository;

  Future<Result<Tag>> call(Tag tag) => _repository.createTag(tag);
}
