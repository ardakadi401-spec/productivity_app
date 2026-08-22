/// DATABASE.md Bölüm 9 — `users/{userId}/pomodoroSessions/{sessionId}`
/// alanlarının Domain katmanı saf temsili. DATABASE.md §13.4 istisnası
/// gereği soft delete taşımaz (salt geçmiş-kaydı niteliğinde, `HabitRecord`
/// ile aynı ilke) — silme akışı yok, yalnızca oluşturma/tamamlama.
class PomodoroSession {
  const PomodoroSession({
    required this.sessionId,
    required this.type,
    required this.plannedDuration,
    required this.actualDuration,
    required this.startedAt,
    required this.isCompleted,
    this.taskId,
    this.completedAt,
  });

  final String sessionId;

  /// Opsiyonel görev bağlantısı — görev silinse bile bu kayıt geçmişte
  /// tutarlı kalır (referans bütünlüğü: orphan `taskId` bırakılır, cascade
  /// delete yapılmaz — ROADMAP FAZ 11 "Test Edilmesi Gereken Noktalar").
  final String? taskId;
  final PomodoroSessionType type;
  final Duration plannedDuration;

  /// Gerçekleşen süre — erken bitirme/iptal durumlarında planlanandan kısa
  /// olabilir.
  final Duration actualDuration;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool isCompleted;

  PomodoroSession copyWith({
    Duration? actualDuration,
    DateTime? completedAt,
    bool? isCompleted,
    String? taskId,
    bool clearTaskId = false,
  }) {
    return PomodoroSession(
      sessionId: sessionId,
      taskId: clearTaskId ? null : (taskId ?? this.taskId),
      type: type,
      plannedDuration: plannedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// DATABASE.md §9.2 — `type` enum (`work`, `break`). Dart'ta `break`
/// ayrılmış anahtar kelime olduğundan `breakTime` adlandırılır.
enum PomodoroSessionType { work, breakTime }
