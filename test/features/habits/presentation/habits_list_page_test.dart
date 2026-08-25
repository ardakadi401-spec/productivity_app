import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/errors/result.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/features/habits/domain/entities/habit.dart';
import 'package:productivity_app/features/habits/domain/entities/habit_record.dart';
import 'package:productivity_app/features/habits/domain/repositories/habit_repository.dart';
import 'package:productivity_app/features/habits/presentation/pages/habits_list_page.dart';
import 'package:productivity_app/features/habits/presentation/providers/habit_providers.dart';
import 'package:productivity_app/shared/components/completion_button_widget.dart';

class _FakeHabitRepository implements HabitRepository {
  List<Habit> habits = const [];
  Map<String, List<HabitRecord>> recordsByHabit = const {};
  ({String habitId, DateTime date, bool isCompleted})? lastCheckIn;

  @override
  String newHabitId() => 'id';

  @override
  Stream<List<Habit>> watchHabits() => Stream.value(habits);

  @override
  Stream<Habit?> watchHabit(String habitId) => const Stream.empty();

  @override
  Stream<List<HabitRecord>> watchHabitRecords(String habitId) =>
      Stream.value(recordsByHabit[habitId] ?? const []);

  Habit? lastCreated;

  @override
  Future<Result<Habit>> createHabit(Habit habit) async {
    lastCreated = habit;
    return Ok(habit);
  }
  @override
  Future<Result<Habit>> updateHabit(Habit habit) => throw UnimplementedError();
  @override
  Future<Result<void>> deleteHabit(String habitId) => throw UnimplementedError();

  @override
  Future<Result<Habit>> setCheckIn(String habitId, DateTime date, {required bool isCompleted}) async {
    lastCheckIn = (habitId: habitId, date: date, isCompleted: isCompleted);
    final habit = habits.firstWhere((h) => h.habitId == habitId);
    return Ok(habit.copyWith(currentStreak: isCompleted ? 1 : 0));
  }

  @override
  Future<List<HabitRecord>> getRecordsInRange(DateTime start, DateTime end) async => const [];
}

Habit _habit({
  String habitId = 'h1',
  String name = 'Su iç',
  HabitTargetFrequency targetFrequency = HabitTargetFrequency.daily,
  List<int> targetDays = const [],
}) =>
    Habit(
      habitId: habitId,
      name: name,
      color: '#FF8A8A',
      targetFrequency: targetFrequency,
      targetDays: targetDays,
      currentStreak: 0,
      longestStreak: 0,
      status: HabitStatus.active,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Widget _wrap(_FakeHabitRepository fake) {
  return ProviderScope(
    overrides: [habitRepositoryProvider.overrideWithValue(fake)],
    child: MaterialApp(theme: AppTheme.light, home: const Scaffold(body: HabitsListPage())),
  );
}

void main() {
  testWidgets('alışkanlık listesi boşken boş durum gösterir', (tester) async {
    await tester.pumpWidget(_wrap(_FakeHabitRepository()));
    await tester.pump();

    expect(find.text('Henüz alışkanlık eklemedin'), findsOneWidget);
    expect(find.text('Alışkanlık Ekle'), findsOneWidget);
  });

  testWidgets('alışkanlık listesi doluyken kartları render eder', (tester) async {
    final fake = _FakeHabitRepository()
      ..habits = [_habit(habitId: 'h1', name: 'Su iç'), _habit(habitId: 'h2', name: 'Kitap oku')];

    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    expect(find.text('Su iç'), findsOneWidget);
    expect(find.text('Kitap oku'), findsOneWidget);
  });

  testWidgets(
    'hedef günü olmayan (specificDays, bugün dahil değil) alışkanlık "soluk" gösterilir ve check-in tetiklemez',
    (tester) async {
      final today = DateTime.now();
      // Bugünün haftanın günü dışındaki tüm günleri hedef seçilir — böylece
      // bugün kesin olarak "hedef değil" olur.
      final otherDays = [1, 2, 3, 4, 5, 6, 7]..remove(today.weekday);
      final fake = _FakeHabitRepository()
        ..habits = [
          _habit(targetFrequency: HabitTargetFrequency.specificDays, targetDays: otherDays),
        ];

      await tester.pumpWidget(_wrap(fake));
      await tester.pump();

      // Completion Button "enabled: false" ile render edilmeli — devre dışı
      // olduğunda dokunma çağrının kartın kendi (navigasyon) InkWell'ine
      // düşmesine izin verir (test ortamında GoRouter yok), bu yüzden
      // gerçek bir dokunma simüle etmek yerine widget durumunu doğrudan
      // doğruluyoruz.
      final completionButton = tester.widget<CompletionButton>(find.byType(CompletionButton));
      expect(completionButton.enabled, isFalse);
    },
  );

  testWidgets('Completion Button dokunması check-in tetikler', (tester) async {
    final fake = _FakeHabitRepository()..habits = [_habit()];

    await tester.pumpWidget(_wrap(fake));
    await tester.pump();

    await tester.tap(find.byType(CompletionButton));
    await tester.pump();

    expect(fake.lastCheckIn?.habitId, 'h1');
    expect(fake.lastCheckIn?.isCompleted, isTrue);
  });

  testWidgets(
    '"Alışkanlık Ekle" boş durum eylemi CreateHabitSheet açar; geçerli isimle oluşturulunca '
    'createHabit çağrılır',
    (tester) async {
      // Bottom Sheet içeriği (isim + ikon/renk seçici + sıklık seçici +
      // kaydet butonu) varsayılan 800x600 test görünümünde taşıyor
      // (project_detail_page_test.dart'taki EditProjectSheet ile aynı
      // gerekçe).
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fake = _FakeHabitRepository();
      await tester.pumpWidget(_wrap(fake));
      await tester.pump();

      await tester.tap(find.text('Alışkanlık Ekle'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Erken kalk');
      await tester.pump();
      await tester.tap(find.text('Oluştur'));
      await tester.pumpAndSettle();

      expect(fake.lastCreated?.name, 'Erken kalk');
    },
  );
}
