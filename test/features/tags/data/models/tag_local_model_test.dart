import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/tags/data/models/tag_local_model.dart';

/// `TagLocalModel.toFirestoreJson()`/`fromFirestoreData()` — ROADMAP.md
/// FAZ 16 coverage denetiminde %0 bulundu (bkz.
/// `task_local_model_test.dart` ile aynı gerekçe).
void main() {
  test('toFirestoreJson doğru anahtarlarla ve Timestamp\'e çevirerek üretir', () {
    final model = TagLocalModel()
      ..tagId = 'tag1'
      ..name = 'İş'
      ..color = '#8AB4FF'
      ..createdAt = DateTime(2026, 1, 1)
      ..updatedAt = DateTime(2026, 1, 2)
      ..syncStatus = TagSyncStatusLocal.pendingCreate
      ..lastSyncedAt = DateTime(2026, 1, 1)
      ..localUpdatedAt = DateTime(2026, 1, 2);

    final json = model.toFirestoreJson();

    expect(json['tagId'], 'tag1');
    expect(json['name'], 'İş');
    expect(json['color'], '#8AB4FF');
    expect(json['createdAt'], Timestamp.fromDate(DateTime(2026, 1, 1)));
    expect(json['updatedAt'], Timestamp.fromDate(DateTime(2026, 1, 2)));
  });

  test('fromFirestoreData -> toFirestoreJson round-trip tüm alanları korur', () {
    final data = {
      'name': 'Kişisel',
      'color': '#FF8A8A',
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    };

    final model = TagLocalModel.fromFirestoreData('tag2', data);

    expect(model.tagId, 'tag2');
    expect(model.name, 'Kişisel');
    expect(model.color, '#FF8A8A');
    expect(model.syncStatus, TagSyncStatusLocal.synced);
    expect(model.toFirestoreJson()['name'], 'Kişisel');
  });
}
