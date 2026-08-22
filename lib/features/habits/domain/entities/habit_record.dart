/// DATABASE.md Bölüm 6.3 — `users/{userId}/habits/{habitId}/habitRecords/{recordId}`
/// alanlarının Domain katmanı saf temsili. `HabitRecord`, DATABASE.md §13.4
/// istisnası gereği soft delete taşımaz (salt geçmiş-kaydı niteliğinde) —
/// bir check-in geri alındığında kayıt kalıcı olarak silinir.
class HabitRecord {
  const HabitRecord({
    required this.recordId,
    required this.habitId,
    required this.date,
    required this.isCompleted,
    this.completedAt,
  });

  /// `yyyy-MM-dd` formatında (DATABASE.md §13.1).
  final String recordId;
  final String habitId;

  /// Saat bileşeni sıfırlanmış gün.
  final DateTime date;
  final bool isCompleted;
  final DateTime? completedAt;
}
