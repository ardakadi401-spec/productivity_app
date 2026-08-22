import '../../domain/entities/habit.dart';
import '../models/habit_local_model.dart';

class HabitMapper {
  HabitMapper._();

  static Habit toEntity(HabitLocalModel model) {
    return Habit(
      habitId: model.habitId,
      name: model.name,
      icon: model.icon,
      color: model.color,
      targetFrequency: _frequencyToEntity(model.targetFrequency),
      targetDays: model.targetDays,
      reminderTime: model.reminderTime,
      currentStreak: model.currentStreak,
      longestStreak: model.longestStreak,
      status: _statusToEntity(model.status),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Yeni bir [HabitLocalModel] oluşturur — `Isar.autoIncrement` `id` hariç
  /// tüm alanlar entity'den ve senkronizasyon meta bilgisinden doldurulur.
  static HabitLocalModel fromEntity(
    Habit habit, {
    required HabitSyncStatusLocal syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return HabitLocalModel()
      ..habitId = habit.habitId
      ..name = habit.name
      ..icon = habit.icon
      ..color = habit.color
      ..targetFrequency = _frequencyToLocal(habit.targetFrequency)
      ..targetDays = habit.targetDays
      ..reminderTime = habit.reminderTime
      ..currentStreak = habit.currentStreak
      ..longestStreak = habit.longestStreak
      ..status = _statusToLocal(habit.status)
      ..createdAt = habit.createdAt
      ..updatedAt = habit.updatedAt
      ..isDeleted = false
      ..syncStatus = syncStatus
      ..lastSyncedAt = lastSyncedAt
      ..localUpdatedAt = habit.updatedAt;
  }

  static HabitTargetFrequency _frequencyToEntity(HabitTargetFrequencyLocal f) => switch (f) {
        HabitTargetFrequencyLocal.daily => HabitTargetFrequency.daily,
        HabitTargetFrequencyLocal.specificDays => HabitTargetFrequency.specificDays,
      };

  static HabitTargetFrequencyLocal _frequencyToLocal(HabitTargetFrequency f) => switch (f) {
        HabitTargetFrequency.daily => HabitTargetFrequencyLocal.daily,
        HabitTargetFrequency.specificDays => HabitTargetFrequencyLocal.specificDays,
      };

  static HabitStatus _statusToEntity(HabitStatusLocal s) => switch (s) {
        HabitStatusLocal.active => HabitStatus.active,
        HabitStatusLocal.archived => HabitStatus.archived,
      };

  static HabitStatusLocal _statusToLocal(HabitStatus s) => switch (s) {
        HabitStatus.active => HabitStatusLocal.active,
        HabitStatus.archived => HabitStatusLocal.archived,
      };
}
