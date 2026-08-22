import '../entities/habit.dart';
import '../entities/habit_record.dart';

/// DATABASE.md §6.4 "Streak Hesaplama Mantığı" — saf, bağımlılıksız algoritma
/// (Repository/Isar/Firestore bilmez, tamamen unit test edilebilir).
///
/// ROADMAP.md FAZ 9 riski: "specificDays tekrar tipinde yanlış gün atlaması
/// sayması" — bu yüzden yalnızca [Habit.isScheduledOn] `true` döndürdüğü
/// günler diziye dahil edilir; hedef olmayan günler seriyi hiç etkilemez.
///
/// "Bugün" kuralı (COMPONENTS.md §9.1 "Bugün İşaretlenmedi" durumu — henüz
/// kırılmış sayılmaz): referans tarih hedef bir günse ve o gün için kayıt
/// henüz yoksa, o gün diziden çıkarılır (ne sayılır ne seriyi bozar) —
/// "gece yarısı" geçip gün değiştiğinde referans tarih ertesi güne
/// kayacağından, dünün kaydı yoksa o zaman gerçekten kırılmış sayılır.
class CalculateStreakUseCase {
  const CalculateStreakUseCase();

  ({int currentStreak, int longestStreak}) call({
    required Habit habit,
    required List<HabitRecord> records,
    required DateTime referenceDate,
  }) {
    final recordsByDate = <DateTime, bool>{
      for (final r in records) _normalize(r.date): r.isCompleted,
    };
    final today = _normalize(referenceDate);

    var earliest = today;
    for (final date in recordsByDate.keys) {
      if (date.isBefore(earliest)) earliest = date;
    }

    final scheduledDates = <DateTime>[];
    // `Duration` bazlı `add` yerine takvim bazlı ilerleme kullanılır —
    // yerel saatte DST geçişi varsa `Duration(days: 1)` eklemek tam gece
    // yarısına denk gelmeyebilir (mutlak süre, takvim günü değil).
    for (var date = earliest; !date.isAfter(today); date = DateTime(date.year, date.month, date.day + 1)) {
      if (habit.isScheduledOn(date)) scheduledDates.add(date);
    }

    var longest = 0;
    var running = 0;
    var currentStreak = 0;

    for (final date in scheduledDates) {
      final isToday = date == today;
      final hasRecord = recordsByDate.containsKey(date);

      if (isToday && !hasRecord) {
        // Bugün henüz işaretlenmedi — seriyi bozmaz, sayılmaz da; mevcut
        // running değeri (dünden gelen seri) currentStreak olarak kalır.
        currentStreak = running;
        break;
      }

      final completed = recordsByDate[date] ?? false;
      if (completed) {
        running += 1;
        if (running > longest) longest = running;
      } else {
        running = 0;
      }
      currentStreak = running;
    }

    return (currentStreak: currentStreak, longestStreak: longest);
  }

  DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);
}
