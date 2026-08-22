import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/notification/domain/utils/notification_id.dart';

void main() {
  test('notificationIdFor aynı kaynak ID için her zaman aynı sonucu döner (deterministik)', () {
    final a = notificationIdFor('task-abc123');
    final b = notificationIdFor('task-abc123');
    expect(a, b);
  });

  test('notificationIdFor her zaman pozitif 32-bit aralığında döner', () {
    for (final id in ['a', 'b', 'z9x8c7v6', '', 'çok-uzun-bir-firestore-id-örneği-1234567890']) {
      final result = notificationIdFor(id);
      expect(result, greaterThanOrEqualTo(0));
      expect(result, lessThanOrEqualTo(0x7fffffff));
    }
  });

  test('farklı kaynak ID\'ler (büyük olasılıkla) farklı sonuç üretir', () {
    final a = notificationIdFor('task-1');
    final b = notificationIdFor('task-2');
    expect(a, isNot(b));
  });

  test('notificationIdForWeekday aynı habitId için farklı günlerde farklı kimlik üretir', () {
    final monday = notificationIdForWeekday('habit-1', 1);
    final tuesday = notificationIdForWeekday('habit-1', 2);
    expect(monday, isNot(tuesday));
  });

  test('notificationIdForWeekday, notificationIdFor\'dan (daily kimliği) farklıdır', () {
    final dailyId = notificationIdFor('habit-1');
    final weekdayId = notificationIdForWeekday('habit-1', 1);
    expect(dailyId, isNot(weekdayId));
  });

  test('notificationIdForWeekday deterministiktir', () {
    final a = notificationIdForWeekday('habit-1', 3);
    final b = notificationIdForWeekday('habit-1', 3);
    expect(a, b);
  });
}
