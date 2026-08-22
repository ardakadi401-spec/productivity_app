import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/notification/domain/entities/notification_request.dart';
import 'package:productivity_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:productivity_app/features/notification/domain/usecases/cancel_notification_usecase.dart';
import 'package:productivity_app/features/notification/domain/usecases/schedule_notification_usecase.dart';
import 'package:productivity_app/features/notification/domain/utils/notification_id.dart';
import 'package:productivity_app/features/settings/domain/entities/notification_preferences.dart';
import 'package:productivity_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:productivity_app/features/settings/domain/usecases/watch_notification_preferences_usecase.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/usecases/sync_task_reminder_usecase.dart';
import 'package:productivity_app/core/errors/result.dart';

class _FakeSettingsRepository implements SettingsRepository {
  NotificationPreferences preferences = NotificationPreferences.defaults;

  @override
  Stream<NotificationPreferences> watchNotificationPreferences() => Stream.value(preferences);

  @override
  Future<Result<void>> updateNotificationPreferences(NotificationPreferences preferences) =>
      throw UnimplementedError();
}

class _FakeNotificationRepository implements NotificationRepository {
  final List<NotificationRequest> scheduled = [];
  final List<int> cancelled = [];

  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Stream<String> get notificationTaps => const Stream.empty();
  @override
  Future<String?> getLaunchPayload() async => null;

  @override
  Future<void> scheduleNotification(NotificationRequest request) async {
    scheduled.add(request);
  }

  @override
  Future<void> cancelNotification(int id) async {
    cancelled.add(id);
  }
}

Task _task({
  String taskId = 't1',
  DateTime? dueDate,
  String? dueTime,
  bool isCompleted = false,
  String title = 'Görev',
}) =>
    Task(
      taskId: taskId,
      title: title,
      priority: TaskPriority.medium,
      status: isCompleted ? TaskStatus.completed : TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      dueDate: dueDate,
      dueTime: dueTime,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  late _FakeSettingsRepository settingsRepo;
  late _FakeNotificationRepository notificationRepo;

  SyncTaskReminderUseCase buildUseCase() => SyncTaskReminderUseCase(
        WatchNotificationPreferencesUseCase(settingsRepo),
        ScheduleNotificationUseCase(notificationRepo),
        CancelNotificationUseCase(notificationRepo),
      );

  setUp(() {
    settingsRepo = _FakeSettingsRepository();
    notificationRepo = _FakeNotificationRepository();
  });

  final future = DateTime.now().add(const Duration(days: 3));

  test('dueDate + dueTime dolu, tamamlanmamış, tercih açık — bildirim planlanır', () async {
    final task = _task(dueDate: future, dueTime: '09:30', title: 'Faturayı öde');

    await buildUseCase().call(task);

    expect(notificationRepo.scheduled, hasLength(1));
    final request = notificationRepo.scheduled.single;
    expect(request.id, notificationIdFor('t1'));
    expect(request.body, 'Faturayı öde');
    expect(request.payload, '/tasks/t1');
    expect(request.scheduledDate, DateTime(future.year, future.month, future.day, 9, 30));
    expect(request.repeat, NotificationRepeatMode.none);
  });

  test('dueTime yoksa (yalnızca dueDate) planlama yapılmaz', () async {
    final task = _task(dueDate: future);

    await buildUseCase().call(task);

    expect(notificationRepo.scheduled, isEmpty);
    expect(notificationRepo.cancelled, [notificationIdFor('t1')]);
  });

  test('görev tamamlanmışsa planlanmaz, olası eski plan iptal edilir', () async {
    final task = _task(dueDate: future, dueTime: '09:00', isCompleted: true);

    await buildUseCase().call(task);

    expect(notificationRepo.scheduled, isEmpty);
    expect(notificationRepo.cancelled, [notificationIdFor('t1')]);
  });

  test('genel bildirim anahtarı kapalıysa taskRemindersEnabled açık olsa bile planlanmaz', () async {
    settingsRepo.preferences = const NotificationPreferences(
      notificationsEnabled: false,
      taskRemindersEnabled: true,
      habitRemindersEnabled: true,
      pomodoroNotificationsEnabled: true,
    );
    final task = _task(dueDate: future, dueTime: '09:00');

    await buildUseCase().call(task);

    expect(notificationRepo.scheduled, isEmpty);
  });

  test('genel anahtar açık ama taskRemindersEnabled kapalıysa planlanmaz', () async {
    settingsRepo.preferences = const NotificationPreferences(
      notificationsEnabled: true,
      taskRemindersEnabled: false,
      habitRemindersEnabled: true,
      pomodoroNotificationsEnabled: true,
    );
    final task = _task(dueDate: future, dueTime: '09:00');

    await buildUseCase().call(task);

    expect(notificationRepo.scheduled, isEmpty);
  });

  test('geçmişte kalmış bir tarih/saat planlanmaz, iptal edilir', () async {
    final past = DateTime.now().subtract(const Duration(days: 1));
    final task = _task(dueDate: past, dueTime: '09:00');

    await buildUseCase().call(task);

    expect(notificationRepo.scheduled, isEmpty);
    expect(notificationRepo.cancelled, [notificationIdFor('t1')]);
  });

  test(
    'görev tarihi/saati değiştirildiğinde eski plan üzerine yazılır (aynı ID ile yeniden planlama)',
    () async {
      final useCase = buildUseCase();
      final original = _task(dueDate: future, dueTime: '09:00');
      await useCase.call(original);

      final rescheduled = _task(dueDate: future, dueTime: '14:00');
      await useCase.call(rescheduled);

      expect(notificationRepo.scheduled, hasLength(2));
      expect(notificationRepo.scheduled.every((r) => r.id == notificationIdFor('t1')), isTrue);
      expect(notificationRepo.scheduled.last.scheduledDate.hour, 14);
    },
  );

  group('resolveScheduledDate (saf fonksiyon)', () {
    test('dueDate veya dueTime eksikse null döner', () {
      expect(SyncTaskReminderUseCase.resolveScheduledDate(_task()), isNull);
      expect(SyncTaskReminderUseCase.resolveScheduledDate(_task(dueDate: future)), isNull);
    });

    test('geçersiz dueTime formatı null döner', () {
      final task = _task(dueDate: future, dueTime: 'geçersiz');
      expect(SyncTaskReminderUseCase.resolveScheduledDate(task), isNull);
    });

    test('geçerli dueDate + dueTime doğru DateTime\'a çözülür', () {
      final task = _task(dueDate: DateTime(2026, 5, 10), dueTime: '18:45');
      expect(SyncTaskReminderUseCase.resolveScheduledDate(task), DateTime(2026, 5, 10, 18, 45));
    });
  });
}
