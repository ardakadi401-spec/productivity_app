import '../../../../core/errors/failure.dart';
import '../../domain/entities/habit.dart';

/// Yeni Alışkanlık / düzenleme Bottom Sheet'inin ortak durumu (SCREENS.md
/// §4.15, PRD §6.9) — Tasks/Projects/Goals'ın form state'leriyle aynı
/// desen.
class HabitFormState {
  const HabitFormState({
    this.icon,
    this.color = '#FF8A8A',
    this.targetFrequency = HabitTargetFrequency.daily,
    this.targetDays = const [],
    this.isSaving = false,
    this.error,
  });

  final String? icon;

  /// Hex kod — UI_GUIDELINES.md §3.3 pastel setinden seçilir.
  final String color;
  final HabitTargetFrequency targetFrequency;

  /// Yalnızca `targetFrequency: specificDays` iken anlamlıdır (1–7,
  /// `DateTime.weekday`).
  final List<int> targetDays;
  final bool isSaving;
  final Failure? error;

  factory HabitFormState.fromHabit(Habit habit) {
    return HabitFormState(
      icon: habit.icon,
      color: habit.color,
      targetFrequency: habit.targetFrequency,
      targetDays: habit.targetDays,
    );
  }

  HabitFormState copyWith({
    String? icon,
    bool clearIcon = false,
    String? color,
    HabitTargetFrequency? targetFrequency,
    List<int>? targetDays,
    bool? isSaving,
    Failure? error,
    bool clearError = false,
  }) {
    return HabitFormState(
      icon: clearIcon ? null : (icon ?? this.icon),
      color: color ?? this.color,
      targetFrequency: targetFrequency ?? this.targetFrequency,
      targetDays: targetDays ?? this.targetDays,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
