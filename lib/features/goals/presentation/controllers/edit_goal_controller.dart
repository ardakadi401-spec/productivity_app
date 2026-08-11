import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/goal.dart';
import '../providers/goal_providers.dart';
import '../states/goal_form_state.dart';

/// Hedef düzenleme Bottom Sheet — Create ile aynı alan seti, ancak
/// [GoalPeriodType] ve dönem tarihleri oluşturulduktan sonra değiştirilemez
/// (zaten takip edilmekte olan bir dönemi yeniden hesaplamak anlam
/// karmaşasına yol açar) — yalnızca başlık/açıklama/ilerleme tipi/bağlı
/// görevler/manuel yüzde düzenlenebilir.
class EditGoalController extends AutoDisposeFamilyNotifier<GoalFormState, Goal> {
  @override
  GoalFormState build(Goal arg) => GoalFormState.fromGoal(arg);

  void setProgressType(GoalProgressType type) => state = state.copyWith(progressType: type);

  void toggleLinkedTask(String taskId) {
    final current = [...state.linkedTaskIds];
    if (!current.remove(taskId)) current.add(taskId);
    state = state.copyWith(linkedTaskIds: current);
  }

  void setManualProgress(int progress) =>
      state = state.copyWith(manualProgress: progress.clamp(0, 100));

  Future<Result<Goal>> save({required String title, String? description}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final trimmedDescription = description?.trim();
    final updated = arg.copyWith(
      title: title.trim(),
      description: trimmedDescription,
      clearDescription: trimmedDescription == null || trimmedDescription.isEmpty,
      progressType: state.progressType,
      linkedTaskIds:
          state.progressType == GoalProgressType.linkedTasks ? state.linkedTaskIds : const [],
      manualProgress: state.progressType == GoalProgressType.manual ? state.manualProgress : null,
      clearManualProgress: state.progressType != GoalProgressType.manual,
      updatedAt: DateTime.now(),
    );

    final result = await ref.read(updateGoalUseCaseProvider).call(updated);
    switch (result) {
      case Ok():
        state = state.copyWith(isSaving: false);
      case Err(:final failure):
        state = state.copyWith(isSaving: false, error: failure);
    }
    return result;
  }
}

final editGoalControllerProvider =
    NotifierProvider.autoDispose.family<EditGoalController, GoalFormState, Goal>(
  EditGoalController.new,
);
