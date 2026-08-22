import '../../../notification/domain/entities/notification_request.dart';
import '../../../notification/domain/usecases/cancel_notification_usecase.dart';
import '../../../notification/domain/usecases/schedule_notification_usecase.dart';
import '../../../notification/domain/utils/notification_id.dart';
import '../../../settings/domain/usecases/watch_notification_preferences_usecase.dart';
import '../entities/task.dart';

/// ROADMAP.md FAZ 13 — bir görev oluşturulduğunda/güncellendiğinde/
/// tamamlandığında çağrılır (Tasks Presentation katmanından — "Tasks
/// tarafında ScheduleNotificationUseCase çağrısından önce [tercih] kontrolü"
/// kullanıcı kararı). Tasks; Settings VE Notification Domain'ine tek yönlü
/// bağımlıdır — Notification'ın kendisi bu ikisinden hiçbirini bilmez
/// (ARCHITECTURE.md §10.2, "tetikleyici olarak kullanılır, tersi değil").
///
/// Yalnızca HEM `dueDate` HEM `dueTime` doluysa planlama yapılır — yalnızca
/// tarih varsa (saat yok) bildirimi hangi anda tetikleyeceği belirsiz
/// kalacağından bilinçli olarak atlanır (kapsam kayması riskine karşı
/// minimal, sürpriz yaratmayan yorum).
class SyncTaskReminderUseCase {
  const SyncTaskReminderUseCase(
    this._watchNotificationPreferencesUseCase,
    this._scheduleNotificationUseCase,
    this._cancelNotificationUseCase,
  );

  final WatchNotificationPreferencesUseCase _watchNotificationPreferencesUseCase;
  final ScheduleNotificationUseCase _scheduleNotificationUseCase;
  final CancelNotificationUseCase _cancelNotificationUseCase;

  Future<void> call(Task task) async {
    final id = notificationIdFor(task.taskId);
    final scheduledDate = resolveScheduledDate(task);

    if (scheduledDate == null || task.isCompleted || !scheduledDate.isAfter(DateTime.now())) {
      await _cancelNotificationUseCase.call(id);
      return;
    }

    final preferences = await _watchNotificationPreferencesUseCase.call().first;
    if (!preferences.tasksAllowed) {
      await _cancelNotificationUseCase.call(id);
      return;
    }

    await _scheduleNotificationUseCase.call(
      NotificationRequest(
        id: id,
        title: 'Görev Hatırlatması',
        body: task.title,
        scheduledDate: scheduledDate,
        payload: '/tasks/${task.taskId}',
      ),
    );
  }

  /// `dueTime` (`HH:mm`) `dueDate`'in gün bileşenine uygulanır; ikisinden
  /// biri eksikse `null` döner. Saf, bağımsız test edilebilir.
  static DateTime? resolveScheduledDate(Task task) {
    final dueDate = task.dueDate;
    final dueTime = task.dueTime;
    if (dueDate == null || dueTime == null) return null;
    final parts = dueTime.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(dueDate.year, dueDate.month, dueDate.day, hour, minute);
  }
}
