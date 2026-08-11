import '../entities/goal.dart';

/// Bir [GoalPeriodType] ve referans tarihe göre dönemin başlangıç/bitişini
/// hesaplar — hem yeni hedef oluştururken (bugünün dönemi) hem de dönem sonu
/// otomatik arşivleme kontrolünde kullanılır.
///
/// Hafta Pazartesi'den başlar (Calendar feature'ının hafta günü kuralıyla
/// tutarlı — `DateTime.weekday`: 1=Pazartesi..7=Pazar). ROADMAP.md FAZ 8
/// "Test Edilmesi Gereken Noktalar": "Haftalık bir hedef, hafta sınırında
/// (Pazar/Pazartesi geçişi) doğru dönemde mi kalıyor?" — bu sınır burada
/// netleştirilir.
class GoalPeriodCalculator {
  GoalPeriodCalculator._();

  static ({DateTime start, DateTime end}) compute(GoalPeriodType type, DateTime reference) {
    return switch (type) {
      GoalPeriodType.daily => _daily(reference),
      GoalPeriodType.weekly => _weekly(reference),
      GoalPeriodType.monthly => _monthly(reference),
    };
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
