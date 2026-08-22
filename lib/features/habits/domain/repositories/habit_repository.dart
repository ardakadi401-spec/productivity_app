import '../../../../core/errors/result.dart';
import '../entities/habit.dart';
import '../entities/habit_record.dart';

/// Data katmanının uyması gereken sözleşme — ARCHITECTURE.md Bölüm 6.2.
///
/// Okuma metotları `Stream` döner (STATE_MANAGEMENT.md §5.2 — Isar üzerinden
/// reaktif). Yazma metotları ARCHITECTURE.md §7.3 gereği `Result` döner.
abstract interface class HabitRepository {
  /// Ağ çağrısı yapmadan yeni bir alışkanlık ID'si tahsis eder (Firestore
  /// client-side doküman ID — offline de çalışır).
  String newHabitId();

  Stream<List<Habit>> watchHabits();

  Stream<Habit?> watchHabit(String habitId);

  Stream<List<HabitRecord>> watchHabitRecords(String habitId);

  Future<Result<Habit>> createHabit(Habit habit);

  Future<Result<Habit>> updateHabit(Habit habit);

  Future<Result<void>> deleteHabit(String habitId);

  /// Günlük check-in — `isCompleted: true` ise kaydı oluşturur/günceller,
  /// `false` ise (geri alma) kaydı kalıcı olarak siler. Her iki durumda da
  /// `currentStreak`/`longestStreak` yeniden hesaplanıp güncellenmiş
  /// [Habit] döner (`CalculateStreakUseCase` — DATABASE.md §6.4).
  Future<Result<Habit>> setCheckIn(String habitId, DateTime date, {required bool isCompleted});

  /// ROADMAP.md FAZ 12 — Statistics'in dönemsel agregasyonu için eklendi.
  /// TÜM alışkanlıklar genelinde, verilen tarih aralığındaki (kapsayıcı)
  /// kayıtları tek seferlik olarak döner — `watchHabitRecords(habitId)`'in
  /// tersine belirli bir habit'e bağlı değildir, tek bir Isar sorgusuyla
  /// N+1 sorgu maliyetinden kaçınır.
  Future<List<HabitRecord>> getRecordsInRange(DateTime start, DateTime end);
}
