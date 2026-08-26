import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/app/reschedule_all_notifications.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme_mode.dart';
import 'package:productivity_app/features/habits/domain/entities/habit.dart';
import 'package:productivity_app/features/habits/domain/entities/habit_record.dart';
import 'package:productivity_app/features/habits/domain/repositories/habit_repository.dart';
import 'package:productivity_app/features/habits/presentation/providers/habit_providers.dart';
import 'package:productivity_app/features/notification/domain/entities/notification_request.dart';
import 'package:productivity_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:productivity_app/features/notification/domain/utils/notification_id.dart';
import 'package:productivity_app/features/notification/presentation/providers/notification_providers.dart';
import 'package:productivity_app/features/settings/domain/entities/notification_preferences.dart';
import 'package:productivity_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:productivity_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Stream<NotificationPreferences> watchNotificationPreferences() =>
      Stream.value(NotificationPreferences.defaults);
  @override
  Future<Result<void>> updateNotificationPreferences(NotificationPreferences preferences) =>
      throw UnimplementedError();
  @override
  Stream<AppThemeMode> watchThemeMode() => Stream.value(AppThemeMode.system);
  @override
  Future<Result<void>> updateThemeMode(AppThemeMode mode) => throw UnimplementedError();
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

class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository(this.tasks);
  final List<Task> tasks;

  @override
  String newTaskId() => 'id';
  @override
  String newSubTaskId(String taskId) => 'id';
  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => Stream.value(tasks);
  @override
  Stream<Task?> watchTask(String taskId) => Stream.value(null);
  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => Stream.value(const []);
  @override
  Stream<List<Task>> watchTodayTasks() => Stream.value(const []);
  @override
  Future<Result<Task>> createTask(Task task) => throw UnimplementedError();
  @override
  Future<Result<Task>> updateTask(Task task) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteTask(String taskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> setTaskCompleted(String taskId, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<Result<SubTask>> addSubTask(SubTask subTask) => throw UnimplementedError();
  @override
  Future<Result<void>> setSubTaskCompleted(String subtaskId, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> deleteSubTask(String subtaskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> recalculateTaskProgress(String taskId) => throw UnimplementedError();
}

class _FakeHabitRepository implements HabitRepository {
  _FakeHabitRepository(this.habits);
  final List<Habit> habits;

  @override
  String newHabitId() => 'id';
  @override
  Stream<List<Habit>> watchHabits() => Stream.value(habits);
  @override
  Stream<Habit?> watchHabit(String habitId) => Stream.value(null);
  @override
  Stream<List<HabitRecord>> watchHabitRecords(String habitId) => Stream.value(const []);
  @override
  Future<Result<Habit>> createHabit(Habit habit) => throw UnimplementedError();
  @override
  Future<Result<Habit>> updateHabit(Habit habit) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteHabit(String habitId) => throw UnimplementedError();
  @override
  Future<Result<Habit>> setCheckIn(String habitId, DateTime date, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<List<HabitRecord>> getRecordsInRange(DateTime start, DateTime end) => throw UnimplementedError();
}

Task _task({required String taskId, required DateTime dueDate, required String dueTime}) => Task(
      taskId: taskId,
      title: 'Görev $taskId',
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      dueDate: dueDate,
      dueTime: dueTime,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Habit _habit({required String habitId, required String reminderTime}) => Habit(
      habitId: habitId,
      name: 'Alışkanlık $habitId',
      color: '#FF8A8A',
      targetFrequency: HabitTargetFrequency.daily,
      currentStreak: 0,
      longestStreak: 0,
      reminderTime: reminderTime,
      status: HabitStatus.active,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  late _FakeNotificationRepository notificationRepo;
  late _FakeSettingsRepository settingsRepo;

  ProviderContainer buildContainer({List<Task> tasks = const [], List<Habit> habits = const []}) {
    notificationRepo = _FakeNotificationRepository();
    settingsRepo = _FakeSettingsRepository();
    return ProviderContainer(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(notificationRepo),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        taskRepositoryProvider.overrideWithValue(_FakeTaskRepository(tasks)),
        habitRepositoryProvider.overrideWithValue(_FakeHabitRepository(habits)),
      ],
    );
  }

  test(
    'boot recovery: Isar\'daki güncel Task/Habit verisinden tüm bildirimler yeniden kurulur '
    '(ROADMAP FAZ 13 "cihaz yeniden başlatıldığında ... tekrar planla" zorunluluğu)',
    () async {
      final future = DateTime.now().add(const Duration(days: 2));
      final container = buildContainer(
        tasks: [_task(taskId: 't1', dueDate: future, dueTime: '09:00')],
        habits: [_habit(habitId: 'h1', reminderTime: '08:00')],
      );
      addTearDown(container.dispose);

      await rescheduleAllNotifications(container);

      expect(
        notificationRepo.scheduled.map((r) => r.id),
        containsAll([notificationIdFor('t1'), notificationIdFor('h1')]),
      );
    },
  );

  test('boot recovery: hiç görev/alışkanlık yoksa hiçbir şey planlanmaz, hata fırlatmaz', () async {
    final container = buildContainer();
    addTearDown(container.dispose);

    await rescheduleAllNotifications(container);

    expect(notificationRepo.scheduled, isEmpty);
  });

  test(
    'boot recovery: Task stream hata verirse (ör. oturum kapalı) Habit tarafı yine de işlenir',
    () async {
      notificationRepo = _FakeNotificationRepository();
      settingsRepo = _FakeSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          notificationRepositoryProvider.overrideWithValue(notificationRepo),
          settingsRepositoryProvider.overrideWithValue(settingsRepo),
          taskRepositoryProvider.overrideWithValue(_ThrowingTaskRepository()),
          habitRepositoryProvider.overrideWithValue(
            _FakeHabitRepository([_habit(habitId: 'h1', reminderTime: '08:00')]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await rescheduleAllNotifications(container);

      expect(notificationRepo.scheduled.map((r) => r.id), contains(notificationIdFor('h1')));
    },
  );
}

class _ThrowingTaskRepository implements TaskRepository {
  @override
  String newTaskId() => 'id';
  @override
  String newSubTaskId(String taskId) => 'id';
  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => Stream.error(Exception('boom'));
  @override
  Stream<Task?> watchTask(String taskId) => Stream.value(null);
  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => Stream.value(const []);
  @override
  Stream<List<Task>> watchTodayTasks() => Stream.value(const []);
  @override
  Future<Result<Task>> createTask(Task task) => throw UnimplementedError();
  @override
  Future<Result<Task>> updateTask(Task task) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteTask(String taskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> setTaskCompleted(String taskId, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<Result<SubTask>> addSubTask(SubTask subTask) => throw UnimplementedError();
  @override
  Future<Result<void>> setSubTaskCompleted(String subtaskId, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> deleteSubTask(String subtaskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> recalculateTaskProgress(String taskId) => throw UnimplementedError();
}
