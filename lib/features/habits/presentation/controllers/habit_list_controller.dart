import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/habit.dart';
import '../providers/habit_providers.dart';

/// Habits Screen (SCREENS.md §4.15) — Isar'ın reaktif stream'ine doğrudan
/// abone olan controller; günlük check-in eylemini de aynı yerden orkestre
/// eder (Isar yazması, `watchHabits` stream'ini otomatik olarak yeniden
/// tetikler — bu nedenle eylem metotları state'i elle güncellemez).
class HabitListController extends AutoDisposeStreamNotifier<List<Habit>> {
  @override
  Stream<List<Habit>> build() {
    return ref.watch(watchHabitsUseCaseProvider).call();
  }

  Future<Result<void>> toggleCheckIn(String habitId, DateTime date, {required bool isCompleted}) async {
    final result =
        await ref.read(checkInHabitUseCaseProvider).call(habitId, date, isCompleted: isCompleted);
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }
}

final habitListControllerProvider =
    AutoDisposeStreamNotifierProvider<HabitListController, List<Habit>>(HabitListController.new);
