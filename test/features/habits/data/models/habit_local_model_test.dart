import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/habits/data/models/habit_local_model.dart';

/// `HabitLocalModel.toFirestoreJson()`/`fromFirestoreData()` — ROADMAP.md
/// FAZ 16 coverage denetiminde %0 bulundu (bkz.
/// `task_local_model_test.dart` ile aynı gerekçe).
HabitLocalModel _fullModel() => HabitLocalModel()
  ..habitId = 'h1'
  ..name = 'Su İç'
  ..icon = 'water_drop'
  ..color = '#8AB4FF'
  ..targetFrequency = HabitTargetFrequencyLocal.specificDays
  ..targetDays = [1, 3, 5]
  ..reminderTime = '09:00'
  ..currentStreak = 3
  ..longestStreak = 5
  ..status = HabitStatusLocal.active
  ..createdAt = DateTime(2026, 1, 1)
  ..updatedAt = DateTime(2026, 1, 2)
  ..isDeleted = false
  ..deletedAt = null
  ..syncStatus = HabitSyncStatusLocal.pendingUpdate
  ..lastSyncedAt = DateTime(2026, 1, 1)
  ..localUpdatedAt = DateTime(2026, 1, 2);

void main() {
  test('toFirestoreJson doğru anahtarlarla ve Timestamp\'e çevirerek üretir', () {
    final json = _fullModel().toFirestoreJson();

    expect(json['habitId'], 'h1');
    expect(json['name'], 'Su İç');
    expect(json['icon'], 'water_drop');
    expect(json['color'], '#8AB4FF');
    expect(json['targetFrequency'], 'specificDays');
    expect(json['targetDays'], [1, 3, 5]);
    expect(json['reminderTime'], '09:00');
    expect(json['currentStreak'], 3);
    expect(json['longestStreak'], 5);
    expect(json['status'], 'active');
  });

  test('fromFirestoreData -> toFirestoreJson round-trip tüm alanları korur', () {
    final original = _fullModel();
    final roundTripped = HabitLocalModel.fromFirestoreData(original.habitId, original.toFirestoreJson());

    expect(roundTripped.habitId, original.habitId);
    expect(roundTripped.name, original.name);
    expect(roundTripped.icon, original.icon);
    expect(roundTripped.color, original.color);
    expect(roundTripped.targetFrequency, original.targetFrequency);
    expect(roundTripped.targetDays, original.targetDays);
    expect(roundTripped.reminderTime, original.reminderTime);
    expect(roundTripped.currentStreak, original.currentStreak);
    expect(roundTripped.longestStreak, original.longestStreak);
    expect(roundTripped.status, original.status);
    expect(roundTripped.syncStatus, HabitSyncStatusLocal.synced);
  });

  test('opsiyonel alanlar eksik geldiğinde varsayılanlar kullanılır', () {
    final data = {
      'name': 'Minimal Alışkanlık',
      'icon': null,
      'color': '#000000',
      'targetFrequency': 'daily',
      // 'targetDays'/'currentStreak'/'longestStreak' kasıtlı olarak eksik.
      'reminderTime': null,
      'status': 'active',
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    };

    final model = HabitLocalModel.fromFirestoreData('h2', data);

    expect(model.targetDays, isEmpty);
    expect(model.currentStreak, 0);
    expect(model.longestStreak, 0);
  });
}
