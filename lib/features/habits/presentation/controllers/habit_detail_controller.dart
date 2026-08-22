import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/habit.dart';
import '../providers/habit_providers.dart';
import '../utils/sync_habit_reminder_safely.dart';

/// Habit Detail Screen (SCREENS.md §4.16) — alışkanlığı Isar'ın reaktif
/// stream'inden okur; check-in ve silme eylemlerini tetikler.
class HabitDetailController extends AutoDisposeFamilyStreamNotifier<Habit?, String> {
  @override
  Stream<Habit?> build(String arg) {
    return ref.watch(watchHabitUseCaseProvider).call(arg);
  }

  Future<Result<void>> toggleCheckIn(DateTime date, {required bool isCompleted}) async {
    final result = await ref.read(checkInHabitUseCaseProvider).call(arg, date, isCompleted: isCompleted);
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }

  Future<Result<void>> deleteHabit() async {
    final result = await ref.read(deleteHabitUseCaseProvider).call(arg);
    if (result case Ok()) cancelHabitReminderSafely(ref, arg);
    return result;
  }
}

final habitDetailControllerProvider =
    StreamNotifierProvider.autoDispose.family<HabitDetailController, Habit?, String>(
  HabitDetailController.new,
);
