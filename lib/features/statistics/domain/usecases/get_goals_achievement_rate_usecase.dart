import '../../../goals/domain/entities/goal.dart';
import '../../../goals/domain/usecases/watch_goals_usecase.dart';
import '../entities/goals_achievement_stats.dart';

/// Kullanıcı kararı: Goals başarı oranı `StatisticsSnapshot` şemasına
/// eklenmez (DATABASE.md §10.2'de zaten yok) — Goals dönem başına küçük
/// hacimli olduğundan her çağrıda Goals Domain'inden canlı hesaplanır,
/// önbelleklenmez.
class GetGoalsAchievementRateUseCase {
  const GetGoalsAchievementRateUseCase(this._watchGoalsUseCase);

  final WatchGoalsUseCase _watchGoalsUseCase;

  Future<GoalsAchievementStats> call(GoalPeriodType periodType) async {
    final goals = await _watchGoalsUseCase.call(periodType: periodType).first;
    final achieved = goals.where((g) => g.status == GoalStatus.achieved).length;
    return GoalsAchievementStats(achievedCount: achieved, totalCount: goals.length);
  }
}
