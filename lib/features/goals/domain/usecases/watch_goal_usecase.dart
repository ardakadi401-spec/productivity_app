import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class WatchGoalUseCase {
  const WatchGoalUseCase(this._repository);

  final GoalRepository _repository;

  Stream<Goal?> call(String goalId) => _repository.watchGoal(goalId);
}
