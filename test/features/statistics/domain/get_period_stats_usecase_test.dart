import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/habits/domain/entities/habit.dart';
import 'package:productivity_app/features/habits/domain/entities/habit_record.dart';
import 'package:productivity_app/features/habits/domain/repositories/habit_repository.dart';
import 'package:productivity_app/features/habits/domain/usecases/get_habit_records_in_range_usecase.dart';
import 'package:productivity_app/features/habits/domain/usecases/watch_habits_usecase.dart';
import 'package:productivity_app/features/pomodoro/domain/entities/pomodoro_session.dart';
import 'package:productivity_app/features/pomodoro/domain/repositories/pomodoro_repository.dart';
import 'package:productivity_app/features/pomodoro/domain/usecases/get_pomodoro_sessions_in_range_usecase.dart';
import 'package:productivity_app/features/statistics/domain/entities/statistics_period.dart';
import 'package:productivity_app/features/statistics/domain/entities/statistics_snapshot.dart';
import 'package:productivity_app/features/statistics/domain/repositories/statistics_snapshot_repository.dart';
import 'package:productivity_app/features/statistics/domain/usecases/get_period_stats_usecase.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/domain/usecases/watch_tasks_usecase.dart';

class _FakeSnapshotRepository implements StatisticsSnapshotRepository {
  List<StatisticsSnapshot> existing = const [];
  final List<StatisticsSnapshot> saved = [];
  int getRangeCallCount = 0;

  @override
  Future<List<StatisticsSnapshot>> getSnapshotsInRange(DateTime start, DateTime end) async {
    getRangeCallCount++;
    return existing
        .where((s) => !s.date.isBefore(start) && !s.date.isAfter(end))
        .toList();
  }

  @override
  Future<Result<StatisticsSnapshot>> saveSnapshot(StatisticsSnapshot snapshot) async {
    saved.add(snapshot);
    return Ok(snapshot);
  }
}

class _FakeTaskRepository implements TaskRepository {
  List<Task> tasks = const [];
  int watchCallCount = 0;

  @override
  String newTaskId() => 'id';
  @override
  String newSubTaskId(String taskId) => 'id';
  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) {
    watchCallCount++;
    return Stream.value(tasks);
  }

  @override
  Stream<Task?> watchTask(String taskId) => const Stream.empty();
  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => const Stream.empty();
  @override
  Stream<List<Task>> watchTodayTasks() => const Stream.empty();
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
  List<Habit> habits = const [];
  List<HabitRecord> records = const [];
  int watchHabitsCallCount = 0;
  int getRecordsInRangeCallCount = 0;

  @override
  String newHabitId() => 'id';
  @override
  Stream<List<Habit>> watchHabits() {
    watchHabitsCallCount++;
    return Stream.value(habits);
  }

  @override
  Stream<Habit?> watchHabit(String habitId) => const Stream.empty();
  @override
  Stream<List<HabitRecord>> watchHabitRecords(String habitId) => const Stream.empty();
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
  Future<List<HabitRecord>> getRecordsInRange(DateTime start, DateTime end) async {
    getRecordsInRangeCallCount++;
    return records.where((r) => !r.date.isBefore(start) && !r.date.isAfter(end)).toList();
  }
}

class _FakePomodoroRepository implements PomodoroRepository {
  List<PomodoroSession> sessions = const [];
  int getSessionsInRangeCallCount = 0;

  @override
  String newSessionId() => 'id';
  @override
  Stream<List<PomodoroSession>> watchSessionsByTask(String taskId) => const Stream.empty();
  @override
  Future<Result<PomodoroSession>> createSession(PomodoroSession session) => throw UnimplementedError();
  @override
  Future<Result<PomodoroSession>> completeSession(
    String sessionId, {
    required Duration actualDuration,
    required bool isCompleted,
  }) =>
      throw UnimplementedError();
  @override
  Future<Result<PomodoroSession>> linkSessionToTask(
    String sessionId, {
    String? taskId,
    bool clearTaskId = false,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<PomodoroSession>> getSessionsInRange(DateTime start, DateTime end) async {
    getSessionsInRangeCallCount++;
    return sessions.where((s) => !s.startedAt.isBefore(start) && !s.startedAt.isAfter(end)).toList();
  }
}

Task _task({String taskId = 't1', DateTime? createdAt, DateTime? completedAt}) => Task(
      taskId: taskId,
      title: 'Görev',
      priority: TaskPriority.medium,
      status: completedAt != null ? TaskStatus.completed : TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      createdAt: createdAt ?? DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      completedAt: completedAt,
    );

Habit _habit({String habitId = 'h1'}) => Habit(
      habitId: habitId,
      name: 'Alışkanlık',
      color: '#FF8A8A',
      targetFrequency: HabitTargetFrequency.daily,
      currentStreak: 0,
      longestStreak: 0,
      status: HabitStatus.active,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

HabitRecord _record({required DateTime date, bool isCompleted = true}) => HabitRecord(
      recordId: '${date.year}-${date.month}-${date.day}',
      habitId: 'h1',
      date: date,
      isCompleted: isCompleted,
    );

PomodoroSession _session({
  required DateTime startedAt,
  PomodoroSessionType type = PomodoroSessionType.work,
  bool isCompleted = true,
  Duration actualDuration = const Duration(minutes: 25),
}) =>
    PomodoroSession(
      sessionId: 'p-${startedAt.millisecondsSinceEpoch}',
      type: type,
      plannedDuration: const Duration(minutes: 25),
      actualDuration: actualDuration,
      startedAt: startedAt,
      isCompleted: isCompleted,
    );

void main() {
  late _FakeSnapshotRepository snapshotRepo;
  late _FakeTaskRepository taskRepo;
  late _FakeHabitRepository habitRepo;
  late _FakePomodoroRepository pomodoroRepo;

  GetPeriodStatsUseCase buildUseCase({DateTime Function()? now}) {
    return GetPeriodStatsUseCase(
      snapshotRepo,
      WatchTasksUseCase(taskRepo),
      WatchHabitsUseCase(habitRepo),
      GetHabitRecordsInRangeUseCase(habitRepo),
      GetPomodoroSessionsInRangeUseCase(pomodoroRepo),
      now: now,
    );
  }

  setUp(() {
    snapshotRepo = _FakeSnapshotRepository();
    taskRepo = _FakeTaskRepository();
    habitRepo = _FakeHabitRepository();
    pomodoroRepo = _FakePomodoroRepository();
  });

  test('bugün her zaman canlı hesaplanır, önbelleğe kaydedilmez', () async {
    final today = DateTime(2026, 3, 10);
    taskRepo.tasks = [_task(completedAt: today)];
    habitRepo.habits = [_habit()];
    habitRepo.records = [_record(date: today)];
    pomodoroRepo.sessions = [_session(startedAt: today)];

    final useCase = buildUseCase(now: () => today);
    final result = await useCase.call(StatisticsPeriod.daily, today);

    expect(result.tasksCompleted, 1);
    expect(result.habitsCompletedCount, 1);
    expect(result.pomodoroSessionsCompleted, 1);
    expect(snapshotRepo.saved, isEmpty, reason: 'bugün immutable önbelleğe yazılmamalı');
  });

  test('geçmiş bir gün için snapshot eksikse hesaplanır ve kalıcı olarak kaydedilir (self-healing)', () async {
    final today = DateTime(2026, 3, 10);
    final yesterday = DateTime(2026, 3, 9);
    taskRepo.tasks = [_task(completedAt: yesterday)];
    habitRepo.habits = [_habit()];
    habitRepo.records = [_record(date: yesterday)];
    pomodoroRepo.sessions = [_session(startedAt: yesterday)];

    final useCase = buildUseCase(now: () => today);
    // Haftalık dönem: bugünü ve dünü kapsar.
    final result = await useCase.call(StatisticsPeriod.weekly, today);

    expect(snapshotRepo.saved, hasLength(1));
    expect(snapshotRepo.saved.single.snapshotId, StatisticsSnapshot.formatSnapshotId(yesterday));
    expect(snapshotRepo.saved.single.tasksCompleted, 1);
    expect(result.tasksCompleted, greaterThanOrEqualTo(1));
  });

  test('geçmiş bir gün için snapshot zaten varsa tekrar hesaplanmaz, doğrudan kullanılır', () async {
    final today = DateTime(2026, 3, 10);
    final yesterday = DateTime(2026, 3, 9);
    // Ham veride 5 tamamlanan görev olsa bile, var olan snapshot 99 diyorsa
    // snapshot esas alınmalı (yeniden hesaplanmamalı).
    taskRepo.tasks = List.generate(5, (i) => _task(taskId: 't$i', completedAt: yesterday));
    snapshotRepo.existing = [
      StatisticsSnapshot(
        date: yesterday,
        tasksCompleted: 99,
        tasksCreated: 0,
        habitsCompletedCount: 0,
        habitsTotalCount: 0,
        pomodoroSessionsCompleted: 0,
        pomodoroTotalMinutes: 0,
        createdAt: yesterday,
      ),
    ];

    final useCase = buildUseCase(now: () => today);
    final result = await useCase.call(StatisticsPeriod.daily, yesterday);

    expect(result.tasksCompleted, 99);
    expect(snapshotRepo.saved, isEmpty, reason: 'var olan snapshot yeniden kaydedilmemeli');
  });

  test(
    'N+1 sorgudan kaçınma: aylık (çok günlü) dönemde Task/Habit/Pomodoro sorguları TEK sefer çağrılır',
    () async {
      final today = DateTime(2026, 3, 15);
      final useCase = buildUseCase(now: () => today);

      await useCase.call(StatisticsPeriod.monthly, today);

      expect(taskRepo.watchCallCount, 1);
      expect(habitRepo.watchHabitsCallCount, 1);
      expect(habitRepo.getRecordsInRangeCallCount, 1);
      expect(pomodoroRepo.getSessionsInRangeCallCount, 1);
    },
  );

  test('yalnızca work tipi tamamlanmış pomodoro oturumları sayılır, break hariç tutulur', () async {
    final today = DateTime(2026, 3, 10);
    pomodoroRepo.sessions = [
      _session(startedAt: today, actualDuration: const Duration(minutes: 25)),
      _session(startedAt: today, type: PomodoroSessionType.breakTime, actualDuration: const Duration(minutes: 5)),
    ];

    final useCase = buildUseCase(now: () => today);
    final result = await useCase.call(StatisticsPeriod.daily, today);

    expect(result.pomodoroSessionsCompleted, 1);
    expect(result.pomodoroTotalMinutes, 25);
  });

  test('habitsTotalCount yalnızca o gün hedeflenen (isScheduledOn) alışkanlıkları sayar', () async {
    final today = DateTime(2026, 3, 10); // Salı
    final scheduledOnlyMonday = Habit(
      habitId: 'h2',
      name: 'Pazartesi alışkanlığı',
      color: '#FF8A8A',
      targetFrequency: HabitTargetFrequency.specificDays,
      targetDays: const [1],
      currentStreak: 0,
      longestStreak: 0,
      status: HabitStatus.active,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    habitRepo.habits = [_habit(), scheduledOnlyMonday];

    final useCase = buildUseCase(now: () => today);
    final result = await useCase.call(StatisticsPeriod.daily, today);

    expect(result.habitsTotalCount, 1, reason: 'yalnızca daily habit bugün hedeflenmiş, diğeri Pazartesi\'ye özel');
  });

  test('dönem tamamen gelecekteyse hiçbir Domain sorgusu yapılmadan sıfır-doldurulmuş sonuç döner', () async {
    final today = DateTime(2026, 3, 10);
    final future = DateTime(2026, 3, 20);
    final useCase = buildUseCase(now: () => today);

    final result = await useCase.call(StatisticsPeriod.daily, future);

    expect(result.isEmpty, isTrue);
    expect(result.dailyBreakdown, hasLength(1));
    expect(taskRepo.watchCallCount, 0);
    expect(habitRepo.watchHabitsCallCount, 0);
    expect(pomodoroRepo.getSessionsInRangeCallCount, 0);
  });

  test('dailyBreakdown dönemdeki her günü (bugün dahil, gelecek dahil) tarih sırasıyla içerir', () async {
    final today = DateTime(2026, 3, 10); // Salı — haftanın ortası
    final useCase = buildUseCase(now: () => today);

    final result = await useCase.call(StatisticsPeriod.weekly, today);

    expect(result.dailyBreakdown, hasLength(7));
    expect(result.dailyBreakdown.first.date, DateTime(2026, 3, 9)); // Pazartesi
    expect(result.dailyBreakdown.last.date, DateTime(2026, 3, 15)); // Pazar
  });
}
