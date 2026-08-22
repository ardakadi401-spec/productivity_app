import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/habit.dart';
import '../providers/habit_providers.dart';
import '../states/habit_form_state.dart';
import '../utils/sync_habit_reminder_safely.dart';

/// Yeni Alışkanlık Bottom Sheet (SCREENS.md §4.15, PRD §6.9).
class CreateHabitController extends AutoDisposeNotifier<HabitFormState> {
  @override
  HabitFormState build() => const HabitFormState();

  void setIcon(String icon) => state = state.copyWith(icon: icon);

  void setColor(String color) => state = state.copyWith(color: color);

  void setTargetFrequency(HabitTargetFrequency frequency) {
    state = state.copyWith(
      targetFrequency: frequency,
      targetDays: frequency == HabitTargetFrequency.daily ? const [] : state.targetDays,
    );
  }

  void toggleTargetDay(int weekday) {
    final current = [...state.targetDays];
    if (!current.remove(weekday)) current.add(weekday);
    current.sort();
    state = state.copyWith(targetDays: current);
  }

  /// İsim boş-doğrulaması form widget'ında yapılır; buraya yalnızca geçerli
  /// veri ulaşır.
  Future<Result<Habit>> save({required String name}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final repository = ref.read(habitRepositoryProvider);
    final now = DateTime.now();
    final habit = Habit(
      habitId: repository.newHabitId(),
      name: name.trim(),
      icon: state.icon,
      color: state.color,
      targetFrequency: state.targetFrequency,
      targetDays: state.targetFrequency == HabitTargetFrequency.specificDays ? state.targetDays : const [],
      currentStreak: 0,
      longestStreak: 0,
      status: HabitStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    final result = await ref.read(createHabitUseCaseProvider).call(habit);
    switch (result) {
      case Ok(:final value):
        syncHabitReminderSafely(ref, value);
        state = state.copyWith(isSaving: false);
      case Err(:final failure):
        state = state.copyWith(isSaving: false, error: failure);
    }
    return result;
  }
}

final createHabitControllerProvider =
    NotifierProvider.autoDispose<CreateHabitController, HabitFormState>(CreateHabitController.new);
