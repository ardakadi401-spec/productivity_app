import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/components/habit_card_widget.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../domain/entities/habit.dart';
import '../controllers/habit_list_controller.dart';
import '../providers/habit_providers.dart';
import '../utils/habit_frequency_label.dart';
import '../utils/habit_icon_options.dart';
import '../widgets/create_habit_sheet.dart';

/// Habits Screen'in liste içeriği (SCREENS.md §4.15) — `HabitsGoalsPage`'in
/// "Alışkanlıklar" sekmesine gömülür; kendi App Bar'ı yoktur (Tasks/
/// Projects/Goals listeleriyle aynı desen).
class HabitsListPage extends ConsumerWidget {
  const HabitsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitListControllerProvider);

    return habitsAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: LoadingSkeleton(height: 88, borderRadius: 16),
          ),
        ),
      ),
      error: (error, _) {
        final message = error is Failure ? error.message : 'Alışkanlıklar yüklenemedi.';
        return Center(
          child: ErrorState(
            message: message,
            onRetry: () => ref.invalidate(habitListControllerProvider),
          ),
        );
      },
      data: (habits) {
        if (habits.isEmpty) {
          return EmptyState(
            icon: Icons.repeat_rounded,
            message: 'Henüz alışkanlık eklemedin',
            actionLabel: 'Alışkanlık Ekle',
            onAction: () => showCreateHabitSheet(context),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: habits.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) => _HabitListItem(habit: habits[index]),
        );
      },
    );
  }
}

class _HabitListItem extends ConsumerWidget {
  const _HabitListItem({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompletedToday = ref.watch(habitTodayCheckInProvider(habit.habitId)).valueOrNull ?? false;
    final today = DateTime.now();
    final notifier = ref.read(habitListControllerProvider.notifier);

    return HabitCardWidget(
      title: habit.name,
      icon: habitIconFor(habit.icon),
      frequencySummary: habitFrequencySummary(habit),
      currentStreak: habit.currentStreak,
      isCompletedToday: isCompletedToday,
      isScheduledToday: habit.isScheduledOn(today),
      onTap: () => context.push(RoutePaths.habitDetail.replaceFirst(':habitId', habit.habitId)),
      onCompletionChanged: (value) async {
        final result = await notifier.toggleCheckIn(habit.habitId, today, isCompleted: value);
        if (!context.mounted) return;
        if (result case Err(:final failure)) {
          AppSnackbar.show(context, message: failure.message);
        }
      },
    );
  }
}
