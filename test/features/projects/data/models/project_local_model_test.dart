import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/projects/data/models/project_local_model.dart';

/// `ProjectLocalModel.toFirestoreJson()`/`fromFirestoreData()` — ROADMAP.md
/// FAZ 16 coverage denetiminde %0 bulundu (bkz.
/// `task_local_model_test.dart` ile aynı gerekçe).
ProjectLocalModel _fullModel() => ProjectLocalModel()
  ..projectId = 'p1'
  ..title = 'Web Sitesi Yenileme'
  ..description = 'Detaylı açıklama'
  ..color = '#FF8A8A'
  ..icon = 'folder'
  ..status = ProjectStatusLocal.archived
  ..taskCount = 4
  ..completedTaskCount = 1
  ..createdAt = DateTime(2026, 1, 1)
  ..updatedAt = DateTime(2026, 1, 2)
  ..isDeleted = false
  ..deletedAt = null
  ..syncStatus = ProjectSyncStatusLocal.pendingUpdate
  ..lastSyncedAt = DateTime(2026, 1, 1)
  ..localUpdatedAt = DateTime(2026, 1, 2);

void main() {
  test('toFirestoreJson doğru anahtarlarla ve Timestamp\'e çevirerek üretir', () {
    final json = _fullModel().toFirestoreJson();

    expect(json['projectId'], 'p1');
    expect(json['title'], 'Web Sitesi Yenileme');
    expect(json['description'], 'Detaylı açıklama');
    expect(json['color'], '#FF8A8A');
    expect(json['icon'], 'folder');
    expect(json['status'], 'archived');
    expect(json['taskCount'], 4);
    expect(json['completedTaskCount'], 1);
    expect(json['isDeleted'], isFalse);
  });

  test('fromFirestoreData -> toFirestoreJson round-trip tüm alanları korur', () {
    final original = _fullModel();
    final roundTripped =
        ProjectLocalModel.fromFirestoreData(original.projectId, original.toFirestoreJson());

    expect(roundTripped.projectId, original.projectId);
    expect(roundTripped.title, original.title);
    expect(roundTripped.description, original.description);
    expect(roundTripped.color, original.color);
    expect(roundTripped.icon, original.icon);
    expect(roundTripped.status, original.status);
    expect(roundTripped.taskCount, original.taskCount);
    expect(roundTripped.completedTaskCount, original.completedTaskCount);
    expect(roundTripped.createdAt, original.createdAt);
    expect(roundTripped.isDeleted, original.isDeleted);
    expect(roundTripped.syncStatus, ProjectSyncStatusLocal.synced);
  });

  test('opsiyonel alanlar eksik geldiğinde varsayılanlar kullanılır', () {
    final data = {
      'title': 'Minimal Proje',
      'description': null,
      'color': '#000000',
      'icon': null,
      'status': 'active',
      // 'taskCount'/'completedTaskCount'/'isDeleted' kasıtlı olarak eksik.
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'deletedAt': null,
    };

    final model = ProjectLocalModel.fromFirestoreData('p2', data);

    expect(model.taskCount, 0);
    expect(model.completedTaskCount, 0);
    expect(model.isDeleted, isFalse);
  });
}
