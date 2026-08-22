import '../entities/statistics_period.dart';

/// Bir [StatisticsPeriod] ve referans tarihe göre raporlama penceresinin
/// başlangıç/bitişini hesaplar — `GoalPeriodCalculator` ile aynı tarih
/// matematiği (hafta Pazartesi'den başlar, `DateTime.weekday`), ama Goals'a
/// bağımlı olmadan Statistics'in kendi saf Domain algoritması olarak ayrı
/// tutulur (her feature kendi tarih hesaplama yardımcısını taşır — Goals/
/// Habits/Pomodoro ile aynı desen).
class StatisticsPeriodCalculator {
  StatisticsPeriodCalculator._();

  static ({DateTime start, DateTime end}) resolve(StatisticsPeriod period, DateTime reference) {
    return switch (period) {
      StatisticsPeriod.daily => _daily(reference),
      StatisticsPeriod.weekly => _weekly(reference),
      StatisticsPeriod.monthly => _monthly(reference),
    };
  }

  /// [start]–[end] (kapsayıcı) aralığındaki her takvim gününü, saat
  /// bileşeni sıfırlanmış olarak, tarih sırasıyla döner — Chart Container'ın
  /// günlük çubukları için.
  static List<DateTime> daysInRange(DateTime start, DateTime end) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    final days = <DateTime>[];
    var cursor = startDay;
    while (!cursor.isAfter(endDay)) {
      days.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return days;
  }

  static ({DateTime start, DateTime end}) _daily(DateTime reference) {
    final start = DateTime(reference.year, reference.month, reference.day);
    final end = DateTime(reference.year, reference.month, reference.day, 23, 59, 59);
    return (start: start, end: end);
  }

  static ({DateTime start, DateTime end}) _weekly(DateTime reference) {
    final today = DateTime(reference.year, reference.month, reference.day);
    final start = today.subtract(Duration(days: today.weekday - 1));
    final endDay = start.add(const Duration(days: 6));
    final end = DateTime(endDay.year, endDay.month, endDay.day, 23, 59, 59);
    return (start: start, end: end);
  }

  static ({DateTime start, DateTime end}) _monthly(DateTime reference) {
    final start = DateTime(reference.year, reference.month);
    final lastDay = DateTime(reference.year, reference.month + 1, 0).day;
    final end = DateTime(reference.year, reference.month, lastDay, 23, 59, 59);
    return (start: start, end: end);
  }
}
