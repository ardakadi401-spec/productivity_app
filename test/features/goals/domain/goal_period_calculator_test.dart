import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/goals/domain/entities/goal.dart';
import 'package:productivity_app/features/goals/domain/utils/goal_period_calculator.dart';

void main() {
  group('daily', () {
    test('gün başı 00:00, gün sonu 23:59:59 olarak hesaplanır', () {
      final period = GoalPeriodCalculator.compute(GoalPeriodType.daily, DateTime(2026, 3, 10, 14, 30));

      expect(period.start, DateTime(2026, 3, 10));
      expect(period.end, DateTime(2026, 3, 10, 23, 59, 59));
    });
  });

  group('weekly', () {
    test('hafta Pazartesi\'den başlar, Pazar biter (haftanın ortasından referans)', () {
      // 2026-03-11 Çarşamba.
      final period =
          GoalPeriodCalculator.compute(GoalPeriodType.weekly, DateTime(2026, 3, 11));

      expect(period.start, DateTime(2026, 3, 9)); // Pazartesi
      expect(period.end, DateTime(2026, 3, 15, 23, 59, 59)); // Pazar
    });

    test('referans Pazartesi ise hafta o gün başlar', () {
      final period = GoalPeriodCalculator.compute(GoalPeriodType.weekly, DateTime(2026, 3, 9));

      expect(period.start, DateTime(2026, 3, 9));
      expect(period.end, DateTime(2026, 3, 15, 23, 59, 59));
    });

    test('referans Pazar ise hafta o gün biter (Pazar/Pazartesi sınır geçişi)', () {
      final period = GoalPeriodCalculator.compute(GoalPeriodType.weekly, DateTime(2026, 3, 15));

      expect(period.start, DateTime(2026, 3, 9));
      expect(period.end, DateTime(2026, 3, 15, 23, 59, 59));
    });

    test('Pazar gecesi ile bir sonraki Pazartesi farklı dönemlere düşer', () {
      final sundayPeriod =
          GoalPeriodCalculator.compute(GoalPeriodType.weekly, DateTime(2026, 3, 15, 23, 59));
      final mondayPeriod =
          GoalPeriodCalculator.compute(GoalPeriodType.weekly, DateTime(2026, 3, 16, 0, 1));

      expect(sundayPeriod.end.isBefore(mondayPeriod.start), isTrue);
      expect(mondayPeriod.start, DateTime(2026, 3, 16));
    });
  });

  group('monthly', () {
    test('ayın ilk günü başlar, son günü biter (31 gün)', () {
      final period = GoalPeriodCalculator.compute(GoalPeriodType.monthly, DateTime(2026, 3, 15));

      expect(period.start, DateTime(2026, 3, 1));
      expect(period.end, DateTime(2026, 3, 31, 23, 59, 59));
    });

    test('Şubat (2026, artık yıl değil) 28 gün ile doğru biter', () {
      final period = GoalPeriodCalculator.compute(GoalPeriodType.monthly, DateTime(2026, 2, 10));

      expect(period.end, DateTime(2026, 2, 28, 23, 59, 59));
    });

    test('Aralık ayı bir sonraki yıla taşmadan doğru hesaplanır', () {
      final period = GoalPeriodCalculator.compute(GoalPeriodType.monthly, DateTime(2026, 12, 5));

      expect(period.start, DateTime(2026, 12, 1));
      expect(period.end, DateTime(2026, 12, 31, 23, 59, 59));
    });
  });
}
