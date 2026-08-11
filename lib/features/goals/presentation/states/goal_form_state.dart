import '../../../../core/errors/failure.dart';
import '../../domain/entities/goal.dart';

/// Yeni Hedef / düzenleme Bottom Sheet'inin ortak durumu (SCREENS.md §4.14,
/// PRD §5.6) — Tasks/Projects'in form state'leriyle aynı desen.
class GoalFormState {
  const GoalFormState({
    this.periodType = GoalPeriodType.daily,
    this.progressType = GoalProgressType.manual,
    this.linkedTaskIds = const [],
    this.manualProgress = 0,
    this.isSaving = false,
    this.error,
  });

  final GoalPeriodType periodType;
  final GoalProgressType progressType;

  /// Yalnızca `progressType: linkedTasks` iken anlamlıdır.
  final List<String> linkedTaskIds;

  /// Yalnızca `progressType: manual` iken anlamlıdır (0–100).
  final int manualProgress;
  final bool isSaving;
  final Failure? error;

  factory GoalFormState.fromGoal(Goal goal) {
    return GoalFormState(
      periodType: goal.periodType,
      progressType: goal.progressType,
      linkedTaskIds: goal.linkedTaskIds,
      manualProgress: goal.manualProgress ?? 0,
    );
  }

  GoalFormState copyWith({
    GoalPeriodType? periodType,
    GoalProgressType? progressType,
    List<String>? linkedTaskIds,
    int? manualProgress,
    bool? isSaving,
    Failure? error,
    bool clearError = false,
  }) {
    return GoalFormState(
      periodType: periodType ?? this.periodType,
      progressType: progressType ?? this.progressType,
      linkedTaskIds: linkedTaskIds ?? this.linkedTaskIds,
      manualProgress: manualProgress ?? this.manualProgress,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
