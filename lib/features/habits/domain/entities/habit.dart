/// DATABASE.md Bölüm 6.2 — `users/{userId}/habits/{habitId}` alanlarının
/// Domain katmanı saf temsili (framework/Firebase/Isar bağımsız).
class Habit {
  const Habit({
    required this.habitId,
    required this.name,
    required this.color,
    required this.targetFrequency,
    required this.currentStreak,
    required this.longestStreak,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.icon,
    this.targetDays = const [],
    this.reminderTime,
  });

  final String habitId;
  final String name;

  /// İkon seti içindeki referans anahtar (opsiyonel).
  final String? icon;

  /// Hex kod — UI_GUIDELINES.md §3.3 pastel setinden seçilir.
  final String color;
  final HabitTargetFrequency targetFrequency;

  /// Yalnızca `targetFrequency: specificDays` iken anlamlıdır.
  /// `DateTime.weekday` kuralıyla aynı (1=Pazartesi..7=Pazar) — projede
  /// Calendar/Goals'ın hafta hesaplamasıyla tutarlı.
  final List<int> targetDays;

  /// `HH:mm` formatında (opsiyonel) — bildirim planlaması FAZ 13 kapsamı,
  /// bu fazda yalnızca alan hazırlanır.
  final String? reminderTime;

  /// Denormalize edilmiş seri sayaçları (DATABASE.md §6.4) —
  /// `CalculateStreakUseCase` tarafından her check-in'de yeniden hesaplanır.
  final int currentStreak;
  final int longestStreak;
  final HabitStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Verilen günün bu alışkanlık için "hedef gün" olup olmadığını söyler —
  /// `daily` her zaman true; `specificDays` yalnızca [targetDays] içindeki
  /// haftanın günlerinde true (COMPONENTS.md §9.1 "Bugün Atlandı" durumu).
  bool isScheduledOn(DateTime date) {
    return switch (targetFrequency) {
      HabitTargetFrequency.daily => true,
      HabitTargetFrequency.specificDays => targetDays.contains(date.weekday),
    };
  }

  Habit copyWith({
    String? name,
    String? icon,
    bool clearIcon = false,
    String? color,
    HabitTargetFrequency? targetFrequency,
    List<int>? targetDays,
    String? reminderTime,
    bool clearReminderTime = false,
    int? currentStreak,
    int? longestStreak,
    HabitStatus? status,
    DateTime? updatedAt,
  }) {
    return Habit(
      habitId: habitId,
      name: name ?? this.name,
      icon: clearIcon ? null : (icon ?? this.icon),
      color: color ?? this.color,
      targetFrequency: targetFrequency ?? this.targetFrequency,
      targetDays: targetDays ?? this.targetDays,
      reminderTime: clearReminderTime ? null : (reminderTime ?? this.reminderTime),
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// DATABASE.md §6.2 — `targetFrequency` enum.
enum HabitTargetFrequency { daily, specificDays }

/// DATABASE.md §6.2 — `status` enum.
enum HabitStatus { active, archived }
