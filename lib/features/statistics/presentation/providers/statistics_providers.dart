import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connectivity_service.dart';
import '../../../../core/storage/isar_provider.dart';
import '../../../goals/presentation/providers/goal_providers.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../pomodoro/presentation/providers/pomodoro_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../data/datasources/local/statistics_snapshot_local_datasource.dart';
import '../../data/datasources/remote/statistics_snapshot_remote_datasource.dart';
import '../../data/repositories/statistics_snapshot_repository_impl.dart';
import '../../domain/entities/goals_achievement_stats.dart';
import '../../domain/entities/period_stats.dart';
import '../../domain/entities/statistics_period.dart';
import '../../domain/repositories/statistics_snapshot_repository.dart';
import '../../domain/usecases/get_goals_achievement_rate_usecase.dart';
import '../../domain/usecases/get_period_stats_usecase.dart';
import '../utils/statistics_period_mapping.dart';

// --- Service / Data katmanı — ARCHITECTURE.md §5.2 ---

final statisticsSnapshotLocalDatasourceProvider = Provider<StatisticsSnapshotLocalDatasource>((ref) {
  return StatisticsSnapshotLocalDatasource(ref.watch(isarProvider));
});

final statisticsSnapshotRemoteDatasourceProvider = Provider<StatisticsSnapshotRemoteDatasource>((ref) {
  return StatisticsSnapshotRemoteDatasource();
});

final statisticsSnapshotRepositoryProvider = Provider<StatisticsSnapshotRepository>((ref) {
  return StatisticsSnapshotRepositoryImpl(
    ref.watch(statisticsSnapshotLocalDatasourceProvider),
    ref.watch(statisticsSnapshotRemoteDatasourceProvider),
    ref.watch(connectivityServiceProvider),
  );
});

// --- Domain katmanı (UseCase provider'ları) ---
//
// ARCHITECTURE.md §4 — Statistics; Tasks, Habits, Pomodoro, Goals Domain'ine
// tek yönlü, salt okunur bağımlıdır. Statistics'in kendi Data/Presentation
// katmanına erişimi yoktur, yalnızca bu feature'ların dışa açık UseCase
// provider'larını okur.

final getPeriodStatsUseCaseProvider = Provider<GetPeriodStatsUseCase>((ref) {
  return GetPeriodStatsUseCase(
    ref.watch(statisticsSnapshotRepositoryProvider),
    ref.watch(watchTasksUseCaseProvider),
    ref.watch(watchHabitsUseCaseProvider),
    ref.watch(getHabitRecordsInRangeUseCaseProvider),
    ref.watch(getPomodoroSessionsInRangeUseCaseProvider),
  );
});

final getGoalsAchievementRateUseCaseProvider = Provider<GetGoalsAchievementRateUseCase>((ref) {
  return GetGoalsAchievementRateUseCase(ref.watch(watchGoalsUseCaseProvider));
});

// --- Presentation katmanı — tek seferlik okuma provider'ları ---
//
// STATE_MANAGEMENT.md §2 satır 10 — "FutureProvider (family — dönem
// parametreli)": Statistics canlı/sürekli akan bir kaynak değildir, dönem
// seçimi değiştiğinde veya ekrana her girişte bir kerelik hesaplanır.

final periodStatsProvider = FutureProvider.autoDispose.family<PeriodStats, StatisticsPeriod>((
  ref,
  period,
) {
  return ref.watch(getPeriodStatsUseCaseProvider).call(period, DateTime.now());
});

final goalsAchievementProvider =
    FutureProvider.autoDispose.family<GoalsAchievementStats, StatisticsPeriod>((ref, period) {
  return ref.watch(getGoalsAchievementRateUseCaseProvider).call(toGoalPeriodType(period));
});
