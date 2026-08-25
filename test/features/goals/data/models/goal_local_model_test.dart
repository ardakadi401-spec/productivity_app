import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/goals/data/models/goal_local_model.dart';

/// `GoalLocalModel.toFirestoreJson()`/`fromFirestoreData()` — ROADMAP.md
/// FAZ 16 coverage denetiminde %0 bulundu (bkz.
/// `task_local_model_test.dart` ile aynı gerekçe).
GoalLocalModel _fullModel() => GoalLocalModel()
  ..goalId = 'g1'
  ..title = 'Günde 2 litre su iç'
  ..description = 'Detaylı açıklama'
  ..periodType = GoalPeriodTypeLocal.weekly
  ..periodStartDate = DateTime(2026, 1, 1)
  ..periodEndDate = DateTime(2026, 1, 7)
  ..linkedTaskIds = ['t1', 't2']
  ..progressType = GoalProgressTypeLocal.linkedTasks
  ..manualProgress = null
  ..status = GoalStatusLocal.inProgress
  ..createdAt = DateTime(2026, 1, 1)
  ..updatedAt = DateTime(2026, 1, 2)
  ..isDeleted = false
  ..deletedAt = null
  ..syncStatus = GoalSyncStatusLocal.pendingUpdate
  ..lastSyncedAt = DateTime(2026, 1, 1)
  ..localUpdatedAt = DateTime(2026, 1, 2);

void main() {
  test('toFirestoreJson doğru anahtarlarla ve Timestamp\'e çevirerek üretir', () {
    final json = _fullModel().toFirestoreJson();

    expect(json['goalId'], 'g1');
    expect(json['title'], 'Günde 2 litre su iç');
    expect(json['periodType'], 'weekly');
    expect(json['periodStartDate'], Timestamp.fromDate(DateTime(2026, 1, 1)));
    expect(json['periodEndDate'], Timestamp.fromDate(DateTime(2026, 1, 7)));
    expect(json['linkedTaskIds'], ['t1', 't2']);
    expect(json['progressType'], 'linkedTasks');
    expect(json['manualProgress'], isNull);
    expect(json['status'], 'inProgress');
  });

  test('fromFirestoreData -> toFirestoreJson round-trip tüm alanları korur', () {
    final original = _fullModel();
    final roundTripped = GoalLocalModel.fromFirestoreData(original.goalId, original.toFirestoreJson());

    expect(roundTripped.goalId, original.goalId);
    expect(roundTripped.title, original.title);
    expect(roundTripped.periodType, original.periodType);
    expect(roundTripped.periodStartDate, original.periodStartDate);
    expect(roundTripped.periodEndDate, original.periodEndDate);
    expect(roundTripped.linkedTaskIds, original.linkedTaskIds);
    expect(roundTripped.progressType, original.progressType);
    expect(roundTripped.manualProgress, original.manualProgress);
    expect(roundTripped.status, original.status);
    expect(roundTripped.syncStatus, GoalSyncStatusLocal.synced);
  });

  test('manuel ilerlemeli hedefte manualProgress korunur, linkedTaskIds eksikse boş liste olur', () {
    final manual = GoalLocalModel.fromFirestoreData('g2', {
      'title': 'Manuel Hedef',
      'periodType': 'daily',
      'periodStartDate': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'periodEndDate': Timestamp.fromDate(DateTime(2026, 1, 1)),
      // 'linkedTaskIds' kasıtlı olarak eksik.
      'progressType': 'manual',
      'manualProgress': 40,
      'status': 'inProgress',
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });

    expect(manual.manualProgress, 40);
    expect(manual.linkedTaskIds, isEmpty);
  });
}
