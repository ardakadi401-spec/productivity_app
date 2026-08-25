import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/habits/domain/entities/habit.dart';
import 'package:productivity_app/features/habits/domain/usecases/sync_habit_reminder_usecase.dart';
import 'package:productivity_app/features/notification/domain/entities/notification_request.dart';
import 'package:productivity_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:productivity_app/features/notification/domain/usecases/cancel_notification_usecase.dart';
import 'package:productivity_app/features/notification/domain/usecases/schedule_notification_usecase.dart';
import 'package:productivity_app/features/notification/domain/utils/notification_id.dart';
import 'package:productivity_app/features/settings/domain/entities/notification_preferences.dart';
import 'package:productivity_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:productivity_app/features/settings/domain/usecases/watch_notification_preferences_usecase.dart';

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
  Future<bool> areNotificationsEnabled() async => true;
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

Habit _habit({
  String habitId = 'h1',
  String? reminderTime,
  HabitTargetFrequency targetFrequency = HabitTargetFrequency.daily,
  List<int> targetDays = const [],
  HabitStatus status = HabitStatus.active,
  String name = 'Alışkanlık',
}) =>
    Habit(
      habitId: habitId,
      name: name,
      color: '#FF8A8A',
      targetFrequency: targetFrequency,
      targetDays: targetDays,
      reminderTime: reminderTime,
      currentStreak: 0,
      longestStreak: 0,
      status: status,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  late _FakeSettingsRepository settingsRepo;
  late _FakeNotificationRepository notificationRepo;

  SyncHabitReminderUseCase buildUseCase() => SyncHabitReminderUseCase(
        WatchNotificationPreferencesUseCase(settingsRepo),
        ScheduleNotificationUseCase(notificationRepo),
        CancelNotificationUseCase(notificationRepo),
      );

  setUp(() {
    settingsRepo = _FakeSettingsRepository();
    notificationRepo = _FakeNotificationRepository();
  });

  test('reminderTime yoksa hiçbir şey planlanmaz, önce tüm eski planlar iptal edilir', () async {
    final habit = _habit();

    await buildUseCase().call(habit);

    expect(notificationRepo.scheduled, isEmpty);
    // daily kimliği + haftanın 7 günü = 8 iptal çağrısı.
    expect(notificationRepo.cancelled, hasLength(8));
  });

  test('daily frekans — TEK bir tekrarlayan (daily) bildirim planlanır', () async {
    final habit = _habit(reminderTime: '08:00', name: 'Su iç');

    await buildUseCase().call(habit);

    expect(notificationRepo.scheduled, hasLength(1));
    final request = notificationRepo.scheduled.single;
    expect(request.id, notificationIdFor('h1'));
    expect(request.repeat, NotificationRepeatMode.daily);
    expect(request.body, 'Su iç');
    expect(request.payload, '/habits/h1');
  });

  test('specificDays frekans — SEÇİLİ HER gün için ayrı haftalık bildirim planlanır', () async {
    final habit = _habit(
      reminderTime: '07:30',
      targetFrequency: HabitTargetFrequency.specificDays,
      targetDays: const [1, 3, 5],
    );

    await buildUseCase().call(habit);

    expect(notificationRepo.scheduled, hasLength(3));
    expect(notificationRepo.scheduled.every((r) => r.repeat == NotificationRepeatMode.weekly), isTrue);
    expect(
      notificationRepo.scheduled.map((r) => r.id).toSet(),
      {
        notificationIdForWeekday('h1', 1),
        notificationIdForWeekday('h1', 3),
        notificationIdForWeekday('h1', 5),
      },
    );
  });

  test('specificDays\'te seçili olmayan bir güne planlama yapılmaz', () async {
    final habit = _habit(
      reminderTime: '07:30',
      targetFrequency: HabitTargetFrequency.specificDays,
      targetDays: const [1],
    );

    await buildUseCase().call(habit);

    expect(
      notificationRepo.scheduled.map((r) => r.id),
      isNot(contains(notificationIdForWeekday('h1', 2))),
    );
  });

  test('arşivlenmiş alışkanlık için planlama yapılmaz', () async {
    final habit = _habit(reminderTime: '08:00', status: HabitStatus.archived);

    await buildUseCase().call(habit);

    expect(notificationRepo.scheduled, isEmpty);
  });

  test('genel anahtar kapalıysa habitRemindersEnabled açık olsa bile planlanmaz', () async {
    settingsRepo.preferences = const NotificationPreferences(
      notificationsEnabled: false,
      taskRemindersEnabled: true,
      habitRemindersEnabled: true,
      pomodoroNotificationsEnabled: true,
    );
    final habit = _habit(reminderTime: '08:00');

    await buildUseCase().call(habit);

    expect(notificationRepo.scheduled, isEmpty);
  });

  test('genel anahtar açık ama habitRemindersEnabled kapalıysa planlanmaz', () async {
    settingsRepo.preferences = const NotificationPreferences(
      notificationsEnabled: true,
      taskRemindersEnabled: true,
      habitRemindersEnabled: false,
      pomodoroNotificationsEnabled: true,
    );
    final habit = _habit(reminderTime: '08:00');

    await buildUseCase().call(habit);

    expect(notificationRepo.scheduled, isEmpty);
  });

  test(
    'frekans daily\'den specificDays\'e değiştiğinde eski daily planı iptal edilir, yenileri kurulur',
    () async {
      final useCase = buildUseCase();
      await useCase.call(_habit(reminderTime: '08:00'));
      notificationRepo.scheduled.clear();
      notificationRepo.cancelled.clear();

      await useCase.call(
        _habit(reminderTime: '08:00', targetFrequency: HabitTargetFrequency.specificDays, targetDays: const [2]),
      );

      expect(notificationRepo.cancelled, contains(notificationIdFor('h1')));
      expect(notificationRepo.scheduled.single.id, notificationIdForWeekday('h1', 2));
    },
  );

  group('cancelAllFor (paylaşılan yardımcı, silme akışında kullanılır)', () {
    test('daily kimliği + haftanın 7 günü için toplam 8 iptal çağrısı yapar', () async {
      await SyncHabitReminderUseCase.cancelAllFor(CancelNotificationUseCase(notificationRepo), 'h1');

      expect(notificationRepo.cancelled, hasLength(8));
      expect(notificationRepo.cancelled, contains(notificationIdFor('h1')));
      for (var weekday = 1; weekday <= 7; weekday++) {
        expect(notificationRepo.cancelled, contains(notificationIdForWeekday('h1', weekday)));
      }
    });
  });

  group('parseReminderTime (saf fonksiyon)', () {
    test('geçersiz formatta null döner', () {
      expect(SyncHabitReminderUseCase.parseReminderTime('geçersiz'), isNull);
    });

    test('geçerli HH:mm doğru saat/dakikaya çözülür', () {
      expect(SyncHabitReminderUseCase.parseReminderTime('07:05'), (hour: 7, minute: 5));
    });
  });
}
