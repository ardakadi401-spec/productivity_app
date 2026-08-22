import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';
import '../states/task_form_state.dart';
import '../utils/sync_task_reminder_safely.dart';

/// Edit Task Screen (SCREENS.md §4.12) — Create Task ile birebir aynı alan
/// seti, mevcut değerlerle önceden doldurulmuş. `family` anahtarı olarak
/// düzenlenecek görevin son okunan anlık görüntüsü ([Task]) alınır; sayfa,
/// `taskDetailProvider` üzerinden veri geldikten sonra bu controller'ı
/// örnekler (STATE_MANAGEMENT.md §5.1 — ekran bazlı `autoDispose`).
class EditTaskController extends AutoDisposeFamilyNotifier<TaskFormState, Task> {
  @override
  TaskFormState build(Task arg) => TaskFormState.fromTask(arg);

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

  /// Başlık boş-doğrulaması form widget'ında yapılır (Create Task ile aynı
  /// kural, SCREENS.md §4.11/§4.12).
  Future<Result<Task>> save({required String title, String? description}) async {
    state = state.copyWith(isSaving: true, clearError: true);
    final trimmedDescription = description?.trim();
    final updated = arg.copyWith(
      title: title.trim(),
      description: trimmedDescription,
      clearDescription: trimmedDescription == null || trimmedDescription.isEmpty,
      priority: state.priority,
      dueDate: state.dueDate,
      clearDueDate: state.dueDate == null,
      dueTime: state.dueTime,
      clearDueTime: state.dueTime == null,
      projectId: state.projectId,
      clearProjectId: state.projectId == null,
      updatedAt: DateTime.now(),
    );

    final result = await ref.read(updateTaskUseCaseProvider).call(updated);
    switch (result) {
      case Ok(:final value):
        syncTaskReminderSafely(ref, value);
        state = state.copyWith(isSaving: false);
      case Err(:final failure):
        state = state.copyWith(isSaving: false, error: failure);
    }
    return result;
  }
}

final editTaskControllerProvider =
    NotifierProvider.autoDispose.family<EditTaskController, TaskFormState, Task>(
  EditTaskController.new,
);
