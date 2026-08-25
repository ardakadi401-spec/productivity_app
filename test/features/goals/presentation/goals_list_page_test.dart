import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/goals/domain/entities/goal.dart';
import 'package:productivity_app/features/goals/domain/repositories/goal_repository.dart';
import 'package:productivity_app/features/goals/presentation/pages/goals_list_page.dart';
import 'package:productivity_app/features/goals/presentation/providers/goal_providers.dart';
import 'package:productivity_app/features/tasks/domain/entities/sub_task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task.dart';
import 'package:productivity_app/features/tasks/domain/entities/task_filter.dart';
import 'package:productivity_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity_app/features/tasks/presentation/providers/task_providers.dart';

class _FakeGoalRepository implements GoalRepository {
  List<Goal> goals = const [];
  Goal? lastCreated;
  Goal? lastUpdated;

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
  Future<Result<Goal>> createGoal(Goal goal) async {
    lastCreated = goal;
    return Ok(goal);
  }

  @override
  Future<Result<Goal>> updateGoal(Goal goal) async {
    lastUpdated = goal;
    return Ok(goal);
  }

  @override
  Future<Result<Goal>> setManualProgress(String goalId, {required int progress}) =>
      throw UnimplementedError();

  @override
  Future<Result<Goal>> setGoalStatus(String goalId, {required GoalStatus status}) async {
    // `CheckExpiredGoalsUseCase` her liste okumasında dönemi geçmiş
    // hedefleri otomatik süresi doldu olarak işaretler — sabit test
    // tarihleriyle bu her zaman tetiklenebileceğinden fake, `throw`
    // yerine sessizce no-op döner.
    final goal = goals.firstWhere((g) => g.goalId == goalId, orElse: () => throw StateError('n/a'));
    return Ok(goal.copyWith(status: status));
  }
}

class _EmptyTaskRepository implements TaskRepository {
  @override
  String newTaskId() => 't1';
  @override
  String newSubTaskId(String taskId) => 's1';
  @override
  Stream<List<Task>> watchTasks({TaskFilter filter = TaskFilter.none}) => Stream.value(const []);
  @override
  Stream<Task?> watchTask(String taskId) => Stream.value(null);
  @override
  Stream<List<SubTask>> watchSubTasks(String taskId) => Stream.value(const []);
  @override
  Stream<List<Task>> watchTodayTasks() => Stream.value(const []);
  @override
  Future<Result<Task>> createTask(Task t) => throw UnimplementedError();
  @override
  Future<Result<Task>> updateTask(Task t) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteTask(String taskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> setTaskCompleted(String taskId, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<Result<SubTask>> addSubTask(SubTask subTask) => throw UnimplementedError();
  @override
  Future<Result<void>> setSubTaskCompleted(String subtaskId, {required bool isCompleted}) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> deleteSubTask(String subtaskId) => throw UnimplementedError();
  @override
  Future<Result<Task>> recalculateTaskProgress(String taskId) => throw UnimplementedError();
}

Goal _goal(String id, String title, {GoalPeriodType periodType = GoalPeriodType.daily}) => Goal(
      goalId: id,
      title: title,
      periodType: periodType,
      // Süresi dolmuş görünmesin diye (`CheckExpiredGoalsUseCase` her liste
      // okumasında kontrol eder) uzak bir gelecek tarih kullanılır.
      periodStartDate: DateTime(2030, 1, 1),
      periodEndDate: DateTime(2030, 1, 1, 23, 59, 59),
      progressType: GoalProgressType.manual,
      manualProgress: 30,
      status: GoalStatus.inProgress,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Widget _wrap(_FakeGoalRepository fake) {
  return ProviderScope(
    overrides: [
      goalRepositoryProvider.overrideWithValue(fake),
      taskRepositoryProvider.overrideWithValue(_EmptyTaskRepository()),
    ],
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

  testWidgets(
    '"Hedef Ekle" boş durum eylemi CreateGoalSheet açar; geçerli başlıkla oluşturulunca createGoal çağrılır',
    (tester) async {
      // Bottom Sheet'in içeriği (form alanları + zaman aralığı seçici +
      // ilerleme tipi + kaydet butonu) varsayılan 800x600 test görünümünde
      // taşıyor (project_detail_page_test.dart'taki EditProjectSheet ile
      // aynı gerekçe).
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fake = _FakeGoalRepository();
      await tester.pumpWidget(_wrap(fake));
      await tester.pump();

      await tester.tap(find.text('Hedef Ekle'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Günde 2 litre su iç');
      await tester.pump();
      await tester.tap(find.text('Oluştur'));
      await tester.pumpAndSettle();

      expect(fake.lastCreated?.title, 'Günde 2 litre su iç');
      expect(fake.lastCreated?.periodType, GoalPeriodType.daily);
    },
  );

  testWidgets('bir hedef kartına dokununca mevcut başlıkla EditGoalSheet açılır ve güncelleme çağrılır', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fake = _FakeGoalRepository()..goals = [_goal('g1', 'Su iç')];
    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    await tester.tap(find.text('Su iç'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Su iç'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Su içmeyi unutma');
    await tester.pump();
    await tester.tap(find.text('Güncelle'));
    await tester.pumpAndSettle();

    expect(fake.lastUpdated?.title, 'Su içmeyi unutma');
  });
}
