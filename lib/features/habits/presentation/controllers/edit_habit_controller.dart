import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/habit.dart';
import '../providers/habit_providers.dart';
import '../states/habit_form_state.dart';
import '../utils/sync_habit_reminder_safely.dart';

/// Alışkanlık düzenleme Bottom Sheet — Create ile aynı alan seti, mevcut
/// değerlerle önceden doldurulmuş (Habit Detail Screen'in "düzenleme"
/// eylemi, SCREENS.md §4.16 — "bu ekran içinde Bottom Sheet ile çözülür").
class EditHabitController extends AutoDisposeFamilyNotifier<HabitFormState, Habit> {
  @override
  HabitFormState build(Habit arg) => HabitFormState.fromHabit(arg);

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

  Future<Result<Habit>> save({required String name}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final updated = arg.copyWith(
      name: name.trim(),
      icon: state.icon,
      clearIcon: state.icon == null,
      color: state.color,
      targetFrequency: state.targetFrequency,
      targetDays: state.targetFrequency == HabitTargetFrequency.specificDays ? state.targetDays : const [],
      updatedAt: DateTime.now(),
    );

    final result = await ref.read(updateHabitUseCaseProvider).call(updated);
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

final editHabitControllerProvider =
    NotifierProvider.autoDispose.family<EditHabitController, HabitFormState, Habit>(
  EditHabitController.new,
);
