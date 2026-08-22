import '../../../goals/domain/entities/goal.dart';
import '../../domain/entities/statistics_period.dart';

/// Statistics'in kendi `StatisticsPeriod`'unu, Goals'ın `GoalPeriodType`'ına
/// eşler — Statistics Screen'in tek bir dönem seçici chip grubu (SCREENS.md
/// §4.20) hem `GetPeriodStatsUseCase`'i hem `GetGoalsAchievementRateUseCase`'i
/// besler. Bu eşleme burada (Statistics'in Presentation katmanında) yaşar,
/// Domain katmanına sızmaz (`GetGoalsAchievementRateUseCase` doğrudan
/// `GoalPeriodType` alır, Statistics'e özgü kavramı bilmez).
GoalPeriodType toGoalPeriodType(StatisticsPeriod period) => switch (period) {
      StatisticsPeriod.daily => GoalPeriodType.daily,
      StatisticsPeriod.weekly => GoalPeriodType.weekly,
      StatisticsPeriod.monthly => GoalPeriodType.monthly,
    };

String statisticsPeriodLabel(StatisticsPeriod period) => switch (period) {
      StatisticsPeriod.daily => 'Günlük',
      StatisticsPeriod.weekly => 'Haftalık',
      StatisticsPeriod.monthly => 'Aylık',
    };
