import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../domain/entities/statistics_period.dart';
import '../providers/statistics_providers.dart';
import '../utils/statistics_period_mapping.dart';
import '../widgets/chart_container_widget.dart';
import '../widgets/statistic_summary_card_widget.dart';

/// Statistics Screen — SCREENS.md §4.20.
class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  StatisticsPeriod _period = StatisticsPeriod.daily;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(periodStatsProvider(_period));
    final goalsAsync = ref.watch(goalsAchievementProvider(_period));

    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Row(
              children: [
                for (final period in StatisticsPeriod.values) ...[
                  AppChip(
                    label: statisticsPeriodLabel(period),
                    selected: _period == period,
                    onTap: () => setState(() => _period = period),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            statsAsync.when(
              loading: () => const _LoadingBody(),
              error: (error, _) {
                final message = error is Failure ? error.message : 'İstatistikler yüklenemedi.';
                return ErrorState(
                  message: message,
                  onRetry: () => ref.invalidate(periodStatsProvider(_period)),
                );
              },
              data: (stats) {
                final goals = goalsAsync.valueOrNull;
                final noData = stats.isEmpty && (goals == null || goals.totalCount == 0);
                if (noData) {
                  return const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.xxl),
                    child: EmptyState(
                      icon: Icons.insert_chart_outlined,
                      message: 'Bu dönem için henüz veri yok',
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1.3,
                      children: [
                        StatisticSummaryCardWidget(
                          label: 'Tamamlanan Görev',
                          value: '${stats.tasksCompleted}',
                        ),
                        StatisticSummaryCardWidget(
                          label: 'Alışkanlık Tamamlama',
                          value: '%${(stats.habitsCompletionRatio * 100).round()}',
                          progress: stats.habitsCompletionRatio,
                        ),
                        StatisticSummaryCardWidget(
                          label: 'Pomodoro Oturumu',
                          value: '${stats.pomodoroSessionsCompleted}',
                        ),
                        StatisticSummaryCardWidget(
                          label: 'Pomodoro Süresi',
                          value: '${stats.pomodoroTotalMinutes} dk',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    goalsAsync.when(
                      loading: () => const LoadingSkeleton(height: 96, borderRadius: 16),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (goals) => StatisticSummaryCardWidget(
                        label: 'Hedef Başarı Oranı',
                        value: '${goals.achievedCount}/${goals.totalCount}',
                        progress: goals.totalCount == 0 ? null : goals.achievementRatio,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ChartContainerWidget(
                      title: 'Tamamlanan Görevler',
                      dailyBreakdown: stats.dailyBreakdown,
                      valueSelector: (p) => p.tasksCompleted,
                      dayLabelBuilder: _dayLabel,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ChartContainerWidget(
                      title: 'Alışkanlık Tamamlama',
                      dailyBreakdown: stats.dailyBreakdown,
                      valueSelector: (p) => p.habitsCompletedCount,
                      dayLabelBuilder: _dayLabel,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ChartContainerWidget(
                      title: 'Pomodoro Oturumları',
                      dailyBreakdown: stats.dailyBreakdown,
                      valueSelector: (p) => p.pomodoroSessionsCompleted,
                      dayLabelBuilder: _dayLabel,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static const _weekdayShort = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  String _dayLabel(DateTime date) {
    if (_period == StatisticsPeriod.monthly) return '${date.day}';
    return _weekdayShort[date.weekday - 1];
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        LoadingSkeleton(height: 180, borderRadius: 16),
        SizedBox(height: AppSpacing.md),
        LoadingSkeleton(height: 140, borderRadius: 16),
      ],
    );
  }
}
