import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/features/goals/domain/entities/goal.dart';
import 'package:productivity_app/features/goals/domain/repositories/goal_repository.dart';
import 'package:productivity_app/features/goals/domain/usecases/watch_goals_usecase.dart';
import 'package:productivity_app/features/statistics/domain/usecases/get_goals_achievement_rate_usecase.dart';

Goal _goal({String goalId = 'g1', GoalStatus status = GoalStatus.inProgress}) => Goal(
      goalId: goalId,
      title: 'Hedef',
      periodType: GoalPeriodType.weekly,
      periodStartDate: DateTime(2026, 1, 1),
      periodEndDate: DateTime(2026, 1, 7, 23, 59, 59),
      progressType: GoalProgressType.manual,
      manualProgress: 0,
      status: status,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

class _FakeGoalRepository implements GoalRepository {
  List<Goal> goals = const [];
  GoalPeriodType? lastPeriodFilter;

  @override
  String newGoalId() => 'id';

  @override
  Stream<List<Goal>> watchGoals({GoalPeriodType? periodType}) {
    lastPeriodFilter = periodType;
    return Stream.value(goals);
  }

  @override
  Stream<Goal?> watchGoal(String goalId) => const Stream.empty();
  @override
  Future<Result<Goal>> createGoal(Goal goal) => throw UnimplementedError();
  @override
  Future<Result<Goal>> updateGoal(Goal goal) => throw UnimplementedError();
  @override
  Future<Result<Goal>> setManualProgress(String goalId, {required int progress}) =>
      throw UnimplementedError();
  @override
  Future<Result<Goal>> setGoalStatus(String goalId, {required GoalStatus status}) =>
      throw UnimplementedError();
}

void main() {
  late _FakeGoalRepository repo;

  setUp(() => repo = _FakeGoalRepository());

  test('periodType\'ı Goals Domain\'ine iletir', () async {
    repo.goals = const [];
    await GetGoalsAchievementRateUseCase(WatchGoalsUseCase(repo)).call(GoalPeriodType.weekly);
    expect(repo.lastPeriodFilter, GoalPeriodType.weekly);
  });

  test('achieved/toplam oranını doğru hesaplar', () async {
    repo.goals = [
      _goal(goalId: 'g1', status: GoalStatus.achieved),
      _goal(goalId: 'g2', status: GoalStatus.achieved),
      _goal(goalId: 'g3', status: GoalStatus.missed),
      _goal(goalId: 'g4', status: GoalStatus.inProgress),
    ];

    final result = await GetGoalsAchievementRateUseCase(WatchGoalsUseCase(repo)).call(GoalPeriodType.weekly);

    expect(result.achievedCount, 2);
    expect(result.totalCount, 4);
    expect(result.achievementRatio, 0.5);
  });

  test('hedef yoksa 0/0 döner, bölme hatası fırlatmaz', () async {
    repo.goals = const [];

    final result = await GetGoalsAchievementRateUseCase(WatchGoalsUseCase(repo)).call(GoalPeriodType.daily);

    expect(result.totalCount, 0);
    expect(result.achievementRatio, 0);
  });
}
