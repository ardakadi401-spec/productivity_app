/// DATABASE.md Bölüm 4 — `users/{userId}/tasks/{taskId}` alanlarının Domain
/// katmanı saf temsili (framework/Firebase/Isar bağımsız).
class Task {
  const Task({
    required this.taskId,
    required this.title,
    required this.priority,
    required this.status,
    required this.subtaskCount,
    required this.completedSubtaskCount,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.dueDate,
    this.dueTime,
    this.projectId,
    this.categoryId,
    this.tagIds = const [],
    this.recurrenceRule,
    this.completedAt,
  });

  final String taskId;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;

  /// `HH:mm` formatında — bildirim tetikleme için `dueDate`'ten ayrı tutulur
  /// (DATABASE.md Bölüm 4, FAZ 13'te kullanılacak).
  final String? dueTime;

  /// İlişkili proje referansı (opsiyonel — DATABASE.md §4.2). Projects
  /// feature'ının Domain katmanı yalnızca bu ID string'ini taşır; Tasks
  /// Projects'in Data/Presentation katmanına bağımlı değildir.
  final String? projectId;
  final String? categoryId;
  final List<String> tagIds;
  final RecurrenceRule? recurrenceRule;

  /// Denormalize edilmiş sayaçlar (DATABASE.md §5.3) — alt görev listesini
  /// yeniden okumadan ilerleme yüzdesi hesaplamak için.
  final int subtaskCount;
  final int completedSubtaskCount;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => status == TaskStatus.completed;

  /// Alt görev yoksa görevin kendi durumuna (0 veya 1), varsa alt görev
  /// oranına göre — ROADMAP.md FAZ 5 "üst görevin tamamlanma yüzdesi
  /// alt görevlere göre otomatik güncellenir" kuralı.
  double get completionRatio {
    if (subtaskCount == 0) return isCompleted ? 1 : 0;
    return completedSubtaskCount / subtaskCount;
  }

  /// Nullable alanları (`description`/`dueDate`/`dueTime`) `null`'a
  /// döndürmek için `clear*` bayrakları kullanılır — düz `?? this.x` deseni
  /// bunu ifade edemez (Edit Task ekranı, kullanıcı bir son tarihi
  /// kaldırdığında bu yola ihtiyaç duyar).
  Task copyWith({
    String? title,
    String? description,
    bool clearDescription = false,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? dueTime,
    bool clearDueTime = false,
    String? projectId,
    bool clearProjectId = false,
    String? categoryId,
    List<String>? tagIds,
    RecurrenceRule? recurrenceRule,
    int? subtaskCount,
    int? completedSubtaskCount,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return Task(
      taskId: taskId,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      dueTime: clearDueTime ? null : (dueTime ?? this.dueTime),
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      categoryId: categoryId ?? this.categoryId,
      tagIds: tagIds ?? this.tagIds,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      subtaskCount: subtaskCount ?? this.subtaskCount,
      completedSubtaskCount: completedSubtaskCount ?? this.completedSubtaskCount,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// DATABASE.md §4 — `priority` enum.
enum TaskPriority { low, medium, high }

/// DATABASE.md §4 — `status` enum.
enum TaskStatus { pending, completed }

/// DATABASE.md §4.3 — yalnızca veri modeli seviyesinde (UI zorunlu değil,
/// ROADMAP.md FAZ 5 notu).
class RecurrenceRule {
  const RecurrenceRule({
    required this.frequency,
    required this.interval,
    this.daysOfWeek,
    this.endDate,
  });

  final RecurrenceFrequency frequency;
  final int interval;
  final List<int>? daysOfWeek;
  final DateTime? endDate;
}

enum RecurrenceFrequency { daily, weekly, monthly }
