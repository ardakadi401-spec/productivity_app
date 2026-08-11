/// DATABASE.md Bölüm 5 — `users/{userId}/tasks/{taskId}/subtasks/{subtaskId}`
/// alt koleksiyonunun Domain katmanı saf temsili. Bilinçli olarak Task'a
/// gömülü bir array DEĞİL, ayrı bir varlık (§5.2 — bağımsız güncellenebilir
/// alt görevler için).
class SubTask {
  const SubTask({
    required this.subtaskId,
    required this.taskId,
    required this.title,
    required this.isCompleted,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  final String subtaskId;
  final String taskId;
  final String title;
  final bool isCompleted;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubTask copyWith({String? title, bool? isCompleted, int? order, DateTime? updatedAt}) {
    return SubTask(
      subtaskId: subtaskId,
      taskId: taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
