import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_mode.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/components/app_top_bar.dart';
import '../../../../shared/components/goal_card_widget.dart';
import '../../../../shared/components/task_card_widget.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../goals/presentation/providers/goal_providers.dart';
import '../../../goals/presentation/utils/goal_card_mapping.dart';
import '../../../goals/presentation/widgets/edit_goal_sheet.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/utils/task_priority_mapping.dart';

/// Dashboard Screen iskeleti — SCREENS.md Bölüm 5, ROADMAP.md FAZ 4.
///
/// Bu fazda yalnızca layout ve hızlı erişim kartlarının navigasyon
/// bağlantıları kurulur; gerçek veri (bugünün görevleri, alışkanlık özeti)
/// ilgili feature fazları (FAZ 5, FAZ 9) tamamlandıkça bağlanır — bu yüzden
/// her bölüm şimdilik Empty State ile gösterilir. Dashboard'un kendi
/// Repository'si yoktur (ARCHITECTURE.md Bölüm 4) — yalnızca diğer
/// feature'ların UseCase'lerini orkestre eder.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppColorsExtension>()!;
    final isAmoled = ref.watch(themeModeProvider) == AppThemeMode.amoled;
    final now = DateTime.now();

    return Scaffold(
      body: Column(
        children: [
          AppTopBar(
            title: 'Dashboard',
            isAmoled: isAmoled,
            actions: [
              AppIconButton(
                icon: Icons.search,
                semanticLabel: 'Ara',
                onPressed: () => context.push(RoutePaths.search),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  _greeting(now),
                  style: AppTypography.display.copyWith(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionHeader(
                  title: 'Bugünkü Görevler',
                  actionLabel: 'Tümünü Gör',
                  onAction: () => context.go(RoutePaths.tasks),
                ),
                const _TodayTasksSection(),
                const SizedBox(height: AppSpacing.lg),
                _SectionHeader(
                  title: 'Alışkanlıklar',
                  actionLabel: 'Tümünü Gör',
                  onAction: () => context.go(RoutePaths.habits),
                ),
                EmptyState(
                  icon: Icons.repeat_rounded,
                  message: 'Henüz alışkanlık eklemedin',
                  actionLabel: 'Alışkanlık Ekle',
                  onAction: () => context.go(RoutePaths.habits),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SectionHeader(
                  title: 'Haftalık İlerleme',
                  actionLabel: 'Tümünü Gör',
                  onAction: () => context.push(RoutePaths.statistics),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tokens.border),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: 0,
                          strokeWidth: 3,
                          backgroundColor: tokens.border,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Bu hafta henüz istatistik yok',
                          style: AppTypography.bodyMd.copyWith(color: tokens.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _FeaturedGoalSection(),
                const SizedBox(height: AppSpacing.lg),
                _SectionHeader(title: 'Hızlı Erişim'),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Yeni Görev',
                        variant: AppButtonVariant.outline,
                        onPressed: () => context.push(RoutePaths.createTask),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: 'Yeni Not',
                        variant: AppButtonVariant.outline,
                        onPressed: () => context.push(RoutePaths.notes),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: 'Pomodoro',
                        variant: AppButtonVariant.outline,
                        onPressed: () => context.push(RoutePaths.pomodoro),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(DateTime now) {
    final hour = now.hour;
    final part = hour < 12 ? 'Günaydın' : (hour < 18 ? 'İyi günler' : 'İyi akşamlar');
    return part;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.h2.copyWith(color: theme.colorScheme.onSurface),
            ),
          ),
          if (actionLabel != null)
            AppButton(label: actionLabel!, variant: AppButtonVariant.text, onPressed: onAction),
        ],
      ),
    );
  }
}

/// Dashboard'un "Bugünkü Görevler" bölümü — ARCHITECTURE.md §4.1 örneği
/// (Dashboard → `GetTodayTasksUseCase`). Dashboard'un kendi Repository'si
/// yoktur; yalnızca Tasks feature'ının dışa açık `todayTasksProvider`'ını
/// okur (STATE_MANAGEMENT.md §2 katman kuralı).
class _TodayTasksSection extends ConsumerWidget {
  const _TodayTasksSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(todayTasksProvider);

    return tasksAsync.when(
      loading: () => const Column(
        children: [
          LoadingSkeleton(height: 76, borderRadius: 16),
          SizedBox(height: AppSpacing.sm),
          LoadingSkeleton(height: 76, borderRadius: 16),
        ],
      ),
      error: (error, _) {
        final message = error is Failure ? error.message : 'Görevler yüklenemedi.';
        return ErrorState(
          message: message,
          onRetry: () => ref.invalidate(todayTasksProvider),
        );
      },
      data: (tasks) {
        if (tasks.isEmpty) {
          return EmptyState(
            icon: Icons.check_circle_outline,
            message: 'Bugün için planlanan bir şey yok',
            actionLabel: 'Görev Ekle',
            onAction: () => context.push(RoutePaths.createTask),
          );
        }
        return Column(
          children: [
            for (final task in tasks) ...[
              TaskCardWidget(
                title: task.title,
                isCompleted: task.isCompleted,
                priority: toPriorityLevel(task.priority),
                dueDate: task.dueDate,
                dueTime: task.dueTime,
                subtaskCount: task.subtaskCount,
                completedSubtaskCount: task.completedSubtaskCount,
                onTap: () =>
                    context.push(RoutePaths.taskDetail.replaceFirst(':taskId', task.taskId)),
                onCompletedChanged: (value) => ref
                    .read(completeTaskUseCaseProvider)
                    .call(task.taskId, isCompleted: value),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

/// Dashboard'un "Haftalık İlerleme / Hedef Durumu" bölümünün hedef parçası
/// (SCREENS.md §5, sıra 4: "aktif hedeflerden en fazla 1 öne çıkan Goal
/// Card") — ROADMAP.md FAZ 8 "Dashboard entegrasyonu". Dashboard'un kendi
/// Repository'si yoktur; yalnızca Goals'ın dışa açık `featuredGoalProvider`'ını
/// okur.
class _FeaturedGoalSection extends ConsumerWidget {
  const _FeaturedGoalSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    final goalAsync = ref.watch(featuredGoalProvider);

    return goalAsync.when(
      loading: () => const LoadingSkeleton(height: 96, borderRadius: 16),
      error: (_, _) => const SizedBox.shrink(),
      data: (goal) {
        if (goal == null) {
          return Row(
            children: [
              Expanded(
                child: Text(
                  'Aktif hedef yok',
                  style: AppTypography.bodyMd.copyWith(color: tokens.textSecondary),
                ),
              ),
              AppButton(
                label: 'Hedef Ekle',
                variant: AppButtonVariant.text,
                onPressed: () => context.go(RoutePaths.goals),
              ),
            ],
          );
        }
        final progress = ref.watch(goalProgressProvider(goal.goalId)).valueOrNull ??
            goal.manualProgressRatio;
        return GoalCardWidget(
          title: goal.title,
          periodLabel: goalPeriodLabels[goal.periodType]!,
          state: toGoalCardState(goal.status),
          progressRatio: progress,
          onTap: () => AppBottomSheet.show<void>(context, child: EditGoalSheet(goal: goal)),
        );
      },
    );
  }
}
