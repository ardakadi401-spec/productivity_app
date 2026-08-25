import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/sub_task.dart';
import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';
import '../utils/sync_task_reminder_safely.dart';

/// Task Detail Screen (SCREENS.md §4.10) — görev + alt görev listesini
/// Isar'ın reaktif stream'inden okur; alt görev eklendiğinde/tamamlandığında
/// üst görevin ilerleme yüzdesi Repository katmanında otomatik yeniden
/// hesaplanır (`TaskRepositoryImpl._recalculate`), bu controller yalnızca
/// eylemi tetikler.
class TaskDetailController extends AutoDisposeFamilyStreamNotifier<Task?, String> {
  @override
  Stream<Task?> build(String arg) {
    return ref.watch(watchTaskUseCaseProvider).call(arg);
  }

  Future<Result<void>> toggleCompleted({required bool isCompleted}) async {
    final result =
        await ref.read(completeTaskUseCaseProvider).call(arg, isCompleted: isCompleted);
    if (result case Ok(:final value)) syncTaskReminderSafely(ref, value);
    return _toVoid(result);
  }

  Future<Result<void>> deleteTask() async {
    final result = await ref.read(deleteTaskUseCaseProvider).call(arg);
    if (result case Ok()) cancelTaskReminderSafely(ref, arg);
    return result;
  }

  Future<Result<void>> addSubTask(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return const Ok(null);
    final repository = ref.read(taskRepositoryProvider);
    final now = DateTime.now();
    final subTask = SubTask(
      subtaskId: repository.newSubTaskId(arg),
      taskId: arg,
      title: trimmed,
      isCompleted: false,
      order: now.millisecondsSinceEpoch,
      createdAt: now,
      updatedAt: now,
    );
    final result = await ref.read(addSubTaskUseCaseProvider).call(subTask);
    return _toVoid(result);
  }

  Future<Result<void>> toggleSubTaskCompleted(String subtaskId, {required bool isCompleted}) {
    return ref.read(completeSubTaskUseCaseProvider).call(subtaskId, isCompleted: isCompleted);
  }

  Future<Result<void>> deleteSubTask(String subtaskId) {
    return ref.read(deleteSubTaskUseCaseProvider).call(subtaskId);
  }

  Result<void> _toVoid<T>(Result<T> result) => switch (result) {
        Ok() => const Ok(null),
        Err(:final failure) => Err(failure),
      };
}

final taskDetailControllerProvider =
    StreamNotifierProvider.autoDispose.family<TaskDetailController, Task?, String>(
  TaskDetailController.new,
);
