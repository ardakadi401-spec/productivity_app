import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/tags/domain/entities/tag.dart';
import 'package:productivity_app/features/tags/domain/repositories/tag_repository.dart';
import 'package:productivity_app/features/tags/domain/usecases/create_tag_usecase.dart';
import 'package:productivity_app/features/tags/domain/usecases/watch_tags_usecase.dart';

Tag _tag({String tagId = 'tg1'}) => Tag(
      tagId: tagId,
      name: 'Etiket $tagId',
      color: '#FF8A8A',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _FakeTagRepository implements TagRepository {
  Result<Tag>? tagResult;
  List<Tag> watchTagsResult = const [];
  Tag? lastCreatedTag;

  @override
  String newTagId() => 'generated-tag-id';

  @override
  Stream<List<Tag>> watchTags() => Stream.value(watchTagsResult);

  @override
  Future<Result<Tag>> createTag(Tag tag) async {
    lastCreatedTag = tag;
    return tagResult!;
  }
}

void main() {
  late _FakeTagRepository repo;

  setUp(() => repo = _FakeTagRepository());

  test('CreateTagUseCase etiketi repository\'ye iletir', () async {
    repo.tagResult = Ok(_tag());
    final result = await CreateTagUseCase(repo).call(_tag());
    expect(repo.lastCreatedTag?.tagId, 'tg1');
    expect(result, isA<Ok<Tag>>());
  });

  test('WatchTagsUseCase repository stream\'ini olduğu gibi iletir', () async {
    repo.watchTagsResult = [_tag(), _tag(tagId: 'tg2')];
    final result = await WatchTagsUseCase(repo).call().first;
    expect(result.map((t) => t.tagId), ['tg1', 'tg2']);
  });

  test('Err durumunda usecase Err\'i olduğu gibi döndürür', () async {
    repo.tagResult = const Err(CacheFailure('boom'));
    final result = await CreateTagUseCase(repo).call(_tag());
    expect(result, isA<Err<Tag>>());
  });
}
