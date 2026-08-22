import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/components/completion_button_widget.dart';
import '../../../../shared/components/streak_indicator_widget.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/dialogs/app_dialog.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_record.dart';
import '../controllers/habit_detail_controller.dart';
import '../providers/habit_providers.dart';
import '../utils/habit_frequency_label.dart';
import '../utils/habit_icon_options.dart';
import '../widgets/edit_habit_sheet.dart';

/// Habit Detail Screen — SCREENS.md §4.16.
class HabitDetailPage extends ConsumerWidget {
  const HabitDetailPage({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitDetailControllerProvider(habitId));
    final recordsAsync = ref.watch(habitRecordsProvider(habitId));
    final controller = ref.read(habitDetailControllerProvider(habitId).notifier);

    ref.listen(habitDetailControllerProvider(habitId), (previous, next) {
      if (next is AsyncError) {
        final failure = next.error;
        final message = failure is Failure ? failure.message : 'Bir şeyler ters gitti.';
        AppSnackbar.show(context, message: message);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(habitAsync.valueOrNull?.name ?? 'Alışkanlık Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Düzenle',
            onPressed: habitAsync.valueOrNull == null
                ? null
                : () => AppBottomSheet.show<void>(
                      context,
                      child: EditHabitSheet(habit: habitAsync.value!),
                    ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Sil',
            onPressed: habitAsync.valueOrNull == null
                ? null
                : () async {
                    final habit = habitAsync.value!;
                    final confirmed = await AppDialog.show(
                      context,
                      title: 'Alışkanlığı Sil',
                      description: '"${habit.name}" alışkanlığını silmek istediğine emin misin?',
                      confirmLabel: 'Sil',
                      isDestructive: true,
                    );
                    if (confirmed != true || !context.mounted) return;
                    final result = await controller.deleteHabit();
                    if (!context.mounted) return;
                    if (result case Err(:final failure)) {
                      AppSnackbar.show(context, message: failure.message);
                    } else {
                      context.pop();
                    }
                  },
          ),
        ],
      ),
      body: habitAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              LoadingSkeleton(height: 28, borderRadius: 8),
              SizedBox(height: AppSpacing.md),
              LoadingSkeleton(height: 80, borderRadius: 16),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: ErrorState(
            message: 'Alışkanlık yüklenemedi.',
            onRetry: () => ref.invalidate(habitDetailControllerProvider(habitId)),
          ),
        ),
        data: (habit) {
          if (habit == null) {
            return const Center(child: ErrorState(message: 'Bu alışkanlık artık mevcut değil.'));
          }
          return _HabitDetailBody(habit: habit, recordsAsync: recordsAsync, controller: controller);
        },
      ),
    );
  }
}

class _HabitDetailBody extends StatelessWidget {
  const _HabitDetailBody({required this.habit, required this.recordsAsync, required this.controller});

  final Habit habit;
  final AsyncValue<List<HabitRecord>> recordsAsync;
  final HabitDetailController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final today = DateTime.now();
    final isScheduledToday = habit.isScheduledOn(today);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            Icon(habitIconFor(habit.icon), size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                habit.name,
                style: AppTypography.h1.copyWith(color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          habitFrequencySummary(habit),
          style: AppTypography.bodyMd.copyWith(color: tokens.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _StreakStat(label: 'Güncel Seri', value: habit.currentStreak, tokens: tokens),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StreakStat(label: 'En Uzun Seri', value: habit.longestStreak, tokens: tokens),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text('Bugün', style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface)),
            const Spacer(),
            CompletionButton(
              isCompleted: recordsAsync.valueOrNull?.any(
                    (r) => r.isCompleted && _isSameDay(r.date, today),
                  ) ??
                  false,
              enabled: isScheduledToday,
              onChanged: (value) async {
                final result = await controller.toggleCheckIn(today, isCompleted: value);
                if (!context.mounted) return;
                if (result case Err(:final failure)) {
                  AppSnackbar.show(context, message: failure.message);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Geçmiş', style: AppTypography.h3.copyWith(color: theme.colorScheme.onSurface)),
        const SizedBox(height: AppSpacing.sm),
        recordsAsync.when(
          loading: () => const LoadingSkeleton(height: 60, borderRadius: 12),
          error: (error, _) => const SizedBox.shrink(),
          data: (records) {
            if (records.isEmpty) {
              return const EmptyState(
                icon: Icons.history,
                message: 'Henüz kayıt yok, bugün başla',
              );
            }
            final sorted = [...records]..sort((a, b) => b.date.compareTo(a.date));
            return Column(
              children: [
                for (final record in sorted.take(30))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      record.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                      color: record.isCompleted ? theme.colorScheme.secondary : tokens.textDisabled,
                    ),
                    title: Text(
                      '${record.date.day}.${record.date.month}.${record.date.year}',
                      style: AppTypography.bodyMd.copyWith(color: theme.colorScheme.onSurface),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _StreakStat extends StatelessWidget {
  const _StreakStat({required this.label, required this.value, required this.tokens});

  final String label;
  final int value;
  final AppColorsExtension tokens;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
          const SizedBox(height: 4),
          StreakIndicator(streak: value),
        ],
      ),
    );
  }
}
