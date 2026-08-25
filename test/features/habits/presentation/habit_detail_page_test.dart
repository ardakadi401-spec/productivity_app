import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/habits/domain/entities/habit.dart';
import 'package:productivity_app/features/habits/domain/entities/habit_record.dart';
import 'package:productivity_app/features/habits/domain/repositories/habit_repository.dart';
import 'package:productivity_app/features/habits/presentation/pages/habit_detail_page.dart';
import 'package:productivity_app/features/habits/presentation/providers/habit_providers.dart';

/// Habit Detail Screen (SCREENS.md §4.16), ROADMAP.md FAZ 16 — coverage
/// denetiminde %0 bulunan bir ekran.
class _FakeHabitRepository implements HabitRepository {
  _FakeHabitRepository(this.habit, {this.records = const []});

  Habit? habit;
  List<HabitRecord> records;
  bool deleteCalled = false;
  ({DateTime date, bool isCompleted})? lastCheckIn;
  final _habitController = StreamController<Habit?>.broadcast();
  final _recordsController = StreamController<List<HabitRecord>>.broadcast();

  @override
  String newHabitId() => 'new-habit-id';

  @override
  Stream<List<Habit>> watchHabits() => Stream.value(const []);

  @override
  Stream<Habit?> watchHabit(String habitId) => Stream<Habit?>.multi((controller) {
        controller.add(habit);
        final sub = _habitController.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Stream<List<HabitRecord>> watchHabitRecords(String habitId) =>
      Stream<List<HabitRecord>>.multi((controller) {
        controller.add(records);
        final sub = _recordsController.stream.listen(controller.add);
        controller.onCancel = sub.cancel;
      });

  @override
  Future<Result<Habit>> createHabit(Habit habit) => throw UnimplementedError();

  @override
  Future<Result<Habit>> updateHabit(Habit habit) async {
    this.habit = habit;
    _habitController.add(habit);
    return Ok(habit);
  }

  @override
  Future<Result<void>> deleteHabit(String habitId) async {
    deleteCalled = true;
    return const Ok(null);
  }

  @override
  Future<Result<Habit>> setCheckIn(String habitId, DateTime date, {required bool isCompleted}) async {
    lastCheckIn = (date: date, isCompleted: isCompleted);
    records = isCompleted
        ? [
            ...records,
            HabitRecord(recordId: 'r-${records.length + 1}', habitId: habitId, date: date, isCompleted: true),
          ]
        : const [];
    _recordsController.add(records);
    final updated = habit!.copyWith(
      currentStreak: isCompleted ? habit!.currentStreak + 1 : 0,
    );
    habit = updated;
    _habitController.add(updated);
    return Ok(updated);
  }

  @override
  Future<List<HabitRecord>> getRecordsInRange(DateTime start, DateTime end) => throw UnimplementedError();
}

Habit _habit({
  String habitId = 'h1',
  String name = 'Su İç',
  HabitTargetFrequency targetFrequency = HabitTargetFrequency.daily,
  List<int> targetDays = const [],
  int currentStreak = 3,
  int longestStreak = 5,
}) =>
    Habit(
      habitId: habitId,
      name: name,
      color: '#8AB4FF',
      targetFrequency: targetFrequency,
      targetDays: targetDays,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      status: HabitStatus.active,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

/// Silme akışı `context.pop()` çağırdığından gerçek bir `GoRouter` gerekir
/// (`task_detail_page_test.dart`'taki aynı gerekçe). Düzenle Bottom Sheet'i
/// varsayılan 800x600 test görünümünde taşabildiğinden görünüm büyütülür
/// (`project_detail_page_test.dart`'taki EditProjectSheet ile aynı gerekçe).
Future<GoRouter> _pumpWithRouter(
  WidgetTester tester, {
  required _FakeHabitRepository habitRepository,
}) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final router = GoRouter(
    initialLocation: '/list',
    routes: [
      GoRoute(path: '/list', builder: (_, _) => const Scaffold(body: Text('Alışkanlık Listesi'))),
      GoRoute(path: '/detail', builder: (_, _) => const HabitDetailPage(habitId: 'h1')),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [habitRepositoryProvider.overrideWithValue(habitRepository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  router.push('/detail');
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('alışkanlık bulunamazsa "Bu alışkanlık artık mevcut değil." gösterir', (tester) async {
    await _pumpWithRouter(tester, habitRepository: _FakeHabitRepository(null));

    expect(find.text('Bu alışkanlık artık mevcut değil.'), findsOneWidget);
  });

  testWidgets('alışkanlık verisi render olur (isim, seri sayaçları)', (tester) async {
    await _pumpWithRouter(
      tester,
      habitRepository: _FakeHabitRepository(_habit(currentStreak: 3, longestStreak: 5)),
    );

    // AppBar başlığı + gövde başlığı olmak üzere iki kez görünür.
    expect(find.text('Su İç'), findsWidgets);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('bugün hedef gün ise Completion Button check-in tetikler', (tester) async {
    final repository = _FakeHabitRepository(_habit());
    await _pumpWithRouter(tester, habitRepository: repository);

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    expect(repository.lastCheckIn?.isCompleted, isTrue);
    expect(repository.habit!.currentStreak, 4);
  });

  testWidgets('geçmiş kayıtlar boşsa "Henüz kayıt yok" gösterir, doluysa liste gösterir', (
    tester,
  ) async {
    await _pumpWithRouter(tester, habitRepository: _FakeHabitRepository(_habit()));
    expect(find.text('Henüz kayıt yok, bugün başla'), findsOneWidget);

    await _pumpWithRouter(
      tester,
      habitRepository: _FakeHabitRepository(
        _habit(),
        records: [
          HabitRecord(
            recordId: 'r1',
            habitId: 'h1',
            date: DateTime(2026, 1, 5),
            isCompleted: true,
          ),
        ],
      ),
    );
    expect(find.text('5.1.2026'), findsOneWidget);
  });

  testWidgets('Sil -> Vazgeç: repository çağrılmaz, ekranda kalınır', (tester) async {
    final repository = _FakeHabitRepository(_habit());
    await _pumpWithRouter(tester, habitRepository: repository);

    await tester.tap(find.byTooltip('Sil'));
    await tester.pumpAndSettle();
    expect(find.text('Alışkanlığı Sil'), findsOneWidget);

    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    expect(repository.deleteCalled, isFalse);
    // AppBar başlığı + gövde başlığı olmak üzere iki kez görünür.
    expect(find.text('Su İç'), findsWidgets);
  });

  testWidgets('Sil -> Onayla: repository.deleteHabit çağrılır ve bir önceki ekrana dönülür', (
    tester,
  ) async {
    final repository = _FakeHabitRepository(_habit());
    await _pumpWithRouter(tester, habitRepository: repository);

    await tester.tap(find.byTooltip('Sil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sil').last);
    await tester.pumpAndSettle();

    expect(repository.deleteCalled, isTrue);
    expect(find.text('Alışkanlık Listesi'), findsOneWidget);
  });

  testWidgets('Düzenle ikonuna dokununca mevcut isimle EditHabitSheet açılır', (tester) async {
    await _pumpWithRouter(tester, habitRepository: _FakeHabitRepository(_habit()));

    await tester.tap(find.byTooltip('Düzenle'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Su İç'), findsOneWidget);
  });

  testWidgets('EditHabitSheet\'te isim güncellenip Güncelle basılınca updateHabit çağrılır', (
    tester,
  ) async {
    final repository = _FakeHabitRepository(_habit());
    await _pumpWithRouter(tester, habitRepository: repository);

    await tester.tap(find.byTooltip('Düzenle'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Su İç'), 'Su içmeyi unutma');
    await tester.pump();
    await tester.tap(find.text('Güncelle'));
    await tester.pumpAndSettle();

    expect(repository.habit?.name, 'Su içmeyi unutma');
  });
}
