/// DATABASE.md Bölüm 3 — `users/{userId}/projects/{projectId}` alanlarının
/// Domain katmanı saf temsili (framework/Firebase/Isar bağımsız).
class Project {
  const Project({
    required this.projectId,
    required this.title,
    required this.color,
    required this.status,
    required this.taskCount,
    required this.completedTaskCount,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.icon,
  });

  final String projectId;
  final String title;
  final String? description;

  /// Hex kod (örn. `#FF8A8A`) — UI_GUIDELINES.md §3.3 pastel setinden seçilir.
  final String color;
  final String? icon;
  final ProjectStatus status;

  /// Denormalize edilmiş sayaçlar (DATABASE.md §3.2) — bağlı görev listesini
  /// yeniden okumadan ilerleme yüzdesi hesaplamak için;
  /// `RecalculateProjectProgressUseCase` tarafından güncel tutulur.
  final int taskCount;
  final int completedTaskCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isArchived => status == ProjectStatus.archived;

  /// 0 görevli bir projede bölme hatası olmadan 0 döner (ROADMAP.md FAZ 6
  /// "Test Edilmesi Gereken Noktalar").
  double get progressRatio => taskCount == 0 ? 0 : completedTaskCount / taskCount;

  Project copyWith({
    String? title,
    String? description,
    bool clearDescription = false,
    String? color,
    String? icon,
    bool clearIcon = false,
    ProjectStatus? status,
    int? taskCount,
    int? completedTaskCount,
    DateTime? updatedAt,
  }) {
    return Project(
      projectId: projectId,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      color: color ?? this.color,
      icon: clearIcon ? null : (icon ?? this.icon),
      status: status ?? this.status,
      taskCount: taskCount ?? this.taskCount,
      completedTaskCount: completedTaskCount ?? this.completedTaskCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// DATABASE.md §3 — `status` enum.
enum ProjectStatus { active, archived }
