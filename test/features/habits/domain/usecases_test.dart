import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/failure.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/habits/domain/entities/habit.dart';
import 'package:productivity_app/features/habits/domain/entities/habit_record.dart';
import 'package:productivity_app/features/habits/domain/repositories/habit_repository.dart';
import 'package:productivity_app/features/habits/domain/usecases/check_in_habit_usecase.dart';
import 'package:productivity_app/features/habits/domain/usecases/create_habit_usecase.dart';
import 'package:productivity_app/features/habits/domain/usecases/delete_habit_usecase.dart';
import 'package:productivity_app/features/habits/domain/usecases/update_habit_usecase.dart';
import 'package:productivity_app/features/habits/domain/usecases/watch_habit_records_usecase.dart';
import 'package:productivity_app/features/habits/domain/usecases/watch_habit_usecase.dart';
import 'package:productivity_app/features/habits/domain/usecases/watch_habits_usecase.dart';

Habit _habit({String habitId = 'h1'}) => Habit(
      habitId: habitId,
      name: 'Örnek alışkanlık',
      color: '#FF8A8A',
      targetFrequency: HabitTargetFrequency.daily,
      currentStreak: 0,
      longestStreak: 0,
      status: HabitStatus.active,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _FakeHabitRepository implements HabitRepository {
  Result<Habit>? habitResult;
  Result<void>? voidResult;
  List<Habit> watchHabitsResult = const [];
  Habit? watchHabitResult;
  List<HabitRecord> watchRecordsResult = const [];

  String? lastWatchedHabitId;
  String? lastWatchedRecordsHabitId;
  Habit? lastCreatedHabit;
  Habit? lastUpdatedHabit;
  String? lastDeletedHabitId;
  ({String habitId, DateTime date, bool isCompleted})? lastCheckInArgs;

  @override
  String newHabitId() => 'generated-habit-id';

  @override
  Stream<List<Habit>> watchHabits() => Stream.value(watchHabitsResult);

  @override
  Stream<Habit?> watchHabit(String habitId) {
    lastWatchedHabitId = habitId;
    return Stream.value(watchHabitResult);
  }

  @override
  Stream<List<HabitRecord>> watchHabitRecords(String habitId) {
    lastWatchedRecordsHabitId = habitId;
    return Stream.value(watchRecordsResult);
  }

  @override
  Future<Result<Habit>> createHabit(Habit habit) async {
    lastCreatedHabit = habit;
    return habitResult!;
  }

  @override
  Future<Result<Habit>> updateHabit(Habit habit) async {
    lastUpdatedHabit = habit;
    return habitResult!;
  }

  @override
  Future<Result<void>> deleteHabit(String habitId) async {
    lastDeletedHabitId = habitId;
    return voidResult!;
  }

  @override
  Future<Result<Habit>> setCheckIn(String habitId, DateTime date, {required bool isCompleted}) async {
    lastCheckInArgs = (habitId: habitId, date: date, isCompleted: isCompleted);
    return habitResult!;
  }

  List<HabitRecord> recordsInRangeResult = const [];
  ({DateTime start, DateTime end})? lastRangeArgs;

  @override
  Future<List<HabitRecord>> getRecordsInRange(DateTime start, DateTime end) async {
    lastRangeArgs = (start: start, end: end);
    return recordsInRangeResult;
  }
}

void main() {
  late _FakeHabitRepository repo;

  setUp(() => repo = _FakeHabitRepository());

  test('CreateHabitUseCase alışkanlığı repository\'ye iletir', () async {
    repo.habitResult = Ok(_habit());
    final result = await CreateHabitUseCase(repo).call(_habit());
    expect(repo.lastCreatedHabit?.habitId, 'h1');
    expect(result, isA<Ok<Habit>>());
  });

  test('UpdateHabitUseCase alışkanlığı repository\'ye iletir', () async {
    repo.habitResult = Ok(_habit());
    await UpdateHabitUseCase(repo).call(_habit());
    expect(repo.lastUpdatedHabit?.habitId, 'h1');
  });

  test('DeleteHabitUseCase habitId\'yi iletir', () async {
    repo.voidResult = const Ok(null);
    await DeleteHabitUseCase(repo).call('h1');
    expect(repo.lastDeletedHabitId, 'h1');
  });

  test('CheckInHabitUseCase habitId/date/isCompleted argümanlarını iletir', () async {
    repo.habitResult = Ok(_habit());
    final date = DateTime(2026, 3, 10);
    await CheckInHabitUseCase(repo).call('h1', date, isCompleted: true);
    expect(repo.lastCheckInArgs, (habitId: 'h1', date: date, isCompleted: true));
  });

  test('WatchHabitsUseCase watchHabits\'i sarmalar', () async {
    repo.watchHabitsResult = [_habit()];
    final result = await WatchHabitsUseCase(repo).call().first;
    expect(result, hasLength(1));
  });

  test('WatchHabitUseCase habitId\'yi iletir', () async {
    repo.watchHabitResult = _habit();
    await WatchHabitUseCase(repo).call('h1').first;
    expect(repo.lastWatchedHabitId, 'h1');
  });

  test('WatchHabitRecordsUseCase habitId\'yi iletir', () async {
    repo.watchRecordsResult = [
      HabitRecord(recordId: '2026-1-1', habitId: 'h1', date: DateTime(2026, 1, 1), isCompleted: true),
    ];
    await WatchHabitRecordsUseCase(repo).call('h1').first;
    expect(repo.lastWatchedRecordsHabitId, 'h1');
  });

  test('Err durumunda usecase Err\'i olduğu gibi döndürür', () async {
    repo.habitResult = const Err(CacheFailure('boom'));
    final result = await CreateHabitUseCase(repo).call(_habit());
    expect(result, isA<Err<Habit>>());
  });
}
