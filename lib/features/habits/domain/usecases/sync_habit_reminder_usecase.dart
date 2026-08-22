import '../../../notification/domain/entities/notification_request.dart';
import '../../../notification/domain/usecases/cancel_notification_usecase.dart';
import '../../../notification/domain/usecases/schedule_notification_usecase.dart';
import '../../../notification/domain/utils/notification_id.dart';
import '../../../settings/domain/usecases/watch_notification_preferences_usecase.dart';
import '../entities/habit.dart';

/// ROADMAP.md FAZ 13 — bir alışkanlık oluşturulduğunda/güncellendiğinde
/// çağrılır. Habits; Settings VE Notification Domain'ine tek yönlü
/// bağımlıdır (Tasks'ın `SyncTaskReminderUseCase`'iyle aynı ilke).
///
/// `daily` frekans TEK bir tekrarlayan (`NotificationRepeatMode.daily`)
/// bildirime, `specificDays` frekans SEÇİLİ HER gün için AYRI bir haftalık
/// tekrarlayan (`NotificationRepeatMode.weekly`) bildirime dönüşür —
/// `flutter_local_notifications`'ın "birden fazla haftanın günü" tek bir
/// istekte desteklenmediğinden (yalnızca tek bir gün+saat kombinasyonu).
class SyncHabitReminderUseCase {
  const SyncHabitReminderUseCase(
    this._watchNotificationPreferencesUseCase,
    this._scheduleNotificationUseCase,
    this._cancelNotificationUseCase,
  );

  final WatchNotificationPreferencesUseCase _watchNotificationPreferencesUseCase;
  final ScheduleNotificationUseCase _scheduleNotificationUseCase;
  final CancelNotificationUseCase _cancelNotificationUseCase;

  Future<void> call(Habit habit) async {
    // Önce olası TÜM eski planları temizle — frekans/gün seçimi değişmiş
    // olabilir, kalıntı bırakmamak için `daily` kimliği + haftanın 7 günü
    // için ayrı kimlikler baştan iptal edilir.
    await cancelAllFor(_cancelNotificationUseCase, habit.habitId);

    if (habit.reminderTime == null || habit.status == HabitStatus.archived) return;

    final preferences = await _watchNotificationPreferencesUseCase.call().first;
    if (!preferences.habitsAllowed) return;

    final time = parseReminderTime(habit.reminderTime!);
    if (time == null) return;

    switch (habit.targetFrequency) {
      case HabitTargetFrequency.daily:
        await _scheduleNotificationUseCase.call(
          NotificationRequest(
            id: notificationIdFor(habit.habitId),
            title: 'Alışkanlık Hatırlatması',
            body: habit.name,
            scheduledDate: nextDailyOccurrence(time),
            payload: '/habits/${habit.habitId}',
            repeat: NotificationRepeatMode.daily,
          ),
        );
      case HabitTargetFrequency.specificDays:
        for (final weekday in habit.targetDays) {
          await _scheduleNotificationUseCase.call(
            NotificationRequest(
              id: notificationIdForWeekday(habit.habitId, weekday),
              title: 'Alışkanlık Hatırlatması',
              body: habit.name,
              scheduledDate: nextWeekdayOccurrence(time, weekday),
              payload: '/habits/${habit.habitId}',
              repeat: NotificationRepeatMode.weekly,
            ),
          );
        }
    }
  }

  /// Silme akışında da (tam [Habit] nesnesi olmadan) kullanılabilmesi için
  /// paylaşılan, bağımsız bir yardımcı.
  static Future<void> cancelAllFor(CancelNotificationUseCase cancelUseCase, String habitId) async {
    await cancelUseCase.call(notificationIdFor(habitId));
    for (var weekday = 1; weekday <= 7; weekday++) {
      await cancelUseCase.call(notificationIdForWeekday(habitId, weekday));
    }
  }

  static ({int hour, int minute})? parseReminderTime(String reminderTime) {
    final parts = reminderTime.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return (hour: hour, minute: minute);
  }

  static DateTime nextDailyOccurrence(({int hour, int minute}) time) {
    final now = DateTime.now();
    var candidate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (!candidate.isAfter(now)) candidate = candidate.add(const Duration(days: 1));
    return candidate;
  }

  static DateTime nextWeekdayOccurrence(({int hour, int minute}) time, int weekday) {
    final now = DateTime.now();
    var candidate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    while (candidate.weekday != weekday || !candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}
