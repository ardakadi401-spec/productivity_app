import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/goals/domain/entities/goal.dart';
import 'package:productivity_app/features/goals/domain/repositories/goal_repository.dart';
import 'package:productivity_app/features/goals/presentation/pages/goals_list_page.dart';
import 'package:productivity_app/features/goals/presentation/providers/goal_providers.dart';

class _FakeGoalRepository implements GoalRepository {
  List<Goal> goals = const [];

  @override
  String newGoalId() => 'id';
  @override
  Stream<List<Goal>> watchGoals({GoalPeriodType? periodType}) {
    final filtered =
        periodType == null ? goals : goals.where((g) => g.periodType == periodType).toList();
    return Stream.value(filtered);
  }

  @override
  Stream<Goal?> watchGoal(String goalId) => const Stream.empty();
  @override
  Future<Result<Goal>> createGoal(Goal goal) => throw UnimplementedError();
  @override
  Future<Result<Goal>> updateGoal(Goal goal) => throw UnimplementedError();
  @override
  Future<Result<Goal>> setManualProgress(String goalId, {required int progress}) =>
      throw UnimplementedError();
  @override
  Future<Result<Goal>> setGoalStatus(String goalId, {required GoalStatus status}) =>
      throw UnimplementedError();
}

Goal _goal(String id, String title, {GoalPeriodType periodType = GoalPeriodType.daily}) => Goal(
      goalId: id,
      title: title,
      periodType: periodType,
      periodStartDate: DateTime(2026, 1, 1),
      periodEndDate: DateTime(2026, 1, 1, 23, 59, 59),
      progressType: GoalProgressType.manual,
      manualProgress: 30,
      status: GoalStatus.inProgress,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Widget _wrap(_FakeGoalRepository fake) {
  return ProviderScope(
    overrides: [goalRepositoryProvider.overrideWithValue(fake)],
    child: MaterialApp(theme: AppTheme.light, home: const Scaffold(body: GoalsListPage())),
  );
}

void main() {
  testWidgets('günlük hedef listesi boşken boş durum gösterir', (tester) async {
    await tester.pumpWidget(_wrap(_FakeGoalRepository()));
    await tester.pump();

    expect(find.text('Henüz günlük hedefi eklemedin'), findsOneWidget);
  });

  testWidgets(
    'aynı anda birden fazla aktif günlük hedef listelenebiliyor (ROADMAP FAZ 8 test noktası)',
    (tester) async {
      final fake = _FakeGoalRepository()
        ..goals = [
          _goal('g1', 'Su iç'),
          _goal('g2', 'Kitap oku'),
          _goal('g3', 'Spor yap'),
        ];

      await tester.pumpWidget(_wrap(fake));
      await tester.pump();

      expect(find.text('Su iç'), findsOneWidget);
      expect(find.text('Kitap oku'), findsOneWidget);
      expect(find.text('Spor yap'), findsOneWidget);
    },
  );

  testWidgets('haftalık sekmesine geçilince yalnızca haftalık hedefler gösterilir', (tester) async {
    final fake = _FakeGoalRepository()
      ..goals = [
        _goal('g1', 'Günlük Hedef'),
        _goal('g2', 'Haftalık Hedef', periodType: GoalPeriodType.weekly),
      ];

    await tester.pumpWidget(_wrap(fake));
    await tester.pump();
    expect(find.text('Günlük Hedef'), findsOneWidget);
    expect(find.text('Haftalık Hedef'), findsNothing);

    await tester.tap(find.text('Haftalık'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Günlük Hedef'), findsNothing);
    expect(find.text('Haftalık Hedef'), findsOneWidget);
  });
}
