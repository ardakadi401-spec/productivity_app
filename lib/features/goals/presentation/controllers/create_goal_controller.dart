import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/goal.dart';
import '../../domain/utils/goal_period_calculator.dart';
import '../providers/goal_providers.dart';
import '../states/goal_form_state.dart';

/// Yeni Hedef Bottom Sheet (SCREENS.md §4.14, PRD §5.6).
class CreateGoalController extends AutoDisposeNotifier<GoalFormState> {
  @override
  GoalFormState build() => const GoalFormState();

  void setPeriodType(GoalPeriodType type) => state = state.copyWith(periodType: type);

  void setProgressType(GoalProgressType type) => state = state.copyWith(progressType: type);

  void toggleLinkedTask(String taskId) {
    final current = [...state.linkedTaskIds];
    if (!current.remove(taskId)) current.add(taskId);
    state = state.copyWith(linkedTaskIds: current);
  }

  void setManualProgress(int progress) =>
      state = state.copyWith(manualProgress: progress.clamp(0, 100));

  /// Başlık boş-doğrulaması form widget'ında yapılır; buraya yalnızca
  /// geçerli veri ulaşır.
  Future<Result<Goal>> save({required String title, String? description}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final repository = ref.read(goalRepositoryProvider);
    final now = DateTime.now();
    final period = GoalPeriodCalculator.compute(state.periodType, now);
    final trimmedDescription = description?.trim();
    final goal = Goal(
      goalId: repository.newGoalId(),
      title: title.trim(),
      description:
          (trimmedDescription == null || trimmedDescription.isEmpty) ? null : trimmedDescription,
      periodType: state.periodType,
      periodStartDate: period.start,
      periodEndDate: period.end,
      linkedTaskIds:
          state.progressType == GoalProgressType.linkedTasks ? state.linkedTaskIds : const [],
      progressType: state.progressType,
      manualProgress: state.progressType == GoalProgressType.manual ? state.manualProgress : null,
      status: GoalStatus.inProgress,
      createdAt: now,
      updatedAt: now,
    );

    final result = await ref.read(createGoalUseCaseProvider).call(goal);
    switch (result) {
      case Ok():
        state = state.copyWith(isSaving: false);
      case Err(:final failure):
        state = state.copyWith(isSaving: false, error: failure);
    }
    return result;
  }
}

final createGoalControllerProvider =
    NotifierProvider.autoDispose<CreateGoalController, GoalFormState>(CreateGoalController.new);
