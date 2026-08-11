import '../../../../core/errors/failure.dart';
import '../../domain/entities/task.dart';

/// Create/Edit Task ekranlarının ortak form durumu — SCREENS.md §4.12
/// "Create Task Screen ile birebir aynı alan seti" gereği tek bir state
/// sınıfı iki controller tarafından paylaşılır (ARCHITECTURE.md §3.1 UI-state
/// / Entity ayrımı).
class TaskFormState {
  const TaskFormState({
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.dueTime,
    this.projectId,
    this.draftSubTasks = const [],
    this.isSaving = false,
    this.error,
  });

  final TaskPriority priority;
  final DateTime? dueDate;

  /// `HH:mm`.
  final String? dueTime;

  /// İlişkili proje (opsiyonel) — ROADMAP.md FAZ 6 "Task-Project ilişkisinin
  /// aktivasyonu". Yalnızca ID taşır; proje başlığı/rengi Create/Edit Task
  /// sayfası tarafından Projects'in kendi (dışa açık) provider'ından okunur.
  final String? projectId;

  /// Create Task ekranında görev henüz kaydedilmeden önceki alt görev
  /// taslakları (SCREENS.md §4.11) — Save sonrası gerçek `SubTask`'lara
  /// dönüştürülür.
  final List<String> draftSubTasks;
  final bool isSaving;
  final Failure? error;

  factory TaskFormState.fromTask(Task task) {
    return TaskFormState(
      priority: task.priority,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      projectId: task.projectId,
    );
  }

  TaskFormState copyWith({
    TaskPriority? priority,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? dueTime,
    bool clearDueTime = false,
    String? projectId,
    bool clearProjectId = false,
    List<String>? draftSubTasks,
    bool? isSaving,
    Failure? error,
    bool clearError = false,
  }) {
    return TaskFormState(
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      dueTime: clearDueTime ? null : (dueTime ?? this.dueTime),
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      draftSubTasks: draftSubTasks ?? this.draftSubTasks,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
