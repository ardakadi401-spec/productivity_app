import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

/// Goals Screen listesi (SCREENS.md §4.14) tarafından tüketilir.
class WatchGoalsUseCase {
  const WatchGoalsUseCase(this._repository);

  final GoalRepository _repository;

  Stream<List<Goal>> call({GoalPeriodType? periodType}) =>
      _repository.watchGoals(periodType: periodType);
}
