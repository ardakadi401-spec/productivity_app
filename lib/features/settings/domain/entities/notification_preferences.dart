/// DATABASE.md §2.3 — `users/{uid}.settings` embedded map'inin bildirim
/// alt kümesi. Domain katmanı saf temsili.
///
/// Kullanıcı kararı: genel anahtar (`notificationsEnabled`) kapalıysa hiçbir
/// tür planlanmaz — tür bazlı anahtarlar (`task/habit/pomodoro...Enabled`)
/// yalnızca genel anahtar açıkken devreye girer. Bu mantık [tasksAllowed]/
/// [habitsAllowed]/[pomodoroAllowed] getter'larında somutlaşır; Tasks/
/// Habits/Pomodoro `ScheduleNotificationUseCase`'i çağırmadan önce bu
/// getter'ları kontrol eder — Notification Domain/Service Settings'e hiç
/// bağımlı olmaz (ARCHITECTURE.md §10.2 kararı).
class NotificationPreferences {
  const NotificationPreferences({
    required this.notificationsEnabled,
    required this.taskRemindersEnabled,
    required this.habitRemindersEnabled,
    required this.pomodoroNotificationsEnabled,
  });

  final bool notificationsEnabled;
  final bool taskRemindersEnabled;
  final bool habitRemindersEnabled;
  final bool pomodoroNotificationsEnabled;

  /// AppUserModel.newProfile() ile birebir aynı varsayılanlar.
  static const defaults = NotificationPreferences(
    notificationsEnabled: true,
    taskRemindersEnabled: true,
    habitRemindersEnabled: true,
    pomodoroNotificationsEnabled: true,
  );

  bool get tasksAllowed => notificationsEnabled && taskRemindersEnabled;
  bool get habitsAllowed => notificationsEnabled && habitRemindersEnabled;
  bool get pomodoroAllowed => notificationsEnabled && pomodoroNotificationsEnabled;

  NotificationPreferences copyWith({
    bool? notificationsEnabled,
    bool? taskRemindersEnabled,
    bool? habitRemindersEnabled,
    bool? pomodoroNotificationsEnabled,
  }) {
    return NotificationPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      taskRemindersEnabled: taskRemindersEnabled ?? this.taskRemindersEnabled,
      habitRemindersEnabled: habitRemindersEnabled ?? this.habitRemindersEnabled,
      pomodoroNotificationsEnabled: pomodoroNotificationsEnabled ?? this.pomodoroNotificationsEnabled,
    );
  }
}
