import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/sub_task.dart';
import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';
import '../states/task_form_state.dart';
import '../utils/sync_task_reminder_safely.dart';

/// Project Detail Screen'den "Görev Ekle" ile proje önceden seçili
/// (SCREENS.md §4.8), Calendar Screen'den "Bu Güne Görev Ekle" ile tarih
/// önceden seçili (SCREENS.md §4.13) gelinebilir — ikisi de `family`
/// argümanı olarak tek bir record'da taşınır (Riverpod family anahtarı,
/// record'ların yapısal eşitliğine güvenir).
typedef CreateTaskInitialArgs = ({String? projectId, DateTime? dueDate});

/// Create Task Screen (SCREENS.md §4.11). Alt görev taslakları, görev henüz
/// oluşturulmadan önce yalnızca bellekte tutulur; [save] başarılı olduktan
/// sonra gerçek `SubTask`'lara dönüştürülüp tek tek eklenir.
class CreateTaskController extends AutoDisposeFamilyNotifier<TaskFormState, CreateTaskInitialArgs> {
  @override
  TaskFormState build(CreateTaskInitialArgs arg) =>
      TaskFormState(projectId: arg.projectId, dueDate: arg.dueDate);

  void setPriority(TaskPriority priority) => state = state.copyWith(priority: priority);

  void setProjectId(String? projectId) {
    state = projectId == null
        ? state.copyWith(clearProjectId: true)
        : state.copyWith(projectId: projectId);
  }

  void setDueDate(DateTime? date) {
    state = date == null
        ? state.copyWith(clearDueDate: true, clearDueTime: true)
        : state.copyWith(dueDate: date);
  }

  void setDueTime(String? time) {
    state = time == null ? state.copyWith(clearDueTime: true) : state.copyWith(dueTime: time);
  }

  void addDraftSubTask(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(draftSubTasks: [...state.draftSubTasks, trimmed]);
  }

  void removeDraftSubTask(int index) {
    final updated = [...state.draftSubTasks]..removeAt(index);
    state = state.copyWith(draftSubTasks: updated);
  }

  /// Başlık boş-doğrulaması form widget'ında (SCREENS.md §4.11 "form
  /// gönderilmeden önce UI seviyesinde de engellenir") yapılır; buraya
  /// yalnızca geçerli veri ulaşır.
  Future<Result<Task>> save({required String title, String? description}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final repository = ref.read(taskRepositoryProvider);
    final now = DateTime.now();
    final task = Task(
      taskId: repository.newTaskId(),
      title: title.trim(),
      description: (description == null || description.trim().isEmpty) ? null : description.trim(),
      priority: state.priority,
      status: TaskStatus.pending,
      subtaskCount: 0,
      completedSubtaskCount: 0,
      dueDate: state.dueDate,
      dueTime: state.dueTime,
      projectId: state.projectId,
      createdAt: now,
      updatedAt: now,
    );

    final result = await ref.read(createTaskUseCaseProvider).call(task);
    switch (result) {
      case Ok(:final value):
        await _createDraftSubTasks(value.taskId);
        syncTaskReminderSafely(ref, value);
        state = state.copyWith(isSaving: false);
        return result;
      case Err(:final failure):
        state = state.copyWith(isSaving: false, error: failure);
        return result;
    }
  }

  Future<void> _createDraftSubTasks(String taskId) async {
    final repository = ref.read(taskRepositoryProvider);
    for (var i = 0; i < state.draftSubTasks.length; i++) {
      final now = DateTime.now();
      final subTask = SubTask(
        subtaskId: repository.newSubTaskId(taskId),
        taskId: taskId,
        title: state.draftSubTasks[i],
        isCompleted: false,
        order: i,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(addSubTaskUseCaseProvider).call(subTask);
    }
  }
}

final createTaskControllerProvider = NotifierProvider.autoDispose
    .family<CreateTaskController, TaskFormState, CreateTaskInitialArgs>(CreateTaskController.new);
