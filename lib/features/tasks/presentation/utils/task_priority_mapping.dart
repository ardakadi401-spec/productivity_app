import '../../../../shared/components/priority_badge_widget.dart';
import '../../domain/entities/task.dart';

/// `Task` feature'ının `TaskPriority`'sini `shared/`'ın feature-agnostik
/// `PriorityLevel`'ına eşler (`shared/` domain entity'lerini bilemez —
/// FOLDER_STRUCTURE.md §6.5).
PriorityLevel toPriorityLevel(TaskPriority priority) => switch (priority) {
      TaskPriority.low => PriorityLevel.low,
      TaskPriority.medium => PriorityLevel.medium,
      TaskPriority.high => PriorityLevel.high,
    };
