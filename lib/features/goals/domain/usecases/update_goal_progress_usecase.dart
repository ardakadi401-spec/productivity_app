import '../../../../core/errors/result.dart';
import '../entities/goal.dart';
import '../repositories/goal_repository.dart';

/// Goals Screen'de (SCREENS.md §4.14) `progressType: manual` hedefler için
/// "kart üstünden hızlı yüzde güncelleme".
class UpdateGoalProgressUseCase {
  const UpdateGoalProgressUseCase(this._repository);

  final GoalRepository _repository;

  Future<Result<Goal>> call(String goalId, {required int progress}) =>
      _repository.setManualProgress(goalId, progress: progress.clamp(0, 100));
}
