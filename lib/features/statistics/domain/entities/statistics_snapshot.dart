/// DATABASE.md Bölüm 10 — `users/{userId}/statisticsSnapshots/{snapshotId}`
/// alanlarının Domain katmanı saf temsili. §10.1'in kendi tanımı gereği
/// **immutable**dir ("önceden hesaplanmış, değişmez özet belgeler") — bir
/// gün kapandıktan sonra bir daha yeniden hesaplanmaz/güncellenmez, bu
/// yüzden `HabitRecord`/`PomodoroSessions` ile aynı ilkeyle (DATABASE §13.4)
/// soft-delete/update alanı taşımaz.
class StatisticsSnapshot {
  const StatisticsSnapshot({
    required this.date,
    required this.tasksCompleted,
    required this.tasksCreated,
    required this.habitsCompletedCount,
    required this.habitsTotalCount,
    required this.pomodoroSessionsCompleted,
    required this.pomodoroTotalMinutes,
    required this.createdAt,
  });

  /// Saat bileşeni sıfırlanmış gün — bu snapshot'ın temsil ettiği takvim
  /// günü.
  final DateTime date;
  final int tasksCompleted;
  final int tasksCreated;
  final int habitsCompletedCount;
  final int habitsTotalCount;
  final int pomodoroSessionsCompleted;
  final int pomodoroTotalMinutes;
  final DateTime createdAt;

  /// DATABASE.md §10.2 — "Önerilen format: `yyyy-MM-dd`".
  String get snapshotId => formatSnapshotId(date);

  static String formatSnapshotId(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
