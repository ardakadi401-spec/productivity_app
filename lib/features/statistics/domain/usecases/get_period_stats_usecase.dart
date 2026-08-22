import '../../../habits/domain/entities/habit.dart';
import '../../../habits/domain/entities/habit_record.dart';
import '../../../habits/domain/usecases/get_habit_records_in_range_usecase.dart';
import '../../../habits/domain/usecases/watch_habits_usecase.dart';
import '../../../pomodoro/domain/entities/pomodoro_session.dart';
import '../../../pomodoro/domain/usecases/get_pomodoro_sessions_in_range_usecase.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_filter.dart';
import '../../../tasks/domain/usecases/watch_tasks_usecase.dart';
import '../entities/period_stats.dart';
import '../entities/statistics_period.dart';
import '../entities/statistics_snapshot.dart';
import '../repositories/statistics_snapshot_repository.dart';
import '../utils/statistics_period_calculator.dart';

/// DATABASE.md §10.1'in iki katmanlı stratejisini uygular: geçmiş günler
/// (bugünden önce) `StatisticsSnapshot` önbelleğinden okunur — eksikse
/// (ROADMAP.md FAZ 12 "gün değişimi" tetikleyicisi, Goals'ın
/// `CheckExpiredGoalsUseCase`'iyle aynı "ekrana giriş anında lazy
/// self-healing" ilkesi) tek seferlik hesaplanıp kalıcı olarak kaydedilir;
/// bugün her zaman ham veriden canlı hesaplanır, hiçbir zaman
/// önbelleklenmez (gün henüz "kapanmadı").
///
/// Tasks/Habits/Pomodoro'nun ham verisi, dönemdeki her gün için AYRI AYRI
/// değil, TEK bir sorguyla (gerekli aralık için) çekilir — ROADMAP.md FAZ 12
/// "N+1 sorgudan kaçının" kararı.
class GetPeriodStatsUseCase {
  const GetPeriodStatsUseCase(
    this._snapshotRepository,
    this._watchTasksUseCase,
    this._watchHabitsUseCase,
    this._getHabitRecordsInRangeUseCase,
    this._getPomodoroSessionsInRangeUseCase, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final StatisticsSnapshotRepository _snapshotRepository;
  final WatchTasksUseCase _watchTasksUseCase;
  final WatchHabitsUseCase _watchHabitsUseCase;
  final GetHabitRecordsInRangeUseCase _getHabitRecordsInRangeUseCase;
  final GetPomodoroSessionsInRangeUseCase _getPomodoroSessionsInRangeUseCase;
  final DateTime Function() _now;

  Future<PeriodStats> call(StatisticsPeriod period, DateTime referenceDate) async {
    final range = StatisticsPeriodCalculator.resolve(period, referenceDate);
    final allDays = StatisticsPeriodCalculator.daysInRange(range.start, range.end);
    final today = _todayDate();

    final effectiveDays = allDays.where((d) => !d.isAfter(today)).toList();
    if (effectiveDays.isEmpty) {
      // Dönem tamamen gelecekte (örn. gelecek haftayı görüntüleme) — hiçbir
      // Domain sorgusu yapmadan sıfır-doldurulmuş çubuklar döner.
      return PeriodStats(
        tasksCompleted: 0,
        tasksCreated: 0,
        habitsCompletedCount: 0,
        habitsTotalCount: 0,
        pomodoroSessionsCompleted: 0,
        pomodoroTotalMinutes: 0,
        dailyBreakdown: [for (final d in allDays) _zeroPoint(d)],
      );
    }

    final pastDays = effectiveDays.where((d) => d.isBefore(today)).toList();
    final includesToday = effectiveDays.any((d) => _isSameDay(d, today));

    final existing = pastDays.isEmpty
        ? const <StatisticsSnapshot>[]
        : await _snapshotRepository.getSnapshotsInRange(pastDays.first, pastDays.last);
    final existingById = {for (final s in existing) s.snapshotId: s};
    final missingPastDays =
        pastDays.where((d) => !existingById.containsKey(StatisticsSnapshot.formatSnapshotId(d))).toList();

    final daysNeedingLiveCompute = [...missingPastDays, if (includesToday) today];
    final computedById = <String, StatisticsSnapshot>{};

    if (daysNeedingLiveCompute.isNotEmpty) {
      daysNeedingLiveCompute.sort();
      final fetchStart = daysNeedingLiveCompute.first;
      final fetchEndDay = daysNeedingLiveCompute.last;
      final fetchEnd = DateTime(fetchEndDay.year, fetchEndDay.month, fetchEndDay.day, 23, 59, 59);

      // Her biri TEK sefer çağrılır (gün başına değil) — N+1'den kaçınma.
      final allTasks = await _watchTasksUseCase.call(filter: TaskFilter.none).first;
      final allHabits = await _watchHabitsUseCase.call().first;
      final habitRecords = await _getHabitRecordsInRangeUseCase.call(fetchStart, fetchEnd);
      final pomodoroSessions = await _getPomodoroSessionsInRangeUseCase.call(fetchStart, fetchEnd);

      for (final day in daysNeedingLiveCompute) {
        final snapshot = _computeSnapshotForDay(day, allTasks, allHabits, habitRecords, pomodoroSessions);
        computedById[snapshot.snapshotId] = snapshot;
        if (missingPastDays.any((d) => _isSameDay(d, day))) {
          // Geçmiş gün — kalıcı olarak kaydet (kayıt başarısız olsa da bu
          // çağrı için hesaplanan değer kullanılmaya devam eder; bir
          // sonraki ekrana girişte tekrar denenir).
          await _snapshotRepository.saveSnapshot(snapshot);
        }
      }
    }

    final dailyBreakdown = <DailyStatPoint>[];
    var tasksCompleted = 0;
    var tasksCreated = 0;
    var habitsCompletedCount = 0;
    var habitsTotalCount = 0;
    var pomodoroSessionsCompleted = 0;
    var pomodoroTotalMinutes = 0;

    for (final day in allDays) {
      final id = StatisticsSnapshot.formatSnapshotId(day);
      final snapshot = existingById[id] ?? computedById[id];
      if (snapshot == null) {
        dailyBreakdown.add(_zeroPoint(day));
        continue;
      }
      dailyBreakdown.add(
        DailyStatPoint(
          date: day,
          tasksCompleted: snapshot.tasksCompleted,
          habitsCompletedCount: snapshot.habitsCompletedCount,
          pomodoroSessionsCompleted: snapshot.pomodoroSessionsCompleted,
        ),
      );
      tasksCompleted += snapshot.tasksCompleted;
      tasksCreated += snapshot.tasksCreated;
      habitsCompletedCount += snapshot.habitsCompletedCount;
      habitsTotalCount += snapshot.habitsTotalCount;
      pomodoroSessionsCompleted += snapshot.pomodoroSessionsCompleted;
      pomodoroTotalMinutes += snapshot.pomodoroTotalMinutes;
    }

    return PeriodStats(
      tasksCompleted: tasksCompleted,
      tasksCreated: tasksCreated,
      habitsCompletedCount: habitsCompletedCount,
      habitsTotalCount: habitsTotalCount,
      pomodoroSessionsCompleted: pomodoroSessionsCompleted,
      pomodoroTotalMinutes: pomodoroTotalMinutes,
      dailyBreakdown: dailyBreakdown,
    );
  }

  StatisticsSnapshot _computeSnapshotForDay(
    DateTime day,
    List<Task> allTasks,
    List<Habit> allHabits,
    List<HabitRecord> habitRecordsInRange,
    List<PomodoroSession> pomodoroSessionsInRange,
  ) {
    final tasksCompleted = allTasks.where((t) => _isSameDay(t.completedAt, day)).length;
    final tasksCreated = allTasks.where((t) => _isSameDay(t.createdAt, day)).length;

    final recordsForDay = habitRecordsInRange.where((r) => _isSameDay(r.date, day));
    final habitsCompletedCount = recordsForDay.where((r) => r.isCompleted).length;
    final habitsTotalCount = allHabits.where((h) => h.isScheduledOn(day)).length;

    final workSessionsForDay = pomodoroSessionsInRange.where(
      (s) => s.type == PomodoroSessionType.work && _isSameDay(s.startedAt, day),
    );
    final pomodoroSessionsCompleted = workSessionsForDay.where((s) => s.isCompleted).length;
    final pomodoroTotalMinutes =
        workSessionsForDay.fold<int>(0, (sum, s) => sum + s.actualDuration.inMinutes);

    return StatisticsSnapshot(
      date: day,
      tasksCompleted: tasksCompleted,
      tasksCreated: tasksCreated,
      habitsCompletedCount: habitsCompletedCount,
      habitsTotalCount: habitsTotalCount,
      pomodoroSessionsCompleted: pomodoroSessionsCompleted,
      pomodoroTotalMinutes: pomodoroTotalMinutes,
      createdAt: _now(),
    );
  }

  DailyStatPoint _zeroPoint(DateTime day) =>
      DailyStatPoint(date: day, tasksCompleted: 0, habitsCompletedCount: 0, pomodoroSessionsCompleted: 0);

  DateTime _todayDate() {
    final now = _now();
    return DateTime(now.year, now.month, now.day);
  }

  bool _isSameDay(DateTime? a, DateTime b) =>
      a != null && a.year == b.year && a.month == b.month && a.day == b.day;
}
