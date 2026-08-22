/// `GetPeriodStatsUseCase`'in döndürdüğü, persist edilmeyen (yalnızca
/// bellekte, o anki sorgu için hesaplanan) toplam + günlük kırılım değeri —
/// Statistic Summary Card'ların toplamları VE Chart Container'ın çubukları
/// aynı tek çağrıdan beslenir.
class PeriodStats {
  const PeriodStats({
    required this.tasksCompleted,
    required this.tasksCreated,
    required this.habitsCompletedCount,
    required this.habitsTotalCount,
    required this.pomodoroSessionsCompleted,
    required this.pomodoroTotalMinutes,
    required this.dailyBreakdown,
  });

  static const empty = PeriodStats(
    tasksCompleted: 0,
    tasksCreated: 0,
    habitsCompletedCount: 0,
    habitsTotalCount: 0,
    pomodoroSessionsCompleted: 0,
    pomodoroTotalMinutes: 0,
    dailyBreakdown: [],
  );

  final int tasksCompleted;
  final int tasksCreated;
  final int habitsCompletedCount;
  final int habitsTotalCount;
  final int pomodoroSessionsCompleted;
  final int pomodoroTotalMinutes;

  /// Chart Container'ın çubuk grafiği için — dönem içindeki HER takvim
  /// günü (gelecekteki günler dahil, sıfır değerlerle) tarih sırasıyla.
  final List<DailyStatPoint> dailyBreakdown;

  /// 0 alışkanlık-günü varsa bölme hatası olmadan 0 döner (Goals/Projects'in
  /// aynı ilkesiyle tutarlı).
  double get habitsCompletionRatio =>
      habitsTotalCount == 0 ? 0 : habitsCompletedCount / habitsTotalCount;

  bool get isEmpty =>
      tasksCompleted == 0 &&
      tasksCreated == 0 &&
      habitsTotalCount == 0 &&
      pomodoroSessionsCompleted == 0;
}

class DailyStatPoint {
  const DailyStatPoint({
    required this.date,
    required this.tasksCompleted,
    required this.habitsCompletedCount,
    required this.pomodoroSessionsCompleted,
  });

  final DateTime date;
  final int tasksCompleted;
  final int habitsCompletedCount;
  final int pomodoroSessionsCompleted;
}
