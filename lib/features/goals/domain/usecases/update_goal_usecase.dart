import '../../../../core/errors/result.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

class UpdateGoalUseCase {
  const UpdateGoalUseCase(this._repository);

  final GoalRepository _repository;

  Future<Result<Goal>> call(Goal goal) => _repository.updateGoal(goal);
}
