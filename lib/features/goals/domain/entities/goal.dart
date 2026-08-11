/// DATABASE.md Bölüm 7 — `users/{userId}/goals/{goalId}` alanlarının Domain
/// katmanı saf temsili (framework/Firebase/Isar bağımsız).
///
/// Günlük/haftalık/aylık hedefler DATABASE.md §7.2 kararı gereği tek bir
/// koleksiyonda [periodType] ayırt edici alanıyla tutulur.
class Goal {
  const Goal({
    required this.goalId,
    required this.title,
    required this.periodType,
    required this.periodStartDate,
    required this.periodEndDate,
    required this.progressType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.linkedTaskIds = const [],
    this.manualProgress,
  });

  final String goalId;
  final String title;
  final String? description;
  final GoalPeriodType periodType;
  final DateTime periodStartDate;
  final DateTime periodEndDate;

  /// Opsiyonel görev bağlantıları — `progressType: linkedTasks` ise
  /// ilerleme bu görevlerin tamamlanma oranından (Tasks Domain üzerinden,
  /// canlı) hesaplanır.
  final List<String> linkedTaskIds;
  final GoalProgressType progressType;

  /// Yalnızca `progressType: manual` iken anlamlıdır (0–100).
  final int? manualProgress;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isInProgress => status == GoalStatus.inProgress;

  /// Yalnızca `progressType: manual` için geçerlidir — `linkedTasks` tipi
  /// hedeflerin ilerlemesi Tasks Domain'inden canlı okunur (Presentation
  /// katmanında, bkz. `goalProgressProvider`), entity bunu bilemez.
  double get manualProgressRatio => (manualProgress ?? 0).clamp(0, 100) / 100;

  Goal copyWith({
    String? title,
    String? description,
    bool clearDescription = false,
    GoalPeriodType? periodType,
    DateTime? periodStartDate,
    DateTime? periodEndDate,
    List<String>? linkedTaskIds,
    GoalProgressType? progressType,
    int? manualProgress,
    bool clearManualProgress = false,
    GoalStatus? status,
    DateTime? updatedAt,
  }) {
    return Goal(
      goalId: goalId,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      periodType: periodType ?? this.periodType,
      periodStartDate: periodStartDate ?? this.periodStartDate,
      periodEndDate: periodEndDate ?? this.periodEndDate,
      linkedTaskIds: linkedTaskIds ?? this.linkedTaskIds,
      progressType: progressType ?? this.progressType,
      manualProgress: clearManualProgress ? null : (manualProgress ?? this.manualProgress),
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// DATABASE.md §7.3 — `periodType` enum.
enum GoalPeriodType { daily, weekly, monthly }

/// DATABASE.md §7.3 — `progressType` enum.
enum GoalProgressType { manual, linkedTasks }

/// DATABASE.md §7.3 — `status` enum.
enum GoalStatus { inProgress, achieved, missed }
