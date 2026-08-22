import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/statistics/domain/entities/goals_achievement_stats.dart';
import 'package:productivity_app/features/statistics/domain/entities/period_stats.dart';
import 'package:productivity_app/features/statistics/presentation/pages/statistics_page.dart';
import 'package:productivity_app/features/statistics/presentation/providers/statistics_providers.dart';

Widget _wrap({required PeriodStats stats, required GoalsAchievementStats goals}) {
  return ProviderScope(
    overrides: [
      periodStatsProvider.overrideWith((ref, period) async => stats),
      goalsAchievementProvider.overrideWith((ref, period) async => goals),
    ],
    child: MaterialApp(theme: AppTheme.light, home: const StatisticsPage()),
  );
}

void main() {
  testWidgets('hiçbir veri olmayan (yeni kullanıcı) dönemde çökmeden Empty State gösterir', (tester) async {
    await tester.pumpWidget(
      _wrap(
        stats: PeriodStats.empty,
        goals: const GoalsAchievementStats(achievedCount: 0, totalCount: 0),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Bu dönem için henüz veri yok'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('veri varken özet kartları doğru değerlerle render edilir', (tester) async {
    await tester.pumpWidget(
      _wrap(
        stats: PeriodStats(
          tasksCompleted: 7,
          tasksCreated: 3,
          habitsCompletedCount: 2,
          habitsTotalCount: 4,
          pomodoroSessionsCompleted: 5,
          pomodoroTotalMinutes: 125,
          dailyBreakdown: [
            DailyStatPoint(
              date: DateTime(2026, 1, 1),
              tasksCompleted: 7,
              habitsCompletedCount: 2,
              pomodoroSessionsCompleted: 5,
            ),
          ],
        ),
        goals: const GoalsAchievementStats(achievedCount: 1, totalCount: 2),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('7'), findsOneWidget);
    expect(find.text('%50'), findsWidgets);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('125 dk'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
  });

  testWidgets('dönem chip\'i değiştirildiğinde çökmeden yeniden render eder', (tester) async {
    await tester.pumpWidget(
      _wrap(
        stats: PeriodStats.empty,
        goals: const GoalsAchievementStats(achievedCount: 0, totalCount: 0),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('Haftalık'));
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Bu dönem için henüz veri yok'), findsOneWidget);
  });
}
