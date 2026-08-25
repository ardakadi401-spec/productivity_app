import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/pomodoro/data/models/pomodoro_session_local_model.dart';

/// `PomodoroSessionLocalModel.toFirestoreJson()`/`fromFirestoreData()` —
/// ROADMAP.md FAZ 16 coverage denetiminde %0 bulundu (bkz.
/// `task_local_model_test.dart` ile aynı gerekçe). `type` alanı `work`/
/// `break` gibi Firestore'a özgü bir sözcükle (Dart'ın `break` anahtar
/// kelimesiyle çakıştığı için yerelde `breakTime` adlandırılan enum
/// değerinden farklı) serileştirildiğinden bu eşleme özellikle test edilir.
void main() {
  test('toFirestoreJson work tipini "work" olarak, Timestamp\'leri doğru çevirerek üretir', () {
    final model = PomodoroSessionLocalModel()
      ..sessionId = 's1'
      ..taskId = 't1'
      ..type = PomodoroSessionTypeLocal.work
      ..plannedDurationSeconds = 1500
      ..actualDurationSeconds = 1480
      ..startedAt = DateTime(2026, 1, 1, 10)
      ..completedAt = DateTime(2026, 1, 1, 10, 25)
      ..isCompleted = true
      ..syncStatus = PomodoroSyncStatusLocal.pendingCreate
      ..lastSyncedAt = DateTime(2026, 1, 1)
      ..localUpdatedAt = DateTime(2026, 1, 1);

    final json = model.toFirestoreJson();

    expect(json['sessionId'], 's1');
    expect(json['taskId'], 't1');
    expect(json['type'], 'work');
    expect(json['plannedDuration'], 1500);
    expect(json['actualDuration'], 1480);
    expect(json['startedAt'], Timestamp.fromDate(DateTime(2026, 1, 1, 10)));
    expect(json['completedAt'], Timestamp.fromDate(DateTime(2026, 1, 1, 10, 25)));
    expect(json['isCompleted'], isTrue);
  });

  test('toFirestoreJson breakTime tipini "break" olarak üretir', () {
    final model = PomodoroSessionLocalModel()
      ..sessionId = 's2'
      ..taskId = null
      ..type = PomodoroSessionTypeLocal.breakTime
      ..plannedDurationSeconds = 300
      ..actualDurationSeconds = 300
      ..startedAt = DateTime(2026, 1, 1, 10, 25)
      ..completedAt = null
      ..isCompleted = false
      ..syncStatus = PomodoroSyncStatusLocal.pendingCreate
      ..lastSyncedAt = DateTime(2026, 1, 1)
      ..localUpdatedAt = DateTime(2026, 1, 1);

    final json = model.toFirestoreJson();

    expect(json['type'], 'break');
    expect(json['taskId'], isNull);
    expect(json['completedAt'], isNull);
  });

  test('fromFirestoreData -> toFirestoreJson round-trip tip eşlemesini korur', () {
    final data = {
      'taskId': 't1',
      'type': 'work',
      'plannedDuration': 1500,
      'actualDuration': 1480,
      'startedAt': Timestamp.fromDate(DateTime(2026, 1, 1, 10)),
      'completedAt': Timestamp.fromDate(DateTime(2026, 1, 1, 10, 25)),
      'isCompleted': true,
    };

    final model = PomodoroSessionLocalModel.fromFirestoreData('s1', data);

    expect(model.type, PomodoroSessionTypeLocal.work);
    expect(model.toFirestoreJson()['type'], 'work');
    expect(model.syncStatus, PomodoroSyncStatusLocal.synced);
  });

  test('type alanı eksikse varsayılan olarak work kabul edilir', () {
    final model = PomodoroSessionLocalModel.fromFirestoreData('s3', {
      'startedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });

    expect(model.type, PomodoroSessionTypeLocal.work);
    expect(model.plannedDurationSeconds, 0);
    expect(model.actualDurationSeconds, 0);
    expect(model.isCompleted, isFalse);
  });
}
