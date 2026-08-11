import '../../../../shared/components/goal_card_widget.dart';
import '../../domain/entities/goal.dart';

/// `Goal` feature'ının `GoalStatus`'unu `shared/`'ın feature-agnostik
/// `GoalCardState`'ine eşler — Tasks'ın `toPriorityLevel`'ı ile aynı desen
/// (`task_priority_mapping.dart`); Dashboard bu dosyayı doğrudan import
/// eder (Dashboard'un Tasks'ın `task_priority_mapping.dart`'ı doğrudan
/// import etmesiyle aynı, mevcut kod tabanında yerleşik desen).
GoalCardState toGoalCardState(GoalStatus status) => switch (status) {
      GoalStatus.inProgress => GoalCardState.inProgress,
      GoalStatus.achieved => GoalCardState.achieved,
      GoalStatus.missed => GoalCardState.missed,
    };

const Map<GoalPeriodType, String> goalPeriodLabels = {
  GoalPeriodType.daily: 'GÜNLÜK',
  GoalPeriodType.weekly: 'HAFTALIK',
  GoalPeriodType.monthly: 'AYLIK',
};
