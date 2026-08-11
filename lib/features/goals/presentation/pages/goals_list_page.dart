import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/components/goal_card_widget.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../domain/entities/goal.dart';
import '../controllers/goal_list_controller.dart';
import '../providers/goal_providers.dart';
import '../utils/goal_card_mapping.dart';
import '../widgets/create_goal_sheet.dart';
import '../widgets/edit_goal_sheet.dart';

const _periodTabLabels = {
  GoalPeriodType.daily: 'Günlük',
  GoalPeriodType.weekly: 'Haftalık',
  GoalPeriodType.monthly: 'Aylık',
};

/// Goals Screen'in liste içeriği (SCREENS.md §4.14) — `HabitsGoalsPage`'in
/// "Hedefler" sekmesine gömülür; kendi App Bar'ı yoktur (Tasks/Projects
/// listeleriyle aynı desen).
class GoalsListPage extends ConsumerStatefulWidget {
  const GoalsListPage({super.key});

  @override
  ConsumerState<GoalsListPage> createState() => _GoalsListPageState();
}

class _GoalsListPageState extends ConsumerState<GoalsListPage> {
  GoalPeriodType _periodType = GoalPeriodType.daily;

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalListControllerProvider(_periodType));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              for (final type in GoalPeriodType.values) ...[
                AppChip(
                  label: _periodTabLabels[type]!,
                  selected: _periodType == type,
                  onTap: () => setState(() => _periodType = type),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ),
        Expanded(
          child: goalsAsync.when(
            loading: () => ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: LoadingSkeleton(height: 96, borderRadius: 16),
                ),
              ),
            ),
            error: (error, _) {
              final message = error is Failure ? error.message : 'Hedefler yüklenemedi.';
              return Center(
                child: ErrorState(
                  message: message,
                  onRetry: () => ref.invalidate(goalListControllerProvider(_periodType)),
                ),
              );
            },
            data: (goals) {
              if (goals.isEmpty) {
                return EmptyState(
                  icon: Icons.flag_outlined,
                  message: 'Henüz ${_periodTabLabels[_periodType]!.toLowerCase()} hedefi eklemedin',
                  actionLabel: 'Hedef Ekle',
                  onAction: () => showCreateGoalSheet(context),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: goals.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) => _GoalListItem(goal: goals[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GoalListItem extends ConsumerWidget {
  const _GoalListItem({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(goalProgressProvider(goal.goalId)).valueOrNull ??
        goal.manualProgressRatio;

    return GoalCardWidget(
      title: goal.title,
      periodLabel: goalPeriodLabels[goal.periodType]!,
      state: toGoalCardState(goal.status),
      progressRatio: progress,
      onTap: () => AppBottomSheet.show<void>(context, child: EditGoalSheet(goal: goal)),
    );
  }
}
