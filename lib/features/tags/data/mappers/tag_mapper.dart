import '../../domain/entities/tag.dart';
import '../models/tag_local_model.dart';

class TagMapper {
  TagMapper._();

  static Tag toEntity(TagLocalModel model) {
    return Tag(
      tagId: model.tagId,
      name: model.name,
      color: model.color,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static TagLocalModel fromEntity(
    Tag tag, {
    required TagSyncStatusLocal syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return TagLocalModel()
      ..tagId = tag.tagId
      ..name = tag.name
      ..color = tag.color
      ..createdAt = tag.createdAt
      ..updatedAt = tag.updatedAt
      ..syncStatus = syncStatus
      ..lastSyncedAt = lastSyncedAt
      ..localUpdatedAt = tag.updatedAt;
  }
}
