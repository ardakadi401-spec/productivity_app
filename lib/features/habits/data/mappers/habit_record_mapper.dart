import '../../domain/entities/habit_record.dart';
import '../models/habit_record_local_model.dart';

class HabitRecordMapper {
  HabitRecordMapper._();

  static HabitRecord toEntity(HabitRecordLocalModel model) {
    return HabitRecord(
      recordId: model.recordId,
      habitId: model.habitId,
      date: model.date,
      isCompleted: model.isCompleted,
      completedAt: model.completedAt,
    );
  }

  static HabitRecordLocalModel fromEntity(
    HabitRecord record, {
    required HabitRecordSyncStatusLocal syncStatus,
    DateTime? lastSyncedAt,
  }) {
    return HabitRecordLocalModel()
      ..compositeKey = HabitRecordLocalModel.buildCompositeKey(record.habitId, record.recordId)
      ..habitId = record.habitId
      ..recordId = record.recordId
      ..date = record.date
      ..isCompleted = record.isCompleted
      ..completedAt = record.completedAt
      ..syncStatus = syncStatus
      ..lastSyncedAt = lastSyncedAt
      ..localUpdatedAt = record.date;
  }
}
